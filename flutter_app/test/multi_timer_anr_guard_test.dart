import 'package:flutter_test/flutter_test.dart';
import 'package:analog_timer/features/multi_timer/bloc/multi_timer_bloc.dart';
import 'package:analog_timer/features/multi_timer/bloc/multi_timer_event.dart';
import 'package:analog_timer/features/multi_timer/models/countdown_timer.dart';

/// [ANR-회귀] 멀티 타이머 티커가 UI를 과도하게 흔들지 않는지 고정한다.
///
/// 배경: 하단 탭(IndexedStack) 도입 후, 러닝 타이머 티커가 16ms(60fps)로 돌며
/// 리스트를 매 프레임 재빌드해 메인스레드를 포화 → 오버레이 토글/드래그 입력이
/// 굶어 "Input dispatching timed out" ANR 이 났다(PR #60). 티커를 250ms 로 완화해
/// 수정했다. 이 테스트는 누군가 다시 촘촘한 티커(예: 16ms)를 넣으면 실패한다.
///
/// 실제 티커를 벽시계로 돌려 emit 횟수를 세는 행위 기반 검증
/// (timer_bloc_reliability_test.dart:74-82 의 "실제 티커 1회 검증" 패턴과 동형).
void main() {
  test('[ANR-회귀] 러닝 타이머 티커는 1초에 UI 를 10회 넘게 갱신하지 않는다 (16ms 재도입 감지)', () async {
    final b = MultiTimerBloc();
    var emits = 0;
    final sub = b.stream.listen((_) => emits++);

    // 10분짜리 러닝 타이머 → 측정 창(1초) 동안 완료되지 않아 티커가 계속 돈다.
    b.add(
      MtRestore([
        CountdownTimer(id: 'a', name: 'A', totalMs: 600000, running: true),
      ]),
    );
    // MtRestore 처리 + 티커 기동 대기 후 카운터 리셋.
    await Future<void>.delayed(const Duration(milliseconds: 60));
    emits = 0;

    await Future<void>.delayed(const Duration(milliseconds: 1000));
    await sub.cancel();
    await b.close();

    // 250ms 티커면 ~4회. 16ms 로 회귀하면 ~60회 → 상한 10 으로 확실히 실패.
    expect(
      emits,
      lessThanOrEqualTo(10),
      reason:
          '티커가 1초에 10회 넘게 emit = 촘촘한 티커(예 16ms) 재도입. 리스트가 60fps 재빌드돼 입력 굶김/ANR 위험.',
    );
    // 티커가 실제로 돌아 카운트다운했는지(간격이 과도하게 길어지지 않았는지)도 확인.
    expect(
      emits,
      greaterThanOrEqualTo(1),
      reason: '측정 창 동안 티커가 한 번도 안 돌았다 — 티커 기동 회귀 가능성.',
    );
  });
}
