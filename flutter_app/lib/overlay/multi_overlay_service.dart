import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../services/platform_info.dart';

/// 엔진 없는 네이티브 멀티 오버레이 브리지.
///
/// 실행 중 카운트다운 타이머마다 독립 pill 창을 띄운다. 네이티브(MultiOverlayService.kt)가
/// FlutterEngine 없이 WindowManager에 순수 Android View를 id별로 붙이므로 창을 N개
/// 띄워도 엔진 메모리가 0이다. 권한(SYSTEM_ALERT_WINDOW)은 flutter_overlay_window의
/// 것을 그대로 재사용한다.
class MultiOverlayService {
  static const _channel = MethodChannel('dev.analogtimer/multi_overlay');

  /// 동시 표시 상한 — 화면 과밀 방지(메모리는 네이티브라 무부담).
  static const int maxWindows = 5;

  /// 네이티브 멀티 오버레이 지원 여부(Android 전용).
  static bool get supported => isAndroid;

  static Future<bool> get isPermissionGranted async {
    if (!isAndroid) return false;
    return FlutterOverlayWindow.isPermissionGranted();
  }

  static Future<void> requestPermission() async {
    if (!isAndroid) return;
    await FlutterOverlayWindow.requestPermission();
  }

  /// id 창을 만들거나(없으면) 갱신한다.
  static Future<void> show({
    required String id,
    required String name,
    required String time,
    required int colorValue,
    double frac = 1.0,
    bool done = false,
  }) => _send(
    'show',
    id,
    name: name,
    time: time,
    color: colorValue,
    frac: frac,
    done: done,
  );

  /// 기존 id 창의 남은시간/진행률만 갱신(없으면 자동 생성).
  static Future<void> update({
    required String id,
    required String name,
    required String time,
    required int colorValue,
    double frac = 1.0,
    bool done = false,
  }) => _send(
    'update',
    id,
    name: name,
    time: time,
    color: colorValue,
    frac: frac,
    done: done,
  );

  /// id 창을 닫는다. 마지막 창이면 서비스가 스스로 종료한다.
  static Future<void> close(String id) async {
    if (!isAndroid) return;
    await _channel.invokeMethod('close', {'id': id});
  }

  static Future<void> closeAll() async {
    if (!isAndroid) return;
    await _channel.invokeMethod('closeAll');
  }

  static Future<void> _send(
    String method,
    String id, {
    required String name,
    required String time,
    required int color,
    required double frac,
    required bool done,
  }) async {
    if (!isAndroid) return;
    await _channel.invokeMethod(method, {
      'id': id,
      'name': name,
      'time': time,
      'color': color,
      'frac': frac,
      'done': done,
    });
  }
}
