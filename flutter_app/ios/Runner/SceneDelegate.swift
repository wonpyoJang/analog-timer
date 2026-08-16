import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

  // 콜드 스타트 — anytime:// 링크로 앱이 실행된 경우
  override func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
                      options connectionOptions: UIScene.ConnectionOptions) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    if let url = connectionOptions.urlContexts.first?.url {
      DeepLinkBridge.shared.deliver(url.absoluteString)
    }
  }

  // 웜 — 실행 중 anytime:// 수신(Shortcuts "Open URL" 등)
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    if let url = URLContexts.first?.url {
      DeepLinkBridge.shared.deliver(url.absoluteString)
    }
    super.scene(scene, openURLContexts: URLContexts)
  }

  // Siri App Intent(openAppWhenRun)로 포그라운드 복귀 시 대기 링크 흡수
  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    DeepLinkBridge.shared.drainDefaults()
  }
}
