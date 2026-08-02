import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'telemetry_service.dart';

/// 사용후기 유도 다이얼로그의 노출 시점·주기 결정 로직.
///
/// 원칙:
/// - 성공 경험 직후에만 (타이머 완주 = allDone, 정지 상태) — 작업 중 방해 금지
/// - 충분히 써본 사용자만: 누적 세션 [minSessions]회 + 첫 실행 [minDays]일 경과
/// - "나중에" → 지수 백오프 재노출: 7일 → 14일 → 28일, 최대 [maxPrompts]회
/// - "다시 보지 않기" / 후기 작성 / 피드백 전송 이력 → 영구 off
/// - 직전 세션이 크래시였으면 이번 세션은 노출 안 함 (나쁜 경험 직후 금지)
///
/// 저장소: Windows 에선 SharedPreferences 대신 **전용 JSON 파일**을 쓴다.
/// 오버레이(위젯) 서브엔진이 위치/스케일 저장 시 자기 prefs 캐시를 통째로
/// flush 해 메인 엔진이 쓴 키를 지우는 race(breadcrumb 이 겪은 것과 동일)로
/// "다시 보지 않기"가 조용히 롤백되는 것을 막기 위함. 모바일은 단일 엔진이라
/// prefs 를 그대로 쓴다.
class ReviewPromptService {
  ReviewPromptService._();
  static final ReviewPromptService instance = ReviewPromptService._();

  // 노출 정책 파라미터 — 주기 조절은 여기서
  static const int minSessions = 5; // 최소 누적 실행 횟수
  static const int minDays = 3; // 첫 실행 후 최소 경과일
  static const int maxPrompts = 3; // 평생 최대 노출 횟수
  static const int baseCooldownDays = 7; // "나중에" 후 첫 재노출 대기일(이후 2배씩)

  static const _kSessions = 'review_sessions_count';
  static const _kFirstRun = 'review_first_run_ms';
  static const _kLastPrompt = 'review_last_prompt_ms';
  static const _kPromptCount = 'review_prompt_count';
  static const _kNever = 'review_dismissed_forever';
  static const _kDone = 'review_done';
  static const _allKeys = [
    _kSessions,
    _kFirstRun,
    _kLastPrompt,
    _kPromptCount,
    _kNever,
    _kDone,
  ];

  /// 테스트용 저장 디렉토리 오버라이드 — 지정 시 무조건 파일 백엔드 사용.
  @visibleForTesting
  static String? storageDirOverride;

  bool _sessionCounted = false;

  File? get _stateFile {
    final dir = storageDirOverride;
    if (dir != null) {
      return File('$dir${Platform.pathSeparator}analog_timer_review.json');
    }
    if (!kIsWeb && Platform.isWindows) {
      final appdata = Platform.environment['APPDATA'];
      if (appdata != null) {
        return File(
          '$appdata\\dev.analogtimer\\analog_timer\\analog_timer_review.json',
        );
      }
    }
    return null; // 모바일 등: 단일 엔진 → prefs race 없음
  }

  Future<Map<String, Object?>> _load() async {
    final f = _stateFile;
    if (f != null) {
      try {
        if (await f.exists()) {
          return (jsonDecode(await f.readAsString()) as Map)
              .cast<String, Object?>();
        }
      } catch (_) {}
      return {};
    }
    final p = await SharedPreferences.getInstance();
    return {
      for (final k in _allKeys)
        if (p.containsKey(k)) k: p.get(k),
    };
  }

  Future<void> _save(Map<String, Object?> m) async {
    final f = _stateFile;
    if (f != null) {
      try {
        await f.parent.create(recursive: true);
        await f.writeAsString(jsonEncode(m));
      } catch (_) {}
      return;
    }
    final p = await SharedPreferences.getInstance();
    for (final e in m.entries) {
      final v = e.value;
      if (v is bool) await p.setBool(e.key, v);
      if (v is int) await p.setInt(e.key, v);
    }
  }

  /// 앱 실행(메인 엔진) 1회당 한 번 호출 — 세션 수·첫 실행 시각 기록.
  Future<void> recordSessionStart() async {
    if (_sessionCounted) return;
    _sessionCounted = true;
    final m = await _load();
    m[_kSessions] = ((m[_kSessions] as num?)?.toInt() ?? 0) + 1;
    m[_kFirstRun] ??= DateTime.now().millisecondsSinceEpoch;
    await _save(m);
  }

  /// 지금 다이얼로그를 띄워도 되는가 — 모든 게이트 통과 시에만 true.
  Future<bool> shouldPrompt() async {
    final m = await _load();
    if (m[_kNever] == true) return false;
    if (m[_kDone] == true) return false;
    // 직전 세션 크래시 → 이번 세션은 쉰다
    if (TelemetryService.instance.lastSessionCrashed) return false;

    if (((m[_kSessions] as num?)?.toInt() ?? 0) < minSessions) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final firstRun = (m[_kFirstRun] as num?)?.toInt() ?? now;
    if (now - firstRun < minDays * Duration.millisecondsPerDay) return false;

    final count = (m[_kPromptCount] as num?)?.toInt() ?? 0;
    if (count >= maxPrompts) return false;
    if (count > 0) {
      // 지수 백오프: 7일 → 14일 → 28일 …
      final cooldownDays = baseCooldownDays * (1 << (count - 1));
      final last = (m[_kLastPrompt] as num?)?.toInt() ?? 0;
      if (now - last < cooldownDays * Duration.millisecondsPerDay) {
        return false;
      }
    }
    return true;
  }

  /// 노출 기록 — 다이얼로그를 실제로 띄운 직후 호출.
  Future<void> recordPromptShown() async {
    final m = await _load();
    m[_kPromptCount] = ((m[_kPromptCount] as num?)?.toInt() ?? 0) + 1;
    m[_kLastPrompt] = DateTime.now().millisecondsSinceEpoch;
    await _save(m);
  }

  /// "다시 보지 않기".
  Future<void> dismissForever() async {
    final m = await _load();
    m[_kNever] = true;
    await _save(m);
  }

  /// 후기 작성 진입 또는 피드백 전송 완료 — 더 이상 조르지 않는다.
  Future<void> markDone() async {
    final m = await _load();
    m[_kDone] = true;
    await _save(m);
  }
}
