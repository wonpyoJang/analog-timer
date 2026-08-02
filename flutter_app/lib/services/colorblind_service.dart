import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 색맹 모드 — 켜면 시계 진행 표시를 색 외 형태(점선 등)로도 구분한다.
///
/// 기본 OFF: 일반 사용자의 기존 화면(채운 쐐기+실선 호)은 그대로 두고,
/// 색맹 사용자만 설정에서 켜서 스톱워치 호를 점선(dashed)으로 본다.
class ColorblindService {
  ColorblindService._();
  static final ColorblindService instance = ColorblindService._();

  static const String _kEnabled = 'colorblind_mode';

  final ValueNotifier<bool> enabledListenable = ValueNotifier<bool>(false);
  bool get enabled => enabledListenable.value;

  Future<void> init() async {
    try {
      final p = await SharedPreferences.getInstance();
      enabledListenable.value = p.getBool(_kEnabled) ?? false;
    } catch (_) {}
  }

  Future<void> setEnabled(bool v) async {
    enabledListenable.value = v;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kEnabled, v);
    } catch (_) {}
  }
}
