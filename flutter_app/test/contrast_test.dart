import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:analog_timer/theme/app_theme.dart';

// WCAG 2.1 상대 휘도 + 대비비 — 텍스트 색이 배경 대비 읽히는지 수치로 검증.
double _lin(int c) {
  final s = c / 255.0;
  return s <= 0.03928
      ? s / 12.92
      : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
}

double _luminance(Color c) {
  final r = (c.r * 255).round();
  final g = (c.g * 255).round();
  final b = (c.b * 255).round();
  return 0.2126 * _lin(r) + 0.7152 * _lin(g) + 0.0722 * _lin(b);
}

double contrast(Color fg, Color bg) {
  final a = _luminance(fg), b = _luminance(bg);
  final hi = math.max(a, b), lo = math.min(a, b);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('WCAG 텍스트 대비 (이슈 #38 접근성)', () {
    // 배경: bg(본문)·surface(카드). 둘 다에서 통과해야 한다.
    const backgrounds = [AppColors.bg, AppColors.surface];

    test('본문 text — AA 일반(4.5:1)', () {
      for (final b in backgrounds) {
        expect(contrast(AppColors.text, b), greaterThanOrEqualTo(4.5));
      }
    });

    test('muted(부제·힌트) — AA 일반(4.5:1)', () {
      for (final b in backgrounds) {
        expect(
          contrast(AppColors.muted, b),
          greaterThanOrEqualTo(4.5),
          reason:
              'muted 대비 ${contrast(AppColors.muted, b).toStringAsFixed(2)}:1',
        );
      }
    });

    test('faint(3차 텍스트) — 최소 AA 큰텍스트(3.0:1)', () {
      for (final b in backgrounds) {
        expect(
          contrast(AppColors.faint, b),
          greaterThanOrEqualTo(3.0),
          reason:
              'faint 대비 ${contrast(AppColors.faint, b).toStringAsFixed(2)}:1',
        );
      }
    });

    test('시각 계층 유지 — text > muted > faint', () {
      final t = _luminance(AppColors.text);
      final m = _luminance(AppColors.muted);
      final f = _luminance(AppColors.faint);
      expect(t, greaterThan(m));
      expect(m, greaterThan(f));
    });
  });
}
