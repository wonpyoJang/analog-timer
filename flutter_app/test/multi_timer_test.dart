import 'package:flutter_test/flutter_test.dart';
import 'package:analog_timer/features/multi_timer/bloc/multi_timer_bloc.dart';
import 'package:analog_timer/features/multi_timer/bloc/multi_timer_event.dart';
import 'package:analog_timer/features/multi_timer/models/countdown_timer.dart';

void main() {
  group('MultiTimerBloc', () {
    test('MtTick — running 타이머만 감소, 정지 타이머 불변', () async {
      final b = MultiTimerBloc();
      b.add(
        MtRestore([
          CountdownTimer(id: 'a', name: 'A', totalMs: 10000, running: true),
          CountdownTimer(id: 'b', name: 'B', totalMs: 10000, running: false),
        ]),
      );
      await Future<void>.delayed(Duration.zero);
      b.add(const MtTick(3000));
      await Future<void>.delayed(Duration.zero);
      final ts = b.state.timers;
      expect(ts.firstWhere((t) => t.id == 'a').remainMs, 7000); // 감소
      expect(ts.firstWhere((t) => t.id == 'b').remainMs, 10000); // 불변
      await b.close();
    });

    test('MtTick — 서로 다른 지속시간이 독립적으로 완료', () async {
      final b = MultiTimerBloc();
      b.add(
        MtRestore([
          CountdownTimer(id: 'ramen', name: '라면', totalMs: 3000, running: true),
          CountdownTimer(id: 'egg', name: '계란', totalMs: 7000, running: true),
        ]),
      );
      await Future<void>.delayed(Duration.zero);
      b.add(const MtTick(3000)); // 라면만 완료
      await Future<void>.delayed(Duration.zero);
      expect(b.state.timers.firstWhere((t) => t.id == 'ramen').done, isTrue);
      expect(b.state.timers.firstWhere((t) => t.id == 'ramen').remainMs, 0);
      expect(b.state.timers.firstWhere((t) => t.id == 'egg').done, isFalse);
      expect(b.state.timers.firstWhere((t) => t.id == 'egg').remainMs, 4000);
      await b.close();
    });

    test('절전 복귀 — 큰 elapsed 단발로 여러 개 동시 완료', () async {
      final b = MultiTimerBloc();
      b.add(
        MtRestore([
          CountdownTimer(id: 'a', name: 'A', totalMs: 3000, running: true),
          CountdownTimer(id: 'b', name: 'B', totalMs: 5000, running: true),
        ]),
      );
      await Future<void>.delayed(Duration.zero);
      b.add(const MtTick(60000)); // 1분 경과 — 둘 다 완료
      await Future<void>.delayed(Duration.zero);
      expect(b.state.timers.every((t) => t.done), isTrue);
      expect(b.state.justCompleted.length, 2);
      await b.close();
    });

    test('MtTick — 역행(음수/0) 방어', () async {
      final b = MultiTimerBloc();
      b.add(
        MtRestore([
          CountdownTimer(id: 'a', name: 'A', totalMs: 5000, running: true),
        ]),
      );
      await Future<void>.delayed(Duration.zero);
      b.add(const MtTick(0));
      b.add(const MtTick(-100));
      await Future<void>.delayed(Duration.zero);
      expect(b.state.timers.first.remainMs, 5000);
      await b.close();
    });

    test('완료 타이머 재시작 — 처음부터', () async {
      final b = MultiTimerBloc();
      b.add(
        MtRestore([
          CountdownTimer(
            id: 'a',
            name: 'A',
            totalMs: 3000,
            remainMs: 0,
            done: true,
          ),
        ]),
      );
      await Future<void>.delayed(Duration.zero);
      b.add(const MtStart('a'));
      await Future<void>.delayed(Duration.zero);
      final t = b.state.timers.first;
      expect(t.running, isTrue);
      expect(t.done, isFalse);
      expect(t.remainMs, 3000);
      await b.close();
    });

    test('MtReset — 정지 + 처음 값 복귀', () async {
      final b = MultiTimerBloc();
      b.add(
        MtRestore([
          CountdownTimer(
            id: 'a',
            name: 'A',
            totalMs: 5000,
            remainMs: 1200,
            running: true,
          ),
        ]),
      );
      await Future<void>.delayed(Duration.zero);
      b.add(const MtReset('a'));
      await Future<void>.delayed(Duration.zero);
      final t = b.state.timers.first;
      expect(t.running, isFalse);
      expect(t.remainMs, 5000);
      await b.close();
    });
  });

  test('CountdownTimer JSON 왕복 — 초 단위 보존', () {
    final t = CountdownTimer(
      id: 'x',
      name: '라면',
      totalMs: 200000,
      remainMs: 95500,
      running: true,
    );
    final back = CountdownTimer.fromJson(t.toJson());
    expect(back.totalMs, 200000);
    expect(back.remainMs, 95500); // 밀리초 → 초 단위 손실 없음
    expect(back.name, '라면');
    expect(back.running, isTrue);
  });
}
