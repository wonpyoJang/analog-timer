import AVKit
import Flutter
import SwiftUI
import UIKit

class TimerPiPManager: NSObject {
    static let shared = TimerPiPManager()

    private var pipController: AVPictureInPictureController?
    private var sourceView: UIView?
    private var isStarted = false

    private override init() {}

    func setup(channel: FlutterMethodChannel) {
        channel.setMethodCallHandler { [weak self] call, result in
            switch call.method {
            case "start":
                self?.startPiP()
                result(nil)
            case "update":
                if let args = call.arguments as? [String: Any] {
                    self?.updateData(args)
                }
                result(nil)
            case "stop":
                self?.stopPiP()
                result(nil)
            case "isAvailable":
                if #available(iOS 15.0, *) {
                    result(AVPictureInPictureController.isPictureInPictureSupported())
                } else {
                    result(false)
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    func startPiP() {
        guard #available(iOS 15.0, *),
              AVPictureInPictureController.isPictureInPictureSupported(),
              !isStarted else { return }

        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return }

        // 애니메이션 시작 기준이 될 1×1 투명 뷰 (우상단 고정)
        let sv = UIView(frame: CGRect(x: rootVC.view.bounds.width - 2, y: 60, width: 1, height: 1))
        sv.backgroundColor = .clear
        rootVC.view.addSubview(sv)
        self.sourceView = sv

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[PiP] Audio session error: \(error)")
        }

        let pipVC = TimerPiPViewController()
        pipVC.preferredContentSize = CGSize(width: 240, height: 96)

        let contentSource = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: sv,
            contentViewController: pipVC
        )

        let pip = AVPictureInPictureController(contentSource: contentSource)
        pip.delegate = self
        pipController = pip
        isStarted = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            pip.startPictureInPicture()
        }
    }

    func stopPiP() {
        pipController?.stopPictureInPicture()
        pipController = nil
        sourceView?.removeFromSuperview()
        sourceView = nil
        isStarted = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func updateData(_ data: [String: Any]) {
        DispatchQueue.main.async {
            let d = TimerPiPData.shared
            d.timerActive  = data["timerActive"]  as? Bool   ?? false
            d.timerRunning = data["timerRunning"] as? Bool   ?? false
            d.timerDone    = data["timerDone"]    as? Bool   ?? false
            d.timerLabel   = data["timerLabel"]   as? String ?? ""
            d.timerRemain  = data["timerRemain"]  as? String ?? "--:--"
            d.ending       = data["ending"]       as? Bool   ?? false
            d.timerFrac    = data["timerFrac"]    as? Double ?? 0
            d.swActive     = data["swActive"]     as? Bool   ?? false
            d.swRunning    = data["swRunning"]    as? Bool   ?? false
            d.swElapsed    = data["swElapsed"]    as? String ?? ""

            if let r = data["timerColorR"] as? Double,
               let g = data["timerColorG"] as? Double,
               let b = data["timerColorB"] as? Double {
                d.accentColor = Color(red: r, green: g, blue: b)
            }
        }
    }
}

extension TimerPiPManager: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerDidStopPictureInPicture(_ controller: AVPictureInPictureController) {
        isStarted = false
        sourceView?.removeFromSuperview()
        sourceView = nil
    }

    func pictureInPictureController(
        _ controller: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        print("[PiP] Failed to start: \(error.localizedDescription)")
        isStarted = false
    }
}
