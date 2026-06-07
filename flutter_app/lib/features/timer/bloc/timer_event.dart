import 'package:equatable/equatable.dart';
import '../models/segment.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();
  @override
  List<Object?> get props => [];
}

class TimerStart extends TimerEvent {
  const TimerStart();
}

class TimerPause extends TimerEvent {
  const TimerPause();
}

class TimerReset extends TimerEvent {
  const TimerReset();
}

class TimerNext extends TimerEvent {
  const TimerNext();
}

class TimerTick extends TimerEvent {
  final int elapsedMs;
  const TimerTick(this.elapsedMs);
  @override
  List<Object?> get props => [elapsedMs];
}

class TimerLoopToggled extends TimerEvent {
  final bool loop;
  const TimerLoopToggled(this.loop);
  @override
  List<Object?> get props => [loop];
}

class TimerSegmentAdded extends TimerEvent {
  const TimerSegmentAdded();
}

class TimerSegmentRemoved extends TimerEvent {
  final int index;
  const TimerSegmentRemoved(this.index);
  @override
  List<Object?> get props => [index];
}

class TimerSegmentUpdated extends TimerEvent {
  final int index;
  final Segment segment;
  const TimerSegmentUpdated(this.index, this.segment);
  @override
  List<Object?> get props => [index, segment];
}
