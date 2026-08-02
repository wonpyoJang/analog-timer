import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:analog_timer/services/shortcut_hint_service.dart';

// 단축키 맥락 힌트 — "액션별 3번째 클릭에 1회만" 규칙 검증.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ShortcutHintService.instance.onHint = null;
  });

  test('3번째 클릭에서 딱 1회 발화, 이후 재발화 없음', () async {
    final fired = <String>[];
    final s = ShortcutHintService.instance;
    s.onHint = fired.add;
    for (var i = 0; i < 6; i++) {
      await s.buttonPressed('timer_toggle');
    }
    expect(fired, ['timer_toggle']); // 정확히 1회
  });

  test('액션별 독립 카운트', () async {
    final fired = <String>[];
    final s = ShortcutHintService.instance;
    s.onHint = fired.add;
    await s.buttonPressed('timer_toggle');
    await s.buttonPressed('timer_toggle');
    await s.buttonPressed('sw_lap');
    expect(fired, isEmpty); // 각 2회·1회 — 아직 임계 미달
    await s.buttonPressed('timer_toggle');
    expect(fired, ['timer_toggle']);
    await s.buttonPressed('sw_lap');
    await s.buttonPressed('sw_lap');
    expect(fired, ['timer_toggle', 'sw_lap']);
  });
}
