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
