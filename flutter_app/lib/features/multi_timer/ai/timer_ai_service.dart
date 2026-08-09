import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../time_parser.dart';
import 'timer_ai_provider.dart';

/// 시간 파싱 AI 폴백 서비스 — **규칙 파서가 우선, AI 는 실패분에만 옵션 폴백**.
///
/// 철칙(디자인 문서): AI 는 실행 경로 밖 / 규칙으로 되는 건 규칙으로 / AI 없이도
/// 도달 가능. 그래서 [enabled] 기본 OFF, provider 기본 Noop → 규칙 경로 100% 불변.
/// 플래그가 켜지고 provider 가 가용할 때만, [ParsedKind.unparsed] 조각에 한해 재해석.
class TimerAiService {
  TimerAiService._();
  static final TimerAiService instance = TimerAiService._();

  static const _kEnabled = 'ai_fallback_enabled';

  /// 사용자 토글(기본 OFF). 켜도 provider 미가용이면 아무 일도 없음.
  final ValueNotifier<bool> enabled = ValueNotifier<bool>(false);

  /// 실제 구현체는 기기 확보 후 교체(GeminiNanoAiProvider). 기본 Noop.
  TimerAiProvider provider = const NoopAiProvider();

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    enabled.value = p.getBool(_kEnabled) ?? false;
  }

  Future<void> setEnabled(bool v) async {
    enabled.value = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kEnabled, v);
  }

  /// 규칙 파서 결과에 AI 폴백을 얹는다. OFF·미지원·unparsed 없음이면 입력 그대로.
  /// 규칙으로 해석된 항목(parsed/preset)은 절대 건드리지 않는다.
  Future<List<ParsedTimer>> enhance(
    List<ParsedTimer> parsed, {
    List<PresetRef> presets = const [],
  }) async {
    if (!enabled.value) return parsed;
    final hasUnresolved = parsed.any((t) => t.kind == ParsedKind.unparsed);
    if (!hasUnresolved) return parsed;
    if (!await provider.isAvailable()) return parsed;

    final unresolved = [
      for (final t in parsed)
        if (t.kind == ParsedKind.unparsed) t,
    ];
    List<ParsedTimer> resolved;
    try {
      resolved = await provider.resolve(unresolved, presets: presets);
    } catch (_) {
      return parsed; // 실패는 조용히 규칙 결과 유지(사일런트 폴백 아님 — 원본 보존).
    }
    // unparsed 자리만 순서대로 치환, 나머지는 그대로.
    var i = 0;
    return [
      for (final t in parsed)
        if (t.kind == ParsedKind.unparsed && i < resolved.length)
          resolved[i++]
        else
          t,
    ];
  }
}
