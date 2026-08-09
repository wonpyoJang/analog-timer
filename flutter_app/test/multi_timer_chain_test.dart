import 'package:flutter_test/flutter_test.dart';
import 'package:analog_timer/features/multi_timer/bloc/multi_timer_bloc.dart';
import 'package:analog_timer/features/multi_timer/bloc/multi_timer_event.dart';

/// ack 게이트 순차 체인(조리법) — 한 단계를 확인(MtAck)하면 다음이 시작된다.
void main() {
  test('체인: 첫 단계만 실행, 확인 시 다음 시작', () async {
    final bloc = MultiTimerBloc();
    const cid = 'chainTest';
    bloc.add(MtAdd('면', 270000, autoStart: true, chainId: cid, chainIndex: 0));
    bloc.add(
      MtAdd('계란', 360000, autoStart: false, chainId: cid, chainIndex: 1),
    );
    bloc.add(
      MtAdd('소스', 300000, autoStart: false, chainId: cid, chainIndex: 2),
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final t = bloc.state.timers;
    expect(t.length, 3);
    // 첫 단계만 running, 나머지 대기.
    expect(t[0].running, true);
    expect(t[1].running, false);
    expect(t[2].running, false);

    // 1단계 확인 → 2단계 시작, 3단계는 여전히 대기.
    bloc.add(MtAck(t[0].id));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state.timers[0].acked, true);
    expect(bloc.state.timers[1].running, true);
    expect(bloc.state.timers[2].running, false);

    // 2단계 확인 → 3단계 시작.
    bloc.add(MtAck(bloc.state.timers[1].id));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state.timers[2].running, true);

    await bloc.close();
  });

  test('체인 아님(chainId null): 확인해도 다른 타이머 안 켜짐', () async {
    final bloc = MultiTimerBloc();
    bloc.add(MtAdd('A', 60000, autoStart: true));
    bloc.add(MtAdd('B', 60000, autoStart: false));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final t = bloc.state.timers;
    bloc.add(MtAck(t[0].id));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state.timers[1].running, false); // 체인 아니므로 그대로
    await bloc.close();
  });
}
