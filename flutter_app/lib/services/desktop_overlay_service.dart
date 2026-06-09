import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'desktop_service.dart';

/// 메인 윈도우에서 always-on-top 플로팅 오버레이(별도 서브윈도우)를 제어한다.
///
/// 모바일의 `flutter_overlay_window` 오버레이에 대응하는 데스크톱 구현으로,
/// `desktop_multi_window` 로 두 번째 네이티브 창을 띄우고 per-window 채널로
/// 상태(메인→오버레이)와 버튼 액션(오버레이→메인)을 주고받는다.
class DesktopOverlayService {
  DesktopOverlayService._();
  static final DesktopOverlayService instance = DesktopOverlayService._();

  /// 메인 윈도우의 windowId — 오버레이가 액션을 되돌려 보낼 대상.
  String selfWindowId = '0';

  /// 오버레이 버튼(재생/일시정지/다음/닫기)에서 올라온 액션 콜백. home_screen 이 설정.
  void Function(String action)? onAction;

  WindowController? _overlay;
  bool get isShown => _overlay != null;

  /// 메인 윈도우에서 1회 호출 — 오버레이가 보내는 'action' 수신 핸들러 등록.
  Future<void> init() async {
    if (!isDesktop) return;
    try {
      final self = await WindowController.fromCurrentEngine();
      selfWindowId = self.windowId;
      await self.setWindowMethodHandler((call) async {
        if (call.method == 'action' && call.arguments is String) {
          onAction?.call(call.arguments as String);
        }
        return null;
      });
    } catch (_) {
      // desktop_multi_window 가 메인 윈도우 정의를 못 주는 경우(단일 창 런처) 무시.
    }
  }

  /// 오버레이 표시 — 없으면 생성, 있으면 다시 보이기.
  Future<void> show(Map<String, dynamic> initialState) async {
    if (!isDesktop) return;
    if (_overlay != null) {
      try {
        await _overlay!.show();
      } catch (_) {}
      await update(initialState);
      return;
    }
    final args = <String, dynamic>{
      ...initialState,
      'role': 'overlay',
      'mainWindowId': selfWindowId,
    };
    _overlay = await WindowController.create(
      WindowConfiguration(arguments: jsonEncode(args), hiddenAtLaunch: true),
    );
    // 서브윈도우가 자체적으로 window_manager 로 frameless/always-on-top 구성 후 show().
  }

  Future<void> hide() async {
    if (_overlay == null) return;
    try {
      await _overlay!.hide();
    } catch (_) {}
  }

  /// 타이머 상태 스냅샷을 오버레이로 push (~48ms 주기).
  Future<void> update(Map<String, dynamic> state) async {
    if (_overlay == null) return;
    try {
      await _overlay!.invokeMethod('update', jsonEncode(state));
    } catch (_) {}
  }
}
