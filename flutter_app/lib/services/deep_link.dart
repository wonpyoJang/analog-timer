/// 딥링크 파서(디자인 "음성 어시스턴트 연동 기획" §3).
///
/// 단축어·루틴·워치·핫키·향후 App Functions까지 전부 같은 `anytime://` URI를
/// 호출한다 — 입구가 늘어도 파싱·동작은 한 곳. 순수 함수(URI → action)라
/// 유닛테스트로 잠근다. v2 App Functions 는 이 함수 위에 스키마만 얹으면 된다.
library;

enum DeepLinkKind {
  start, // anytime://start?min=&sec=&label=&color=
  preset, // anytime://preset/{id}
  loop, // anytime://loop/{id}?rounds=
  extend, // anytime://extend?min=&target=
  stop, // anytime://stop?target=&all=1
  ack, // anytime://ack?target=
  workout, // anytime://workout/{id}
  status, // anytime://status
  unknown,
}

class DeepLinkAction {
  final DeepLinkKind kind;
  final bool silent; // ?silent=1 — 앱 전면 안 띄우고 pill 만 갱신
  final int? min;
  final int? sec;
  final String? label;
  final int? color;
  final String? id; // preset/loop/workout id
  final int? rounds;
  final String? target; // 대상 타이머 이름/id
  final bool all; // stop?all=1

  const DeepLinkAction({
    required this.kind,
    this.silent = false,
    this.min,
    this.sec,
    this.label,
    this.color,
    this.id,
    this.rounds,
    this.target,
    this.all = false,
  });

  /// start 류의 총 밀리초(min·sec 조합). 값이 없으면 null.
  int? get totalMs {
    if (min == null && sec == null) return null;
    return ((min ?? 0) * 60 + (sec ?? 0)) * 1000;
  }

  @override
  String toString() =>
      'DeepLinkAction($kind, silent=$silent, min=$min, sec=$sec, '
      'label=$label, id=$id, rounds=$rounds, target=$target, all=$all)';
}

/// `anytime://...` 문자열을 파싱한다. 스킴이 다르거나 못 읽으면 unknown.
DeepLinkAction parseDeepLink(String raw) {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null || uri.scheme != 'anytime') {
    return const DeepLinkAction(kind: DeepLinkKind.unknown);
  }
  final q = uri.queryParameters;
  final silent = q['silent'] == '1' || q['silent'] == 'true';

  // host 가 명령, 경로 첫 세그먼트가 id(preset/loop/workout).
  final host = uri.host.isNotEmpty ? uri.host : _firstSeg(uri);
  final seg = uri.host.isNotEmpty
      ? (uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null)
      : _secondSeg(uri);

  int? intOf(String? s) => s == null ? null : int.tryParse(s);

  switch (host) {
    case 'start':
      return DeepLinkAction(
        kind: DeepLinkKind.start,
        silent: silent,
        min: intOf(q['min']),
        sec: intOf(q['sec']),
        label: q['label'],
        color: intOf(q['color']),
      );
    case 'preset':
      return DeepLinkAction(kind: DeepLinkKind.preset, silent: silent, id: seg);
    case 'loop':
      return DeepLinkAction(
        kind: DeepLinkKind.loop,
        silent: silent,
        id: seg,
        rounds: intOf(q['rounds']),
      );
    case 'extend':
      return DeepLinkAction(
        kind: DeepLinkKind.extend,
        silent: silent,
        min: intOf(q['min']),
        target: q['target'],
      );
    case 'stop':
      return DeepLinkAction(
        kind: DeepLinkKind.stop,
        silent: silent,
        target: q['target'],
        all: q['all'] == '1' || q['all'] == 'true',
      );
    case 'ack':
      return DeepLinkAction(
        kind: DeepLinkKind.ack,
        silent: silent,
        target: q['target'],
      );
    case 'workout':
      return DeepLinkAction(
        kind: DeepLinkKind.workout,
        silent: silent,
        id: seg,
      );
    case 'status':
      return const DeepLinkAction(kind: DeepLinkKind.status);
    default:
      return const DeepLinkAction(kind: DeepLinkKind.unknown);
  }
}

// `anytime:///preset/x` 처럼 host 가 비어 path 로만 오는 변형 대비.
String? _firstSeg(Uri u) =>
    u.pathSegments.isNotEmpty ? u.pathSegments.first : null;
String? _secondSeg(Uri u) =>
    u.pathSegments.length > 1 ? u.pathSegments[1] : null;
