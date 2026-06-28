import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_theme.dart';
import '../models/segment.dart';
import '../../../services/telemetry_service.dart';
import 'timer_event.dart';
import 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  Timer? _ticker;
  DateTime? _lastTick;

  TimerBloc() : super(TimerState.initial()) {
    on<TimerStart>(_onStart);
    on<TimerPause>(_onPause);
    on<TimerReset>(_onReset);
    on<TimerNext>(_onNext);
    on<TimerTick>(_onTick);
    on<TimerLoopToggled>(_onLoopToggled);
    on<TimerSegmentAdded>(_onSegmentAdded);
    on<TimerSegmentRemoved>(_onSegmentRemoved);
    on<TimerSegmentUpdated>(_onSegmentUpdated);
    on<TimerSegmentReordered>(_onSegmentReordered);
    on<TimerSegmentsAppended>(_onSegmentsAppended);
    on<TimerRestore>(_onRestore);
  }

  void _onStart(TimerStart event, Emitter<TimerState> emit) {
    if (state.segments.isEmpty) return;

    TimerState next = state;
    if (state.status == TimerStatus.idle || state.status == TimerStatus.done) {
      next = state.copyWith(
        currentSeg: 0,
        loopCount: 0,
        segRemainMs: state.segments[0].duration.inMilliseconds,
        log: [
          ...state.log,
          TimerLogEntry(
            DateTime.now(),
            TimerLogType.start,
            state.segments[0].color.toARGB32(),
            segName: state.segments[0].name,
          ),
        ],
      );
    }
    emit(next.copyWith(status: TimerStatus.running));
    _startTicker();
    unawaited(TelemetryService.instance
        .logEvent('timer_start', {'seg': state.currentSegment?.name}));
  }

  void _onPause(TimerPause event, Emitter<TimerState> emit) {
    if (state.status != TimerStatus.running) return;
    _stopTicker();
    emit(
      state.copyWith(
        status: TimerStatus.paused,
        log: [
          ...state.log,
          TimerLogEntry(
            DateTime.now(),
            TimerLogType.pause,
            AppColors.muted.toARGB32(),
          ),
        ],
      ),
    );
    unawaited(TelemetryService.instance.logEvent('timer_pause'));
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _stopTicker();
    emit(
      state.copyWith(
        status: TimerStatus.idle,
        currentSeg: 0,
        segRemainMs: 0,
        loopCount: 0,
        log: [
          ...state.log,
          TimerLogEntry(
            DateTime.now(),
            TimerLogType.reset,
            AppColors.muted.toARGB32(),
          ),
        ],
      ),
    );
    unawaited(TelemetryService.instance.logEvent('timer_reset'));
  }

  void _onNext(TimerNext event, Emitter<TimerState> emit) {
    if (state.status == TimerStatus.idle) return;
    final cur = state.currentSegment;
    if (cur == null) return;

    final log = [
      ...state.log,
      TimerLogEntry(
        DateTime.now(),
        TimerLogType.skip,
        AppColors.accent.toARGB32(),
        segName: cur.name,
      ),
    ];

    final nextSeg = state.currentSeg + 1;
    if (nextSeg >= state.segments.length) {
      if (state.loop) {
        emit(
          state.copyWith(
            currentSeg: 0,
            segRemainMs: state.segments[0].duration.inMilliseconds,
            loopCount: state.loopCount + 1,
            status: TimerStatus.running,
            log: [
              ...log,
              TimerLogEntry(
                DateTime.now(),
                TimerLogType.loop,
                AppColors.accent.toARGB32(),
                segName: '${state.loopCount + 1}',
              ),
            ],
          ),
        );
        if (state.status != TimerStatus.running) _startTicker();
      } else {
        _stopTicker();
        emit(
          state.copyWith(
            status: TimerStatus.done,
            segRemainMs: 0,
            log: [
              ...log,
              TimerLogEntry(
                DateTime.now(),
                TimerLogType.allDone,
                AppColors.accent.toARGB32(),
              ),
            ],
          ),
        );
      }
    } else {
      final wasRunning = state.status == TimerStatus.running;
      emit(
        state.copyWith(
          currentSeg: nextSeg,
          segRemainMs: state.segments[nextSeg].duration.inMilliseconds,
          status: TimerStatus.running,
          log: [
            ...log,
            TimerLogEntry(
              DateTime.now(),
              TimerLogType.start,
              state.segments[nextSeg].color.toARGB32(),
              segName: state.segments[nextSeg].name,
            ),
          ],
        ),
      );
      if (!wasRunning) _startTicker();
    }
    unawaited(TelemetryService.instance.logEvent('timer_skip'));
  }

  void _onTick(TimerTick event, Emitter<TimerState> emit) {
    if (state.status != TimerStatus.running) return;
    int remain = state.segRemainMs - event.elapsedMs;

    if (remain <= 0) {
      unawaited(TelemetryService.instance
          .logEvent('segment_done', {'seg': state.currentSegment?.name}));
      final doneLog = [
        ...state.log,
        TimerLogEntry(
          DateTime.now(),
          TimerLogType.done,
          state.currentSegment?.color.toARGB32() ?? 0,
          segName: state.currentSegment?.name ?? '',
        ),
      ];
      final nextSeg = state.currentSeg + 1;
      if (nextSeg >= state.segments.length) {
        if (state.loop) {
          emit(
            state.copyWith(
              currentSeg: 0,
              segRemainMs: state.segments[0].duration.inMilliseconds,
              loopCount: state.loopCount + 1,
              log: [
                ...doneLog,
                TimerLogEntry(
                  DateTime.now(),
                  TimerLogType.loop,
                  AppColors.accent.toARGB32(),
                  segName: '${state.loopCount + 1}',
                ),
                TimerLogEntry(
                  DateTime.now(),
                  TimerLogType.start,
                  state.segments[0].color.toARGB32(),
                  segName: state.segments[0].name,
                ),
              ],
            ),
          );
        } else {
          _stopTicker();
          emit(
            state.copyWith(
              status: TimerStatus.done,
              segRemainMs: 0,
              log: [
                ...doneLog,
                TimerLogEntry(
                  DateTime.now(),
                  TimerLogType.allDone,
                  AppColors.accent.toARGB32(),
                ),
              ],
            ),
          );
        }
      } else {
        emit(
          state.copyWith(
            currentSeg: nextSeg,
            segRemainMs: state.segments[nextSeg].duration.inMilliseconds,
            log: [
              ...doneLog,
              TimerLogEntry(
                DateTime.now(),
                TimerLogType.start,
                state.segments[nextSeg].color.toARGB32(),
                segName: state.segments[nextSeg].name,
              ),
            ],
          ),
        );
      }
    } else {
      emit(state.copyWith(segRemainMs: remain));
    }
  }

  void _onLoopToggled(TimerLoopToggled event, Emitter<TimerState> emit) {
    emit(state.copyWith(loop: event.loop));
  }

  void _onSegmentAdded(TimerSegmentAdded event, Emitter<TimerState> emit) {
    final color =
        AppColors.segColors[state.segments.length % AppColors.segColors.length];
    final segs = [
      ...state.segments,
      Segment(
        name: 'Segment ${state.segments.length + 1}',
        minutes: 5,
        color: color,
      ),
    ];
    emit(state.copyWith(segments: segs));
  }

  void _onSegmentRemoved(TimerSegmentRemoved event, Emitter<TimerState> emit) {
    if (state.segments.length <= 1) return;
    final segs = List<Segment>.from(state.segments)..removeAt(event.index);
    emit(state.copyWith(segments: segs));
  }

  void _onSegmentUpdated(TimerSegmentUpdated event, Emitter<TimerState> emit) {
    final segs = List<Segment>.from(state.segments);
    if (event.index < segs.length) segs[event.index] = event.segment;
    emit(state.copyWith(segments: segs));
  }

  void _onSegmentsAppended(
    TimerSegmentsAppended event,
    Emitter<TimerState> emit,
  ) {
    if (event.segments.isEmpty) return;
    // 현재 진행/표시 상태는 그대로 두고 목록 끝에만 덧붙인다.
    emit(state.copyWith(segments: [...state.segments, ...event.segments]));
  }

  void _onSegmentReordered(
    TimerSegmentReordered event,
    Emitter<TimerState> emit,
  ) {
    final old = event.oldIndex;
    if (old < 0 || old >= state.segments.length) return;
    // onReorderItem: newIndex 는 이미 '제거 후' 기준이라 추가 보정 불필요.
    final to = event.newIndex;
    if (to == old) return;

    final segs = List<Segment>.from(state.segments);
    final moved = segs.removeAt(old);
    segs.insert(to, moved);

    // 진행/일시정지 중인 현재 세그먼트 인덱스를 이동에 맞춰 보정.
    int cur = state.currentSeg;
    if (cur == old) {
      cur = to;
    } else {
      if (old < cur) cur -= 1; // 앞에서 빠지면 한 칸 당겨짐
      if (to <= cur) cur += 1; // 앞에 끼어들면 한 칸 밀림
    }
    cur = cur.clamp(0, segs.length - 1);

    emit(state.copyWith(segments: segs, currentSeg: cur));
  }

  void _onRestore(TimerRestore event, Emitter<TimerState> emit) {
    _stopTicker();
    emit(
      state.copyWith(
        segments: event.segments,
        currentSeg: event.currentSeg,
        segRemainMs: event.segRemainMs,
        status: event.status,
        loop: event.loop,
        log: const [],
      ),
    );
    if (event.status == TimerStatus.running) _startTicker();
  }

  void _startTicker() {
    _stopTicker();
    _lastTick = DateTime.now();
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final now = DateTime.now();
      final elapsed = now.difference(_lastTick!).inMilliseconds;
      _lastTick = now;
      add(TimerTick(elapsed));
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
    _lastTick = null;
  }

  @override
  Future<void> close() {
    _stopTicker();
    return super.close();
  }
}
