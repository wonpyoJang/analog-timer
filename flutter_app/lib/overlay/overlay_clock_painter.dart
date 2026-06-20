import 'dart:math';
import 'package:flutter/material.dart';

/// 오버레이(모바일 플로팅 위젯 / 데스크톱 always-on-top 서브윈도우) 공용
/// 아날로그 클록 페인터 — 메인 앱 ClockPainter 와 동일한 디자인을 R 비례로 환산.
class OverlayClockPainter extends CustomPainter {
  final DateTime now;
  final bool timerActive;
  final int segRemainMs;
  final Color segColor;
  final bool swActive;
  final int swElapsedMs;
  final double? swStartAngleRad;

  const OverlayClockPainter({
    required this.now,
    required this.timerActive,
    required this.segRemainMs,
    required this.segColor,
    required this.swActive,
    required this.swElapsedMs,
    required this.swStartAngleRad,
  });

  double _minuteHandAngle() {
    final m = now.minute;
    final s = now.second;
    final ms = now.millisecond;
    return ((m + (s + ms / 1000) / 60) / 60) * 2 * pi - pi / 2;
  }

  void _drawFace(Canvas canvas, double cx, double cy, double R) {
    canvas.drawCircle(Offset(cx, cy), R, Paint()..color = Colors.white);
    canvas.drawCircle(
      Offset(cx, cy),
      R,
      Paint()
        ..color = const Color(0xFF111111)
        ..style = PaintingStyle.stroke
        ..strokeWidth = R * 0.044, // 7px at R=160
    );
    canvas.drawCircle(
      Offset(cx, cy),
      R - R * 0.038, // 6px offset at R=160
      Paint()
        ..color = const Color(0xFF555555)
        ..style = PaintingStyle.stroke
        ..strokeWidth = R * 0.009, // 1.5px at R=160
    );
  }

  void _drawTimerSpiral(Canvas canvas, double cx, double cy, double R) {
    if (!timerActive || segRemainMs <= 0) return;
    final remainMin = segRemainMs / 60000.0;
    final minAngle = _minuteHandAngle();
    final ringW = R * 0.100; // 16px at R=160
    final gap = R * 0.019; // 3px  at R=160
    final step = ringW + gap;
    final innermost = R * 0.088; // 14px at R=160
    final rOuter = R * 0.79;
    final fullLaps = remainMin ~/ 60;
    final partialMin = remainMin % 60;
    for (int ring = 0; ring < fullLaps; ring++) {
      final r = innermost + ring * step + ringW / 2;
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = segColor.withAlpha(0x77)
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringW
          ..strokeCap = StrokeCap.butt,
      );
    }
    if (partialMin > 0) {
      final sweep = (partialMin / 60) * 2 * pi;
      final innerR = innermost + fullLaps * step;
      final path = Path();
      path.arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: rOuter),
        minAngle,
        sweep,
        true,
      );
      path.arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: innerR),
        minAngle + sweep,
        -sweep,
        false,
      );
      path.close();
      canvas.drawPath(path, Paint()..color = segColor.withAlpha(0xCC));
      canvas.drawPath(
        path,
        Paint()
          ..color = segColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _drawStopwatchRings(Canvas canvas, double cx, double cy, double R) {
    if (!swActive || swElapsedMs <= 0) return;
    final elapsedMin = swElapsedMs / 60000.0;
    final ringW = R * 0.081; // 13px at R=160
    final gap = R * 0.013; // 2px  at R=160
    final step = ringW + gap;
    final outermost = R - R * 0.056; // R-9 at R=160
    final innerLimit = R * 0.225; // 36px at R=160
    final maxRings = ((outermost - innerLimit) / step).floor();
    final fullLaps = elapsedMin ~/ 60;
    final partialMin = elapsedMin % 60;
    final startAngle = swStartAngleRad ?? _minuteHandAngle();
    const swColor = Color(0xFF2EA84A);
    for (int ring = 0; ring < min(fullLaps, maxRings); ring++) {
      final r = outermost - ring * step - ringW / 2;
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = swColor.withAlpha(0x77)
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringW
          ..strokeCap = StrokeCap.butt,
      );
    }
    final curRing = min(fullLaps, maxRings - 1);
    if (curRing >= 0 && partialMin > 0) {
      final r = outermost - curRing * step - ringW / 2;
      final sweep = (partialMin / 60) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        startAngle,
        sweep,
        false,
        Paint()
          ..color = swColor.withAlpha(0xCC)
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringW
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawTicks(Canvas canvas, double cx, double cy, double R) {
    final rOuter = R - R * 0.044; // R-7 at R=160
    for (int i = 0; i < 60; i++) {
      final angle = (i / 60) * 2 * pi - pi / 2;
      final isQ = i % 15 == 0;
      final isM = i % 5 == 0;
      final r0 = isQ
          ? R - R * 0.138 // R-22 at R=160
          : isM
              ? R - R * 0.100 // R-16 at R=160
              : R - R * 0.056; // R-9  at R=160
      canvas.drawLine(
        Offset(cx + cos(angle) * r0, cy + sin(angle) * r0),
        Offset(cx + cos(angle) * rOuter, cy + sin(angle) * rOuter),
        Paint()
          ..color = isQ
              ? Colors.black
              : isM
                  ? const Color(0xFF333333)
                  : const Color(0xFFAAAAAA)
          ..strokeWidth = isQ
              ? R * 0.031 // 5px at R=160
              : isM
                  ? R * 0.016 // 2.5px at R=160
                  : R * 0.006 // 1px at R=160
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawNumbers(Canvas canvas, double cx, double cy, double R) {
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 1; i <= 12; i++) {
      final angle = (i / 12) * 2 * pi - pi / 2;
      tp.text = TextSpan(
        text: '$i',
        style: TextStyle(
          color: const Color(0xFF111111),
          fontSize: R * 0.13,
          fontWeight: FontWeight.w700,
          fontFamily: 'Pretendard',
        ),
      );
      tp.layout();
      final numR = R * 0.781; // R-35 at R=160
      final dx = cx + cos(angle) * numR - tp.width / 2;
      final dy = cy + sin(angle) * numR - tp.height / 2;
      tp.paint(canvas, Offset(dx, dy));
    }
  }

  void _drawHand(
    Canvas canvas,
    double cx,
    double cy,
    double angle,
    double len,
    double width,
    Color color,
  ) {
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + cos(angle) * len, cy + sin(angle) * len),
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawHands(Canvas canvas, double cx, double cy, double R) {
    final h = now.hour % 12;
    final m = now.minute;
    final s = now.second;
    final ms = now.millisecond;
    final secA = ((s + ms / 1000) / 60) * 2 * pi - pi / 2;
    final minA = ((m + (s + ms / 1000) / 60) / 60) * 2 * pi - pi / 2;
    final hourA = ((h + m / 60) / 12) * 2 * pi - pi / 2;
    _drawHand(canvas, cx, cy, hourA, R * 0.48, R * 0.063, const Color(0xFF111111));
    _drawHand(canvas, cx, cy, minA, R * 0.66, R * 0.044, const Color(0xFF111111));
    _drawHand(canvas, cx, cy, secA, R * 0.79, R * 0.013, const Color(0xFFDD2222));
    _drawHand(canvas, cx, cy, secA + pi, R * 0.17, R * 0.013, const Color(0xFFDD2222));
    canvas.drawCircle(
      Offset(cx, cy),
      R * 0.063, // 10px at R=160
      Paint()..color = const Color(0xFFDD2222),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      R * 0.025,
      Paint()..color = Colors.white,
    ); // 4px at R=160
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final R = size.width / 2 - 4;
    _drawFace(canvas, cx, cy, R);
    _drawTimerSpiral(canvas, cx, cy, R);
    _drawStopwatchRings(canvas, cx, cy, R);
    _drawTicks(canvas, cx, cy, R);
    _drawNumbers(canvas, cx, cy, R);
    _drawHands(canvas, cx, cy, R);
  }

  @override
  bool shouldRepaint(OverlayClockPainter old) =>
      old.now.second != now.second ||
      old.now.millisecond != now.millisecond ||
      old.timerActive != timerActive ||
      old.segRemainMs != segRemainMs ||
      old.segColor != segColor ||
      old.swActive != swActive ||
      old.swElapsedMs != swElapsedMs ||
      old.swStartAngleRad != swStartAngleRad;
}
