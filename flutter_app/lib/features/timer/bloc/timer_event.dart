import 'package:equatable/equatable.dart';
import '../models/segment.dart';
import 'timer_state.dart';

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

/// 날짜 계획 불러오기 — 세그먼트 목록을 완전히 교체하고 타이머를 idle 상태로 초기화.
class TimerSegmentsReplaced extends TimerEvent {
  final List<Segment> segments;
  const TimerSegmentsReplaced(this.segments);
  @override
  List<Object?> get props => [segments];
}

/// 프리셋 적용 — 현재 세그먼트 목록 끝에 덧붙인다(교체 아님).
class TimerSegmentsAppended extends TimerEvent {
  final List<Segment> segments;
  const TimerSegmentsAppended(this.segments);
  @override
  List<Object?> get props => [segments];
}

/// 세그먼트 순서 변경 (onReorderItem 규약: newIndex 는 '제거 후' 기준).
class TimerSegmentReordered extends TimerEvent {
  final int oldIndex;
  final int newIndex;
  const TimerSegmentReordered(this.oldIndex, this.newIndex);
  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class TimerRestore extends TimerEvent {
  final List<Segment> segments;
  final int currentSeg;
  final int segRemainMs;
  final TimerStatus status;
  final bool loop;

  /// true 면 세션 로그를 비우지 않는다 — sync 원격 적용처럼 세션이 계속되는
  /// 경로용. 앱 시작 복원(기본 false)은 새 세션이므로 로그를 비운다.
  final bool preserveLog;
  const TimerRestore({
    required this.segments,
    required this.currentSeg,
    required this.segRemainMs,
    required this.status,
    required this.loop,
    this.preserveLog = false,
  });
  @override
  List<Object?> get props => [
    segments,
    currentSeg,
    segRemainMs,
    status,
    loop,
    preserveLog,
  ];
}
