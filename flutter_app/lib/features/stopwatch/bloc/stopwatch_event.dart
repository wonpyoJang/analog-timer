import 'package:equatable/equatable.dart';

abstract class StopwatchEvent extends Equatable {
  const StopwatchEvent();
  @override
  List<Object?> get props => [];
}

class StopwatchToggle extends StopwatchEvent {
  const StopwatchToggle();
}

class StopwatchLap extends StopwatchEvent {
  const StopwatchLap();
}

class StopwatchReset extends StopwatchEvent {
  const StopwatchReset();
}

class StopwatchTick extends StopwatchEvent {
  final int elapsedMs;
  const StopwatchTick(this.elapsedMs);
  @override
  List<Object?> get props => [elapsedMs];
}

class StopwatchRestore extends StopwatchEvent {
  final int elapsedMs;
  final bool running;
  final double? startAngleRadians;
  const StopwatchRestore({
    required this.elapsedMs,
    required this.running,
    this.startAngleRadians,
  });
  @override
  List<Object?> get props => [elapsedMs, running];
}
