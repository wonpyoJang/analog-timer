import Flutter
import UIKit
import AppIntents

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // scene-based lifecycle에서 window 프로퍼티는 nil — 다음 run loop에서 scene window가 준비됨
    DispatchQueue.main.async {
      if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
         let controller = scene.windows.first?.rootViewController as? FlutterViewController {
        let channel = FlutterMethodChannel(name: "analog_timer/pip", binaryMessenger: controller.binaryMessenger)
        TimerPiPManager.shared.setup(channel: channel)
        // anytime:// 딥링크 브리지 — URL 스킴/Siri App Intent 가 같은 채널로 넘긴다.
        DeepLinkBridge.shared.attach(messenger: controller.binaryMessenger)
      }
    }

    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

/// anytime:// 딥링크를 Flutter(`dev.analogtimer/deeplink` 채널, Android와 공유)로
/// 전달하는 브리지. URL 스킴 오픈·Siri App Intent 양쪽 입구가 이 한 곳으로 모인다.
final class DeepLinkBridge {
  static let shared = DeepLinkBridge()
  private init() {}

  private var channel: FlutterMethodChannel?
  private var pending: String?  // 채널 준비 전(콜드) 수신분 흡수
  private static let defaultsKey = "pending_deeplink"

  func attach(messenger: FlutterBinaryMessenger) {
    let ch = FlutterMethodChannel(name: "dev.analogtimer/deeplink", binaryMessenger: messenger)
    ch.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "getInitialLink":
        result(self?.consumePending())
      case "openRoutines":
        result(false)  // iOS 는 삼성 "모드와 루틴" 앱 없음
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    channel = ch
  }

  /// 외부(URL 스킴/Intent)에서 링크 수신 → 웜이면 즉시 전달, 아니면 대기 저장.
  func deliver(_ link: String) {
    guard !link.isEmpty else { return }
    if let ch = channel {
      ch.invokeMethod("link", arguments: link)
    } else {
      pending = link
    }
  }

  /// App Intent 가 UserDefaults 에 남긴 대기 링크를 흡수(웜 포그라운드 복귀 시 호출).
  func drainDefaults() {
    let d = UserDefaults.standard
    guard let s = d.string(forKey: Self.defaultsKey), !s.isEmpty else { return }
    d.removeObject(forKey: Self.defaultsKey)
    deliver(s)
  }

  private func consumePending() -> String? {
    drainDefaults()
    let p = pending
    pending = nil
    return p
  }

  /// App Intent 는 앱과 다른 실행 맥락일 수 있어 UserDefaults 로 링크를 넘긴다.
  static func stash(_ link: String) {
    UserDefaults.standard.set(link, forKey: defaultsKey)
  }
}

/// Siri/단축어 "타이머 시작" — Android App Actions(CREATE_TIMER)의 iOS 대응.
/// anytime://start 딥링크로 변환해 앱의 공통 딥링크 경로로 흘려보낸다.
@available(iOS 16.0, *)
struct StartTimerIntent: AppIntent {
  static var title: LocalizedStringResource = "타이머 시작"
  static var description = IntentDescription("지정한 시간으로 아날로그 타이머를 시작합니다.")
  static var openAppWhenRun: Bool = true

  @Parameter(title: "분", default: 5)
  var minutes: Int

  @Parameter(title: "이름")
  var label: String?

  func perform() async throws -> some IntentResult {
    var comps = URLComponents()
    comps.scheme = "anytime"
    comps.host = "start"
    var items = [URLQueryItem(name: "min", value: String(max(0, minutes)))]
    if let l = label, !l.isEmpty { items.append(URLQueryItem(name: "label", value: l)) }
    comps.queryItems = items
    DeepLinkBridge.stash(comps.url?.absoluteString ?? "anytime://start?min=\(max(0, minutes))")
    return .result()
  }
}

@available(iOS 16.0, *)
struct AnalogTimerShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: StartTimerIntent(),
      phrases: [
        "\(.applicationName)로 타이머 시작",
        "\(.applicationName) 타이머 시작",
        "Start a timer in \(.applicationName)"
      ],
      shortTitle: "타이머 시작",
      systemImageName: "timer"
    )
  }
}
