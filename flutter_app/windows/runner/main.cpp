#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // 단일 인스턴스 보장 — 이미 실행 중이면 기존 창을 앞으로 가져오고 종료.
  // (desktop_multi_window 의 오버레이 서브윈도우는 같은 프로세스 내에서
  //  생성되므로 wWinMain 은 인스턴스당 1회만 실행되어 안전하다.)
  ::CreateMutexW(nullptr, FALSE, L"Local\\AnalogTimer_SingleInstance_Mutex");
  if (::GetLastError() == ERROR_ALREADY_EXISTS) {
    HWND existing = ::FindWindowW(L"FLUTTER_RUNNER_WIN32_WINDOW", L"Analog Timer");
    if (existing == nullptr) {
      existing = ::FindWindowW(L"FLUTTER_RUNNER_WIN32_WINDOW", L"analog_timer");
    }
    if (existing != nullptr) {
      if (::IsIconic(existing)) {
        ::ShowWindow(existing, SW_RESTORE);
      }
      ::SetForegroundWindow(existing);
    }
    return EXIT_SUCCESS;
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
  ::TerminateProcess(::GetCurrentProcess(), 0);

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
