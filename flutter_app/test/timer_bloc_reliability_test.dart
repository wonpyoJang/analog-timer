import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:analog_timer/features/timer/bloc/timer_bloc.dart';
import 'package:analog_timer/features/timer/bloc/timer_event.dart';
import 'package:analog_timer/features/timer/bloc/timer_state.dart';
import 'package:analog_timer/features/timer/models/segment.dart';

/// 타이머 신뢰성 회귀 테스트 — 감사에서 확정·수정한 결함들이 되살아나지 않게 고정.
/// TimerTick 을 직접 주입해 실제 티커 없이 결정론적으로 검증한다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  List<Segment> segs3() => [
        Segment(name: 'A', minutes: 5, color: const Color(0xFFE07A52)),
        Segment(name: 'B', minutes: 5, color: const Color(0xFF52B0E0)),
        Segment(name: 'C', minutes: 5, color: const Color(0xFF2EA84A)),
      ];

  Future<TimerBloc> startedBloc({bool loop = false}) async {
    final b = TimerBloc();
    b.add(TimerSegmentsReplaced(segs3()));
    if (loop) b.add(const TimerLoopToggled(true));
    b.add(TimerStart());
    await Future<void>.delayed(Duration.zero);
    return b;
  }

  test('절전 이월 — 한 tick 이 여러 세그먼트를 관통해도 정확히 따라잡는다', () async {
    final b = await startedBloc();
    // 5분 세그 A 진행 중 12분 경과(절전) → A(5)+B(5) 소비, C 에서 2분 경과
    b.add(const TimerTick(12 * 60 * 1000));
    await Future<void>.delayed(Duration.zero);
    expect(b.state.currentSeg, 2); // C
    expect(b.state.segRemainMs, 3 * 60 * 1000); // C 잔여 3분
    expect(b.state.status, TimerStatus.running);
    await b.close();
  });

  test('절전 이월 + loop — 전체 사이클을 넘겨도 랩어라운드', () async {
    final b = await startedBloc(loop: true);
    // 총 15분 사이클, 17분 경과 → 1루프 + A 에서 2분
    b.add(const TimerTick(17 * 60 * 1000));
    await Future<void>.delayed(Duration.zero);
    expect(b.state.currentSeg, 0);
    expect(b.state.segRemainMs, 3 * 60 * 1000);
    expect(b.state.loopCount, 1);
    await b.close();
  });

  test('비-loop 완주 — done 상태 + allDone 로그', () async {
    final b = await startedBloc();
    b.add(const TimerTick(16 * 60 * 1000));
    await Future<void>.delayed(Duration.zero);
    expect(b.state.status, TimerStatus.done);
    expect(b.state.log.any((e) => e.type == TimerLogType.allDone), true);
    await b.close();
  });

  test('[회귀] loop-wrap Next: 일시정지 후 Next 로 루프를 감아도 타이머가 흐른다',
      () async {
    final b = await startedBloc(loop: true);
    // 마지막 세그(C)로 이동
    b.add(TimerNext());
    b.add(TimerNext());
    b.add(TimerPause());
    await Future<void>.delayed(Duration.zero);
    expect(b.state.currentSeg, 2);
    expect(b.state.status, TimerStatus.paused);
    // 일시정지 상태에서 Next → 루프 랩 → running + 티커 재기동돼야 함
    b.add(TimerNext());
    await Future<void>.delayed(Duration.zero);
    expect(b.state.currentSeg, 0);
    expect(b.state.status, TimerStatus.running);
    expect(b.state.loopCount, 1);
    // 티커가 실제로 돌면 ~50ms 안에 segRemainMs 가 줄어든다 (dead-code 회귀 감지)
    final before = b.state.segRemainMs;
    await Future<void>.delayed(const Duration(milliseconds: 120));
    expect(b.state.segRemainMs, lessThan(before),
        reason: '티커 미기동 — loop-wrap _startTicker dead code 회귀');
    await b.close();
  });

  test('[회귀] 세그먼트 삭제: 앞 세그 삭제 시 진행 인덱스 당김', () async {
    final b = await startedBloc();
    b.add(TimerNext()); // B 진행(currentSeg=1)
    await Future<void>.delayed(Duration.zero);
    b.add(const TimerSegmentRemoved(0)); // A 삭제
    await Future<void>.delayed(Duration.zero);
    expect(b.state.currentSeg, 0); // 여전히 B
    expect(b.state.segments[b.state.currentSeg].name, 'B');
    await b.close();
  });

  test('[회귀] 세그먼트 삭제: 진행 중 세그 삭제 시 다음 세그를 처음부터', () async {
    final b = await startedBloc();
    b.add(TimerNext()); // B 진행
    await Future<void>.delayed(Duration.zero);
    b.add(const TimerSegmentRemoved(1)); // B(진행 중) 삭제
    await Future<void>.delayed(Duration.zero);
    expect(b.state.segments[b.state.currentSeg].name, 'C');
    expect(b.state.segRemainMs, 5 * 60 * 1000); // C 전체 시간으로 리셋
    await b.close();
  });

  test('[회귀] logSeq 단조 증가 — 300캡 이후에도 신규 로그 감지 가능', () async {
    final b = await startedBloc(loop: true);
    var lastSeq = b.state.logSeq;
    // 루프를 수백 번 감아 로그 캡(300) 을 한참 초과시킨다
    for (var i = 0; i < 200; i++) {
      b.add(const TimerTick(15 * 60 * 1000)); // 매 tick 1루프
    }
    await Future<void>.delayed(Duration.zero);
    expect(b.state.log.length, lessThanOrEqualTo(300)); // 캡 동작
    expect(b.state.logSeq, greaterThan(lastSeq)); // seq 는 계속 증가
    lastSeq = b.state.logSeq;
    // 캡 도달 상태에서 새 이벤트 → length 는 고정이어도 seq 는 반드시 증가
    b.add(const TimerTick(15 * 60 * 1000));
    await Future<void>.delayed(Duration.zero);
    expect(b.state.log.length, 300);
    expect(b.state.logSeq, greaterThan(lastSeq),
        reason: '캡 도달 후 신규 로그 감지 불가 — length 기반 diff 회귀');
    await b.close();
  });

  test('시계 역행 방어 — 음수/0 tick 은 상태를 바꾸지 않는다', () async {
    final b = await startedBloc();
    final before = b.state.segRemainMs;
    // _startTicker 는 음수 elapsed 를 걸러 add 자체를 안 하지만,
    // 방어적으로 0/음수가 들어와도 잔여시간이 늘어나면 안 된다.
    b.add(const TimerTick(0));
    b.add(const TimerTick(-5000));
    await Future<void>.delayed(Duration.zero);
    expect(b.state.segRemainMs, lessThanOrEqualTo(before));
    expect(b.state.segRemainMs, greaterThan(before - 6000),
        reason: '음수 tick 으로 시간이 거꾸로/과소비되면 안 됨');
    await b.close();
  });

  test('TimerRestore — 로그는 비우되 logSeq 는 유지(단조성 보존)', () async {
    final b = await startedBloc();
    b.add(TimerNext());
    await Future<void>.delayed(Duration.zero);
    final seqBefore = b.state.logSeq;
    expect(seqBefore, greaterThan(0));
    b.add(TimerRestore(
      segments: segs3(),
      currentSeg: 1,
      segRemainMs: 60 * 1000,
      status: TimerStatus.paused,
      loop: false,
    ));
    await Future<void>.delayed(Duration.zero);
    expect(b.state.log, isEmpty);
    expect(b.state.logSeq, seqBefore); // 감소하지 않음
    expect(b.state.currentSeg, 1);
    expect(b.state.segRemainMs, 60 * 1000);
    await b.close();
  });
}
