import 'package:equatable/equatable.dart';
import '../models/countdown_timer.dart';

abstract class MultiTimerEvent extends Equatable {
  const MultiTimerEvent();
  @override
  List<Object?> get props => [];
}

class MtAdd extends MultiTimerEvent {
  final String name;
  final int totalMs;

  /// true 면 추가 즉시 실행(프리셋 원탭 시작).
  final bool autoStart;

  /// 프리셋 카테고리 — 재알림 간격 결정(알람 시안 §1).
  final String? category;

  /// ack 게이트 순차 체인(조리법) — 같은 chainId, 확인 시 chainIndex+1 시작.
  final String? chainId;
  final int chainIndex;
  const MtAdd(
    this.name,
    this.totalMs, {
    this.autoStart = false,
    this.category,
    this.chainId,
    this.chainIndex = 0,
  });
  @override
  List<Object?> get props => [
    name,
    totalMs,
    autoStart,
    category,
    chainId,
    chainIndex,
  ];
}

/// 루프 프리셋 추가(루프 시안 §2) — 단계들을 자동 반복.
class MtAddLoop extends MultiTimerEvent {
  final String name;
  final List<LoopStep> steps;
  final int repeat;
  final bool autoStart;
  const MtAddLoop(this.name, this.steps, this.repeat, {this.autoStart = true});
  @override
  List<Object?> get props => [name, steps, repeat, autoStart];
}

/// 동시 완료(끝 맞추기) 추가 — 여러 타이머를 같은 시각에 끝나게 지연 배치.
/// 가장 긴 것은 지금 실행, 짧은 것은 waiting(시작 시각에 시작 알람).
class MtAddFinishTogether extends MultiTimerEvent {
  final List<({String name, int totalMs})> items;
  const MtAddFinishTogether(this.items);
  @override
  List<Object?> get props => [items];
}

/// 루프 현재 단계 건너뛰기(⏭, 루프 행 전용).
class MtLoopSkip extends MultiTimerEvent {
  final String id;
  const MtLoopSkip(this.id);
  @override
  List<Object?> get props => [id];
}

/// 완료 확인(acknowledge) — 재알림 중단(요리 시안: 끄기 ≠ 확인).
class MtAck extends MultiTimerEvent {
  final String id;
  const MtAck(this.id);
  @override
  List<Object?> get props => [id];
}

/// 프리-알림 연장 — 잔여 시간에 [addMs] 를 더한다(+5분 등).
class MtExtend extends MultiTimerEvent {
  final String id;
  final int addMs;
  const MtExtend(this.id, this.addMs);
  @override
  List<Object?> get props => [id, addMs];
}

class MtRemove extends MultiTimerEvent {
  final String id;
  const MtRemove(this.id);
  @override
  List<Object?> get props => [id];
}

class MtRename extends MultiTimerEvent {
  final String id;
  final String name;
  const MtRename(this.id, this.name);
  @override
  List<Object?> get props => [id, name];
}

class MtSetDuration extends MultiTimerEvent {
  final String id;
  final int totalMs;
  const MtSetDuration(this.id, this.totalMs);
  @override
  List<Object?> get props => [id, totalMs];
}

class MtStart extends MultiTimerEvent {
  final String id;
  const MtStart(this.id);
  @override
  List<Object?> get props => [id];
}

class MtPause extends MultiTimerEvent {
  final String id;
  const MtPause(this.id);
  @override
  List<Object?> get props => [id];
}

class MtReset extends MultiTimerEvent {
  final String id;
  const MtReset(this.id);
  @override
  List<Object?> get props => [id];
}

/// 내부 틱 — 경과 밀리초를 running 타이머 전부에서 차감.
class MtTick extends MultiTimerEvent {
  final int elapsedMs;
  const MtTick(this.elapsedMs);
  @override
  List<Object?> get props => [elapsedMs];
}

/// 앱 재시작 복원 — 저장된 타이머 목록으로 교체.
class MtRestore extends MultiTimerEvent {
  final List<CountdownTimer> timers;
  const MtRestore(this.timers);
  @override
  List<Object?> get props => [timers];
}
