import 'package:flutter_test/flutter_test.dart';
import 'package:analog_timer/features/stopwatch/bloc/stopwatch_bloc.dart';
import 'package:analog_timer/features/stopwatch/bloc/stopwatch_event.dart';

/// 스톱워치 bloc 자체의 시간 정확도 — 실제 티커로 3초 돌려 벽시계와 대조.
/// (티커는 now-lastTick 벽시계 차분이라 구조적으로 드리프트가 없어야 한다)
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('실제 티커 3초 — 벽시계 대비 오차 1% 미만', () async {
    final b = StopwatchBloc();
    final t0 = DateTime.now();
    b.add(StopwatchToggle());
    await Future<void>.delayed(const Duration(seconds: 3));
    final wallMs = DateTime.now().difference(t0).inMilliseconds;
    final swMs = b.state.elapsedMs;
    b.add(StopwatchToggle());
    await b.close();
    final driftPct = (swMs - wallMs) / wallMs * 100;
    // ignore: avoid_print
    print(
      'wall=${wallMs}ms sw=${swMs}ms drift=${driftPct.toStringAsFixed(3)}%',
    );
    expect(
      (swMs - wallMs).abs(),
      lessThan(wallMs * 0.01),
      reason: '스톱워치 드리프트 1% 초과: wall=$wallMs sw=$swMs',
    );
  });
}
