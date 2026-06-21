import 'package:live_activities/live_activities.dart';
import '../services/platform_info.dart';

const _appGroupId = 'group.dev.analogtimer.analogTimer';
const _activityId = 'analog_timer_activity';

class LiveActivityService {
  static final _plugin = LiveActivities();
  static bool _initialized = false;
  static bool _active = false;

  static Future<void> init() async {
    if (!isIOS || _initialized) return;
    await _plugin.init(appGroupId: _appGroupId);
    _initialized = true;
  }

  static Future<void> update({
    required bool timerActive,
    required String timerLabel,
    required String timerRemain,
    required bool swActive,
    required String swElapsed,
  }) async {
    if (!isIOS) return;
    if (!_initialized) await init();

    final data = {
      'timerActive': timerActive,
      'timerLabel': timerLabel,
      'timerRemain': timerRemain,
      'swActive': swActive,
      'swElapsed': swElapsed,
    };

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
  }

  static Future<void> end() async {
    if (!isIOS || !_initialized) return;
    await _plugin.endAllActivities();
    _active = false;
  }
}
