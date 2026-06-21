import Foundation
import SwiftUI

class TimerPiPData: ObservableObject {
    static let shared = TimerPiPData()

    @Published var timerActive: Bool = false
    @Published var timerRunning: Bool = false
    @Published var timerDone: Bool = false
    @Published var timerLabel: String = ""
    @Published var timerRemain: String = "--:--"
    @Published var accentColor: Color = Color(red: 0.878, green: 0.478, blue: 0.322)
    @Published var timerFrac: Double = 0
    @Published var ending: Bool = false
    @Published var swActive: Bool = false
    @Published var swRunning: Bool = false
    @Published var swElapsed: String = ""

    private init() {}
}
