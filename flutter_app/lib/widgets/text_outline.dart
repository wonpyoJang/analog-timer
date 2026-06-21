import 'package:flutter/material.dart';

/// 글자 가독성용 드롭 섀도. 아래쪽 한 방향으로만 떨어져, 사방 halo 와 달리
/// 작은 한글 획 사이를 메우지 않으면서 입체감·배경 분리를 더한다.
List<Shadow> textOutline({
  Color color = const Color(0xCC0A0A0C),
  Offset offset = const Offset(0, 1.5),
  double blur = 2,
}) =>
    [Shadow(color: color, offset: offset, blurRadius: blur)];

/// 가변 배경(흰 다이얼 · 색 부채꼴 · 시침/분침) 위 글자 가독성용 —
/// stroke 외곽선 + drop shadow 를 함께 입힌다.
///
/// 글자를 두 번 그린다: 아래 레이어는 윤곽선(stroke)에 그림자([shadows])를 얹고,
/// 위 레이어는 원래 색으로 채워 stroke 안쪽 두께를 복구한다. 윤곽선이 배경과
/// 또렷하게 분리하고, 그림자가 입체감을 더한다.
///
/// [strokeWidth] 는 폰트 크기에 맞춰 줄 것 — 작은 한글(13~16px)은 1.2~1.5,
/// 큰 숫자(26~48px)는 2.4~3.2 정도. [shadows] 미지정 시 기본 drop shadow.
class OutlinedText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color strokeColor;
  final double strokeWidth;
  final List<Shadow>? shadows;

  const OutlinedText(
    this.text, {
    super.key,
    required this.style,
    this.strokeColor = const Color(0xE6101012),
    this.strokeWidth = 1.6,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 아래: 외곽선 + 그림자. copyWith 에 foreground 를 주면 color 는 무시된다.
        Text(
          text,
          style: style.copyWith(
            shadows: shadows ?? textOutline(),
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..strokeJoin = StrokeJoin.round
              ..color = strokeColor,
          ),
        ),
        // 위: 원래 색으로 채워 stroke 가 잠식한 안쪽 두께를 복구.
        Text(text, style: style),
      ],
    );
  }
}
