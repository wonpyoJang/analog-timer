import 'package:equatable/equatable.dart';
import '../models/segment.dart';

enum TimerStatus { idle, running, paused, done }

/// 로그 이벤트 종류 — 표시 시점에 현지화하기 위해 문자열 대신 타입으로 저장한다.
enum TimerLogType { start, pause, reset, skip, done, allDone, loop }

class TimerLogEntry {
  final DateTime time;
  final TimerLogType type;
  final int colorValue;

  /// start/skip/done 처럼 세그먼트 이름이 필요한 타입에만 사용.
  final String? segName;

  const TimerLogEntry(this.time, this.type, this.colorValue, {this.segName});
}

class TimerState extends Equatable {
  final TimerStatus status;
  final List<Segment> segments;
  final int currentSeg;
  final int segRemainMs;
  final bool loop;
  final int loopCount;
  final List<TimerLogEntry> log;

  const TimerState({
    required this.status,
    required this.segments,
    required this.currentSeg,
    required this.segRemainMs,
    required this.loop,
    required this.loopCount,
    required this.log,
  });

  factory TimerState.initial() => TimerState(
    status: TimerStatus.idle,
    segments: Segment.defaults,
    currentSeg: 0,
    segRemainMs: 0,
    loop: false,
    loopCount: 0,
    log: const [],
  );

  Segment? get currentSegment =>
      segments.isNotEmpty && currentSeg < segments.length
      ? segments[currentSeg]
      : null;

  int get totalMs =>
      segments.fold(0, (s, seg) => s + seg.duration.inMilliseconds);

  int get elapsedMs {
    int e = 0;
    for (int i = 0; i < currentSeg && i < segments.length; i++) {
      e += segments[i].duration.inMilliseconds;
    }
    if (currentSegment != null) {
      e +=
          currentSegment!.duration.inMilliseconds -
          segRemainMs.clamp(0, currentSegment!.duration.inMilliseconds);
    }
    return e;
  }

  TimerState copyWith({
    TimerStatus? status,
    List<Segment>? segments,
    int? currentSeg,
    int? segRemainMs,
    bool? loop,
    int? loopCount,
    List<TimerLogEntry>? log,
  }) => TimerState(
    status: status ?? this.status,
    segments: segments ?? this.segments,
    currentSeg: currentSeg ?? this.currentSeg,
    segRemainMs: segRemainMs ?? this.segRemainMs,
    loop: loop ?? this.loop,
    loopCount: loopCount ?? this.loopCount,
    log: log ?? this.log,
  );

  @override
  List<Object?> get props => [
    status,
    segments,
    currentSeg,
    segRemainMs,
    loop,
    loopCount,
    log.length,
  ];
}
