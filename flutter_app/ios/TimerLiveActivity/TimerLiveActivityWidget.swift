import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - 색상

private let bgColor    = Color(red: 0.055, green: 0.055, blue: 0.059)
private let mutedColor = Color(red: 0.420, green: 0.412, blue: 0.408)
private let swGreen    = Color(red: 0.180, green: 0.659, blue: 0.290)

private let sharedDefault = UserDefaults(suiteName: "group.dev.analogtimer.analogTimer")!

// MARK: - UserDefaults 헬퍼

private func str(_ key: String) -> String { sharedDefault.string(forKey: key) ?? "" }
private func bool(_ key: String) -> Bool  { sharedDefault.bool(forKey: key) }
private func dbl(_ key: String) -> Double { sharedDefault.double(forKey: key) }

private func timerColor(_ attrs: LiveActivitiesAppAttributes) -> Color {
    let r = dbl(attrs.prefixedKey("timerColorR"))
    let g = dbl(attrs.prefixedKey("timerColorG"))
    let b = dbl(attrs.prefixedKey("timerColorB"))
    // 모두 0이면 아직 저장 전 — 기본 오렌지
    if r == 0 && g == 0 && b == 0 { return Color(red: 0.878, green: 0.478, blue: 0.322) }
    return Color(red: r, green: g, blue: b)
}

// timerEndEpochMs(ms) → countdown Text용 Date
private func endDate(_ attrs: LiveActivitiesAppAttributes) -> Date? {
    let ms = dbl(attrs.prefixedKey("timerEndEpochMs"))
    guard ms > 0 else { return nil }
    return Date(timeIntervalSince1970: ms / 1000)
}

// swStartEpochMs(ms) → stopwatch Text용 Date
private func swStartDate(_ attrs: LiveActivitiesAppAttributes) -> Date? {
    let ms = dbl(attrs.prefixedKey("swStartEpochMs"))
    guard ms > 0 else { return nil }
    return Date(timeIntervalSince1970: ms / 1000)
}

// MARK: - 상태 도트 (실행/일시정지 표시)

private struct StateDot: View {
    let running: Bool
    let color: Color

    var body: some View {
        ZStack {
            Circle().fill(color).frame(width: 7, height: 7)
            if running {
                Circle()
                    .fill(color.opacity(0.35))
                    .frame(width: 13, height: 13)
            }
        }
    }
}

// MARK: - 타이머 섹션

private struct TimerSection: View {
    let attrs: LiveActivitiesAppAttributes

    var body: some View {
        let active  = bool(attrs.prefixedKey("timerActive"))
        let running = bool(attrs.prefixedKey("timerRunning"))
        let done    = bool(attrs.prefixedKey("timerDone"))
        let ending  = bool(attrs.prefixedKey("ending"))
        let label   = str(attrs.prefixedKey("timerLabel"))
        let remain  = str(attrs.prefixedKey("timerRemain"))
        let frac    = dbl(attrs.prefixedKey("timerFrac"))
        let tColor  = ending ? Color(red: 0.878, green: 0.322, blue: 0.322) : timerColor(attrs)
        let end     = endDate(attrs)

        if !active && !done { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    StateDot(running: running && !done, color: done ? mutedColor : tColor)
                    if !label.isEmpty {
                        Text(label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(tColor.opacity(0.8))
                            .lineLimit(1)
                    }
                    if done {
                        Text("완료")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(mutedColor)
                    } else if !running {
                        Text("일시정지")
                            .font(.system(size: 10))
                            .foregroundColor(mutedColor)
                    }
                }
                // 실행 중이고 endDate가 있으면 시스템 자동 카운트다운 사용
                if running, let end = end {
                    Text(timerInterval: Date()...end, countsDown: true)
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(tColor)
                        .monospacedDigit()
                } else {
                    Text(done ? "00:00" : remain)
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(done ? mutedColor : tColor)
                }
                // 진행률 바
                if !done && frac > 0 {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(tColor.opacity(0.2)).frame(height: 3)
                            Capsule()
                                .fill(tColor)
                                .frame(width: geo.size.width * frac, height: 3)
                        }
                    }
                    .frame(height: 3)
                }
            }
        )
    }
}

// MARK: - 스톱워치 섹션

private struct StopwatchSection: View {
    let attrs: LiveActivitiesAppAttributes

    var body: some View {
        let active  = bool(attrs.prefixedKey("swActive"))
        let running = bool(attrs.prefixedKey("swRunning"))
        let elapsed = str(attrs.prefixedKey("swElapsed"))
        let start   = swStartDate(attrs)

        if !active { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    StateDot(running: running, color: swGreen)
                    Text("스톱워치")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(swGreen.opacity(0.8))
                    if !running {
                        Text("일시정지")
                            .font(.system(size: 10))
                            .foregroundColor(mutedColor)
                    }
                }
                if running, let start = start {
                    Text(timerInterval: start...Date.distantFuture, countsDown: false)
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(swGreen)
                        .monospacedDigit()
                } else {
                    Text(elapsed.isEmpty ? "00:00" : elapsed)
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(swGreen)
                }
            }
        )
    }
}

// MARK: - Lock Screen / Notification Banner

struct TimerLockScreenView: View {
    let attrs: LiveActivitiesAppAttributes

    var body: some View {
        let timerActive = bool(attrs.prefixedKey("timerActive"))
        let timerDone   = bool(attrs.prefixedKey("timerDone"))
        let swActive    = bool(attrs.prefixedKey("swActive"))

        HStack(spacing: 16) {
            if timerActive || timerDone {
                TimerSection(attrs: attrs)
            }
            if (timerActive || timerDone) && swActive {
                Divider().frame(height: 36).background(mutedColor)
            }
            if swActive {
                StopwatchSection(attrs: attrs)
            }
            if !timerActive && !timerDone && !swActive {
                Text("⏱ 대기 중")
                    .font(.system(size: 14))
                    .foregroundColor(mutedColor)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(bgColor)
    }
}

// MARK: - Dynamic Island Compact

struct TimerCompactLeading: View {
    let attrs: LiveActivitiesAppAttributes
    var body: some View {
        let timerActive = bool(attrs.prefixedKey("timerActive"))
        let timerDone   = bool(attrs.prefixedKey("timerDone"))
        let running     = bool(attrs.prefixedKey("timerRunning"))
        let ending      = bool(attrs.prefixedKey("ending"))
        let remain      = str(attrs.prefixedKey("timerRemain"))
        let tColor      = ending ? Color(red: 0.878, green: 0.322, blue: 0.322) : timerColor(attrs)
        let end         = endDate(attrs)

        if timerActive || timerDone {
            HStack(spacing: 4) {
                StateDot(running: running && !timerDone, color: timerDone ? mutedColor : tColor)
                if running, let end = end {
                    Text(timerInterval: Date()...end, countsDown: true)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(tColor)
                        .monospacedDigit()
                } else {
                    Text(timerDone ? "완료" : remain)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(timerDone ? mutedColor : tColor)
                }
            }
        }
    }
}

struct TimerCompactTrailing: View {
    let attrs: LiveActivitiesAppAttributes
    var body: some View {
        let swActive = bool(attrs.prefixedKey("swActive"))
        let running  = bool(attrs.prefixedKey("swRunning"))
        let elapsed  = str(attrs.prefixedKey("swElapsed"))
        let start    = swStartDate(attrs)

        if swActive {
            HStack(spacing: 4) {
                StateDot(running: running, color: swGreen)
                if running, let start = start {
                    Text(timerInterval: start...Date.distantFuture, countsDown: false)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(swGreen)
                        .monospacedDigit()
                } else {
                    Text(elapsed.isEmpty ? "00:00" : elapsed)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(swGreen)
                }
            }
        }
    }
}

// MARK: - Dynamic Island Expanded

struct TimerExpandedView: View {
    let attrs: LiveActivitiesAppAttributes
    var body: some View {
        let timerActive = bool(attrs.prefixedKey("timerActive"))
        let timerDone   = bool(attrs.prefixedKey("timerDone"))
        let swActive    = bool(attrs.prefixedKey("swActive"))

        HStack(spacing: 20) {
            if timerActive || timerDone {
                TimerSection(attrs: attrs)
            }
            if (timerActive || timerDone) && swActive {
                Divider().frame(height: 40).background(mutedColor)
            }
            if swActive {
                StopwatchSection(attrs: attrs)
            }
        }
        .padding(.horizontal, 12)
    }
}

// MARK: - Widget Bundle

@main
struct TimerLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        TimerLiveActivityWidget()
    }
}

struct TimerLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            TimerLockScreenView(attrs: context.attributes)
        } dynamicIsland: { context in
            let timerActive = bool(context.attributes.prefixedKey("timerActive"))
            let timerDone   = bool(context.attributes.prefixedKey("timerDone"))
            let swActive    = bool(context.attributes.prefixedKey("swActive"))

            return DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    TimerExpandedView(attrs: context.attributes)
                }
            } compactLeading: {
                TimerCompactLeading(attrs: context.attributes)
            } compactTrailing: {
                TimerCompactTrailing(attrs: context.attributes)
            } minimal: {
                if timerActive || timerDone {
                    StateDot(running: bool(context.attributes.prefixedKey("timerRunning")) && !timerDone,
                             color: timerColor(context.attributes))
                } else if swActive {
                    StateDot(running: bool(context.attributes.prefixedKey("swRunning")), color: swGreen)
                } else {
                    Circle().fill(mutedColor).frame(width: 7, height: 7)
                }
            }
        }
    }
}
