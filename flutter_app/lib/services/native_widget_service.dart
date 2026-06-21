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

  static Future<void> cancelNotification() async {
    if (!Platform.isAndroid) return;
    try {
      await _ch.invokeMethod('cancelNotification');
    } catch (_) {}
  }
}
