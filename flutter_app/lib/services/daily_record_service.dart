import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/timer/models/segment.dart';

class DailyRecordService {
  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String _logKey(DateTime date) => 'daylog_${_dateKey(date)}';
  static String _planKey(DateTime date) => 'dayplan_${_dateKey(date)}';

  // ── Daily Log ────────────────────────────────────────────────

  static Future<void> appendLogEntry(
    DateTime date,
    Map<String, dynamic> entry,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _logKey(date);
    final existing = prefs.getString(key);
    final List<dynamic> entries = existing != null
        ? jsonDecode(existing) as List
        : [];
    entries.add(entry);
    await prefs.setString(key, jsonEncode(entries));
  }

  static Future<List<Map<String, dynamic>>> loadLog(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_logKey(date));
    if (str == null) return const [];
    try {
      return (jsonDecode(str) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return const [];
    }
  }

  // ── Day Plan ─────────────────────────────────────────────────

  static Future<void> savePlan(DateTime date, List<Segment> segments) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _planKey(date),
      jsonEncode(segments.map((s) => s.toJson()).toList()),
    );
  }

  static Future<List<Segment>?> loadPlan(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_planKey(date));
    if (str == null) return null;
    try {
      return (jsonDecode(str) as List)
          .map((e) => Segment.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> deletePlan(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_planKey(date));
  }
}
