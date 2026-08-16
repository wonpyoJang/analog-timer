import Foundation
import SwiftUI
import WatchConnectivity

/// 워치 쪽 WCSession — 폰이 보낸 상태(applicationContext/message)를 받아 @Published 로
/// 노출하고, 버튼 명령(cmd)을 폰으로 되돌린다. Wear OS 미러와 동형 계약.
final class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    @Published var timerActive = false
    @Published var timerRunning = false
    @Published var timerDone = false
    @Published var timerLabel = ""
    @Published var timerRemain = "--:--"
    @Published var timerEndEpochMs: Double = 0
    @Published var swActive = false
    @Published var swRunning = false
    @Published var swElapsed = ""

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func send(cmd: String) {
        guard WCSession.default.activationState == .activated,
              WCSession.default.isReachable else { return }
        WCSession.default.sendMessage(["cmd": cmd], replyHandler: nil, errorHandler: nil)
    }

    private func apply(_ s: [String: Any]) {
        DispatchQueue.main.async {
            self.timerActive = s["timerActive"] as? Bool ?? false
            self.timerRunning = s["timerRunning"] as? Bool ?? false
            self.timerDone = s["timerDone"] as? Bool ?? false
            self.timerLabel = s["timerLabel"] as? String ?? ""
            self.timerRemain = s["timerRemain"] as? String ?? "--:--"
            self.timerEndEpochMs = s["timerEndEpochMs"] as? Double ?? 0
            self.swActive = s["swActive"] as? Bool ?? false
            self.swRunning = s["swRunning"] as? Bool ?? false
            self.swElapsed = s["swElapsed"] as? String ?? ""
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        apply(message)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        apply(applicationContext)
    }
}
