import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  static const _kOverlayOn = 'overlay_on';
  static const _kTimerData = 'timer_data';
  static const _kSwData = 'sw_data';

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
}
