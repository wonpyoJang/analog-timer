#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <d3d11.h>

#include "flutter_window.h"
#include "utils.h"

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

DWORD WINAPI TdrWatchdog(LPVOID param) {
  HWND main_hwnd = static_cast<HWND>(param);
  ID3D11Device* device = nullptr;
  for (;;) {
    ::Sleep(5000);
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
      // 3분 이내 재감지 = 드라이버 반복 리셋 중 → 재시작 폭주 방지, 감시만 계속.
      if (TdrFlagFresh(flag, 180)) continue;
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
    for (int i = 0; i < 20; ++i) {
      HWND w = ::FindWindowW(L"FLUTTER_RUNNER_WIN32_WINDOW", L"Analog Timer");
      if (w == nullptr) {
        w = ::FindWindowW(L"FLUTTER_RUNNER_WIN32_WINDOW", L"analog_timer");
      }
      if (w != nullptr && ::IsWindowVisible(w)) {
        existing = w;
        break;
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
