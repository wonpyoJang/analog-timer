import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 촉각 피드백(햅틱) — 시각/청각에 의존하지 않는 조작 확인용 접근성 기능.
///
/// 기본 ON, 설정 토글로 끈다(진동을 방해로 느끼는 사용자 대응). 모든 호출은
/// 토글을 확인한 뒤 실행하며, 실패는 조용히 무시(부가 기능이라 본체 무영향).
class HapticService {
  HapticService._();
  static final HapticService instance = HapticService._();

  static const String _kEnabled = 'haptics_enabled';

  final ValueNotifier<bool> enabledListenable = ValueNotifier<bool>(true);
  bool get enabled => enabledListenable.value;

  Future<void> init() async {
    try {
      final p = await SharedPreferences.getInstance();
      enabledListenable.value = p.getBool(_kEnabled) ?? true;
    } catch (_) {}
  }

  Future<void> setEnabled(bool v) async {
    enabledListenable.value = v;
    if (v) selection(); // 켤 때 즉시 미리듣기
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kEnabled, v);
    } catch (_) {}
  }

  /// 일반 버튼 탭 — 시작/일시정지/다음 등.
  void selection() {
    if (!enabled) return;
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// 중요 상태 전환 — 타이머 완료 등. 더 강한 진동.
  void impact() {
    if (!enabled) return;
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}
  }
}
