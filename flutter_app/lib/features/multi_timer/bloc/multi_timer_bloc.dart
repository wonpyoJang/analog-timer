import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/countdown_timer.dart';
import 'multi_timer_event.dart';
import 'multi_timer_state.dart';

/// 여러 독립 카운트다운을 하나의 16ms 티커로 함께 감소시킨다.
/// 드리프트 보정은 TimerBloc/StopwatchBloc과 동일 패턴(기준점을 소비한 ms만큼만 전진).
class MultiTimerBloc extends Bloc<MultiTimerEvent, MultiTimerState> {
  Timer? _ticker;
  DateTime? _lastTick;

  MultiTimerBloc() : super(const MultiTimerState()) {
    on<MtAdd>(_onAdd);
    on<MtRemove>(_onRemove);
    on<MtRename>(_onRename);
    on<MtSetDuration>(_onSetDuration);
    on<MtStart>(_onStart);
    on<MtPause>(_onPause);
    on<MtReset>(_onReset);
    on<MtTick>(_onTick);
    on<MtRestore>(_onRestore);
  }

  List<CountdownTimer> _map(
    CountdownTimer Function(CountdownTimer) f, {
    String? onlyId,
  }) => state.timers
      .map((t) => (onlyId == null || t.id == onlyId) ? f(t) : t)
      .toList();

  void _onAdd(MtAdd e, Emitter<MultiTimerState> emit) {
    final t = CountdownTimer(
      name: e.name,
      totalMs: e.totalMs,
      running: e.autoStart,
    );
    emit(state.copyWith(timers: [...state.timers, t]));
    if (e.autoStart) _syncTicker();
  }

  void _onRemove(MtRemove e, Emitter<MultiTimerState> emit) {
    emit(
      state.copyWith(timers: state.timers.where((t) => t.id != e.id).toList()),
    );
    _syncTicker();
  }

  void _onRename(MtRename e, Emitter<MultiTimerState> emit) {
    emit(
      state.copyWith(
        timers: _map((t) => t.copyWith(name: e.name), onlyId: e.id),
      ),
    );
  }

  void _onSetDuration(MtSetDuration e, Emitter<MultiTimerState> emit) {
    // 지속시간 변경 = 정지 상태로 리셋(실행 중 변경은 혼란).
    emit(
      state.copyWith(
        timers: _map(
          (t) => t.copyWith(
            totalMs: e.totalMs,
            remainMs: e.totalMs,
            running: false,
            done: false,
          ),
          onlyId: e.id,
        ),
      ),
    );
    _syncTicker();
  }

  void _onStart(MtStart e, Emitter<MultiTimerState> emit) {
    emit(
      state.copyWith(
        timers: _map((t) {
          if (t.id != e.id) return t;
          // 완료된 타이머 재시작 = 처음부터. 남은 시간 0이면 리셋.
          final fresh = (t.done || t.remainMs <= 0);
          return t.copyWith(
            running: true,
            done: false,
            remainMs: fresh ? t.totalMs : t.remainMs,
          );
        }, onlyId: e.id),
      ),
    );
    _syncTicker();
  }

  void _onPause(MtPause e, Emitter<MultiTimerState> emit) {
    // 마지막 틱 이후 흐른 시간(0~250ms)을 먼저 차감 — 안 하면 일시정지할 때마다
    // 그만큼 되돌려받아, 자주 멈추면 누적으로 실제보다 느리게 간다.
    _flushElapsed(emit);
    emit(
      state.copyWith(
        timers: _map((t) => t.copyWith(running: false), onlyId: e.id),
      ),
    );
    _syncTicker();
  }

  /// 티커 기준점(_lastTick) 이후 흐른 시간을 즉시 반영하고 기준점을 전진시킨다.
  void _flushElapsed(Emitter<MultiTimerState> emit) {
    final last = _lastTick;
    if (last == null) return;
    final now = DateTime.now();
    final diff = now.difference(last);
    if (diff.isNegative) {
      _lastTick = now;
      return;
    }
    final ms = diff.inMilliseconds;
    if (ms == 0) return;
    _lastTick = last.add(Duration(milliseconds: ms));
    _applyTick(ms, emit);
  }

  void _onReset(MtReset e, Emitter<MultiTimerState> emit) {
    emit(
      state.copyWith(
        timers: _map(
          (t) => t.copyWith(remainMs: t.totalMs, running: false, done: false),
          onlyId: e.id,
        ),
      ),
    );
    _syncTicker();
  }

  void _onTick(MtTick e, Emitter<MultiTimerState> emit) {
    _applyTick(e.elapsedMs, emit);
    _syncTicker();
  }

  void _applyTick(int elapsedMs, Emitter<MultiTimerState> emit) {
    if (elapsedMs <= 0) return; // 역행 방어
    final justCompleted = <String>[];
    final next = state.timers.map((t) {
      if (!t.running || t.done) return t;
      final r = t.remainMs - elapsedMs;
      if (r <= 0) {
        justCompleted.add(t.id);
        return t.copyWith(remainMs: 0, running: false, done: true);
      }
      return t.copyWith(remainMs: r);
    }).toList();
    emit(state.copyWith(timers: next, justCompleted: justCompleted));
  }

  void _onRestore(MtRestore e, Emitter<MultiTimerState> emit) {
    emit(state.copyWith(timers: e.timers));
    _syncTicker();
  }

  /// running 타이머가 있으면 티커 유지, 없으면 중지.
  void _syncTicker() {
    if (state.runningCount > 0) {
      _ticker ??= _startTicker();
    } else {
      _stopTicker();
    }
  }

  Timer _startTicker() {
    _lastTick = DateTime.now();
    // 250ms 주기 — 표시는 mm:ss(초 단위)라 16ms(60fps) 재빌드는 낭비이고 리스트를
    // 60fps 로 다시 그려 입력(오버레이 토글/드래그)을 굶겼다. 경과는 실제 ms 로
    // 측정·드리프트 보정하므로 정확도 손실 없음.
    return Timer.periodic(const Duration(milliseconds: 250), (_) {
      final now = DateTime.now();
      final diff = now.difference(_lastTick!);
      if (diff.isNegative) {
        _lastTick = now; // 시계 역행 — 기준점만 리셋
        return;
      }
      final ms = diff.inMilliseconds;
      if (ms == 0) return; // 1ms 미만 — 다음 tick 에 이월
      // 소비한 ms 만큼만 전진(버림 소수부 이월) — TimerBloc과 동일 드리프트 보정.
      _lastTick = _lastTick!.add(Duration(milliseconds: ms));
      add(MtTick(ms));
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
