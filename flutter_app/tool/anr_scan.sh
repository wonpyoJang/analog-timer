#!/usr/bin/env bash
# logcat 에서 ANR 시그니처를 스캔한다. 하나라도 매치하면 exit 1.
# 사용: adb logcat -c (테스트 전) → 시나리오 구동 → anr_scan.sh [serial]
set -euo pipefail

PKG="dev.analogtimer.analog_timer"
ADB="${ADB:-adb}"
SERIAL_ARG=()
[ -n "${1:-}" ] && SERIAL_ARG=(-s "$1")

# 세션 내내 실제로 관측된 ANR 시그니처들.
PATTERNS='ANR in '"$PKG"'|ForegroundServiceDidNotStartInTimeException|Input dispatching timed out|Waited 5000ms for MotionEvent|Bringing down service while still waiting for start foreground'

# 판정은 logcat 기준(테스트 전 `logcat -c` 로 초기화되므로 이번 실행분만 반영).
echo "[anr_scan] logcat 덤프 스캔 중..."
DUMP="$("$ADB" "${SERIAL_ARG[@]}" logcat -d 2>/dev/null || true)"
HITS="$(printf '%s\n' "$DUMP" | grep -E "$PATTERNS" || true)"

# 참고용: ApplicationExitInfo 는 누적 이력이라 과거 ANR도 남는다 → 판정엔 쓰지 않고 출력만.
EXITINFO="$("$ADB" "${SERIAL_ARG[@]}" shell dumpsys activity exit-info "$PKG" 2>/dev/null || true)"
ANR_EXIT="$(printf '%s\n' "$EXITINFO" | grep -iE 'reason=6 \(ANR\)|REASON_ANR' || true)"
[ -n "$ANR_EXIT" ] && echo "ℹ️  [anr_scan] (참고) exit-info 이력에 과거 ANR 있음(누적, 판정 제외)."

if [ -n "$HITS" ]; then
  echo "❌ [anr_scan] 이번 실행에서 ANR 시그니처 감지:"
  printf '%s\n' "$HITS" | tail -20
  exit 1
fi

echo "✅ [anr_scan] 이번 실행 ANR 시그니처 없음."
