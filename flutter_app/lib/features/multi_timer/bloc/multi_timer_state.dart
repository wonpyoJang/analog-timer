import 'package:equatable/equatable.dart';
import '../models/countdown_timer.dart';

class MultiTimerState extends Equatable {
  final List<CountdownTimer> timers;

  /// 이 상태 방출에서 새로 완료된 타이머 id들 — 화면이 알림/햅틱/TTS 트리거에 사용.
  /// 상태 동등성에는 넣지 않는다(부수효과 신호일 뿐, 저장·비교 대상 아님).
  final List<String> justCompleted;

  /// 이 방출에서 루프 단계가 전환된 id 들 — 전환 통지(가벼움/회차 시작 강함) 트리거.
  final List<String> justLooped;

  const MultiTimerState({
    this.timers = const [],
    this.justCompleted = const [],
    this.justLooped = const [],
  });

  MultiTimerState copyWith({
    List<CountdownTimer>? timers,
    List<String> justCompleted = const [],
    List<String> justLooped = const [],
  }) => MultiTimerState(
    timers: timers ?? this.timers,
    justCompleted: justCompleted,
    justLooped: justLooped,
  );

  int get runningCount => timers.where((t) => t.running).length;

  @override
  List<Object?> get props => [timers];
}
