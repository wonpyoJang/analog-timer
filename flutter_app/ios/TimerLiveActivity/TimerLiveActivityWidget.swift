import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - 색상

private let timerOrange = Color(red: 0.878, green: 0.478, blue: 0.322)
private let swGreen     = Color(red: 0.180, green: 0.659, blue: 0.290)
private let bgColor     = Color(red: 0.055, green: 0.055, blue: 0.059)
private let mutedColor  = Color(red: 0.420, green: 0.412, blue: 0.408)

private let sharedDefault = UserDefaults(suiteName: "group.dev.analogtimer.analogTimer")!

// MARK: - Lock Screen / Notification Banner

struct TimerLockScreenView: View {
    let attrs: LiveActivitiesAppAttributes

    private var timerActive: Bool { sharedDefault.bool(forKey: attrs.prefixedKey("timerActive")) }
    private var timerLabel: String { sharedDefault.string(forKey: attrs.prefixedKey("timerLabel")) ?? "" }
    private var timerRemain: String { sharedDefault.string(forKey: attrs.prefixedKey("timerRemain")) ?? "--:--" }
    private var swActive: Bool { sharedDefault.bool(forKey: attrs.prefixedKey("swActive")) }
    private var swElapsed: String { sharedDefault.string(forKey: attrs.prefixedKey("swElapsed")) ?? "" }

    var body: some View {
        HStack(spacing: 16) {
            if timerActive {
                HStack(spacing: 6) {
                    Circle().fill(timerOrange).frame(width: 8, height: 8)
                    VStack(alignment: .leading, spacing: 0) {
                        if !timerLabel.isEmpty {
                            Text(timerLabel)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(timerOrange.opacity(0.8))
                        }
                        Text(timerRemain)
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundColor(timerOrange)
                    }
                }
            }

            if timerActive && swActive {
                Divider().frame(height: 28).background(mutedColor)
            }

            if swActive {
                HStack(spacing: 6) {
                    Circle().fill(swGreen).frame(width: 8, height: 8)
                    Text(swElapsed)
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(swGreen)
                }
            }

            if !timerActive && !swActive {
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
        let timerActive = sharedDefault.bool(forKey: attrs.prefixedKey("timerActive"))
        let timerRemain = sharedDefault.string(forKey: attrs.prefixedKey("timerRemain")) ?? "--:--"
        if timerActive {
            HStack(spacing: 4) {
                Circle().fill(timerOrange).frame(width: 6, height: 6)
                Text(timerRemain)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(timerOrange)
            }
        }
    }
}

struct TimerCompactTrailing: View {
    let attrs: LiveActivitiesAppAttributes
    var body: some View {
        let swActive = sharedDefault.bool(forKey: attrs.prefixedKey("swActive"))
        let swElapsed = sharedDefault.string(forKey: attrs.prefixedKey("swElapsed")) ?? ""
        if swActive {
            HStack(spacing: 4) {
                Circle().fill(swGreen).frame(width: 6, height: 6)
                Text(swElapsed)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(swGreen)
            }
        }
    }
}

// MARK: - Dynamic Island Expanded

struct TimerExpandedView: View {
    let attrs: LiveActivitiesAppAttributes
    var body: some View {
        let timerActive = sharedDefault.bool(forKey: attrs.prefixedKey("timerActive"))
        let timerLabel = sharedDefault.string(forKey: attrs.prefixedKey("timerLabel")) ?? ""
        let timerRemain = sharedDefault.string(forKey: attrs.prefixedKey("timerRemain")) ?? "--:--"
        let swActive = sharedDefault.bool(forKey: attrs.prefixedKey("swActive"))
        let swElapsed = sharedDefault.string(forKey: attrs.prefixedKey("swElapsed")) ?? ""

        HStack(spacing: 24) {
            if timerActive {
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Circle().fill(timerOrange).frame(width: 6, height: 6)
                        Text("타이머").font(.caption2).foregroundColor(mutedColor)
                    }
                    if !timerLabel.isEmpty {
                        Text(timerLabel).font(.caption2).foregroundColor(timerOrange.opacity(0.8))
                    }
                    Text(timerRemain)
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(timerOrange)
                }
            }
            if timerActive && swActive {
                Divider().frame(height: 36).background(mutedColor)
            }
            if swActive {
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Circle().fill(swGreen).frame(width: 6, height: 6)
                        Text("스톱워치").font(.caption2).foregroundColor(mutedColor)
                    }
                    Text(swElapsed)
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(swGreen)
                }
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
            let timerActive = sharedDefault.bool(forKey: context.attributes.prefixedKey("timerActive"))
            let swActive = sharedDefault.bool(forKey: context.attributes.prefixedKey("swActive"))

            return DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    TimerExpandedView(attrs: context.attributes)
                }
            } compactLeading: {
                TimerCompactLeading(attrs: context.attributes)
            } compactTrailing: {
                TimerCompactTrailing(attrs: context.attributes)
            } minimal: {
                Circle().fill(timerActive ? timerOrange : swGreen)
                    .frame(width: 8, height: 8)
            }
        }
    }
}
