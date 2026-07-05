import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'platform_info.dart';

// isDesktop/isWindows 등 웹 안전 플랫폼 판별은 platform_info.dart 로 옮겼다.
// 기존에 desktop_service.dart 에서 isDesktop 을 가져다 쓰던 파일들이 그대로
// 동작하도록 re-export 한다.
export 'platform_info.dart';

/// 데스크톱 창(window_manager) + 시스템 트레이(tray_manager) 통합 서비스.
///
/// - 창 닫기(X) → 완전 종료 (상태 저장 후 프로세스 종료)
/// - 트레이 좌클릭 → 창 복원, 우클릭 → 컨텍스트 메뉴(열기/종료)
/// - 트레이 툴팁/메뉴에 타이머 상태 표시
class DesktopService with WindowListener, TrayListener {
  DesktopService._();
  static final DesktopService instance = DesktopService._();

  /// 트레이 "열기" 또는 좌클릭으로 창을 복원할 때 호출.
  VoidCallback? onShow;

  /// 종료 직전 호출 — 상태 저장용. 실제 프로세스 종료는 서비스가 담당한다.
  Future<void> Function()? onQuit;

  bool _trayReady = false;
  bool _quitting = false;
  String? _lastMenuStatus;

  /// runApp 이전에 호출 — 창 크기/최소 크기를 고정하고 표시.
  static Future<void> bootstrapWindow() async {
    if (!isDesktop) return;
    await windowManager.ensureInitialized();
    const options = WindowOptions(
      size: Size(460, 860),
      minimumSize: Size(420, 680),
      center: true,
      title: 'Analog Timer',
      backgroundColor: Colors.transparent,
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  /// runApp 이후(또는 직전) 호출 — 트레이 아이콘/메뉴 + 리스너 등록.
  Future<void> init() async {
    if (!isDesktop) return;
    // X(닫기)는 window_manager 가로채기 없이 표준 Win32 경로로 닫는다.
    // 러너(main.cpp)가 메시지 루프 종료 후 TerminateProcess 로 즉시 종료하므로
    // teardown 레이스(크래시·좀비) 없이 한 번에 닫힌다. preventClose 미사용.
    trayManager.addListener(this);
    await trayManager.setIcon(
      isWindows
          ? 'assets/icons/app_icon.ico'
          : 'assets/icons/app_icon.png',
    );
    await trayManager.setToolTip('Analog Timer');
    await _rebuildMenu('대기 중');
    _trayReady = true;
  }

  Future<void> _rebuildMenu(String status) async {
    _lastMenuStatus = status;
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(label: status, disabled: true),
          MenuItem.separator(),
          MenuItem(key: 'show', label: '열기'),
          MenuItem(key: 'quit', label: '종료'),
        ],
      ),
    );
  }

  /// 타이머 상태를 트레이 툴팁/메뉴에 반영. ~1초 주기로 호출.
  Future<void> updateTray({
    required String tooltip,
    required String menuStatus,
  }) async {
    if (!_trayReady) return;
    await trayManager.setToolTip(tooltip);
    // 메뉴 재생성은 비용이 있으므로 상태 텍스트가 바뀔 때만.
    if (menuStatus != _lastMenuStatus) {
      await _rebuildMenu(menuStatus);
    }
  }

  /// 트레이 "종료" 처리 — 상태 저장 후 네이티브 close 경로로 종료.
  ///
  /// windowManager.close() 가 WM_CLOSE 를 보내면 러너의 메시지 루프가 끝나고
  /// main.cpp 가 TerminateProcess 로 프로세스를 강제 종료한다(teardown 건너뜀).
  /// X 버튼은 Dart 를 거치지 않고 같은 네이티브 경로로 닫힌다.
  Future<void> quit() async {
    if (!isDesktop || _quitting) return;
    _quitting = true;
    final cb = onQuit;
    if (cb != null) {
      try {
        await cb().timeout(const Duration(milliseconds: 500));
      } catch (_) {}
    }
    try {
      await trayManager.destroy().timeout(const Duration(milliseconds: 300));
    } catch (_) {}
    try {
      await windowManager.close();
    } catch (_) {}
  }

  Future<void> _showWindow() async {
    await windowManager.show();
    await windowManager.focus();
    onShow?.call();
  }

  // X(닫기)는 네이티브 경로로 처리하므로 WindowListener.onWindowClose 는 두지 않는다.

  // ── TrayListener ────────────────────────────────────────────
  @override
  void onTrayIconMouseDown() {
    _showWindow();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show':
        _showWindow();
      case 'quit':
        quit();
    }
  }
}
