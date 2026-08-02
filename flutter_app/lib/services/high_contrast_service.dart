import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

/// 고대비 모드 — 켜면 2·3차 텍스트 색(muted/faint)을 더 밝게 올려 대비를 강화.
///
/// AppColors.muted/faint는 이 서비스가 세팅하는 정적 플래그(AppColors.highContrast)를
/// 읽는 getter라, 호출부 152곳을 바꾸지 않고 토글로 전역 전환된다. 앱 루트를
/// ValueListenableBuilder로 감싸 토글 시 리빌드→getter 재평가.
class HighContrastService {
  HighContrastService._();
  static final HighContrastService instance = HighContrastService._();

  static const String _kEnabled = 'high_contrast';

  final ValueNotifier<bool> enabledListenable = ValueNotifier<bool>(false);
  bool get enabled => enabledListenable.value;

  Future<void> init() async {
    try {
      final p = await SharedPreferences.getInstance();
      final v = p.getBool(_kEnabled) ?? false;
      enabledListenable.value = v;
      AppColors.highContrast = v;
    } catch (_) {}
  }

  Future<void> setEnabled(bool v) async {
    enabledListenable.value = v;
    AppColors.highContrast = v; // getter가 즉시 새 값을 반환
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kEnabled, v);
    } catch (_) {}
  }

  /// 오버레이 isolate 등에서 IPC로 받은 값을 반영(prefs 재저장 없이).
  void applyLive(bool v) {
    enabledListenable.value = v;
    AppColors.highContrast = v;
  }
}
