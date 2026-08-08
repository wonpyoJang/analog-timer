import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  static const _kOverlayOn = 'overlay_on';
  static const _kTimerData = 'timer_data';
  static const _kSwData = 'sw_data';
  static const _kPresets = 'presets';
  static const _kLocale = 'locale';
  static const _kHiddenDefaults = 'hidden_default_presets';
  static const _kOverlayHintCount = 'overlay_hint_count';
  static const _kDpadOnLeft = 'dpad_on_left';
  static const _kMultiTimerData = 'multi_timer_data';
  static const _kMultiTimerPresets = 'multi_timer_presets';
  static const _kWorkoutRoutines = 'workout_routines';
  static const _kWorkoutConfig = 'workout_config';

  static Future<List<Map<String, dynamic>>?> loadWorkoutRoutines() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_kWorkoutRoutines);
    if (str == null) return null;
    try {
      return (jsonDecode(str) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveWorkoutRoutines(
    List<Map<String, dynamic>> routines,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kWorkoutRoutines, jsonEncode(routines));
  }

  static Future<Map<String, dynamic>?> loadWorkoutConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_kWorkoutConfig);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveWorkoutConfig(Map<String, dynamic> cfg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kWorkoutConfig, jsonEncode(cfg));
  }

  /// 멀티 타이머 프리셋 목록. null = 아직 저장된 적 없음(기본 시드 대상).
  /// 각 항목: {'name': String, 'durationMs': int}
  static Future<List<Map<String, dynamic>>?> loadMultiTimerPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_kMultiTimerPresets);
    if (str == null) return null;
    try {
      return (jsonDecode(str) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveMultiTimerPresets(
    List<Map<String, dynamic>> presets,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMultiTimerPresets, jsonEncode(presets));
  }

  /// 멀티 타이머 목록 저장 — 상태 전이 시에만 호출(tick마다 금지).
  static Future<void> saveMultiTimerState(
    List<Map<String, dynamic>> timers,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kMultiTimerData,
      jsonEncode({
        'timers': timers,
        'savedAtMs': DateTime.now().millisecondsSinceEpoch,
      }),
    );
  }

  static Future<Map<String, dynamic>?> loadMultiTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_kMultiTimerData);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static const _kOverlayPosX = 'overlay_pos_x';
  static const _kOverlayPosY = 'overlay_pos_y';
  static const _kOverlayCustomW = 'overlay_custom_w';
  static const _kEditCoachCount = 'edit_coach_count';

  /// 편집 모드 코치 오버레이 노출 횟수 — 최대 2회 후 종료. 오버레이 isolate 전용
  static Future<int> loadEditCoachCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kEditCoachCount) ?? 0;
  }

  static Future<void> saveEditCoachCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kEditCoachCount, count);
  }

  /// 오버레이 사용자 지정 너비(dp) — null이면 기본 42% 공식. 오버레이 isolate 전용
  static Future<void> saveOverlayCustomW(int w) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kOverlayCustomW, w);
  }

  static Future<int?> loadOverlayCustomW() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kOverlayCustomW);
  }

  /// 오버레이 창 마지막 위치(dp, topCenter gravity 기준) — 오버레이 isolate 전용
  static Future<void> saveOverlayPos(double x, double y) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kOverlayPosX, x);
    await prefs.setDouble(_kOverlayPosY, y);
  }

  static Future<({double x, double y})?> loadOverlayPos() async {
    final prefs = await SharedPreferences.getInstance();
    final x = prefs.getDouble(_kOverlayPosX);
    final y = prefs.getDouble(_kOverlayPosY);
    if (x == null || y == null) return null;
    return (x: x, y: y);
  }

  /// 편집 D-pad 도킹 방향 — 오버레이 isolate에서 읽고 쓴다 (⇄ 전환 기억)
  static Future<bool> loadDpadOnLeft() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kDpadOnLeft) ?? false;
  }

  static Future<void> saveDpadOnLeft(bool onLeft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDpadOnLeft, onLeft);
  }

  /// 오버레이 길게 누르기 힌트 노출 횟수 — 편집 모드 사용 확인 시 999로 영구 종료
  static Future<int> loadOverlayHintCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kOverlayHintCount) ?? 0;
  }

  static Future<void> saveOverlayHintCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kOverlayHintCount, count);
  }

  /// 숨긴 기본 프리셋의 builtinKey 목록 저장.
  static Future<void> saveHiddenDefaults(List<String> keys) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kHiddenDefaults, keys);
  }

  static Future<List<String>> loadHiddenDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kHiddenDefaults) ?? const [];
  }

  /// 수동 선택 언어 태그 저장(null=시스템 기본값으로 되돌림). 예: 'en', 'ko', 'zh_Hant'
  static Future<void> saveLocale(String? tag) async {
    final prefs = await SharedPreferences.getInstance();
    if (tag == null) {
      await prefs.remove(_kLocale);
    } else {
      await prefs.setString(_kLocale, tag);
    }
  }

  static Future<String?> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLocale);
  }

  static Future<void> saveOverlayOn(bool on) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOverlayOn, on);
  }

  static Future<bool> loadOverlayOn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOverlayOn) ?? false;
  }

  static Future<void> saveTimerState({
    required List<Map<String, dynamic>> segments,
    required int currentSeg,
    required int segRemainMs,
    required String status,
    required bool loop,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kTimerData,
      jsonEncode({
        'segments': segments,
        'currentSeg': currentSeg,
        'segRemainMs': segRemainMs,
        'status': status,
        'loop': loop,
        'savedAtMs': DateTime.now().millisecondsSinceEpoch,
      }),
    );
  }

  static Future<Map<String, dynamic>?> loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_kTimerData);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveSwState({
    required int elapsedMs,
    required bool running,
    double? startAngleRadians,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kSwData,
      jsonEncode({
        'elapsedMs': elapsedMs,
        'running': running,
        'startAngleRadians': startAngleRadians,
        'savedAtMs': DateTime.now().millisecondsSinceEpoch,
      }),
    );
  }

  static Future<Map<String, dynamic>?> loadSwState() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_kSwData);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// 프리셋(세그먼트 템플릿) 목록 저장. 각 원소는 Preset.toJson() 결과.
  static Future<void> savePresets(List<Map<String, dynamic>> presets) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPresets, jsonEncode(presets));
  }

  /// 저장된 프리셋 목록. 한 번도 저장된 적 없으면 null(=기본 프리셋으로 시드).
  static Future<List<Map<String, dynamic>>?> loadPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_kPresets);
    if (str == null) return null;
    try {
      return (jsonDecode(str) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }
}
