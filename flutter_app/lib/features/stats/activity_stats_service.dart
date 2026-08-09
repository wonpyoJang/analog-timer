import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

/// 완료된 타이머 1건의 활동 로그(디자인 "활동 통계"의 자동 집계 소스).
class ActivityLog {
  final String name;
  final int durationMs;
  final int atMs; // 완료 시각(epoch)
  const ActivityLog({
    required this.name,
    required this.durationMs,
    required this.atMs,
  });

  Map<String, dynamic> toJson() => {'n': name, 'd': durationMs, 't': atMs};

  static ActivityLog fromJson(Map<String, dynamic> j) => ActivityLog(
    name: j['n'] as String? ?? '',
    durationMs: (j['d'] as num?)?.toInt() ?? 0,
    atMs: (j['t'] as num?)?.toInt() ?? 0,
  );
}

/// 활동 통계 — 타이머/운동/루프 완료를 이름별로 집계.
///
/// 데이터는 기기에만 저장(계정·클라우드 없음). 최근 90일만 보관.
/// 완료 시 [log] 를 호출해 레코드를 쌓고, 통계 화면이 [load]/집계 헬퍼로 읽는다.
class ActivityStatsService {
  ActivityStatsService._();
  static final ActivityStatsService instance = ActivityStatsService._();

  static const _kLogs = 'activity_logs_v1';
  static const _retentionDays = 90;

  /// 완료 1건 기록 — 이름 없으면(무제목) 무시. 최소 5초 이상만(오탭 방지).
  Future<void> log(String name, int durationMs) async {
    if (name.trim().isEmpty || durationMs < 5000) return;
    try {
      final p = await SharedPreferences.getInstance();
      final list = _decode(p.getString(_kLogs));
      list.add(
        ActivityLog(
          name: name.trim(),
          durationMs: durationMs,
          atMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      final cutoff = DateTime.now()
          .subtract(const Duration(days: _retentionDays))
          .millisecondsSinceEpoch;
      final trimmed = list.where((e) => e.atMs >= cutoff).toList();
      await p.setString(
        _kLogs,
        jsonEncode(trimmed.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  Future<List<ActivityLog>> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      return _decode(p.getString(_kLogs));
    } catch (_) {
      return [];
    }
  }

  List<ActivityLog> _decode(String? s) {
    if (s == null) return [];
    try {
      return (jsonDecode(s) as List)
          .map((e) => ActivityLog.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// 활동 이름 → 안정적 색(이름 해시로 segColors 순환).
  static Color colorFor(String name) {
    var h = 0;
    for (final c in name.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return AppColors.segColors[h % AppColors.segColors.length];
  }
}
