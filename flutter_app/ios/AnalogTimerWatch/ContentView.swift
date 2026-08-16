import SwiftUI

private let accent = Color(red: 0.878, green: 0.478, blue: 0.322)
private let swGreen = Color(red: 0.180, green: 0.659, blue: 0.290)

struct ContentView: View {
    @ObservedObject var conn = WatchConnectivityManager.shared

    var body: some View {
        VStack(spacing: 6) {
            if conn.timerActive || conn.timerDone {
                if !conn.timerLabel.isEmpty {
                    Text(conn.timerLabel)
                        .font(.caption2).foregroundColor(accent).lineLimit(1)
                }
                timeText
                HStack(spacing: 10) {
                    Button(conn.timerRunning ? "⏸" : "▶") { conn.send(cmd: "timer_toggle") }
                    Button("⏭") { conn.send(cmd: "timer_next") }
                }
                .buttonStyle(.bordered)
            } else if conn.swActive {
                Text("스톱워치").font(.caption2).foregroundColor(swGreen)
                Text(conn.swElapsed.isEmpty ? "00:00" : conn.swElapsed)
                    .font(.system(size: 30, weight: .bold, design: .monospaced))
                    .foregroundColor(swGreen)
                Button(conn.swRunning ? "⏸" : "▶") { conn.send(cmd: "sw_toggle") }
                    .buttonStyle(.bordered)
            } else {
                Image(systemName: "timer").font(.title2).foregroundColor(.gray)
                Text("타이머 없음").font(.caption).foregroundColor(.gray)
                Button("타이머 시작") { conn.send(cmd: "timer_toggle") }
                    .buttonStyle(.bordered)
            }
        }
        .padding()
    }

    @ViewBuilder
    private var timeText: some View {
        if conn.timerRunning, conn.timerEndEpochMs > 0, #available(watchOS 9.0, *) {
            Text(timerInterval: Date()...Date(timeIntervalSince1970: conn.timerEndEpochMs / 1000),
                 countsDown: true)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(conn.timerDone ? .gray : accent)
                .monospacedDigit()
        } else {
            Text(conn.timerDone ? "완료" : conn.timerRemain)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(conn.timerDone ? .gray : accent)
        }
    }
}
