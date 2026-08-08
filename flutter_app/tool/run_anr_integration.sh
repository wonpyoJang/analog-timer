#!/usr/bin/env bash
# Phase 3 오케스트레이터: 에뮬레이터에서 ANR 통합 검증을 돌린다.
#  1) 기기 부팅 대기 + 오버레이 권한 부여
#  2) logcat 클리어
#  3) Dart 통합 테스트(탭 churn 스모크) + adb 네이티브 오버레이 churn 병행
#  4) anr_scan.sh 로 logcat ANR 시그니처 판정 (최종 결과)
set -euo pipefail
cd "$(dirname "$0")/.."   # flutter_app/

PKG="dev.analogtimer.analog_timer"
ADB="${ADB:-adb}"
SERIAL="${1:-}"
SERIAL_ARG=(); [ -n "$SERIAL" ] && SERIAL_ARG=(-s "$SERIAL")
a() { "$ADB" "${SERIAL_ARG[@]}" "$@"; }

echo "[run] 기기 부팅 대기"
a wait-for-device
until [ "$(a shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do sleep 2; done

echo "[run] 오버레이 권한 부여 + logcat 클리어"
a shell appops set "$PKG" SYSTEM_ALERT_WINDOW allow || true
a logcat -c || true

echo "[run] Dart 통합 테스트 + 네이티브 churn 병행"
# 네이티브 churn 을 백그라운드로(설치된 앱 대상). Dart 테스트가 앱을 재빌드/설치·구동.
( sleep 25; bash tool/anr_overlay_churn.sh "$SERIAL" ) &
CHURN_PID=$!

set +e
flutter test integration_test/multi_overlay_anr_test.dart ${SERIAL:+-d "$SERIAL"}
DART_RC=$?
set -e
wait "$CHURN_PID" 2>/dev/null || true

echo "[run] ANR 스캔"
set +e
ADB="$ADB" bash tool/anr_scan.sh "$SERIAL"
SCAN_RC=$?
set -e

echo "[run] Dart rc=$DART_RC, scan rc=$SCAN_RC"
[ "$DART_RC" -eq 0 ] && [ "$SCAN_RC" -eq 0 ]
