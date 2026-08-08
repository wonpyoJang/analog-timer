import 'package:equatable/equatable.dart';

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
  );

  @override
  List<Object?> get props => [id, name, totalMs, remainMs, running, done, acked, doneAtMs, extendCount];
}
