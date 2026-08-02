import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:analog_timer/features/timer/bloc/timer_bloc.dart';
import 'package:analog_timer/features/timer/bloc/timer_event.dart';
import 'package:analog_timer/features/timer/bloc/timer_state.dart';
import 'package:analog_timer/features/timer/models/segment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Segment seg(String name, int minutes) =>
      Segment(name: name, minutes: minutes, color: const Color(0xFFFF0000));

  group('TimerSegmentRemoved 보정', () {
    test('실행 중 현재 세그먼트 삭제 → 다음 세그먼트 길이로 잔여시간 클램프', () async {
      final bloc = TimerBloc();
      bloc.add(TimerSegmentsReplaced([seg('A', 30), seg('B', 5)]));
      await Future<void>.delayed(Duration.zero);
      bloc.add(TimerStart());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.status, TimerStatus.running);
      expect(bloc.state.currentSeg, 0);

      bloc.add(const TimerSegmentRemoved(0));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.segments.length, 1);
      expect(bloc.state.segments[0].name, 'B');
      expect(bloc.state.currentSeg, 0);
      // 핵심: 잔여시간이 B(5분)로 클램프돼야 함 — A의 30분이 남으면 결함
      expect(bloc.state.segRemainMs, 5 * 60 * 1000);
      await bloc.close();
    });

    test('일시정지 중 현재 세그먼트 삭제도 동일 보정', () async {
      final bloc = TimerBloc();
      bloc.add(TimerSegmentsReplaced([seg('A', 30), seg('B', 5)]));
      await Future<void>.delayed(Duration.zero);
      bloc.add(TimerStart());
      await Future<void>.delayed(Duration.zero);
      bloc.add(TimerPause());
      await Future<void>.delayed(Duration.zero);

      bloc.add(const TimerSegmentRemoved(0));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.segRemainMs, 5 * 60 * 1000);
      await bloc.close();
    });

    test('앞 세그먼트 삭제 시 인덱스만 당기고 잔여시간 유지', () async {
      final bloc = TimerBloc();
      bloc.add(TimerSegmentsReplaced([seg('A', 5), seg('B', 30)]));
      await Future<void>.delayed(Duration.zero);
      bloc.add(TimerStart());
      await Future<void>.delayed(Duration.zero);
      bloc.add(TimerNext()); // B로 이동
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.currentSeg, 1);
      final remainBefore = bloc.state.segRemainMs;

      bloc.add(const TimerSegmentRemoved(0)); // 앞(A) 삭제
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.currentSeg, 0);
      expect(bloc.state.segments[0].name, 'B');
      // 잔여시간은 티커 진행분 오차(2s)만 허용
      expect((bloc.state.segRemainMs - remainBefore).abs() < 2000, true);
      await bloc.close();
    });

    test('실행 중 마지막 세그먼트 삭제 + loop OFF → done (되감김 금지)', () async {
      final bloc = TimerBloc();
      bloc.add(TimerSegmentsReplaced([seg('A', 5), seg('B', 30)]));
      await Future<void>.delayed(Duration.zero);
      bloc.add(TimerStart());
      await Future<void>.delayed(Duration.zero);
      bloc.add(TimerNext()); // B(마지막)로 이동
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.currentSeg, 1);

      bloc.add(const TimerSegmentRemoved(1)); // 실행 중인 마지막 삭제
      await Future<void>.delayed(Duration.zero);

      // 이미 완료한 A 로 되감겨 재실행되면 안 된다 — 완료 처리돼야 함
      expect(bloc.state.status, TimerStatus.done);
      expect(bloc.state.segRemainMs, 0);
      await bloc.close();
    });

    test('실행 중 마지막 세그먼트 삭제 + loop ON → 처음부터 랩', () async {
      final bloc = TimerBloc();
      bloc.add(TimerSegmentsReplaced([seg('A', 5), seg('B', 30)]));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const TimerLoopToggled(true));
      await Future<void>.delayed(Duration.zero);
      bloc.add(TimerStart());
      await Future<void>.delayed(Duration.zero);
      bloc.add(TimerNext());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.currentSeg, 1);

      bloc.add(const TimerSegmentRemoved(1));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.status, TimerStatus.running);
      expect(bloc.state.currentSeg, 0);
      expect(bloc.state.segRemainMs, 5 * 60 * 1000);
      await bloc.close();
    });

    test('범위 밖 인덱스는 무시 (stale index 가드)', () async {
      final bloc = TimerBloc();
      bloc.add(TimerSegmentsReplaced([seg('A', 5), seg('B', 5)]));
      await Future<void>.delayed(Duration.zero);

      bloc.add(const TimerSegmentRemoved(5)); // stale
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.segments.length, 2); // RangeError 없이 무시돼야 함
      await bloc.close();
    });
  });
}
