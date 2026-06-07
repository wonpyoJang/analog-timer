import 'package:equatable/equatable.dart';

class LapEntry extends Equatable {
  final int lapMs;
  final int totalMs;
  const LapEntry(this.lapMs, this.totalMs);
  @override
  List<Object?> get props => [lapMs, totalMs];
}

class StopwatchState extends Equatable {
  final bool running;
  final int elapsedMs;
  final List<LapEntry> laps;
  final int lapStartMs;
  final double? startAngleRadians; //분침 각도 at start

  const StopwatchState({
    required this.running,
    required this.elapsedMs,
    required this.laps,
    required this.lapStartMs,
    this.startAngleRadians,
  });

  factory StopwatchState.initial() => const StopwatchState(
    running: false,
    elapsedMs: 0,
    laps: [],
    lapStartMs: 0,
  );

  StopwatchState copyWith({
    bool? running,
    int? elapsedMs,
    List<LapEntry>? laps,
    int? lapStartMs,
    double? startAngleRadians,
    bool clearAngle = false,
  }) => StopwatchState(
    running: running ?? this.running,
    elapsedMs: elapsedMs ?? this.elapsedMs,
    laps: laps ?? this.laps,
    lapStartMs: lapStartMs ?? this.lapStartMs,
    startAngleRadians: clearAngle
        ? null
        : (startAngleRadians ?? this.startAngleRadians),
  );

  @override
  List<Object?> get props => [running, elapsedMs, laps.length, lapStartMs];
}
