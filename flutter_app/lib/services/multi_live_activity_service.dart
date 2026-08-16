import 'package:flutter/foundation.dart';
import 'package:live_activities/live_activities.dart';
import 'platform_info.dart';

/// iOS 멀티 타이머 오버레이 = 타이머별 Live Activity(다이나믹 아일랜드/잠금화면).
/// Android 의 네이티브 pill 오버레이에 대응 — iOS 는 서드파티 자유 플로팅 오버레이가
/// 불가하므로 실행 중인 타이머마다 Live Activity 를 하나씩 띄운다. 활동 id = 타이머 id.
class MultiLiveActivityService {
  MultiLiveActivityService._();
  static final MultiLiveActivityService instance = MultiLiveActivityService._();

  static const _appGroupId = 'group.dev.analogtimer.analogTimer';
  static const maxActivities = 8; // iOS 동시 Live Activity 한도 고려

  final _plugin = LiveActivities();
  bool _initialized = false;
  final Set<String> _active = {};

  bool get supported => isIOS;
  bool get atLimit => _active.length >= maxActivities;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _plugin.init(appGroupId: _appGroupId);
    _initialized = true;
  }

  /// 활동 생성(있으면 update). 상한 초과면 false.
  Future<bool> start(String timerId, Map<String, dynamic> data) async {
    if (!isIOS) return false;
    if (_active.contains(timerId)) {
      await update(timerId, data);
      return true;
    }
    if (_active.length >= maxActivities) return false;
    await _ensureInit();
    try {
      await _plugin.createOrUpdateActivity(
        timerId,
        data,
        iOSEnableRemoteUpdates: false,
      );
      _active.add(timerId);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[MultiLA] start error: $e');
      return false;
    }
  }

  Future<void> update(String timerId, Map<String, dynamic> data) async {
    if (!isIOS || !_active.contains(timerId)) return;
    try {
      await _plugin.updateActivity(timerId, data);
    } catch (_) {}
  }

  Future<void> end(String timerId) async {
    if (!isIOS || !_active.remove(timerId)) return;
    try {
      await _plugin.endActivity(timerId);
    } catch (_) {}
  }

  /// 이 서비스가 만든 활동만 종료(단일 타이머 Live Activity 는 건드리지 않음).
  Future<void> endAll() async {
    if (!isIOS) return;
    final ids = _active.toList();
    _active.clear();
    for (final id in ids) {
      try {
        await _plugin.endActivity(id);
      } catch (_) {}
    }
  }
}
