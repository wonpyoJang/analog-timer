import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0E0E0F);
  static const surface = Color(0xFF1A1A1C);
  static const border = Color(0xFF2E2E32);
  static const text = Color(0xFFE8E6E0);
  static const muted = Color(0xFF6B6968);
  /// muted 보다 더 옅은 3차 텍스트 — 메뉴 그룹 헤더·힌트·쉐브론 (시안 토큰).
  static const faint = Color(0xFF46443F);
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
