import Foundation
import SwiftUI
import WatchConnectivity

/// 워치 쪽 WCSession — 폰이 보낸 상태(applicationContext/message)를 받아 @Published 로
/// 노출하고, 버튼 명령(cmd)을 폰으로 되돌린다. Wear OS 미러와 동형 계약.
/// 델리게이트 메서드는 nonisolated 로 명시 — Xcode16 기본 MainActor 격리에서도
/// WCSessionDelegate(nonisolated 요구) 준수가 되도록.
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

    @MainActor
    private func apply(_ s: [String: Any]) {
        timerActive = s["timerActive"] as? Bool ?? false
        timerRunning = s["timerRunning"] as? Bool ?? false
        timerDone = s["timerDone"] as? Bool ?? false
        timerLabel = s["timerLabel"] as? String ?? ""
        timerRemain = s["timerRemain"] as? String ?? "--:--"
        timerEndEpochMs = s["timerEndEpochMs"] as? Double ?? 0
        swActive = s["swActive"] as? Bool ?? false
        swRunning = s["swRunning"] as? Bool ?? false
        swElapsed = s["swElapsed"] as? String ?? ""
    }

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in self.apply(message) }
    }

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in self.apply(applicationContext) }
    }
}
