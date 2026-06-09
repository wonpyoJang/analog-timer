import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class Segment extends Equatable {
  final String name;
  final int minutes;
  final Color color;

  const Segment({
    required this.name,
    required this.minutes,
    required this.color,
  });

  Segment copyWith({String? name, int? minutes, Color? color}) => Segment(
    name: name ?? this.name,
    minutes: minutes ?? this.minutes,
    color: color ?? this.color,
  );

  Duration get duration => Duration(minutes: minutes);

  Map<String, dynamic> toJson() => {
    'name': name,
    'minutes': minutes,
    'colorValue': color.toARGB32(),
  };

  static Segment fromJson(Map<String, dynamic> json) => Segment(
    name: json['name'] as String,
    minutes: (json['minutes'] as num).toInt(),
    color: Color(json['colorValue'] as int),
  );

  static List<Segment> get defaults => [
    Segment(name: '할 것 1', minutes: 2, color: AppColors.segColors[3]),
    Segment(name: '휴식 1', minutes: 5, color: AppColors.segColors[1]),
    Segment(name: '할 것 2', minutes: 5, color: AppColors.segColors[3]),
    Segment(name: '휴식 2', minutes: 5, color: AppColors.segColors[1]),
    Segment(name: '할 것 3', minutes: 10, color: AppColors.segColors[3]),
    Segment(name: '휴식 3', minutes: 5, color: AppColors.segColors[1]),
    Segment(name: '할 것 4', minutes: 15, color: AppColors.segColors[3]),
    Segment(name: '휴식 4', minutes: 5, color: AppColors.segColors[1]),
  ];

  @override
  List<Object?> get props => [name, minutes, color];
}
