import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class Segment extends Equatable {
  /// 리스트 재정렬(ReorderableListView) 키 등 UI 식별용. 동등성에는 포함하지 않는다.
  final String id;
  final String name;
  final int minutes;
  final Color color;

  Segment({
    String? id,
    required this.name,
    required this.minutes,
    required this.color,
  }) : id = id ?? _nextId();

  static int _idCounter = 0;
  static String _nextId() =>
      's${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

  Segment copyWith({String? name, int? minutes, Color? color}) => Segment(
    id: id,
    name: name ?? this.name,
    minutes: minutes ?? this.minutes,
    color: color ?? this.color,
  );

  Duration get duration => Duration(minutes: minutes);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'minutes': minutes,
    'colorValue': color.toARGB32(),
  };

  static Segment fromJson(Map<String, dynamic> json) => Segment(
    id: json['id'] as String?,
    name: json['name'] as String,
    minutes: (json['minutes'] as num).toInt(),
    color: Color(json['colorValue'] as int),
  );

  static List<Segment> get defaults => [
    Segment(name: 'Task 1', minutes: 2, color: AppColors.segColors[3]),
    Segment(name: 'Break 1', minutes: 5, color: AppColors.segColors[1]),
    Segment(name: 'Task 2', minutes: 5, color: AppColors.segColors[3]),
    Segment(name: 'Break 2', minutes: 5, color: AppColors.segColors[1]),
    Segment(name: 'Task 3', minutes: 10, color: AppColors.segColors[3]),
    Segment(name: 'Break 3', minutes: 5, color: AppColors.segColors[1]),
    Segment(name: 'Task 4', minutes: 15, color: AppColors.segColors[3]),
    Segment(name: 'Break 4', minutes: 5, color: AppColors.segColors[1]),
  ];

  // id 는 제외 — 내용(이름/분/색)이 같으면 동등하게 취급(기존 동작 유지).
  @override
  List<Object?> get props => [name, minutes, color];
}
