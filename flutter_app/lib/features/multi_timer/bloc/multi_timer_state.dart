import 'package:equatable/equatable.dart';
import '../models/countdown_timer.dart';

class MultiTimerState extends Equatable {
  final List<CountdownTimer> timers;

  /// 이 상태 방출에서 새로 완료된 타이머 id들 — 화면이 알림/햅틱/TTS 트리거에 사용.
  /// 상태 동등성에는 넣지 않는다(부수효과 신호일 뿐, 저장·비교 대상 아님).
  final List<String> justCompleted;

  /// 이 방출에서 루프 단계가 전환된 id 들 — 전환 통지(가벼움/회차 시작 강함) 트리거.
  final List<String> justLooped;

  /// 이 방출에서 시작 시각이 도래해 "시작 알람"이 켜진 id 들(동시 완료 §4).
  final List<String> justStartArmed;

  const MultiTimerState({
    this.timers = const [],
    this.justCompleted = const [],
    this.justLooped = const [],
    this.justStartArmed = const [],
  });

  MultiTimerState copyWith({
    List<CountdownTimer>? timers,
    List<String> justCompleted = const [],
    List<String> justLooped = const [],
    List<String> justStartArmed = const [],
  }) => MultiTimerState(
    timers: timers ?? this.timers,
    justCompleted: justCompleted,
    justLooped: justLooped,
    justStartArmed: justStartArmed,
  );

  int get runningCount => timers.where((t) => t.running).length;

  /// 아직 시작 안 한 동시 완료 대기 타이머 수 — 틱 유지 조건(도래 시 arming).
  int get waitingCount => timers.where((t) => t.waiting).length;

  @override
  List<Object?> get props => [timers];
}
