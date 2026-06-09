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
      final elapsed = now.difference(_lastTick!).inMilliseconds;
      _lastTick = now;
      add(StopwatchTick(elapsed));
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
