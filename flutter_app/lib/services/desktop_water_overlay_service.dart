import 'dart:async';
import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'desktop_service.dart';
import 'desktop_overlay_service.dart';

/// 데스크톱 물 위젯 — 오늘 마신 잔/목표·다음 알림 시각을 보여주는 단일
/// always-on-top pill 창. 멀티 타이머 pill 과 동일한 제약을 따른다:
/// 창 파괴 금지(핸들 누수) — 닫기는 hide, 재표시는 update+show.
class DesktopWaterOverlayService {
  DesktopWaterOverlayService._();
  static final DesktopWaterOverlayService instance =
      DesktopWaterOverlayService._();

  WindowController? _win;
  bool _creating = false;

  /// 표시하거나(없으면 생성) 상태를 갱신한다.
  /// [state]: {title, count, goal, nextHm} — 문자열은 메인의 l10n 으로 채운다.
  Future<void> show(Map<String, dynamic> state) async {
    if (!isDesktop || _creating) return;
    final payload = jsonEncode(state);
    final existing = _win;
    if (existing != null) {
      try {
        await existing.invokeMethod('update', payload);
        await existing.show();
      } catch (_) {}
      return;
    }
    _creating = true;
    try {
      _win = await WindowController.create(
        WindowConfiguration(
          arguments: jsonEncode({
            ...state,
            'role': 'overlay', // main.dart 서브윈도우 라우팅 재사용
            'variant': 'water',
            'mainWindowId': DesktopOverlayService.instance.selfWindowId,
          }),
          hiddenAtLaunch: true,
        ),
      );
      // 서브윈도우가 스스로 frameless/topmost 구성 후 show() 한다.
    } catch (_) {
      _win = null;
    } finally {
      _creating = false;
    }
  }

  /// 표시 중일 때만 상태 갱신(숨김 상태면 무시).
  Future<void> update(Map<String, dynamic> state) async {
    final w = _win;
    if (w == null) return;
    try {
      await w.invokeMethod('update', jsonEncode(state));
    } catch (_) {}
  }

  Future<void> hide() async {
    final w = _win;
    if (w == null) return;
    try {
      await w.hide();
    } catch (_) {}
  }
}
