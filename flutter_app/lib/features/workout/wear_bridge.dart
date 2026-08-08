import 'package:flutter/services.dart';
import '../../services/platform_info.dart';

/// 운동 TTS 워치 미러 브리지(Wear OS).
///
/// 세션 상태를 Data Layer 로 워치에 push 하고, 워치의 ⏹/⏭ 명령을 받는다.
/// 워치 미페어링/미설치 환경에서는 네이티브가 조용히 무시하므로 항상 호출해도 안전.
class WearBridge {
  static const _channel = MethodChannel('dev.analogtimer/wear');

  /// 워치 명령(stop/skip) 콜백 — 실행 화면이 등록.
  static void Function(String cmd)? onCommand;

  static bool _listening = false;

  static void ensureListening() {
    if (_listening || !isAndroid) return;
    _listening = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'command') {
        onCommand?.call(call.arguments as String? ?? '');
      }
    });
  }

  static Future<void> pushState({
    required String phase,
    required String name,
    required String type,
    required int set,
    required int sets,
    required int rep,
    required int reps,
    required int t,
  }) async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod('pushState', {
        'phase': phase,
        'name': name,
        'type': type,
        'set': set,
        'sets': sets,
        'rep': rep,
        'reps': reps,
        't': t,
      });
    } catch (_) {}
  }
}
