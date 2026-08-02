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
    on<TimerSegmentsReplaced>(_onSegmentsReplaced);
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
        logSeq: state.logSeq + 1,
      );
    }
    emit(next.copyWith(status: TimerStatus.running));
    _startTicker();
    unawaited(
      TelemetryService.instance.logEvent('timer_start', {
        'seg': state.currentSegment?.name,
      }),
    );
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
        logSeq: state.logSeq + 1,
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
        logSeq: state.logSeq + 1,
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
    // emit 은 state 를 동기 갱신하므로 '시작 전 실행 여부'는 여기서 캡처해야 한다.
    final wasRunningBeforeNext = state.status == TimerStatus.running;
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
            logSeq: state.logSeq + 2,
          ),
        );
        // 일시정지 상태에서 loop-wrap Next → 티커 재기동 필요.
        if (!wasRunningBeforeNext) _startTicker();
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
            logSeq: state.logSeq + 2,
          ),
        );
      }
    } else {
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
          logSeq: state.logSeq + 2,
        ),
      );
      if (!wasRunningBeforeNext) _startTicker();
    }
    unawaited(TelemetryService.instance.logEvent('timer_skip'));
  }

  void _onTick(TimerTick event, Emitter<TimerState> emit) {
    if (state.status != TimerStatus.running) return;
    // 시계 역행 방어(심층) — 티커가 거르지만 bloc 단독으로도 음수 tick 에
    // 시간이 거꾸로 가면 안 된다.
    if (event.elapsedMs <= 0) return;
    int remain = state.segRemainMs - event.elapsedMs;

    if (remain > 0) {
      emit(state.copyWith(segRemainMs: remain));
      return;
    }

    // 세그먼트 경계 통과. 절전/최대절전/프로세스 일시정지 복귀 시 elapsed 가
    // 여러 세그먼트를 한 번에 관통할 수 있으므로, 복원 경로(_advanceTimer)와
    // 동일하게 초과분을 이월하며 따라잡는다(이전엔 한 세그먼트만 소비하고
    // 나머지를 버려 절전 후 타이머가 실제보다 덜 진행되는 버그).
    unawaited(
      TelemetryService.instance.logEvent('segment_done', {
        'seg': state.currentSegment?.name,
      }),
    );
    final log = [
      ...state.log,
      TimerLogEntry(
        DateTime.now(),
        TimerLogType.done,
        state.currentSegment?.color.toARGB32() ?? 0,
        segName: state.currentSegment?.name ?? '',
      ),
    ];
    var seg = state.currentSeg;
    var loopCount = state.loopCount;

    while (remain <= 0) {
      seg++;
      if (seg >= state.segments.length) {
        if (state.loop) {
          seg = 0;
          loopCount++;
          log.add(
            TimerLogEntry(
              DateTime.now(),
              TimerLogType.loop,
              AppColors.accent.toARGB32(),
              segName: '$loopCount',
            ),
          );
        } else {
          _stopTicker();
          log.add(
            TimerLogEntry(
              DateTime.now(),
              TimerLogType.allDone,
              AppColors.accent.toARGB32(),
            ),
          );
          emit(
            state.copyWith(
              status: TimerStatus.done,
              segRemainMs: 0,
              log: _capLog(log),
              // 캡 전 길이 차이 = 이번에 추가된 엔트리 수 (단조 증가 유지)
              logSeq: state.logSeq + (log.length - state.log.length),
            ),
          );
          return;
        }
      }
      final segMs = state.segments[seg].duration.inMilliseconds;
      // 0ms 세그먼트 + loop ON 이면 이 루프가 영원히 못 빠져나가 메인 isolate
      // 가 프리즈된다(ANR). 복원 경로(_advanceTimer)와 동일하게 즉시 완료 처리.
      if (segMs <= 0) {
        _stopTicker();
        emit(
          state.copyWith(
            currentSeg: seg,
            status: TimerStatus.done,
            segRemainMs: 0,
            log: _capLog(log),
            logSeq: state.logSeq + (log.length - state.log.length),
          ),
        );
        return;
      }
      remain += segMs;
      log.add(
        TimerLogEntry(
          DateTime.now(),
          remain <= 0 ? TimerLogType.done : TimerLogType.start,
          state.segments[seg].color.toARGB32(),
          segName: state.segments[seg].name,
        ),
      );
    }

    emit(
      state.copyWith(
        currentSeg: seg,
        segRemainMs: remain,
        loopCount: loopCount,
        log: _capLog(log),
        logSeq: state.logSeq + (log.length - state.log.length),
      ),
    );
  }

  /// 로그 무한 축적 방지 — loop 타이머를 밤새 돌려도 최근 300개만 유지.
  List<TimerLogEntry> _capLog(List<TimerLogEntry> log) =>
      log.length > 300 ? log.sublist(log.length - 300) : log;

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
    // 리빌드 직전 UI 가 들고 있던 stale index 방어 — 범위 밖이면 무시.
    if (event.index < 0 || event.index >= state.segments.length) return;
    final segs = List<Segment>.from(state.segments)..removeAt(event.index);
    // 진행 인덱스 보정 — 앞 세그먼트가 빠지면 한 칸 당기고, 진행 중이던
    // 세그먼트 자체가 삭제되면 같은 자리(다음 세그먼트)를 처음부터 시작한다.
    int cur = state.currentSeg;
    int remain = state.segRemainMs;
    if (event.index < cur) {
      cur -= 1;
    } else if (event.index == cur &&
        state.status != TimerStatus.idle &&
        state.status != TimerStatus.done) {
      if (cur >= segs.length) {
        // 진행 중이던 '마지막' 세그먼트 삭제 — 다음 세그먼트가 없다.
        // 앞으로 되감으면 이미 완료한 세그먼트가 재실행되고 done 로그/알림이
        // 중복되므로, loop 면 랩(처음부터), 아니면 완료 처리한다.
        if (state.loop) {
          cur = 0;
          remain = segs[0].duration.inMilliseconds;
        } else {
          _stopTicker();
          emit(
            state.copyWith(
              segments: segs,
              currentSeg: segs.length - 1,
              segRemainMs: 0,
              status: TimerStatus.done,
            ),
          );
          return;
        }
      } else {
        remain = segs[cur].duration.inMilliseconds;
      }
    }
    cur = cur.clamp(0, segs.length - 1);
    emit(state.copyWith(segments: segs, currentSeg: cur, segRemainMs: remain));
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

  void _onSegmentsReplaced(
    TimerSegmentsReplaced event,
    Emitter<TimerState> emit,
  ) {
    if (event.segments.isEmpty) return;
    _ticker?.cancel();
    _ticker = null;
    emit(
      TimerState(
        status: TimerStatus.idle,
        segments: event.segments,
        currentSeg: 0,
        segRemainMs: 0,
        loop: state.loop,
        loopCount: 0,
        log: state.log,
        logSeq: state.logSeq,
      ),
    );
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
        log: event.preserveLog ? state.log : const [],
      ),
    );
    if (event.status == TimerStatus.running) _startTicker();
  }

  void _startTicker() {
    _stopTicker();
    _lastTick = DateTime.now();
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final now = DateTime.now();
      final diff = now.difference(_lastTick!);
      // 시계 역행(수동 변경/NTP 보정/DST) — 기준점 리셋 후 이번 tick 은 버린다.
      if (diff.isNegative) {
        _lastTick = now;
        return;
      }
      final ms = diff.inMilliseconds;
      if (ms == 0) return; // 1ms 미만 — 다음 tick 에 포함
      // 기준점을 '소비한 ms 만큼만' 전진 — inMilliseconds 버림 소수부를 이월.
      // (기준점을 now 로 덮으면 매 tick 평균 ~0.35ms 영구 소실 → 실측 -2.2%
      // 드리프트. 스톱워치와 동일 결함)
      _lastTick = _lastTick!.add(Duration(milliseconds: ms));
      add(TimerTick(ms));
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
