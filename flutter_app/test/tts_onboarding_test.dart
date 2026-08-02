import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:analog_timer/services/tts_service.dart';

// TTS 온보딩 판정 로직 — "3번째 세그먼트 전환 직후 1회만" 규칙 검증.
// (TtsService.supported 개념 없음 — 판정은 플랫폼 무관 순수 prefs 로직)
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('전환 1·2회차엔 안 뜨고 3회차에 뜬다', () async {
    final s = TtsService.instance;
    await s.init();
    expect(await s.shouldShowOnboarding(), false); // 1회
    expect(await s.shouldShowOnboarding(), false); // 2회
    expect(await s.shouldShowOnboarding(), true); // 3회 — 노출 타이밍
  });

  test('노출 마킹 후엔 다시 뜨지 않는다 (수락/무시 무관)', () async {
    final s = TtsService.instance;
    await s.init();
    for (var i = 0; i < 3; i++) {
      await s.shouldShowOnboarding();
    }
    await s.markOnboardingShown();
    expect(await s.shouldShowOnboarding(), false);
    expect(await s.shouldShowOnboarding(), false);
  });

  test('TTS 가 이미 켜져 있으면 온보딩 불필요', () async {
    SharedPreferences.setMockInitialValues({'tts_enabled': true});
    final s = TtsService.instance;
    await s.init();
    for (var i = 0; i < 5; i++) {
      expect(await s.shouldShowOnboarding(), false);
    }
  });
}
