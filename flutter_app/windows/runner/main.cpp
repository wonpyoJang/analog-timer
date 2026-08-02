#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <tlhelp32.h>
#include <d3d11.h>

#include "flutter_window.h"
#include "resource.h"
#include "utils.h"

// 파일 하단 정의 — TdrWatchdog(익명 네임스페이스)에서도 사용하는 전역 함수.
void WriteCleanExitMarker();

namespace {

// ── GPU TDR(드라이버 타임아웃 리셋) 워치독 ─────────────────────────────
//
// 검증된 사실(강제 TDR 실험): TDR 발생 시 이 Flutter 엔진 버전은 D3D 디바이스
// 로스트에서 복구하지 못한다 — 프로세스와 Dart 로직은 살아있지만 메인 창은
// 순백, 오버레이 위젯은 스타일까지 풀린 검은 창이 된다(리사이즈/최소화·복원으로도
// 재생 불가). IPC 는 멀쩡히 동작하므로 Dart 쪽 auto-recreate 도 감지하지 못한다.
//
// 대응: 초경량 D3D11 디바이스를 하나 들고 5초마다 GetDeviceRemovedReason() 을
// 폴링한다(비용 ~0). 디바이스 로스트가 감지되면 ① 텔레메트리용 TDR 마커를 남기고
// ② 자기 자신을 2초 뒤 재실행 예약한 뒤 ③ 검증된 종료 경로(WM_CLOSE)로 닫는다.
// 재시작하면 타이머는 savedAtMs 경과 보정으로 이어지고 위젯도 자동 복원된다.
//
// 폭주 방지: 직전 TDR 재시작이 3분 이내면(드라이버가 반복 리셋 중) 재시작하지
// 않는다 — 재시작 루프로 사용자를 괴롭히는 것보다 죽은 창이 낫다.
void MarkerPath(wchar_t* buf, const wchar_t* name) {
  buf[0] = L'\0';
  DWORD n = ::GetTempPathW(MAX_PATH, buf);
  if (n > 0 && n < MAX_PATH - 40) {
    ::lstrcatW(buf, name);
  } else {
    buf[0] = L'\0';
  }
}

bool TdrFlagFresh(const wchar_t* path, int seconds) {
  WIN32_FILE_ATTRIBUTE_DATA fad;
  if (!::GetFileAttributesExW(path, GetFileExInfoStandard, &fad)) return false;
  FILETIME now_ft;
  ::GetSystemTimeAsFileTime(&now_ft);
  ULARGE_INTEGER now_u{now_ft.dwLowDateTime, now_ft.dwHighDateTime};
  ULARGE_INTEGER mod_u{fad.ftLastWriteTime.dwLowDateTime,
                       fad.ftLastWriteTime.dwHighDateTime};
  return (now_u.QuadPart - mod_u.QuadPart) <
         static_cast<ULONGLONG>(seconds) * 10000000ULL;
}

// 우리 프로세스 소유의 러너 메인 창이 존재하는지 — janitor 판정용.
// 저장해둔 HWND 로 IsWindow 를 확인하는 방식은 창 파괴 후 다른 창이 같은 핸들
// 값을 재사용하면 영원히 TRUE 라 janitor 가 눈멀게 된다(실환경에서 확인됨).
// 클래스명으로 재탐색하고 소유 프로세스를 대조해 핸들 재사용에 면역으로 만든다.
bool MainWindowAlive() {
  DWORD self = ::GetCurrentProcessId();
  HWND w = nullptr;
  while ((w = ::FindWindowExW(nullptr, w, L"FLUTTER_RUNNER_WIN32_WINDOW",
                              nullptr)) != nullptr) {
    DWORD pid = 0;
    ::GetWindowThreadProcessId(w, &pid);
    if (pid == self) return true;
  }
  return false;
}

// Dart heartbeat 파일(%APPDATA%\dev.analogtimer\analog_timer\
// analog_timer_heartbeat.json)의 마지막 수정 이후 경과(초). 실패 시 -1.
// Dart 쪽이 10초 주기로 갱신하므로, 한참 정체 = Dart 이벤트 루프 프리즈.
int HeartbeatAgeSeconds() {
  wchar_t path[MAX_PATH];
  DWORD n = ::GetEnvironmentVariableW(L"APPDATA", path, MAX_PATH);
  if (n == 0 || n >= MAX_PATH - 60) return -1;
  ::lstrcatW(path, L"\\dev.analogtimer\\analog_timer\\analog_timer_heartbeat.json");
  WIN32_FILE_ATTRIBUTE_DATA fad;
  if (!::GetFileAttributesExW(path, GetFileExInfoStandard, &fad)) return -1;
  FILETIME now_ft;
  ::GetSystemTimeAsFileTime(&now_ft);
  ULARGE_INTEGER now_u{now_ft.dwLowDateTime, now_ft.dwHighDateTime};
  ULARGE_INTEGER mod_u{fad.ftLastWriteTime.dwLowDateTime,
                       fad.ftLastWriteTime.dwHighDateTime};
  if (mod_u.QuadPart > now_u.QuadPart) return 0;
  return static_cast<int>((now_u.QuadPart - mod_u.QuadPart) / 10000000ULL);
}

// 멈춤 고지 팝업 — powershell WScript Popup(20초 자동 타임아웃, system-modal).
// 렌더가 죽어도 OS 가 그리므로 항상 보인다. 한글 메시지는 소스 인코딩 이슈를
// 피하려고 UTF-16LE base64(-EncodedCommand)로 임베드했다.
// 반환: 1=확인, 2=취소, 그 외(-1 등)=타임아웃/실패.
int ShowFreezeCountdownPopup() {
  // "타이머가 응답하지 않습니다. 확인을 누르거나 20초가 지나면 자동으로 다시
  //  시작합니다. (기록과 경과 시간은 유지됩니다)" / 제목 "Analog Timer - 멈춤 감지"
  static const wchar_t kCmd[] =
      L"powershell -NoProfile -WindowStyle Hidden -EncodedCommand "
      L"ZQB4AGkAdAAgACgATgBlAHcALQBPAGIAagBlAGMAdAAgAC0AQwBvAG0ATwBiAGoAZQBjAHQA"
      L"IABXAFMAYwByAGkAcAB0AC4AUwBoAGUAbABsACkALgBQAG8AcAB1AHAAKAAnAMDQdMc4ugCs"
      L"IABRx/WyWNXAySAASsW1wsiy5LIuACAAVdZ4x0THIAAEsnS5cKyYsCAAMgAwAAjNAKwgAMDJ"
      L"mLB0uiAAkMfZszzHXLggAOSy3MIgANzCkcdp1ciy5LIuACAAKAAwrl24/KwgAL2s/KwgANzC"
      L"BKxAxyAAIMfAySm0yLLksikAJwAsACAAMgAwACwAIAAnAEEAbgBhAGwAbwBnACAAVABpAG0A"
      L"ZQByACAALQAgAEi6pM0gABCswMknACwAIAA0ADAAOQA3ACkA";
  wchar_t cmd[1024];
  ::lstrcpyW(cmd, kCmd);
  STARTUPINFOW si{};
  si.cb = sizeof(si);
  PROCESS_INFORMATION pi{};
  if (!::CreateProcessW(nullptr, cmd, nullptr, nullptr, FALSE,
                        CREATE_NO_WINDOW, nullptr, nullptr, &si, &pi)) {
    return -1;
  }
  DWORD code = static_cast<DWORD>(-1);
  if (::WaitForSingleObject(pi.hProcess, 35000) == WAIT_OBJECT_0) {
    ::GetExitCodeProcess(pi.hProcess, &code);
  } else {
    ::TerminateProcess(pi.hProcess, 0);
  }
  ::CloseHandle(pi.hProcess);
  ::CloseHandle(pi.hThread);
  return static_cast<int>(code);
}

// 복구 마커(JSON) 기록 — 다음 실행의 Dart TelemetryService 가 읽어
// type:'recovery' 리포트로 전송한다(원인·디버깅 정보 동봉). ASCII 전용.
void WriteRecoveryMarkerJson(const wchar_t* filename, const char* json) {
  wchar_t path[MAX_PATH];
  MarkerPath(path, filename);
  if (path[0] == L'\0') return;
  HANDLE h = ::CreateFileW(path, GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS,
                           FILE_ATTRIBUTE_NORMAL, nullptr);
  if (h == INVALID_HANDLE_VALUE) return;
  DWORD written = 0;
  ::WriteFile(h, json, static_cast<DWORD>(::lstrlenA(json)), &written, nullptr);
  ::CloseHandle(h);
}

// clean 마커 기록 후 자기 자신을 지연 재기동하고 즉시 종료.
// (TDR 자가재시작과 동일 패턴 — teardown 을 건너뛰어 레이스 없이 끝낸다)
void RelaunchSelfAndDie() {
  wchar_t exe[MAX_PATH];
  if (::GetModuleFileNameW(nullptr, exe, MAX_PATH) == 0) return;
  wchar_t cmd[MAX_PATH + 64];
  ::wsprintfW(cmd, L"cmd /c ping -n 4 127.0.0.1 >nul & start \"\" \"%s\"", exe);
  STARTUPINFOW si{};
  si.cb = sizeof(si);
  PROCESS_INFORMATION pi{};
  if (::CreateProcessW(nullptr, cmd, nullptr, nullptr, FALSE,
                       CREATE_NO_WINDOW, nullptr, nullptr, &si, &pi)) {
    ::CloseHandle(pi.hProcess);
    ::CloseHandle(pi.hThread);
    WriteCleanExitMarker();  // 파일 상단 전역 선언 사용 (익명 NS 내 extern 금지)
    ::TerminateProcess(::GetCurrentProcess(), 0);
  }
}

DWORD WINAPI TdrWatchdog(LPVOID param) {
  HWND main_hwnd = static_cast<HWND>(param);
  ID3D11Device* device = nullptr;
  int tick = 0;
  // 진단 스위치: TDR 자가재시작 비활성(janitor 는 유지). 강제 TDR 실험에서
  // "엔진이 스스로 device-lost 를 복구하는지"를 워치독 개입 없이 관찰할 때 쓴다.
  //   set ANALOG_TIMER_NO_TDR_RESTART=1
  const bool no_tdr_restart =
      ::GetEnvironmentVariableW(L"ANALOG_TIMER_NO_TDR_RESTART", nullptr, 0) > 0;
  for (;;) {
    ::Sleep(1000);
    // ── 고아 위젯 좀비 janitor ──
    // 메인 창이 파괴됐는데 메시지 루프가 안 끝나는 사례(위젯 서브윈도우가 루프를
    // 붙잡음 — WM_DESTROY 가 플러그인 체인에 삼켜져 PostQuitMessage 미도달)에서
    // '창 없는 프로세스 + 남은 위젯'이 생긴다. 어느 경로로 죽었든 메인 창이
    // 사라졌으면 1초 내에 확실히 종료한다. 정상 X 닫기는 사용자의 의도적 종료
    // 이므로 clean 마커를 남긴다(루프 정상 종료 경로와 동일 의미).
    if (!MainWindowAlive()) {
      // 발동 원인 기록: 프로세스 uptime(초) — 좀비 발생 빈도/시점 추적용.
      char jbuf[128];
      ::wsprintfA(jbuf, "{\"kind\":\"janitor_close\",\"uptimeSec\":%d}", tick);
      WriteRecoveryMarkerJson(L"analog_timer_janitor.json", jbuf);
      WriteCleanExitMarker();
      ::TerminateProcess(::GetCurrentProcess(), 0);
    }
    if (++tick % 5 != 0) continue;  // 무거운 체크(D3D/heartbeat)는 5초 주기

    // ── Dart 프리즈 감지 (heartbeat 정체) ──
    // Dart 가 10초 주기로 갱신하는 heartbeat 파일이 60초+ 정체 = Dart 이벤트
    // 루프가 얼어붙음(렌더만이 아니라 통째로). 팝업(20초 카운트다운) 고지 후
    // 자동 재시작한다 — 타이머는 savedAtMs 벽시계 보정으로 이어진다.
    //
    // 절전/최대절전 복귀 오탐 방어: 잠들어 있던 동안엔 tick 루프도 멈추므로
    // GetTickCount64 간격이 크게 점프한다. 점프 감지 후 90초는 판정 유예
    // (Dart 가 깨어나 heartbeat 를 다시 쓸 시간).
    {
      static ULONGLONG last_check_ms = ::GetTickCount64();
      static ULONGLONG grace_until_ms = 0;
      static ULONGLONG snooze_until_ms = 0;
      // 이 세션에서 heartbeat 가 fresh 한 것을 본 적 있어야만 정체를 신뢰한다.
      // 파일이 아예 없거나 영구적으로 못 쓰는 환경(권한 등)에서 "정체" 오판
      // → 무한 재시작 루프가 되는 것을 차단.
      static bool seen_fresh = false;
      ULONGLONG now_ms = ::GetTickCount64();
      if (now_ms - last_check_ms > 30000) {  // 5초 주기가 30초+ 점프 = 절전 복귀
        grace_until_ms = now_ms + 90000;
      }
      last_check_ms = now_ms;
      if (now_ms >= grace_until_ms && now_ms >= snooze_until_ms) {
        int age = HeartbeatAgeSeconds();
        if (age >= 0 && age < 30) seen_fresh = true;
        if (seen_fresh && age >= 60) {
          int r = ShowFreezeCountdownPopup();
          if (r == 2) {
            snooze_until_ms = now_ms + 10 * 60 * 1000;  // 취소 → 10분 보류
            char jbuf[160];
            ::wsprintfA(jbuf,
                        "{\"kind\":\"freeze_restart_declined\","
                        "\"hbAgeSec\":%d,\"uptimeSec\":%d}",
                        age, tick);
            WriteRecoveryMarkerJson(L"analog_timer_freeze_restart.json", jbuf);
          } else {
            // 발동 원인 기록: heartbeat 나이·팝업 응답(1=확인/-1=타임아웃)·uptime.
            char jbuf[160];
            ::wsprintfA(jbuf,
                        "{\"kind\":\"freeze_restart\",\"hbAgeSec\":%d,"
                        "\"popup\":%d,\"uptimeSec\":%d}",
                        age, r, tick);
            WriteRecoveryMarkerJson(L"analog_timer_freeze_restart.json", jbuf);
            RelaunchSelfAndDie();  // 확인/타임아웃 → 재시작 (미반환)
            snooze_until_ms = now_ms + 60 * 1000;  // 재기동 실패 시 1분 후 재시도
          }
        }
      }
    }

    if (no_tdr_restart) continue;   // 진단 모드: TDR 감지·자가재시작 생략
    if (device == nullptr) {
      HRESULT hr = ::D3D11CreateDevice(
          nullptr, D3D_DRIVER_TYPE_HARDWARE, nullptr, 0, nullptr, 0,
          D3D11_SDK_VERSION, &device, nullptr, nullptr);
      if (FAILED(hr)) {
        device = nullptr;
        continue;  // 드라이버 회복 대기 후 재시도
      }
    }
    if (device->GetDeviceRemovedReason() == S_OK) continue;

    // ── TDR 감지 ──
    device->Release();
    device = nullptr;

    wchar_t flag[MAX_PATH];
    MarkerPath(flag, L"analog_timer_tdr.flag");
    if (flag[0] != L'\0') {
      // 60초 이내 재감지 = 드라이버 반복 리셋 중 → 재시작 폭주 방지, 감시만 계속.
      // (원래 180초 — 반복 TDR 시 사용자가 최대 3분간 멈춘 시계를 보다 강제종료하는
      //  패턴이 텔레메트리로 확인돼 60초로 단축. 폭주 상한은 분당 1회 재시작.)
      if (TdrFlagFresh(flag, 60)) continue;
      HANDLE h = ::CreateFileW(flag, GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS,
                               FILE_ATTRIBUTE_NORMAL, nullptr);
      if (h != INVALID_HANDLE_VALUE) ::CloseHandle(h);
    }

    // ~5초 뒤 자기 자신 재실행. 너무 빨리 뜨면 드라이버/DWM 가 아직 회복 중이라
    // 위젯 서브엔진 생성이 실패하는 것이 확인됨 — 여유를 둔다.
    // (그 사이 현 프로세스는 종료되어 mutex 도 해제됨)
    wchar_t exe[MAX_PATH];
    ::GetModuleFileNameW(nullptr, exe, MAX_PATH);
    wchar_t cmd[MAX_PATH * 2];
    ::swprintf(cmd, MAX_PATH * 2,
               L"cmd /c ping -n 6 127.0.0.1 >nul & start \"\" \"%s\"", exe);
    STARTUPINFOW si{};
    si.cb = sizeof(si);
    si.dwFlags = STARTF_USESHOWWINDOW;
    si.wShowWindow = SW_HIDE;
    PROCESS_INFORMATION pi{};
    if (::CreateProcessW(nullptr, cmd, nullptr, nullptr, FALSE,
                         CREATE_NO_WINDOW, nullptr, nullptr, &si, &pi)) {
      ::CloseHandle(pi.hProcess);
      ::CloseHandle(pi.hThread);
    }

    // 즉시 자기 종료. WM_CLOSE 경로는 위젯 서브윈도우가 떠 있을 때 메시지 루프가
    // 끝나지 않아 '고아 위젯 좀비'를 남기는 것이 확인됨(강제 TDR 실험) — 그래서
    // clean 마커를 직접 남기고 TerminateProcess 로 확실하게 끝낸다. 상태는 30초
    // 주기 + 변경 시 저장이 보장하고, 타이머는 savedAtMs 경과 보정으로 이어진다.
    (void)main_hwnd;
    wchar_t clean[MAX_PATH];
    MarkerPath(clean, L"analog_timer_clean.flag");
    if (clean[0] != L'\0') {
      HANDLE h = ::CreateFileW(clean, GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS,
                               FILE_ATTRIBUTE_NORMAL, nullptr);
      if (h != INVALID_HANDLE_VALUE) ::CloseHandle(h);
    }
    ::TerminateProcess(::GetCurrentProcess(), 0);
    return 0;
  }
}

}  // namespace

// clean-exit 마커 기록 — 정상 종료 경로들(메시지 루프 종료 / TDR 자가재시작 /
// 시스템 종료 WM_ENDSESSION)이 공용으로 사용. win32_window.cpp 에서 extern 참조.
void WriteCleanExitMarker() {
  wchar_t clean[MAX_PATH];
  MarkerPath(clean, L"analog_timer_clean.flag");
  if (clean[0] != L'\0') {
    HANDLE h = ::CreateFileW(clean, GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS,
                             FILE_ATTRIBUTE_NORMAL, nullptr);
    if (h != INVALID_HANDLE_VALUE) ::CloseHandle(h);
  }
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // 단일 인스턴스 — 이미 실행 중이면 기존 창을 앞으로 가져오고 종료한다.
  // (오버레이 서브윈도우는 같은 프로세스 내에서 생성되므로 wWinMain 은 인스턴스당
  //  1회만 실행되어 안전하다.)
  //
  // 단, 좀비/숨겨진 인스턴스가 mutex 만 잡고 '보이는 창'이 없을 때 새 실행이 조용히
  // 종료되어 "아무리 클릭해도 안 켜짐" 으로 보이던 문제를 막는다 → 보이는 기존 창을
  // 최대 ~2초 재시도해 찾고(시작 중인 인스턴스 대기 겸용), 그래도 없으면 그냥 정상
  // 실행으로 진행한다.
  ::CreateMutexW(nullptr, FALSE, L"Local\\AnalogTimer_SingleInstance_Mutex");
  if (::GetLastError() == ERROR_ALREADY_EXISTS) {
    HWND existing = nullptr;
    // 콜드 스타트(AV 스캔/저사양)에서 첫 창 표시가 2초를 넘겨 이중 인스턴스로
    // 폴스루하던 문제 — 창이 안 보여도 우리 exe 프로세스가 더 있으면 15초까지
    // 대기를 연장한다(진짜 좀비면 프로세스가 있어도 끝내 창이 안 떠 폴스루 유지).
    for (int i = 0; i < 150; ++i) {
      HWND w = ::FindWindowW(L"FLUTTER_RUNNER_WIN32_WINDOW", L"Analog Timer");
      if (w == nullptr) {
        w = ::FindWindowW(L"FLUTTER_RUNNER_WIN32_WINDOW", L"analog_timer");
      }
      if (w != nullptr && ::IsWindowVisible(w)) {
        existing = w;
        break;
      }
      if (i >= 19) {
        // 2초 경과 후엔 다른 인스턴스 프로세스 생존 여부로 계속 기다릴지 판단.
        bool other_alive = false;
        HANDLE snap = ::CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
        if (snap != INVALID_HANDLE_VALUE) {
          PROCESSENTRY32W pe{};
          pe.dwSize = sizeof(pe);
          DWORD self = ::GetCurrentProcessId();
          if (::Process32FirstW(snap, &pe)) {
            do {
              if (pe.th32ProcessID != self &&
                  ::_wcsicmp(pe.szExeFile, L"analog_timer.exe") == 0) {
                other_alive = true;
                break;
              }
            } while (::Process32NextW(snap, &pe));
          }
          ::CloseHandle(snap);
        }
        if (!other_alive) break; // 좀비도 없음 — 즉시 정상 실행 폴스루
      }
      ::Sleep(100);
    }
    if (existing != nullptr) {
      if (::IsIconic(existing)) {
        ::ShowWindow(existing, SW_RESTORE);
      }
      ::SetForegroundWindow(existing);
      return EXIT_SUCCESS;
    }
    // 보이는 기존 창을 못 찾음(좀비/숨김) → 정상 실행으로 진행(fall through).
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"analog_timer", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  // 창 아이콘 명시 지정 — 작업표시줄/Alt+Tab 이 기본 문서 아이콘으로 뜨던 문제.
  // 클래스 hIcon(LoadIcon)은 크기 지정이 안 돼 셸이 원하는 치수를 못 얻는
  // 경우가 있다. LoadImage 로 SM_CXICON/SM_CXSMICON 에 맞춰 각각 로드해
  // WM_SETICON 으로 창에 직접 박는다(ICO 에 16~256px 다중 크기 포함 필요).
  if (HWND hwnd = window.GetHandle()) {
    HICON icon_big = static_cast<HICON>(::LoadImageW(
        instance, MAKEINTRESOURCEW(IDI_APP_ICON), IMAGE_ICON,
        ::GetSystemMetrics(SM_CXICON), ::GetSystemMetrics(SM_CYICON),
        LR_DEFAULTCOLOR));
    HICON icon_small = static_cast<HICON>(::LoadImageW(
        instance, MAKEINTRESOURCEW(IDI_APP_ICON), IMAGE_ICON,
        ::GetSystemMetrics(SM_CXSMICON), ::GetSystemMetrics(SM_CYSMICON),
        LR_DEFAULTCOLOR));
    if (icon_big) {
      ::SendMessageW(hwnd, WM_SETICON, ICON_BIG,
                     reinterpret_cast<LPARAM>(icon_big));
    }
    if (icon_small) {
      ::SendMessageW(hwnd, WM_SETICON, ICON_SMALL,
                     reinterpret_cast<LPARAM>(icon_small));
    }
  }

  // TDR 워치독 시작 — GPU 드라이버 리셋 감지 시 자가 재시작(위 주석 참조).
  ::CreateThread(nullptr, 0, TdrWatchdog, window.GetHandle(), 0, nullptr);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  // 창이 닫혀(WM_CLOSE→WM_DESTROY→PostQuitMessage) 메시지 루프가 끝나면,
  // Flutter 엔진/오버레이 서브엔진과 실행 중인 타이머·스트림의 destructor
  // teardown 이 레이스를 일으켜 0xC0000005(액세스 위반) 크래시 + '창 없는
  // 좀비 프로세스'가 남는 사례가 있었다. 정리 코드를 건너뛰고 프로세스를
  // 즉시 강제 종료해 X 한 번에 확실히·깨끗이 닫히도록 한다.
  //
  // 메시지 루프가 정상적으로 끝났다 = 사용자가 X 로 '정상 종료'했다는 뜻이므로,
  // 텔레메트리용 clean-exit 마커를 남긴다. 이 마커가 없으면 다음 실행이 직전
  // 세션을 '비정상 종료(네이티브 크래시)'로 간주해 리포트한다.
  // (경로는 Dart TelemetryService 의 Directory.systemTemp 와 일치)
  {
    wchar_t marker[MAX_PATH];
    DWORD n = ::GetTempPathW(MAX_PATH, marker);
    if (n > 0 && n < MAX_PATH - 30) {
      ::lstrcatW(marker, L"analog_timer_clean.flag");
      HANDLE h = ::CreateFileW(marker, GENERIC_WRITE, 0, nullptr,
                               CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
      if (h != INVALID_HANDLE_VALUE) ::CloseHandle(h);
    }
  }
  ::TerminateProcess(::GetCurrentProcess(), 0);

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
