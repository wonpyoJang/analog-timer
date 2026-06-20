import 'package:flutter/material.dart';

/// 시계 나선·바늘 등 복잡한 배경 위에서 글자 가독성을 높이기 위한 어두운 외곽선.
///
/// TextStyle.shadows 에 8방향 그림자를 깔아 테두리처럼 보이게 한다(글자색과 공존).
/// 예: `style.copyWith(shadows: textOutline())`
List<Shadow> textOutline({
  Color color = const Color(0xFF0E0E0F),
  double width = 1.6,
}) {
  const dirs = <Offset>[
    Offset(-1, -1), Offset(1, -1), Offset(1, 1), Offset(-1, 1),
    Offset(0, -1), Offset(0, 1), Offset(-1, 0), Offset(1, 0),
  ];
  return [for (final d in dirs) Shadow(offset: d * width, color: color)];
}
