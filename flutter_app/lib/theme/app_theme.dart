import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0E0E0F);
  static const surface = Color(0xFF1A1A1C);
  static const border = Color(0xFF2E2E32);
  static const text = Color(0xFFE8E6E0);
  // 접근성: 배경(bg/surface) 대비 WCAG AA 충족하도록 상향 (이슈 #38).
  //  muted #6B6968(3.5:1, AA 미달) → #908E8A(5.9:1 vs bg)
  //  faint #46443F(2.0:1, 대비 실패) → #7C7A76(4.5:1 vs bg)
  // 계층(text > muted > faint)은 유지.
  static const muted = Color(0xFF908E8A);

  /// muted 보다 더 옅은 3차 텍스트 — 메뉴 그룹 헤더·힌트·쉐브론 (시안 토큰).
  static const faint = Color(0xFF7C7A76);
  static const accent = Color(0xFFF0C040);
  static const timerOrange = Color(0xFFE07A52);
  static const timerOrangeDark = Color(0xFFC05A28);
  static const swGreen = Color(0xFF2EA84A);
  static const danger = Color(0xFFE05252);

  static const segColors = [
    Color(0xFFE05252),
    Color(0xFF52B0E0),
    Color(0xFF52E08E),
    Color(0xFFE07A52),
    Color(0xFFA052E0),
    Color(0xFFE0C052),
  ];
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.accent,
    ),
  );
}
