import 'package:equatable/equatable.dart';

/// 운동 종류 — reps(세트×횟수 구령) / time(초 버티기) / free(무한 카운트).
enum WorkoutType { reps, time, free }

/// 루틴 안의 운동 한 항목. 라이브러리에서 추가되며 세트/횟수/페이스/시간을 편집한다.
class WorkoutExercise extends Equatable {
  final String id;

  /// 라이브러리 키 — 표시 이름은 l10n 으로 로케일을 따라간다.
  final String libKey;

  /// 커스텀 운동 이름 — 있으면 libKey 대신 이 이름을 표시한다.
  final String? customName;
  final WorkoutType type;
  final int sets;
  final int reps;

  /// 구령 간격(초) — reps/free 에서 사용.
  final double pace;

  /// 유지 시간(초) — time 에서 사용.
  final int dur;

  const WorkoutExercise({
    required this.id,
    required this.libKey,
    this.customName,
    required this.type,
    this.sets = 3,
    this.reps = 10,
    this.pace = 2.0,
    this.dur = 30,
  });

  WorkoutExercise copyWith({int? sets, int? reps, double? pace, int? dur}) =>
      WorkoutExercise(
        id: id,
        libKey: libKey,
        customName: customName,
        type: type,
        sets: sets ?? this.sets,
        reps: reps ?? this.reps,
        pace: pace ?? this.pace,
        dur: dur ?? this.dur,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'libKey': libKey,
    'customName': customName,
    'type': type.name,
    'sets': sets,
    'reps': reps,
    'pace': pace,
    'dur': dur,
  };

  static WorkoutExercise fromJson(Map<String, dynamic> j) => WorkoutExercise(
    id: j['id'] as String? ?? 'w${DateTime.now().microsecondsSinceEpoch}',
    libKey: j['libKey'] as String? ?? 'squat',
    customName: j['customName'] as String?,
    type: WorkoutType.values.firstWhere(
      (t) => t.name == j['type'],
      orElse: () => WorkoutType.reps,
    ),
    sets: (j['sets'] as num?)?.toInt() ?? 3,
    reps: (j['reps'] as num?)?.toInt() ?? 10,
    pace: (j['pace'] as num?)?.toDouble() ?? 2.0,
    dur: (j['dur'] as num?)?.toInt() ?? 30,
  );

  @override
  List<Object?> get props => [id, libKey, customName, type, sets, reps, pace, dur];
}

class WorkoutRoutine extends Equatable {
  final String id;
  final String name;
  final List<WorkoutExercise> items;

  const WorkoutRoutine({
    required this.id,
    required this.name,
    this.items = const [],
  });

  WorkoutRoutine copyWith({String? name, List<WorkoutExercise>? items}) =>
      WorkoutRoutine(
        id: id,
        name: name ?? this.name,
        items: items ?? this.items,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'items': items.map((e) => e.toJson()).toList(),
  };

  static WorkoutRoutine fromJson(Map<String, dynamic> j) => WorkoutRoutine(
    id: j['id'] as String? ?? 'r${DateTime.now().microsecondsSinceEpoch}',
    name: j['name'] as String? ?? '',
    items: ((j['items'] as List?) ?? const [])
        .map((e) => WorkoutExercise.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
  );

  @override
  List<Object?> get props => [id, name, items];
}

/// 운동 모드 공통 설정 — 휴식·보이스 톤·덕킹·말해줄 것 토글(스펙: 전부 개별 OFF).
class WorkoutConfig {
  int restSec;
  String tone; // 'coach' | 'calm'
  bool duck;
  bool sayCount;
  bool saySetAnnounce;
  bool sayCallout;
  bool sayCountdown;
  bool sayCheer;
  bool sayPreview;

  WorkoutConfig({
    this.restSec = 15,
    this.tone = 'coach',
    this.duck = true,
    this.sayCount = true,
    this.saySetAnnounce = true,
    this.sayCallout = true,
    this.sayCountdown = true,
    this.sayCheer = true,
    this.sayPreview = true,
  });

  Map<String, dynamic> toJson() => {
    'restSec': restSec,
    'tone': tone,
    'duck': duck,
    'count': sayCount,
    'setAnn': saySetAnnounce,
    'callout': sayCallout,
    'countdown': sayCountdown,
    'cheer': sayCheer,
    'preview': sayPreview,
  };

  static WorkoutConfig fromJson(Map<String, dynamic> j) => WorkoutConfig(
    restSec: (j['restSec'] as num?)?.toInt() ?? 15,
    tone: j['tone'] as String? ?? 'coach',
    duck: j['duck'] as bool? ?? true,
    sayCount: j['count'] as bool? ?? true,
    saySetAnnounce: j['setAnn'] as bool? ?? true,
    sayCallout: j['callout'] as bool? ?? true,
    sayCountdown: j['countdown'] as bool? ?? true,
    sayCheer: j['cheer'] as bool? ?? true,
    sayPreview: j['preview'] as bool? ?? true,
  );
}

/// 운동 라이브러리 프리셋(스펙 §04) — libKey 는 l10n 키와 매핑된다.
class WorkoutLibEntry {
  final String libKey;
  final String? customName;
  final WorkoutType type;
  final int sets;
  final int reps;
  final double pace;
  final int dur;
  const WorkoutLibEntry(
    this.libKey,
    this.type, {
    this.customName,
    this.sets = 3,
    this.reps = 10,
    this.pace = 2.0,
    this.dur = 30,
  });

  bool get isCustom => customName != null;

  WorkoutExercise instantiate() => WorkoutExercise(
    id: 'w${DateTime.now().microsecondsSinceEpoch}',
    libKey: libKey,
    customName: customName,
    type: type,
    sets: sets,
    reps: reps,
    pace: pace,
    dur: dur,
  );

  Map<String, dynamic> toJson() => {
    'customName': customName,
    'type': type.name,
    'sets': sets,
    'reps': reps,
    'pace': pace,
    'dur': dur,
  };

  static WorkoutLibEntry fromJson(Map<String, dynamic> j) => WorkoutLibEntry(
    'custom',
    WorkoutType.values.firstWhere(
      (t) => t.name == j['type'],
      orElse: () => WorkoutType.reps,
    ),
    customName: j['customName'] as String?,
    sets: (j['sets'] as num?)?.toInt() ?? 3,
    reps: (j['reps'] as num?)?.toInt() ?? 10,
    pace: (j['pace'] as num?)?.toDouble() ?? 2.0,
    dur: (j['dur'] as num?)?.toInt() ?? 30,
  );
}

const workoutLibrary = [
  WorkoutLibEntry('squat', WorkoutType.reps, sets: 3, reps: 10, pace: 2.0),
  WorkoutLibEntry('pushup', WorkoutType.reps, sets: 3, reps: 10, pace: 1.5),
  WorkoutLibEntry('lunge', WorkoutType.reps, sets: 3, reps: 10, pace: 2.0),
  WorkoutLibEntry('burpee', WorkoutType.reps, sets: 2, reps: 8, pace: 3.0),
  WorkoutLibEntry('crunch', WorkoutType.reps, sets: 3, reps: 15, pace: 1.5),
  WorkoutLibEntry('plank', WorkoutType.time, dur: 30),
  WorkoutLibEntry('wallsit', WorkoutType.time, dur: 45),
  WorkoutLibEntry('pullup', WorkoutType.free, pace: 2.5),
];
