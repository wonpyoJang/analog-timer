import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/app_theme.dart';
import '../models/segment.dart';
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
  }

  void _onStart(TimerStart event, Emitter<TimerState> emit) {
    if (state.segments.isEmpty) return;

    TimerState next = state;
    if (state.status == TimerStatus.idle) {
      next = state.copyWith(
        currentSeg: 0,
        loopCount: 0,
        segRemainMs: state.segments[0].duration.inMilliseconds,
        log: [
          ...state.log,
          TimerLogEntry(
            DateTime.now(),
            '시작: ${state.segments[0].name}',
            state.segments[0].color.toARGB32(),
          ),
        ],
      );
    }
    emit(next.copyWith(status: TimerStatus.running));
    _startTicker();
  }

  void _onPause(TimerPause event, Emitter<TimerState> emit) {
    if (state.status != TimerStatus.running) return;
    _stopTicker();
    emit(
      state.copyWith(
        status: TimerStatus.paused,
        log: [
          ...state.log,
          TimerLogEntry(DateTime.now(), '일시정지', AppColors.muted.toARGB32()),
        ],
      ),
    );
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
          TimerLogEntry(DateTime.now(), '리셋', AppColors.muted.toARGB32()),
        ],
      ),
    );
  }

  void _onNext(TimerNext event, Emitter<TimerState> emit) {
    if (state.status == TimerStatus.idle) return;
    final cur = state.currentSegment;
    if (cur == null) return;

    final log = [
      ...state.log,
      TimerLogEntry(
        DateTime.now(),
        '건너뜀: ${cur.name}',
        AppColors.accent.toARGB32(),
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
                '🔁 루프 ${state.loopCount + 1}회 완료',
                AppColors.accent.toARGB32(),
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
                '모든 세그먼트 완료 🎉',
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
              '시작: ${state.segments[nextSeg].name}',
              state.segments[nextSeg].color.toARGB32(),
            ),
          ],
        ),
      );
      if (!wasRunning) _startTicker();
    }
  }

  void _onTick(TimerTick event, Emitter<TimerState> emit) {
    if (state.status != TimerStatus.running) return;
    int remain = state.segRemainMs - event.elapsedMs;

    if (remain <= 0) {
      final doneLog = [
        ...state.log,
        TimerLogEntry(
          DateTime.now(),
          '완료: ${state.currentSegment?.name ?? ''}',
          state.currentSegment?.color.toARGB32() ?? 0,
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
                  '🔁 루프 ${state.loopCount + 1}회 완료',
                  AppColors.accent.toARGB32(),
                ),
                TimerLogEntry(
                  DateTime.now(),
                  '시작: ${state.segments[0].name}',
                  state.segments[0].color.toARGB32(),
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
                  '모든 세그먼트 완료 🎉',
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
                '시작: ${state.segments[nextSeg].name}',
                state.segments[nextSeg].color.toARGB32(),
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
        name: '세그먼트 ${state.segments.length + 1}',
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
