import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

/// Windows/macOS/Linux 데스크톱 여부. 모바일에선 false.
/// (이 앱은 web 타겟을 빌드하지 않으므로 dart:io 사용이 안전하다.)
bool get isDesktop =>
    Platform.isWindows || Platform.isLinux || Platform.isMacOS;

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
    windowManager.addListener(this);
    // 닫기 버튼을 가로채 트레이로 숨기기 위함.
    await windowManager.setPreventClose(true);

    trayManager.addListener(this);
    await trayManager.setIcon(
      Platform.isWindows
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

  /// 완전 종료 — 상태 저장(best-effort) 후 네이티브 close 경로로 깔끔히 종료.
  ///
  /// preventClose 를 해제하고 close() 를 호출하면 러너의 SetQuitOnClose(true)
  /// 에 의해 메시지 루프가 정상 종료되어 프로세스가 깨끗이 끝난다.
  /// (exit(0) 는 Flutter 멀티스레드 teardown 중 액세스 위반을 유발할 수 있어 지양)
  Future<void> quit() async {
    if (!isDesktop || _quitting) return;
    _quitting = true;
    final cb = onQuit;
    if (cb != null) {
      try {
        await cb();
      } catch (_) {}
    }
    try {
      await trayManager.destroy();
    } catch (_) {}
    try {
      await windowManager.setPreventClose(false);
    } catch (_) {}
    await windowManager.close();
  }

  Future<void> _showWindow() async {
    await windowManager.show();
    await windowManager.focus();
    onShow?.call();
  }

  // ── WindowListener ──────────────────────────────────────────
  @override
  void onWindowClose() async {
    // X = 완전 종료 (상태 저장 후). 트레이 상주하지 않는다.
    await quit();
  }

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
