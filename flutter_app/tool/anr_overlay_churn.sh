#!/usr/bin/env bash
# 네이티브 오버레이 ANR 원인을 재현하는 부하 생성기(best-effort, 좌표 heuristic).
# 오버레이 토글 연타(FGS start/stop 레이스) + pill 드래그 + 탭 churn 을 adb 로 구동.
# 좌표는 wm size 비율로 계산 — 정확한 위젯 히트는 보장 못 하나, 목적은 입력 폭주 부하.
set -euo pipefail

PKG="dev.analogtimer.analog_timer"
ADB="${ADB:-adb}"
SERIAL_ARG=()
[ -n "${1:-}" ] && SERIAL_ARG=(-s "$1")
a() { "$ADB" "${SERIAL_ARG[@]}" "$@"; }

# 화면 크기 → 비율 좌표.
SIZE="$(a shell wm size | grep -oE '[0-9]+x[0-9]+' | head -1)"
W="${SIZE%x*}"; H="${SIZE#*x}"
r() { awk "BEGIN{printf \"%d\", $1}"; }
NAV_Y=$(r "$H*0.94")
TAB_TIMER_X=$(r "$W*0.17"); TAB_MULTI_X=$(r "$W*0.50"); TAB_SET_X=$(r "$W*0.83")
ROW1_Y=$(r "$H*0.155"); ROW2_Y=$(r "$H*0.232")   # 타이머 행(대략)
TOGGLE_X=$(r "$W*0.80")                            # 행 내 오버레이 토글(대략)
PILL_CX=$(r "$W*0.15"); PILL_CY=$(r "$H*0.20")     # pill 스폰 좌상단(대략)

echo "[churn] size=$SIZE nav_y=$NAV_Y"
a shell appops set "$PKG" SYSTEM_ALERT_WINDOW allow || true
a shell am start -n "$PKG/.MainActivity" >/dev/null 2>&1 || true
sleep 6
a shell input tap "$TAB_MULTI_X" "$NAV_Y" || true; sleep 1  # 멀티 탭

# 오버레이 토글 연타(FGS 레이스) — 두 행 모두.
echo "[churn] 오버레이 토글 연타"
for i in $(seq 1 12); do
  a shell input tap "$TOGGLE_X" "$ROW1_Y" || true; sleep 0.4
  a shell input tap "$TOGGLE_X" "$ROW2_Y" || true; sleep 0.4
done

# pill 드래그 churn(네이티브 attachDrag 경로).
echo "[churn] pill 드래그"
for i in $(seq 1 6); do
  a shell input touchscreen swipe "$PILL_CX" "$PILL_CY" $(r "$PILL_CX+400") $(r "$PILL_CY+500") 400 || true
  a shell input touchscreen swipe $(r "$PILL_CX+400") $(r "$PILL_CY+500") "$PILL_CX" "$PILL_CY" 400 || true
done

# 탭 churn(숨겨진 HomeScreen active 게이트 부하).
echo "[churn] 탭 churn"
for i in $(seq 1 10); do
  a shell input tap "$TAB_TIMER_X" "$NAV_Y" || true; sleep 0.2
  a shell input tap "$TAB_MULTI_X" "$NAV_Y" || true; sleep 0.2
done

echo "[churn] 완료"
