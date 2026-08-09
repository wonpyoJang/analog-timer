import 'dart:io';
import 'package:flutter/services.dart';

class NativeWidgetService {
  static const _ch = MethodChannel('dev.analogtimer/widget');

  static Future<void> updateState({
    required bool timerActive,
    required String timerLabel,
    required String timerTime,
    required String swTime,
    int timerColor = 0xFFE07A52,
  }) async {
    if (!Platform.isAndroid) return;
    try {
      await _ch.invokeMethod('updateState', {
        'timerActive': timerActive,
        'timerLabel': timerLabel,
        'timerTime': timerTime,
        'swTime': swTime,
        'timerColor': timerColor,
      });
    } catch (_) {}
  }

  /// 알람 점검용 테스트 알람 발송(고중요도 알림).
  static Future<void> testAlarm(String title, String body) async {
    if (!Platform.isAndroid) return;
    try {
      await _ch.invokeMethod('testAlarm', {'title': title, 'body': body});
    } catch (_) {}
  }

  static Future<void> cancelNotification() async {
    if (!Platform.isAndroid) return;
    try {
      await _ch.invokeMethod('cancelNotification');
    } catch (_) {}
  }
}
