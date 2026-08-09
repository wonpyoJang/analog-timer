import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:analog_timer/features/multi_timer/time_parser.dart';
import 'package:analog_timer/features/multi_timer/ai/timer_ai_provider.dart';
import 'package:analog_timer/features/multi_timer/ai/timer_ai_service.dart';

ParsedTimer _unparsed(String src) =>
    ParsedTimer(name: src, totalMs: 0, kind: ParsedKind.unparsed, source: src);
ParsedTimer _parsed(String name, int ms) =>
    ParsedTimer(name: name, totalMs: ms, kind: ParsedKind.parsed, source: name);

/// 항상 가용하고 unparsed 를 60초짜리 parsed 로 바꾸는 테스트 더블.
class _FakeProvider implements TimerAiProvider {
  bool available;
  _FakeProvider(this.available);
  @override
  Future<bool> isAvailable() async => available;
  @override
  Future<List<ParsedTimer>> resolve(
    List<ParsedTimer> unresolved, {
    List<PresetRef> presets = const [],
  }) async => [for (final t in unresolved) _parsed(t.name, 60000)];
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // 각 테스트는 provider/flag 를 명시적으로 세팅한다.
    TimerAiService.instance.provider = const NoopAiProvider();
  });

  test('기본 플래그 OFF — enhance 는 입력을 그대로 반환(규칙 경로 불변)', () async {
    await TimerAiService.instance.load();
    expect(TimerAiService.instance.enabled.value, false);
    final input = [_parsed('계란', 420000), _unparsed('음..')];
    final out = await TimerAiService.instance.enhance(input);
    expect(out, same(input)); // 손 안 댐
  });

  test('NoopAiProvider — 항상 미지원', () async {
    expect(await const NoopAiProvider().isAvailable(), false);
  });

  test('플래그 ON 이어도 provider 미가용이면 그대로', () async {
    await TimerAiService.instance.setEnabled(true);
    TimerAiService.instance.provider = _FakeProvider(false);
    final input = [_unparsed('뭐라고')];
    final out = await TimerAiService.instance.enhance(input);
    expect(out, same(input));
  });

  test('플래그 ON + unparsed 없음 → 그대로(가용 provider 도 호출 안 함)', () async {
    await TimerAiService.instance.setEnabled(true);
    TimerAiService.instance.provider = _FakeProvider(true);
    final input = [_parsed('계란', 420000)];
    final out = await TimerAiService.instance.enhance(input);
    expect(out, same(input));
  });

  test('플래그 ON + 가용 + unparsed 있음 → 그 자리만 AI 결과로 치환', () async {
    await TimerAiService.instance.setEnabled(true);
    TimerAiService.instance.provider = _FakeProvider(true);
    final input = [_parsed('파스타', 480000), _unparsed('소스 대충')];
    final out = await TimerAiService.instance.enhance(input);
    expect(out.length, 2);
    expect(out[0].kind, ParsedKind.parsed); // 규칙 결과 보존
    expect(out[0].totalMs, 480000);
    expect(out[1].kind, ParsedKind.parsed); // unparsed → AI 로 해석됨
    expect(out[1].totalMs, 60000);
    // 원본 리스트는 건드리지 않음(새 리스트 반환).
    expect(input[1].kind, ParsedKind.unparsed);
  });

  test('setEnabled 는 영속화된다', () async {
    await TimerAiService.instance.setEnabled(true);
    final p = await SharedPreferences.getInstance();
    expect(p.getBool('ai_fallback_enabled'), true);
  });
}
