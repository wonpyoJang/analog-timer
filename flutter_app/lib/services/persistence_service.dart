import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  static const _kOverlayOn = 'overlay_on';
  static const _kTimerData = 'timer_data';
  static const _kSwData = 'sw_data';
  static const _kPresets = 'presets';

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
