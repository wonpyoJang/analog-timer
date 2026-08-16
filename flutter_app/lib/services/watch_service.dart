import 'package:flutter/services.dart';
import 'platform_info.dart';

/// Apple Watch 연동 브리지 — WatchConnectivity(WCSession) 위에서 폰↔워치 통신.
/// Wear OS 미러와 동형: 폰 → 워치 상태 전송, 워치 → 폰 명령 수신.
/// 네이티브(WatchBridge)가 `analog_timer/watch` 채널로 중계한다.
class WatchService {
  WatchService._();
  static final WatchService instance = WatchService._();

  static const _channel = MethodChannel('analog_timer/watch');

  /// 워치에서 온 명령 콜백 — 앱 루트가 등록해 실제 bloc 에 연결.
  /// cmd: 'timer_toggle' | 'timer_next' | 'sw_toggle' | 'sw_lap'
  void Function(String cmd)? onCommand;

  bool _started = false;
  String _lastSig = '';

  void init() {
    if (_started || !isIOS) return;
    _started = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'command') {
        final cmd = call.arguments as String? ?? '';
        if (cmd.isNotEmpty) onCommand?.call(cmd);
      }
    });
  }

  /// 폰 → 워치 상태 전송. 시그니처가 바뀔 때만(초 단위 스팸 방지 — 워치는
  /// 남은 시간을 종료 epoch 로 자체 카운트다운). 최신 상태는 applicationContext.
  Future<void> sync(Map<String, dynamic> state) async {
    if (!isIOS) return;
    final sig =
        '${state['timerRunning']}|${state['timerLabel']}|'
        '${state['swRunning']}|${state['timerActive']}|${state['swActive']}';
    if (sig == _lastSig) return;
    _lastSig = sig;
    try {
      await _channel.invokeMethod('sync', state);
    } catch (_) {}
  }
}
