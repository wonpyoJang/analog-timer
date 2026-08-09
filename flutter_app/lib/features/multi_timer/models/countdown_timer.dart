import 'package:equatable/equatable.dart';

/// 루프 프리셋의 한 단계(루프 시안 §2) — 이름 + 지속시간.
class LoopStep extends Equatable {
  final String name;
  final int ms;
  const LoopStep(this.name, this.ms);

  Map<String, dynamic> toJson() => {'name': name, 'ms': ms};

  static LoopStep fromJson(Map<String, dynamic> j) =>
      LoopStep(j['name'] as String? ?? '', (j['ms'] as num?)?.toInt() ?? 0);

  @override
  List<Object?> get props => [name, ms];
}

/// 멀티 타이머 모드의 독립 카운트다운 하나 — 이름 + 지속시간(밀리초, 초 단위 지원).
/// 기존 Segment(분 전용, 순차 세그먼트)와 달리 서로 독립적으로 실행된다.
class CountdownTimer extends Equatable {
  /// 리스트 키·식별용. 동등성에는 포함하지 않는다(Segment 패턴 동형).
  final String id;
  final String name;
  final int totalMs;
  final int remainMs;
  final bool running;

  /// remainMs 가 0에 도달해 완료된 상태. 리셋으로 해제된다.
  final bool done;

  /// 완료를 사용자가 확인했는가 — false 면 "울리는 중"(1분 재알림 대상).
  final bool acked;

  /// 완료 시각(epoch ms) — 재알림 경과("2분 지났어요") 계산용.
  final int doneAtMs;

  /// 완료 후 +연장 횟수 — 알람 화면 이력 표시("+1:00 연장 · 2회").
  final int extendCount;

  /// 프리셋 카테고리(cooking/focus/chore/null) — 재알림 간격 결정(알람 시안 §1).
  final String? category;

  /// 루프 단계들(비면 일반 타이머). 루프면 현재 단계가 totalMs/remainMs 를 차지.
  final List<LoopStep> loopSteps;
  final int loopRepeat;

  /// 현재 단계 인덱스(0-base)·회차(1-base).
  final int loopStepIdx;
  final int loopRound;

  /// ack 게이트 순차 체인(조리법). 같은 chainId 를 공유하고, 한 단계를 확인(ack)하면
  /// chainIndex+1 이 시작된다. null 이면 체인 아님(루프·병렬과 무관).
  final String? chainId;
  final int chainIndex;

  /// 동시 완료(끝 맞추기, §동시완료). 같은 groupId 를 공유. 짧은 타이머는 지연 시작.
  final String? groupId;

  /// 시작 예정 절대시각(epoch ms) — >0 이면 아직 안 돈 waiting 상태. 0 이면 즉시/이미 시작.
  final int startAtMs;

  /// 시작 시각이 도래해 "시작 알람"이 울리는 중(완료 알람의 반대). 확인=시작.
  final bool startArmed;

  /// 그룹 정렬 완료 목표시각(epoch ms) — 어긋남 감지용. 0 이면 없음.
  final int targetFinishMs;

  bool get isLoop => loopSteps.isNotEmpty;

  /// 아직 시작 전(동시 완료 대기). startArmed 면 시작 알람 울리는 중.
  bool get waiting => startAtMs > 0 && !running && !done;

  CountdownTimer({
    String? id,
    required this.name,
    required this.totalMs,
    int? remainMs,
    this.running = false,
    this.done = false,
    this.acked = true,
    this.doneAtMs = 0,
    this.extendCount = 0,
    this.category,
    this.loopSteps = const [],
    this.loopRepeat = 1,
    this.loopStepIdx = 0,
    this.loopRound = 1,
    this.chainId,
    this.chainIndex = 0,
    this.groupId,
    this.startAtMs = 0,
    this.startArmed = false,
    this.targetFinishMs = 0,
  }) : id = id ?? _nextId(),
       remainMs = remainMs ?? totalMs;

  static int _idCounter = 0;
  static String _nextId() =>
      'mt${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

  CountdownTimer copyWith({
    String? name,
    int? totalMs,
    int? remainMs,
    bool? running,
    bool? done,
    bool? acked,
    int? doneAtMs,
    int? extendCount,
    int? loopStepIdx,
    int? loopRound,
    int? startAtMs,
    bool? startArmed,
    int? targetFinishMs,
  }) => CountdownTimer(
    id: id,
    name: name ?? this.name,
    totalMs: totalMs ?? this.totalMs,
    remainMs: remainMs ?? this.remainMs,
    running: running ?? this.running,
    done: done ?? this.done,
    acked: acked ?? this.acked,
    doneAtMs: doneAtMs ?? this.doneAtMs,
    extendCount: extendCount ?? this.extendCount,
    category: category,
    loopSteps: loopSteps,
    loopRepeat: loopRepeat,
    loopStepIdx: loopStepIdx ?? this.loopStepIdx,
    loopRound: loopRound ?? this.loopRound,
    chainId: chainId,
    chainIndex: chainIndex,
    groupId: groupId,
    startAtMs: startAtMs ?? this.startAtMs,
    startArmed: startArmed ?? this.startArmed,
    targetFinishMs: targetFinishMs ?? this.targetFinishMs,
  );

  double get frac =>
      totalMs <= 0 ? 0 : (1 - remainMs / totalMs).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'totalMs': totalMs,
    'remainMs': remainMs,
    'running': running,
    'done': done,
    'acked': acked,
    'doneAtMs': doneAtMs,
    'extendCount': extendCount,
    'category': category,
    'loopSteps': loopSteps.map((e) => e.toJson()).toList(),
    'loopRepeat': loopRepeat,
    'loopStepIdx': loopStepIdx,
    'loopRound': loopRound,
    'chainId': chainId,
    'chainIndex': chainIndex,
    'groupId': groupId,
    'startAtMs': startAtMs,
    'startArmed': startArmed,
    'targetFinishMs': targetFinishMs,
  };

  static CountdownTimer fromJson(Map<String, dynamic> json) => CountdownTimer(
    id: json['id'] as String?,
    name: json['name'] as String? ?? '',
    totalMs: (json['totalMs'] as num).toInt(),
    remainMs: (json['remainMs'] as num?)?.toInt(),
    running: json['running'] as bool? ?? false,
    done: json['done'] as bool? ?? false,
    acked: json['acked'] as bool? ?? true,
    doneAtMs: (json['doneAtMs'] as num?)?.toInt() ?? 0,
    extendCount: (json['extendCount'] as num?)?.toInt() ?? 0,
    category: json['category'] as String?,
    loopSteps: ((json['loopSteps'] as List?) ?? const [])
        .map((e) => LoopStep.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    loopRepeat: (json['loopRepeat'] as num?)?.toInt() ?? 1,
    loopStepIdx: (json['loopStepIdx'] as num?)?.toInt() ?? 0,
    loopRound: (json['loopRound'] as num?)?.toInt() ?? 1,
    chainId: json['chainId'] as String?,
    chainIndex: (json['chainIndex'] as num?)?.toInt() ?? 0,
    groupId: json['groupId'] as String?,
    startAtMs: (json['startAtMs'] as num?)?.toInt() ?? 0,
    startArmed: json['startArmed'] as bool? ?? false,
    targetFinishMs: (json['targetFinishMs'] as num?)?.toInt() ?? 0,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    totalMs,
    remainMs,
    running,
    done,
    acked,
    doneAtMs,
    extendCount,
    category,
    loopSteps,
    loopRepeat,
    loopStepIdx,
    loopRound,
    chainId,
    chainIndex,
    groupId,
    startAtMs,
    startArmed,
    targetFinishMs,
  ];
}
