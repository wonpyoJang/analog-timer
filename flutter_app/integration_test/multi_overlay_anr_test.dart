import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:analog_timer/main.dart' as app;

/// [ANR] 하단 탭 churn 스모크 — 실기기/에뮬레이터에서 앱을 실제 구동해 탭을 빠르게
/// 오가도 메인 아이솔레이트가 wedge 되지 않는지(pumpAndSettle 성공) 확인한다.
///
/// 한계(중요): 네이티브 오버레이 pill 은 WindowManager 창(위젯 트리 밖)이라
/// WidgetTester 로 만질 수 없고, 진짜 ANR(FGS 데드라인·Input dispatching)은 Dart 가
/// 직접 관측 못 한다. 그 판정은 tool/anr_scan.sh(logcat 스캔)가 담당한다.
/// 이 테스트는 탭 전환/IndexedStack·HomeScreen active 게이트가 앱을 멈추게 하지
/// 않는지의 결정론적 스모크 게이트다.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('탭 churn 후에도 앱이 응답한다 (메인 아이솔레이트 wedge 없음)', (tester) async {
    app.main(const <String>[]);
    // 스플래시(≈800ms + 페이드) 통과.
    await tester.pumpAndSettle(const Duration(seconds: 8));

    // 하단 탭 라벨(en): Timer / Multi / Settings. 'Multi' 는 나비게이션에만 등장.
    final multiTab = find.text('Multi');
    final timerTab = find.text('Timer');
    expect(multiTab, findsWidgets, reason: '하단 탭이 렌더되지 않음 — 셸 진입 실패');

    // 탭을 빠르게 오가며 IndexedStack·active 게이트를 흔든다.
    for (var i = 0; i < 8; i++) {
      await tester.tap(multiTab.last);
      await tester.pump(const Duration(milliseconds: 120));
      await tester.tap(timerTab.last);
      await tester.pump(const Duration(milliseconds: 120));
    }

    // churn 직후 정착 — 여기서 타임아웃하면 메인 아이솔레이트가 굶은 것.
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // 멀티 탭이 정상 렌더되는지로 앱 생존 확인(제목 또는 동명 타이머로 여러 개 매칭 가능).
    await tester.tap(multiTab.last);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Multiple timers'), findsWidgets);
  });
}
