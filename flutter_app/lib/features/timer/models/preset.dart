import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import 'segment.dart';

/// 세그먼트 구성을 이름 붙여 저장·재사용하는 프리셋(템플릿).
///
/// 현재 실행 상태(timer_data)와는 별개로 prefs('presets')에 목록 저장된다.
class Preset {
  final String name;
  final List<Segment> segments;
  final bool loop;

  /// 기본(빌트인) 프리셋을 언어와 무관하게 식별하는 안정적 키.
  /// 사용자 프리셋은 null. prefs에는 저장하지 않는다.
  final String? builtinKey;

  const Preset({
    required this.name,
    required this.segments,
    required this.loop,
    this.builtinKey,
  });

  /// 적용할 때마다 새 [Segment] 인스턴스(=새 id)를 만들어, 같은 프리셋을
  /// 반복 적용해도 ReorderableListView 키(id)가 충돌하지 않게 한다.
  List<Segment> freshSegments() => [
    for (final s in segments)
      Segment(name: s.name, minutes: s.minutes, color: s.color),
  ];

  Map<String, dynamic> toJson() => {
    'name': name,
    'loop': loop,
    'segments': segments.map((s) => s.toJson()).toList(),
  };

  factory Preset.fromJson(Map<String, dynamic> json) => Preset(
    name: json['name'] as String,
    loop: json['loop'] as bool? ?? false,
    segments: (json['segments'] as List)
        .map((e) => Segment.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  /// 기존(영어 중립) 기본 프리셋 이름 — prefs 마이그레이션에서 걸러내는 용도.
  static const builtinEnNames = {'Pomodoro 25/5', '52/17', 'Deep work 90/20'};

  /// 현재 언어로 생성하는 기본 프리셋(집중=주황 segColors[3], 휴식=파랑 segColors[1]).
  static List<Preset> defaultsFor(AppLocalizations l) => [
    Preset(
      name: l.presetPomodoro,
      loop: true,
      builtinKey: 'pomodoro',
      segments: [
        Segment(name: l.segFocus, minutes: 25, color: AppColors.segColors[3]),
        Segment(name: l.segBreak, minutes: 5, color: AppColors.segColors[1]),
      ],
    ),
    Preset(
      name: l.preset5217,
      loop: true,
      builtinKey: 'fifty2seventeen',
      segments: [
        Segment(name: l.segFocus, minutes: 52, color: AppColors.segColors[3]),
        Segment(name: l.segBreak, minutes: 17, color: AppColors.segColors[1]),
      ],
    ),
    Preset(
      name: l.presetDeepwork,
      loop: false,
      builtinKey: 'deepwork',
      segments: [
        Segment(name: l.segFocus, minutes: 90, color: AppColors.segColors[3]),
        Segment(name: l.segBreak, minutes: 20, color: AppColors.segColors[1]),
      ],
    ),
  ];
}
