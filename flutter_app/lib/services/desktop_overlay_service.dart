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

  bool _shouldShow = false; // 사용자가 위젯을 켜둔 상태인지
  DateTime? _lastCreate;
  int _updateFails = 0;

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
    _shouldShow = true;
    if (_overlay != null) {
      try {
        await _overlay!.show();
      } catch (_) {}
      await update(initialState);
      return;
    }
    await _create(initialState);
  }

  Future<void> _create(Map<String, dynamic> state) async {
    final args = <String, dynamic>{
      ...state,
      'role': 'overlay',
      'mainWindowId': selfWindowId,
    };
    _overlay = await WindowController.create(
      WindowConfiguration(arguments: jsonEncode(args), hiddenAtLaunch: true),
    );
    _lastCreate = DateTime.now();
    _updateFails = 0;
    // 서브윈도우가 자체적으로 window_manager 로 frameless/always-on-top 구성 후 show().
  }

  Future<void> hide() async {
    _shouldShow = false;
    if (_overlay == null) return;
    try {
      await _overlay!.hide();
    } catch (_) {}
  }

  /// 타이머 상태 스냅샷을 오버레이로 push (~48ms 주기).
  ///
  /// 서브윈도우가 모종의 이유로 사라지면 invokeMethod 가 실패한다. 위젯이 켜진
  /// 상태에서 연속 실패가 누적되면 오버레이를 자동 재생성해 '사라짐'을 복구한다.
  Future<void> update(Map<String, dynamic> state) async {
    final ov = _overlay;
    if (ov == null) return;
    try {
      await ov.invokeMethod('update', jsonEncode(state));
      _updateFails = 0;
    } catch (_) {
      if (!_shouldShow) return;
      // 생성 직후(엔진 준비 중) 잠깐의 실패는 무시.
      final last = _lastCreate;
      if (last != null &&
          DateTime.now().difference(last) < const Duration(seconds: 2)) {
        return;
      }
      // 연속 3회(≈150ms) 실패 시에만 재생성 — 일시적 오류로 인한 오작동 방지.
      if (++_updateFails < 3) return;
      // NOTE: desktop_multi_window 0.3.0 은 서브윈도우 파괴 API(close)를 제공하지
      // 않아, 강제 종료 후 재생성을 반복하면 네이티브 엔진/핸들이 누수된다(라이브러리
      // 한계). 정상 사용에선 위젯이 죽지 않아 재생성이 사실상 일어나지 않으므로 영향이
      // 없지만, 완전 해결하려면 라이브러리에 window_close 를 추가해야 한다.
      _overlay = null;
      try {
        await _create(state);
      } catch (_) {}
    }
  }
}
