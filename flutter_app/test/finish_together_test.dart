import 'package:flutter_test/flutter_test.dart';
import 'package:analog_timer/features/multi_timer/finish_together.dart';
import 'package:analog_timer/features/multi_timer/models/countdown_timer.dart';
import 'package:analog_timer/features/multi_timer/bloc/multi_timer_bloc.dart';
import 'package:analog_timer/features/multi_timer/bloc/multi_timer_event.dart';

void main() {
  group('computeFinishTogether', () {
    test('가장 긴 것 지금, 짧은 것 지연 — 모두 같은 시각 완료', () {
      // 파스타 8분, 소스 5분, now=1000ms
      final p = computeFinishTogether([480000, 300000], 1000);
      expect(p.targetFinishMs, 1000 + 480000); // now + max
      expect(p.startAtMs[0], 1000); // 파스타 지금
      expect(p.startAtMs[1], 1000 + 180000); // 소스 3분 뒤
      // 둘 다 targetFinish 에 끝남
      expect(p.startAtMs[0] + 480000, p.targetFinishMs);
      expect(p.startAtMs[1] + 300000, p.targetFinishMs);
    });
  });

  group('finishTogetherDrift', () {
    CountdownTimer t({
      required String id,
      required int total,
      required int remain,
      required bool running,
      int startAt = 0,
      String gid = 'g',
      int target = 0,
    }) => CountdownTimer(
      id: id,
      name: id,
      totalMs: total,
      remainMs: remain,
      running: running,
      startAtMs: startAt,
      groupId: gid,
      targetFinishMs: target,
    );

    test('정렬 맞으면 null', () {
      final now = 1000000;
      final list = [
        t(
          id: 'a',
          total: 480000,
          remain: 300000,
          running: true,
        ), // 끝 now+300000
        t(
          id: 'b',
          total: 300000,
          remain: 300000,
          running: true,
        ), // 끝 now+300000
      ];
      expect(finishTogetherDrift(list, now), isNull);
    });

    test('한쪽이 늦으면 anchor·gap 반환', () {
      final now = 1000000;
      final list = [
        t(
          id: 'pasta',
          total: 480000,
          remain: 180000,
          running: true,
        ), // 끝 now+180000
        t(
          id: 'sauce',
          total: 300000,
          remain: 300000,
          running: true,
        ), // 끝 now+300000 (2분 늦음)
      ];
      final d = finishTogetherDrift(list, now);
      expect(d, isNotNull);
      expect(d!.lateId, 'sauce');
      expect(d.anchorId, 'pasta');
      expect(d.gapMs, 120000); // 2분
    });
  });

  group('bloc 동시 완료 플로우', () {
    test('추가 시 가장 긴 것 실행·짧은 것 waiting, 시작 시 waiting 해제', () async {
      final bloc = MultiTimerBloc();
      bloc.add(
        const MtAddFinishTogether([
          (name: '파스타', totalMs: 480000),
          (name: '소스', totalMs: 300000),
        ]),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final ts = bloc.state.timers;
      expect(ts.length, 2);
      final pasta = ts.firstWhere((x) => x.name == '파스타');
      final sauce = ts.firstWhere((x) => x.name == '소스');
      expect(pasta.running, true); // 가장 긴 것 지금 실행
      expect(pasta.waiting, false);
      expect(sauce.running, false); // 짧은 것 대기
      expect(sauce.waiting, true);
      expect(sauce.groupId, pasta.groupId); // 같은 그룹
      expect(sauce.targetFinishMs, greaterThan(0));

      // 소스 시작(확인=시작) → waiting 해제, 실행.
      bloc.add(MtStart(sauce.id));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final sauce2 = bloc.state.timers.firstWhere((x) => x.name == '소스');
      expect(sauce2.running, true);
      expect(sauce2.waiting, false);
      expect(sauce2.startAtMs, 0);
      await bloc.close();
    });

    test('시작 시각 도래 시 startArmed·justStartArmed 로 시작 알람(§4)', () async {
      // 갭 1초(2초-1초)로 짧게 → 대기 타이머가 곧 arming 되는지 확인.
      final bloc = MultiTimerBloc();
      final armed = <String>[];
      final sub = bloc.stream.listen((s) => armed.addAll(s.justStartArmed));
      bloc.add(
        const MtAddFinishTogether([
          (name: '긴것', totalMs: 2000),
          (name: '짧은것', totalMs: 1000),
        ]),
      );
      // 틱 250ms · 갭 1초 → 1.4초면 도래·arming.
      await Future<void>.delayed(const Duration(milliseconds: 1400));
      final shortOne = bloc.state.timers.firstWhere((x) => x.name == '짧은것');
      expect(shortOne.startArmed, true); // 시작 알람 켜짐(자동 시작 안 함)
      expect(shortOne.running, false); // 확인 전까지 실행 안 함
      expect(armed, contains(shortOne.id)); // 방출에 신호 실림
      await sub.cancel();
      await bloc.close();
    });
  });
}
