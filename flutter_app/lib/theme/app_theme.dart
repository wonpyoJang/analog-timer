import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0E0E0F);
  static const surface = Color(0xFF1A1A1C);
  static const border = Color(0xFF2E2E32);
  static const text = Color(0xFFE8E6E0);

  /// 고대비 모드 플래그 — HighContrastService가 세팅. muted/faint getter가 읽어
  /// 앱 전역(호출부 152곳)을 토글로 전환. 기본 대비는 이미 WCAG AA(이슈 #38).
  static bool highContrast = false;

  // 기본: bg 대비 AA 충족(muted 5.9:1, faint 4.5:1).
  // 고대비: text에 가깝게 상향(muted ~10:1, faint ~7:1 AAA급).
  static const _mutedBase = Color(0xFF908E8A);
  static const _mutedHC = Color(0xFFC6C4C0);
  static const _faintBase = Color(0xFF7C7A76);
  static const _faintHC = Color(0xFFABA9A4);

  static Color get muted => highContrast ? _mutedHC : _mutedBase;

  /// muted 보다 더 옅은 3차 텍스트 — 메뉴 그룹 헤더·힌트·쉐브론 (시안 토큰).
  static Color get faint => highContrast ? _faintHC : _faintBase;
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
