import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../overlay/multi_overlay_service.dart';

/// 오버레이 pill 표시 설정(디자인 "설정 상세 페이지" §D).
///
/// 크기·붙는 위치·이름 표시·잠금화면 표시·완료 자동 숨김. 값이 바뀌면 네이티브
/// (MultiOverlayService)에 즉시 push 해 살아있는 pill 을 재생성한다.
class OverlaySettingsService {
  OverlaySettingsService._();
  static final OverlaySettingsService instance = OverlaySettingsService._();

  static const _kSizeDp = 'overlay_size_dp'; // 88 · 108 · 132
  static const _kSideRight = 'overlay_side_right';
  static const _kShowName = 'overlay_show_name';
  static const _kShowOnLock = 'overlay_show_on_lock';
  static const _kAutoHideDone = 'overlay_auto_hide_done';

  final ValueNotifier<int> sizeDp = ValueNotifier<int>(108);
  final ValueNotifier<bool> sideRight = ValueNotifier<bool>(false);
  final ValueNotifier<bool> showName = ValueNotifier<bool>(true);
  final ValueNotifier<bool> showOnLock = ValueNotifier<bool>(false);

  /// 완료·확인된 pill 을 자동으로 닫는다(Dart 측 _syncOverlays 가 참조).
  final ValueNotifier<bool> autoHideDone = ValueNotifier<bool>(false);

  Future<void> init() async {
    try {
      final p = await SharedPreferences.getInstance();
      sizeDp.value = p.getInt(_kSizeDp) ?? 108;
      sideRight.value = p.getBool(_kSideRight) ?? false;
      showName.value = p.getBool(_kShowName) ?? true;
      showOnLock.value = p.getBool(_kShowOnLock) ?? false;
      autoHideDone.value = p.getBool(_kAutoHideDone) ?? false;
    } catch (_) {}
    await _pushToNative();
  }

  Future<void> setSizeDp(int v) async {
    sizeDp.value = v;
    await _putInt(_kSizeDp, v);
    await _pushToNative();
  }

  Future<void> setSideRight(bool v) async {
    sideRight.value = v;
    await _putBool(_kSideRight, v);
    await _pushToNative();
  }

  Future<void> setShowName(bool v) async {
    showName.value = v;
    await _putBool(_kShowName, v);
    await _pushToNative();
  }

  Future<void> setShowOnLock(bool v) async {
    showOnLock.value = v;
    await _putBool(_kShowOnLock, v);
    await _pushToNative();
  }

  Future<void> setAutoHideDone(bool v) async {
    autoHideDone.value = v;
    await _putBool(_kAutoHideDone, v);
  }

  Future<void> _pushToNative() => MultiOverlayService.setDisplayPrefs(
    sizeDp: sizeDp.value,
    sideRight: sideRight.value,
    showName: showName.value,
    showOnLock: showOnLock.value,
  );

  Future<void> _putInt(String k, int v) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt(k, v);
    } catch (_) {}
  }

  Future<void> _putBool(String k, bool v) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(k, v);
    } catch (_) {}
  }
}
