import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../services/platform_info.dart';
import '../services/care_service.dart';

/// 엔진 없는 네이티브 멀티 오버레이 브리지.
///
/// 실행 중 카운트다운 타이머마다 독립 pill 창을 띄운다. 네이티브(MultiOverlayService.kt)가
/// FlutterEngine 없이 WindowManager에 순수 Android View를 id별로 붙이므로 창을 N개
/// 띄워도 엔진 메모리가 0이다. 권한(SYSTEM_ALERT_WINDOW)은 flutter_overlay_window의
/// 것을 그대로 재사용한다.
class MultiOverlayService {
  static const _channel = MethodChannel('dev.analogtimer/multi_overlay');

  /// pill 탭 콜백(네이티브→Dart) — 프리-알림 +5분 연장(페르소나 §5).
  static void Function(String id)? onPillTap;
  static bool _tapListening = false;

  static void ensureTapListening() {
    if (_tapListening || !isAndroid) return;
    _tapListening = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'pillTap') {
        onPillTap?.call(call.arguments as String? ?? '');
      }
    });
  }

  /// 네이티브 조회 실패 시 동시 표시 상한 폴백.
  static const int fallbackMaxWindows = 5;

  /// UX 상한 — 슬롯이 아무리 많아도 이 이상은 서로 구분이 어려워 의미 없음.
  static const int maxWindowsCap = 16;

  /// 기기별 동시 표시 상한 — 겹침 없이 배치 가능한 슬롯 수(네이티브 격자 공식).
  /// 화면이 클수록 늘어난다. 실측상 메모리·ANR 제약은 없고 화면 공간만이 제약.
  static Future<int> maxWindows() async {
    if (!isAndroid) return fallbackMaxWindows;
    try {
      final v = await _channel.invokeMethod<int>('capacity');
      if (v == null || v < 1) return fallbackMaxWindows;
      return v.clamp(1, maxWindowsCap);
    } catch (_) {
      return fallbackMaxWindows;
    }
  }

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
  ///
  /// 매초 push 하지 않는다 — 상태 변화(start/pause/reset/complete/rename) 시에만 호출하고,
  /// 네이티브 뷰가 [remainMs]/[running] 으로 마감시각을 잡아 자체적으로 매초 갱신한다.
  /// 이렇게 하면 플랫폼 스레드가 다른 오버레이 엔진으로 바빠도 표시 시간이 정확하다.
  static Future<void> show({
    required String id,
    required String name,
    required int colorValue,
    required int totalMs,
    required int remainMs,
    required bool running,
    bool done = false,
    String doneText = '',
  }) => _send(
    'show',
    id,
    name: name,
    color: colorValue,
    totalMs: totalMs,
    remainMs: remainMs,
    running: running,
    done: done,
    doneText: doneText,
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
    required int color,
    required int totalMs,
    required int remainMs,
    required bool running,
    required bool done,
    required String doneText,
  }) async {
    if (!isAndroid) return;
    // 마감 절대시각을 push 시점에 계산해 보낸다 — 네이티브가 도착시각 기준으로 잡으면
    // 채널 전달 지연만큼 pill 이 리스트보다 늦게 가는 것으로 보인다.
    final deadlineMs = running
        ? DateTime.now().millisecondsSinceEpoch + remainMs
        : 0;
    await _channel.invokeMethod(method, {
      'id': id,
      'name': name,
      'color': color,
      'totalMs': totalMs,
      'remainMs': remainMs,
      'running': running,
      'done': done,
      'doneText': doneText,
      'deadlineMs': deadlineMs,
      // 프리-알림 구간(잔여 N분)에 pill 링·시간이 accent 로 전환(페르소나 §5).
      'preAlarmMs': CareService.instance.preAlarmMin.value * 60000,
    });
  }
}
