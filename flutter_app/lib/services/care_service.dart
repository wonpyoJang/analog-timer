import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 조용한 배려 설정(디자인 "페르소나 장치 제안" §3·§5).
///
/// - 프리-알림: 잔여 N분에 소리 없이 예고(pill accent 전환 + 배너 + +5분 연장)
/// - 조용한 시간: 22:00–07:00 에는 효과음 대신 진동
/// - 알람 문구 톤: 다정 / 중립 / 간결
class CareService {
  CareService._();
  static final CareService instance = CareService._();

  static const _kPreAlarm = 'care_pre_alarm_min';
  static const _kQuietHours = 'care_quiet_hours';
  static const _kTone = 'care_message_tone';
  static const _kRealarm = 'care_realarm';

  /// 프리-알림 분(0=OFF, 1/2/5). 기본 2분(시안).
  final ValueNotifier<int> preAlarmMin = ValueNotifier<int>(2);

  /// 조용한 시간(22:00–07:00 소리→진동). 기본 ON(시안).
  final ValueNotifier<bool> quietHours = ValueNotifier<bool>(true);

  /// 알람 문구 톤: 'warm' | 'neutral' | 'brief'. 기본 중립.
  final ValueNotifier<String> messageTone = ValueNotifier<String>('neutral');

  /// 확인까지 재알림(요리 시안 §5, 기본 ON) — 완료 미확인 타이머를 1분마다 다시 울림.
  final ValueNotifier<bool> realarm = ValueNotifier<bool>(true);

  Future<void> init() async {
    try {
      final p = await SharedPreferences.getInstance();
      preAlarmMin.value = p.getInt(_kPreAlarm) ?? 2;
      quietHours.value = p.getBool(_kQuietHours) ?? true;
      final t = p.getString(_kTone);
      if (t != null && ['warm', 'neutral', 'brief'].contains(t)) {
        messageTone.value = t;
      }
      realarm.value = p.getBool(_kRealarm) ?? true;
    } catch (_) {}
  }

  Future<void> setRealarm(bool v) async {
    realarm.value = v;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kRealarm, v);
    } catch (_) {}
  }

  Future<void> setPreAlarmMin(int v) async {
    preAlarmMin.value = v;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt(_kPreAlarm, v);
    } catch (_) {}
  }

  Future<void> setQuietHours(bool v) async {
    quietHours.value = v;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kQuietHours, v);
    } catch (_) {}
  }

  Future<void> setMessageTone(String v) async {
    messageTone.value = v;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kTone, v);
    } catch (_) {}
  }

  /// 지금이 조용한 시간대(22:00–07:00)인가.
  bool get inQuietWindow {
    if (!quietHours.value) return false;
    final h = DateTime.now().hour;
    return h >= 22 || h < 7;
  }
}
