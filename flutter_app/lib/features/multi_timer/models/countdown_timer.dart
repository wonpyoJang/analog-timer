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

  CountdownTimer({
    String? id,
    required this.name,
    required this.totalMs,
    int? remainMs,
    this.running = false,
    this.done = false,
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
  }) => CountdownTimer(
    id: id,
    name: name ?? this.name,
    totalMs: totalMs ?? this.totalMs,
    remainMs: remainMs ?? this.remainMs,
    running: running ?? this.running,
    done: done ?? this.done,
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
  };

  static CountdownTimer fromJson(Map<String, dynamic> json) => CountdownTimer(
    id: json['id'] as String?,
    name: json['name'] as String? ?? '',
    totalMs: (json['totalMs'] as num).toInt(),
    remainMs: (json['remainMs'] as num?)?.toInt(),
    running: json['running'] as bool? ?? false,
    done: json['done'] as bool? ?? false,
  );

  @override
  List<Object?> get props => [id, name, totalMs, remainMs, running, done];
}
