import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 두 오버레이 시스템의 상호 배타 조정자.
///
/// 단일 오버레이(flutter_overlay_window, 별도 FlutterEngine)와 멀티 네이티브
/// 오버레이(엔진 0개)를 동시에 켜면, 살아있는 2nd 엔진이 플랫폼 스레드를 60fps로
/// 잠식해 멀티 오버레이의 표시 지연·드래그 지연·서비스 ANR을 유발한다.
/// [enabled] 이면 하나를 켤 때 다른 하나를 끈다(각 화면이 훅을 등록). 설정에서 끄면
/// 두 오버레이를 동시에 띄울 수 있다(경합은 사용자가 감수).
class OverlayCoordinator {
  OverlayCoordinator._();
  static final OverlayCoordinator instance = OverlayCoordinator._();

  static const String _kEnabled = 'overlay_mutex';

  /// 기본 ON — 경합/ANR을 막는 안전한 기본값.
  final ValueNotifier<bool> enabledListenable = ValueNotifier<bool>(true);
  bool get enabled => enabledListenable.value;

  /// 단일 오버레이를 끄는 훅 — home_screen 이 등록.
  Future<void> Function()? hideSingleOverlay;

  /// 멀티 오버레이를 전부 끄는 훅 — multi_timer_screen 이 등록.
  Future<void> Function()? closeMultiOverlays;

  Future<void> init() async {
    try {
      final p = await SharedPreferences.getInstance();
      enabledListenable.value = p.getBool(_kEnabled) ?? true;
    } catch (_) {}
  }

  Future<void> setEnabled(bool v) async {
    enabledListenable.value = v;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kEnabled, v);
    } catch (_) {}
  }

  /// 멀티 오버레이가 켜졌다 → 단일 오버레이를 끈다.
  Future<void> onMultiOverlayEnabled() async {
    if (!enabled) return;
    await hideSingleOverlay?.call();
  }

  /// 단일 오버레이가 켜졌다 → 멀티 오버레이를 전부 끈다.
  Future<void> onSingleOverlayEnabled() async {
    if (!enabled) return;
    await closeMultiOverlays?.call();
  }
}
