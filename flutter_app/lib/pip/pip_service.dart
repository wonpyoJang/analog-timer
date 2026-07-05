import 'dart:io';
import 'package:flutter/services.dart';

class PipService {
  static const _channel = MethodChannel('analog_timer/pip');

  static Future<bool> isAvailable() async {
    if (!Platform.isIOS) return false;
    try {
      return await _channel.invokeMethod<bool>('isAvailable') ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> start() async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('start');
    } catch (e) {
      // PiP not supported on this device/version
    }
  }

  static Future<void> update({
    required bool timerActive,
    required bool timerRunning,
    required bool timerDone,
    required String timerLabel,
    required String timerRemain,
    required int timerColorValue,
    required double timerFrac,
    required bool ending,
    required bool swActive,
    required bool swRunning,
    required String swElapsed,
  }) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('update', {
        'timerActive': timerActive,
        'timerRunning': timerRunning,
        'timerDone': timerDone,
        'timerLabel': timerLabel,
        'timerRemain': timerRemain,
        'timerColorR': ((timerColorValue >> 16) & 0xFF) / 255.0,
        'timerColorG': ((timerColorValue >> 8) & 0xFF) / 255.0,
        'timerColorB': (timerColorValue & 0xFF) / 255.0,
        'timerFrac': timerFrac,
        'ending': ending,
        'swActive': swActive,
        'swRunning': swRunning,
        'swElapsed': swElapsed,
      });
    } catch (_) {}
  }

  static Future<void> stop() async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod('stop');
    } catch (_) {}
  }
}
