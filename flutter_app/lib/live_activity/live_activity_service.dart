import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:live_activities/live_activities.dart';

const _appGroupId = 'group.dev.analogtimer.analogTimer';
const _activityId = 'analog_timer_activity';

class LiveActivityService {
  static final _plugin = LiveActivities();
  static bool _initialized = false;
  static bool _active = false;
  // Activity가 시스템에서 소실됐을 때 true — end() 호출 전까지 재시도 차단
  static bool _activityLost = false;

  static Future<void> init() async {
    if (!Platform.isIOS || _initialized) return;
    await _plugin.init(appGroupId: _appGroupId);
    _initialized = true;
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
    required int segRemainMs,
    required bool swActive,
    required bool swRunning,
    required String swElapsed,
    required int swElapsedMs,
  }) async {
    if (!Platform.isIOS) return;
    if (!_initialized) await init();
    if (_activityLost) return;

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    // timerEndEpochMs: 타이머가 실행 중일 때만 유효한 종료 시각 (ms)
    // Swift에서 Text(timerInterval:) 으로 부드러운 카운트다운에 사용
    final timerEndEpochMs = timerRunning ? nowMs + segRemainMs : 0;
    // swStartEpochMs: 스톱워치가 실행 중일 때 시작 시각 (ms)
    final swStartEpochMs = swRunning ? nowMs - swElapsedMs : 0;

    final data = {
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
      'timerEndEpochMs': timerEndEpochMs,
      'swActive': swActive,
      'swRunning': swRunning,
      'swElapsed': swElapsed,
      'swElapsedMs': swElapsedMs,
      'swStartEpochMs': swStartEpochMs,
    };

    try {
      if (_active) {
        if (!timerActive && !swActive) {
          await _plugin.endActivity(_activityId);
          _active = false;
        } else {
          await _plugin.updateActivity(_activityId, data);
        }
      } else {
        if (timerActive || swActive) {
          await _plugin.createOrUpdateActivity(
            _activityId,
            data,
            iOSEnableRemoteUpdates: false,
          );
          _active = true;
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[LiveActivity] error: $e');
      if (e.toString().contains('ACTIVITY_ERROR')) {
        _active = false;
        _activityLost = true; // end() 호출 전까지 재시도 차단
      }
    }
  }

  static Future<void> end() async {
    if (!Platform.isIOS || !_initialized) return;
    try {
      await _plugin.endAllActivities();
    } catch (_) {}
    _active = false;
    _activityLost = false; // 다음 Widget 토글 시 재시도 허용
  }
}
