import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:analog_timer/features/timer/bloc/timer_bloc.dart';
import 'package:analog_timer/features/timer/bloc/timer_event.dart';
import 'package:analog_timer/features/timer/bloc/timer_state.dart';
import 'package:analog_timer/features/timer/models/segment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Segment seg(String name, int minutes) =>
      Segment(name: name, minutes: minutes, color: const Color(0xFF00FF00));

  group('TimerRestore 로그 처리', () {
    Future<TimerBloc> blocWithLog() async {
      final bloc = TimerBloc();
      bloc.add(TimerSegmentsReplaced([seg('A', 5)]));
      await Future<void>.delayed(Duration.zero);
      bloc.add(TimerStart()); // start 로그 1개 생성
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.log, isNotEmpty);
      return bloc;
    }

    test('기본(앱 시작 복원): 로그를 비운다', () async {
      final bloc = await blocWithLog();
      bloc.add(
        TimerRestore(
          segments: [seg('B', 10)],
          currentSeg: 0,
          segRemainMs: 600000,
          status: TimerStatus.paused,
          loop: false,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.log, isEmpty);
      await bloc.close();
    });

    test('preserveLog: sync 원격 적용은 오늘 로그를 보존한다', () async {
      final bloc = await blocWithLog();
      final before = bloc.state.log.length;
      bloc.add(
        TimerRestore(
          segments: [seg('B', 10)],
          currentSeg: 0,
          segRemainMs: 600000,
          status: TimerStatus.paused,
          loop: false,
          preserveLog: true,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.log.length, before);
      await bloc.close();
    });
  });
}
