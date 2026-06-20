import 'package:flutter/material.dart';

/// 시계 나선·바늘 위 글자 가독성용 — 부드러운 어두운 후광.
///
/// 하드 외곽선(offset 그림자 8방향)은 작은 한글 글자의 가는 획 사이를 메워
/// 뭉개지므로, blur 후광을 여러 겹 쌓아 글자 모양은 유지한 채 배경과만 분리한다.
/// [layers] 가 클수록 후광이 진해진다.
List<Shadow> textOutline({
  Color color = const Color(0xCC060607),
  double blur = 3,
  int layers = 3,
}) =>
    [for (var i = 0; i < layers; i++) Shadow(color: color, blurRadius: blur)];
