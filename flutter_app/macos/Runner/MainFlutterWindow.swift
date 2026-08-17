import Cocoa
import FlutterMacOS
import desktop_multi_window

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // desktop_multi_window — 서브윈도우(오버레이/멀티 위젯 창)에도 플러그인 등록.
    // 이게 없으면 서브윈도우 엔진이 채널 통신을 못 해 창이 안 뜬다(macOS 필수).
    FlutterMultiWindowPlugin.setOnWindowCreatedCallback { controller in
      RegisterGeneratedPlugins(registry: controller)
    }

    // 위젯(오버레이 pill)만 떠 있고 메인 창을 X 로 닫으면, pill 이 앱을 살려둔
    // 채로 메인 창이 파괴돼 되살릴 수 없었다. 닫아도 창 객체를 유지(+AppDelegate
    // 전역 참조)해 Dock 재열기/트레이 '열기' 로 복구한다. pill 이 없으면
    // applicationShouldTerminateAfterLastWindowClosed 가 그대로 종료시킨다.
    self.isReleasedWhenClosed = false
    AppDelegate.mainWindow = self

    super.awakeFromNib()
  }
}
