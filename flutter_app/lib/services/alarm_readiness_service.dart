import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'platform_info.dart';

/// 알람 준비 상태(디자인 "설정 구조 & 초기 설정" §1·§3) — ADHD 타이머의 생명선.
///
/// 배터리 최적화가 앱을 재우면 알람이 조용히 죽는다. 알림 권한 + 배터리 예외
/// 두 가지가 핵심. 상태를 확인·요청하고, 깨졌을 때 설정 상단 점검 카드를 띄운다.
class AlarmReadinessService {
  AlarmReadinessService._();
  static final AlarmReadinessService instance = AlarmReadinessService._();

  /// 점검 카드/온보딩이 구독 — 상태 변화 시 갱신.
  final ValueNotifier<bool> notificationsOk = ValueNotifier<bool>(true);
  final ValueNotifier<bool> batteryExemptOk = ValueNotifier<bool>(true);

  /// 오버레이(다른 앱 위에 표시) 권한 — pill 표시에 필요. 점검 페이지 항목.
  final ValueNotifier<bool> overlayOk = ValueNotifier<bool>(true);

  /// 알림·배터리 둘 다 정상이면 준비 완료 — 점검 카드 숨김(오버레이는 선택 기능).
  bool get allReady => notificationsOk.value && batteryExemptOk.value;

  Future<void> refresh() async {
    if (!isAndroid) {
      notificationsOk.value = true;
      batteryExemptOk.value = true;
      overlayOk.value = true;
      return;
    }
    try {
      notificationsOk.value = await Permission.notification.isGranted;
    } catch (_) {}
    try {
      batteryExemptOk.value =
          await Permission.ignoreBatteryOptimizations.isGranted;
    } catch (_) {}
    try {
      overlayOk.value = await Permission.systemAlertWindow.isGranted;
    } catch (_) {}
  }

  Future<bool> requestOverlay() async {
    if (!isAndroid) return true;
    try {
      final st = await Permission.systemAlertWindow.request();
      overlayOk.value = st.isGranted;
      return st.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// 알림 권한 요청 → 상태 갱신.
  Future<bool> requestNotifications() async {
    if (!isAndroid) return true;
    try {
      final st = await Permission.notification.request();
      notificationsOk.value = st.isGranted;
      return st.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// 배터리 최적화 예외 요청(시스템 다이얼로그 "제한 없음") → 상태 갱신.
  Future<bool> requestBatteryExempt() async {
    if (!isAndroid) return true;
    try {
      final st = await Permission.ignoreBatteryOptimizations.request();
      batteryExemptOk.value = st.isGranted;
      return st.isGranted;
    } catch (_) {
      return false;
    }
  }
}
