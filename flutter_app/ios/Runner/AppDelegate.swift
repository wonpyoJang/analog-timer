import Flutter
import UIKit

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
      }
    }

    return result
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
