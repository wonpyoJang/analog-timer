import SwiftUI

private let bgColor    = Color(red: 0.055, green: 0.055, blue: 0.059)
private let mutedColor = Color(red: 0.420, green: 0.412, blue: 0.408)
private let swGreen    = Color(red: 0.180, green: 0.659, blue: 0.290)

struct TimerPiPView: View {
    @ObservedObject var data: TimerPiPData

    var body: some View {
        ZStack {
            bgColor.edgesIgnoringSafeArea(.all)
            HStack(spacing: 12) {
                if data.timerActive || data.timerDone {
                    timerSection
                }
                if (data.timerActive || data.timerDone) && data.swActive {
                    Divider().frame(height: 32).background(mutedColor)
                }
                if data.swActive {
                    swSection
                }
                if !data.timerActive && !data.timerDone && !data.swActive {
                    idleView
                }
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private var timerSection: some View {
        let color = data.ending
            ? Color(red: 0.878, green: 0.322, blue: 0.322)
            : data.accentColor
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Circle().fill(data.timerDone ? mutedColor : color)
                    .frame(width: 6, height: 6)
                if !data.timerLabel.isEmpty {
                    Text(data.timerLabel)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(color.opacity(0.8))
                        .lineLimit(1)
                }
                if data.timerDone {
                    Text("완료").font(.system(size: 9)).foregroundColor(mutedColor)
                } else if !data.timerRunning {
                    Text("일시정지").font(.system(size: 9)).foregroundColor(mutedColor)
                }
            }
            Text(data.timerDone ? "00:00" : data.timerRemain)
                .font(.system(size: 26, weight: .bold, design: .monospaced))
                .foregroundColor(data.timerDone ? mutedColor : color)
        }
    }

    @ViewBuilder
    private var swSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Circle().fill(swGreen).frame(width: 6, height: 6)
                Text("SW").font(.system(size: 9, weight: .medium))
                    .foregroundColor(swGreen.opacity(0.8))
                if !data.swRunning {
                    Text("일시정지").font(.system(size: 9)).foregroundColor(mutedColor)
                }
            }
            Text(data.swElapsed.isEmpty ? "00:00" : data.swElapsed)
                .font(.system(size: data.timerActive ? 18 : 26, weight: .bold, design: .monospaced))
                .foregroundColor(swGreen)
        }
    }

    private var idleView: some View {
        HStack(spacing: 6) {
            Image(systemName: "timer")
                .font(.system(size: 18))
                .foregroundColor(mutedColor)
            Text("⏱ Timer")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(mutedColor)
        }
    }
}
