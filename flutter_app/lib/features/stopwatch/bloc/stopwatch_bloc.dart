import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'stopwatch_event.dart';
import 'stopwatch_state.dart';

class StopwatchBloc extends Bloc<StopwatchEvent, StopwatchState> {
  Timer? _ticker;
  DateTime? _lastTick;

  StopwatchBloc() : super(StopwatchState.initial()) {
    on<StopwatchToggle>(_onToggle);
    on<StopwatchLap>(_onLap);
    on<StopwatchReset>(_onReset);
    on<StopwatchTick>(_onTick);
    on<StopwatchRestore>(_onRestore);
  }

  double _minAngle() {
    final now = DateTime.now();
    final m = now.minute;
    final s = now.second;
    final ms = now.millisecond;
    return ((m + (s + ms / 1000) / 60) / 60) * 2 * pi - pi / 2;
  }

  void _onToggle(StopwatchToggle event, Emitter<StopwatchState> emit) {
    if (!state.running) {
      final angle = state.elapsedMs == 0
          ? _minAngle()
          : state.startAngleRadians;
      emit(state.copyWith(running: true, startAngleRadians: angle));
      _startTicker();
    } else {
      _stopTicker();
      emit(state.copyWith(running: false));
    }
  }

  void _onLap(StopwatchLap event, Emitter<StopwatchState> emit) {
    if (!state.running && state.elapsedMs == 0) return;
    final lapMs = state.elapsedMs - state.lapStartMs;
    final laps = [...state.laps, LapEntry(lapMs, state.elapsedMs)];
    emit(state.copyWith(laps: laps, lapStartMs: state.elapsedMs));
  }

  void _onReset(StopwatchReset event, Emitter<StopwatchState> emit) {
    _stopTicker();
    emit(StopwatchState.initial());
  }

  void _onTick(StopwatchTick event, Emitter<StopwatchState> emit) {
    emit(state.copyWith(elapsedMs: state.elapsedMs + event.elapsedMs));
  }

  void _onRestore(StopwatchRestore event, Emitter<StopwatchState> emit) {
    _stopTicker();
    emit(
      state.copyWith(
        elapsedMs: event.elapsedMs,
        running: event.running,
        startAngleRadians: event.startAngleRadians ?? _minAngle(),
        laps: const [],
        lapStartMs: 0,
      ),
    );
    if (event.running) _startTicker();
  }

  void _startTicker() {
    _stopTicker();
    _lastTick = DateTime.now();
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final now = DateTime.now();
      final diff = now.difference(_lastTick!);
      // 시계 역행(수동 변경/NTP/DST) — 기준점 리셋 후 이번 tick 은 버린다.
      if (diff.isNegative) {
        _lastTick = now;
        return;
      }
      final ms = diff.inMilliseconds;
      if (ms == 0) return; // 1ms 미만 — 다음 tick 에 포함
      // 기준점을 '소비한 ms 만큼만' 전진 — inMilliseconds 버림으로 생기는
      // 소수 ms 를 이월한다. (기준점을 now 로 덮으면 매 tick 평균 ~0.35ms 가
      // 영구 소실되어 실측 -2.2% 드리프트: 뽀모도로 25분이 실제 25분30초)
      _lastTick = _lastTick!.add(Duration(milliseconds: ms));
      add(StopwatchTick(ms));
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
