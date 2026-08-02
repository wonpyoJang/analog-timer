import 'dart:math';
import 'package:flutter/material.dart';
import '../features/timer/bloc/timer_state.dart';
import '../features/stopwatch/bloc/stopwatch_state.dart';

class ClockPainter extends CustomPainter {
  final TimerState timerState;
  final StopwatchState swState;
  final DateTime now;

  /// 색맹 모드 — 켜지면 스톱워치 호를 점선으로(색 외 형태 구분).
  final bool colorblind;

  ClockPainter({
    required this.timerState,
    required this.swState,
    required this.now,
    this.colorblind = false,
  });

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

  void _drawFace(Canvas canvas, double cx, double cy, double R) {
    // White fill
    canvas.drawCircle(Offset(cx, cy), R, Paint()..color = Colors.white);
    // Outer border
    canvas.drawCircle(
      Offset(cx, cy),
      R,
      Paint()
        ..color = const Color(0xFF111111)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7,
    );
    // Inner ring
    canvas.drawCircle(
      Offset(cx, cy),
      R - 6,
      Paint()
        ..color = const Color(0xFF555555)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  // 타이머: 분침 위치부터 시계 방향 쐐기. 60분 초과 시 안쪽 링 추가.
  void _drawTimerSpiral(Canvas canvas, double cx, double cy, double R) {
    if (timerState.status == TimerStatus.idle ||
        timerState.status == TimerStatus.done) {
      return;
    }
    final seg = timerState.currentSegment;
    if (seg == null) return;

    final remainMs = timerState.segRemainMs.clamp(
      0,
      seg.duration.inMilliseconds,
    );
    if (remainMs <= 0) return;

    final remainMin = remainMs / 60000.0;
    final minAngle = _minuteHandAngle();
    final color = seg.color;

    const ringW = 16.0;
    const gap = 3.0;
    const step = ringW + gap;
    const innermost = 14.0;
    final rOuter = R * 0.79;

    final fullLaps = remainMin ~/ 60;
    final partialMin = remainMin % 60;

    // 완전한 60분 바퀴 → 안쪽 링(반투명)
    for (int ring = 0; ring < fullLaps; ring++) {
      final r = innermost + ring * step + ringW / 2;
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..color = color.withAlpha(0x77)
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringW
          ..strokeCap = StrokeCap.butt,
      );
    }

    // 현재 바퀴 → 쐐기
    if (partialMin > 0) {
      final sweep = (partialMin / 60) * 2 * pi;
      final innerR = innermost + fullLaps * step;

      final path = Path();
      final rect = Rect.fromCircle(center: Offset(cx, cy), radius: rOuter);
      path.arcTo(rect, minAngle, sweep, true);

      final innerRect = Rect.fromCircle(center: Offset(cx, cy), radius: innerR);
      path.arcTo(innerRect, minAngle + sweep, -sweep, false);
      path.close();

      canvas.drawPath(path, Paint()..color = color.withAlpha(0xCC));
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  // 스톱워치: 바깥 테두리부터 안쪽으로 링 채움. 1바퀴 = 60분.
  void _drawStopwatchRings(Canvas canvas, double cx, double cy, double R) {
    if (!swState.running && swState.elapsedMs == 0) return;

    final totalMs = swState.elapsedMs;
    if (totalMs <= 0) return;

    final elapsedMin = totalMs / 60000.0;
    const ringW = 13.0;
    const gap = 2.0;
    const step = ringW + gap;
    final outermost = R - 9;
    final maxRings = ((outermost - 36) / step).floor();

    final fullLaps = elapsedMin ~/ 60;
    final partialMin = elapsedMin % 60;
    final startAngle = swState.startAngleRadians ?? _minuteHandAngle();
    const swColor = Color(0xFF2EA84A);

    // 완성 바퀴 (바깥 → 안). 색맹 모드에서만 점선(색 외 형태 구분), 기본은 실선.
    for (int ring = 0; ring < min(fullLaps, maxRings); ring++) {
      final r = outermost - ring * step - ringW / 2;
      final paint = Paint()
        ..color = swColor.withAlpha(0x77)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringW
        ..strokeCap = StrokeCap.butt;
      if (colorblind) {
        _drawDashedArc(
          canvas,
          Rect.fromCircle(center: Offset(cx, cy), radius: r),
          -pi / 2,
          2 * pi,
          paint,
        );
      } else {
        canvas.drawCircle(Offset(cx, cy), r, paint);
      }
    }

    // 현재 진행 링
    final curRing = min(fullLaps, maxRings - 1);
    if (curRing >= 0 && partialMin > 0) {
      final r = outermost - curRing * step - ringW / 2;
      final sweep = (partialMin / 60) * 2 * pi;
      final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
      final paint = Paint()
        ..color = swColor.withAlpha(0xCC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringW
        ..strokeCap = colorblind ? StrokeCap.butt : StrokeCap.round;
      if (colorblind) {
        _drawDashedArc(canvas, rect, startAngle, sweep, paint);
      } else {
        canvas.drawArc(rect, startAngle, sweep, false, paint);
      }
    }
  }

  /// 색맹 안전 패턴용 점선 호 — dash/gap(라디안 단위)으로 반복 렌더.
  void _drawDashedArc(
    Canvas canvas,
    Rect rect,
    double start,
    double sweep,
    Paint paint, {
    double dash = 0.13,
    double gap = 0.07,
  }) {
    final end = start + sweep;
    double a = start;
    while (a < end) {
      final seg = min(dash, end - a);
      canvas.drawArc(rect, a, seg, false, paint);
      a += dash + gap;
    }
  }

  void _drawTicks(Canvas canvas, double cx, double cy, double R) {
    for (int i = 0; i < 60; i++) {
      final angle = (i / 60) * 2 * pi - pi / 2;
      final isQ = i % 15 == 0;
      final isM = i % 5 == 0;
      final r0 = isQ
          ? R - 22
          : isM
          ? R - 16
          : R - 9;
      canvas.drawLine(
        Offset(cx + cos(angle) * r0, cy + sin(angle) * r0),
        Offset(cx + cos(angle) * (R - 7), cy + sin(angle) * (R - 7)),
        Paint()
          ..color = isQ
              ? Colors.black
              : isM
              ? const Color(0xFF333333)
              : const Color(0xFFAAAAAA)
          ..strokeWidth = isQ
              ? 5
              : isM
              ? 2.5
              : 1
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _drawNumbers(Canvas canvas, double cx, double cy, double R) {
    if (R < 10) return;
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 1; i <= 12; i++) {
      final angle = (i / 12) * 2 * pi - pi / 2;
      tp.text = TextSpan(
        text: '$i',
        style: TextStyle(
          color: const Color(0xFF111111),
          fontSize: (R * 0.13).clamp(1.0, double.infinity),
          fontWeight: FontWeight.w700,
          fontFamily: 'Pretendard',
        ),
      );
      tp.layout();
      final dx = cx + cos(angle) * (R - 35) - tp.width / 2;
      final dy = cy + sin(angle) * (R - 35) - tp.height / 2;
      tp.paint(canvas, Offset(dx, dy));
    }
  }

  void _drawHands(Canvas canvas, double cx, double cy, double R) {
    final h = now.hour % 12;
    final m = now.minute;
    final s = now.second;
    final ms = now.millisecond;

    final secA = ((s + ms / 1000) / 60) * 2 * pi - pi / 2;
    final minA = ((m + (s + ms / 1000) / 60) / 60) * 2 * pi - pi / 2;
    final hourA = ((h + m / 60) / 12) * 2 * pi - pi / 2;

    _drawHand(canvas, cx, cy, hourA, R * 0.48, 10, const Color(0xFF111111));
    _drawHand(canvas, cx, cy, minA, R * 0.66, 7, const Color(0xFF111111));
    _drawHand(canvas, cx, cy, secA, R * 0.79, 2, const Color(0xFFDD2222));
    _drawHand(canvas, cx, cy, secA + pi, R * 0.17, 2, const Color(0xFFDD2222));

    // Center dot
    canvas.drawCircle(
      Offset(cx, cy),
      10,
      Paint()..color = const Color(0xFFDD2222),
    );
    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = Colors.white);
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

  double _minuteHandAngle() {
    final m = now.minute;
    final s = now.second;
    final ms = now.millisecond;
    return ((m + (s + ms / 1000) / 60) / 60) * 2 * pi - pi / 2;
  }

  @override
  bool shouldRepaint(ClockPainter old) =>
      old.timerState != timerState ||
      old.swState != swState ||
      old.colorblind != colorblind ||
      old.now.second != now.second ||
      old.now.millisecond != now.millisecond;
}
