import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  /// 닫혀도 유지되는 메인 창 참조(MainFlutterWindow 가 등록) — Dock 재열기 복구용.
  static var mainWindow: NSWindow?

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  /// 위젯만 떠 있고 메인 창을 닫았을 때 Dock 아이콘 클릭으로 메인을 되살린다.
  /// 창이 화면 밖으로 밀렸거나(orderOut) 다른 창에 묻힌 경우 모두 앞으로 가져온다.
  override func applicationShouldHandleReopen(
    _ sender: NSApplication, hasVisibleWindows flag: Bool
  ) -> Bool {
    AppDelegate.mainWindow?.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
