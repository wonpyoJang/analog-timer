import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:analog_timer/services/review_prompt_service.dart';

/// 후기 유도 노출 주기 로직 검증 — 실제 파일 백엔드(Windows 경로와 동일)로 테스트.
/// TelemetryService.lastSessionCrashed 는 기본 false(미초기화)이므로
/// 크래시 가드 외의 게이트를 순수하게 검증할 수 있다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final svc = ReviewPromptService.instance;
  final now = DateTime.now().millisecondsSinceEpoch;
  const day = Duration.millisecondsPerDay;
  late Directory tmp;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('review_test_');
    ReviewPromptService.storageDirOverride = tmp.path;
  });
  tearDown(() {
    ReviewPromptService.storageDirOverride = null;
    try {
      tmp.deleteSync(recursive: true);
    } catch (_) {}
  });

  void seed({
    int sessions = 10,
    int? firstRunAgoDays = 10,
    int promptCount = 0,
    int? lastPromptAgoDays,
    bool never = false,
    bool done = false,
  }) {
    File(
      '${tmp.path}${Platform.pathSeparator}analog_timer_review.json',
    ).writeAsStringSync(
      jsonEncode({
        'review_sessions_count': sessions,
        if (firstRunAgoDays != null)
          'review_first_run_ms': now - firstRunAgoDays * day,
        'review_prompt_count': promptCount,
        if (lastPromptAgoDays != null)
          'review_last_prompt_ms': now - lastPromptAgoDays * day,
        'review_dismissed_forever': never,
        'review_done': done,
      }),
    );
  }

  test('모든 조건 충족 시 노출', () async {
    seed();
    expect(await svc.shouldPrompt(), true);
  });

  test('세션 수 미달(<5) 시 미노출', () async {
    seed(sessions: 4);
    expect(await svc.shouldPrompt(), false);
  });

  test('첫 실행 3일 미경과 시 미노출', () async {
    seed(firstRunAgoDays: 2);
    expect(await svc.shouldPrompt(), false);
  });

  test('1회 노출 후 7일 쿨다운: 6일 경과 미노출 / 8일 경과 노출', () async {
    seed(promptCount: 1, lastPromptAgoDays: 6);
    expect(await svc.shouldPrompt(), false);
    seed(promptCount: 1, lastPromptAgoDays: 8);
    expect(await svc.shouldPrompt(), true);
  });

  test('2회 노출 후 14일 백오프: 13일 미노출 / 15일 노출', () async {
    seed(promptCount: 2, lastPromptAgoDays: 13);
    expect(await svc.shouldPrompt(), false);
    seed(promptCount: 2, lastPromptAgoDays: 15);
    expect(await svc.shouldPrompt(), true);
  });

  test('최대 3회 노출 후 영구 미노출', () async {
    seed(promptCount: 3, lastPromptAgoDays: 365);
    expect(await svc.shouldPrompt(), false);
  });

  test('다시 보지 않기 → 미노출', () async {
    seed(never: true);
    expect(await svc.shouldPrompt(), false);
  });

  test('후기 작성/피드백 전송 완료 → 미노출', () async {
    seed(done: true);
    expect(await svc.shouldPrompt(), false);
  });

  test('recordPromptShown 이 count/시각 기록 + 즉시 재노출 차단', () async {
    seed();
    await svc.recordPromptShown();
    final saved =
        jsonDecode(
              File(
                '${tmp.path}${Platform.pathSeparator}analog_timer_review.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    expect(saved['review_prompt_count'], 1);
    expect(saved['review_last_prompt_ms'], isNotNull);
    expect(await svc.shouldPrompt(), false);
  });

  test('dismissForever/markDone 이 기존 상태 보존하며 플래그만 추가', () async {
    seed(promptCount: 2, lastPromptAgoDays: 20);
    await svc.dismissForever();
    final saved =
        jsonDecode(
              File(
                '${tmp.path}${Platform.pathSeparator}analog_timer_review.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    expect(saved['review_dismissed_forever'], true);
    expect(saved['review_prompt_count'], 2); // 기존 카운트 유지
    expect(await svc.shouldPrompt(), false);
  });
}
