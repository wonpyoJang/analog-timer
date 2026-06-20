import '../../../theme/app_theme.dart';
import 'segment.dart';

/// 세그먼트 구성을 이름 붙여 저장·재사용하는 프리셋(템플릿).
///
/// 현재 실행 상태(timer_data)와는 별개로 prefs('presets')에 목록 저장된다.
class Preset {
  final String name;
  final List<Segment> segments;
  final bool loop;

  const Preset({required this.name, required this.segments, required this.loop});

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

  /// 처음 실행 시 미리 제공되는 기본 프리셋. (집중=주황, 휴식=파랑)
  static List<Preset> get defaults => [
    Preset(
      name: '뽀모도로 25/5',
      loop: true,
      segments: [
        Segment(name: '집중', minutes: 25, color: AppColors.segColors[3]),
        Segment(name: '휴식', minutes: 5, color: AppColors.segColors[1]),
      ],
    ),
    Preset(
      name: '52/17',
      loop: true,
      segments: [
        Segment(name: '집중', minutes: 52, color: AppColors.segColors[3]),
        Segment(name: '휴식', minutes: 17, color: AppColors.segColors[1]),
      ],
    ),
    Preset(
      name: '딥워크 90/20',
      loop: false,
      segments: [
        Segment(name: '집중', minutes: 90, color: AppColors.segColors[3]),
        Segment(name: '휴식', minutes: 20, color: AppColors.segColors[1]),
      ],
    ),
  ];
}
