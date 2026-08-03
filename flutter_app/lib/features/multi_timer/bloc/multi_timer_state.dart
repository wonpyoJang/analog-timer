import 'package:equatable/equatable.dart';
import '../models/countdown_timer.dart';

class MultiTimerState extends Equatable {
  final List<CountdownTimer> timers;

  /// 이 상태 방출에서 새로 완료된 타이머 id들 — 화면이 알림/햅틱/TTS 트리거에 사용.
  /// 상태 동등성에는 넣지 않는다(부수효과 신호일 뿐, 저장·비교 대상 아님).
  final List<String> justCompleted;

  const MultiTimerState({
    this.timers = const [],
    this.justCompleted = const [],
  });

  MultiTimerState copyWith({
    List<CountdownTimer>? timers,
    List<String> justCompleted = const [],
  }) => MultiTimerState(
    timers: timers ?? this.timers,
    justCompleted: justCompleted,
  );

  int get runningCount => timers.where((t) => t.running).length;

  @override
  List<Object?> get props => [timers];
}
