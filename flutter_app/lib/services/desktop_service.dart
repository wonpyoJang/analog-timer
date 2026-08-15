import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'native_confirm.dart';
import 'platform_info.dart';
import 'telemetry_service.dart';

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
      // 커스텀 타이틀바(DesktopTitleBar)를 직접 그리므로 OS 캡션은 숨긴다.
      // hidden 은 리사이즈 테두리를 유지하므로 창 크기 조절은 그대로 동작.
      titleBarStyle: TitleBarStyle.hidden,
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  /// 프레임 정체 워치독 — "렌더 콜백이 멈춘" 유형의 freeze 감지.
  ///
  /// 역할 분담(강제 TDR 실험으로 확인): TDR 순백 화면에서는 프레임 콜백이
  /// 계속 돌기 때문에 이 감지로는 안 잡힌다 — 그 유형은 네이티브 워치독
  /// (D3D device-removed 폴링)이 담당. 여기는 raster/콜백 자체가 멎는 유형과,
  /// Dart 는 살아있는데 프레임 스케줄이 죽은 잔여 케이스를 잡는다.
  Timer? _freezeWatchdog;
  int _staleCount = 0;
  int _lastFreezeCheckMs = 0;
  int _freezeSnoozeUntilMs = 0;

  void _startFreezeWatchdog() {
    _freezeWatchdog?.cancel();
    _freezeWatchdog = Timer.periodic(const Duration(seconds: 5), (_) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      // 절전 복귀 방어: 5초 주기가 15초+ 점프했으면 판정 리셋 후 한 텀 유예.
      final jumped =
          _lastFreezeCheckMs != 0 && now - _lastFreezeCheckMs > 15000;
      _lastFreezeCheckMs = now;
      if (jumped) {
        _staleCount = 0;
        return;
      }
      if (now < _freezeSnoozeUntilMs || _restarting || _quitting) return;
      final frameMs = TelemetryService.instance.lastFrameMs;
      if (frameMs == 0) return; // 첫 프레임 전
      // 최소화/숨김(트레이) 상태에선 프레임이 안 그려지는 게 정상.
      try {
        if (await windowManager.isMinimized() ||
            !await windowManager.isVisible()) {
          _staleCount = 0;
          return;
        }
      } catch (_) {
        return;
      }
      if (now - frameMs > 15000) {
        // 연속 3회(15초 창 3번) 확인 후에만 발동 — 일시 부하 오탐 방지.
        if (++_staleCount < 3) return;
        _staleCount = 0;
        unawaited(
          TelemetryService.instance.logEvent('freeze_detected', {
            'kind': 'frame_stall',
            'frameAgeSec': ((now - frameMs) / 1000).round(),
          }),
        );
        await restart(
          reason: 'auto_frame_stall',
          confirmTimeoutSeconds: 20,
          proceedOnTimeout: true,
        );
        // restart 가 거절로 돌아왔으면 10분 보류(팝업 스팸 방지).
        _freezeSnoozeUntilMs =
            DateTime.now().millisecondsSinceEpoch + 10 * 60 * 1000;
      } else {
        _staleCount = 0;
      }
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
      isWindows ? 'assets/icons/app_icon.ico' : 'assets/icons/app_icon.png',
    );
    await trayManager.setToolTip('Analog Timer');
    await _rebuildMenu('대기 중');
    _trayReady = true;
    _startFreezeWatchdog();
  }

  Future<void> _rebuildMenu(String status) async {
    _lastMenuStatus = status;
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(label: status, disabled: true),
          MenuItem.separator(),
          MenuItem(key: 'show', label: '열기'),
          MenuItem(key: 'multi', label: '멀티 타이머'),
          MenuItem(key: 'restart', label: '다시 시작 (화면 멈춤 해소)'),
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

  /// 3초 뒤 자기 자신을 재기동하는 프로세스 예약 — 메인/오버레이 엔진 공용.
  /// 단일 인스턴스 mutex 는 종료와 함께 해제되므로 지연 기동이 필요하다.
  /// 성공 여부를 반환한다.
  ///
  /// bat 파일 + cmd 방식인 이유: detached powershell 에 -Command 인자를 넘기는
  /// 방식은 실환경에서 인자가 통째로 유실돼(빈 powershell 만 상주) 재기동이
  /// 조용히 실패하는 것이 확인됐다. 인자 인용 문제가 없는 스크립트 파일 실행으로
  /// 교체 — 네이티브 TDR 자가재실행(main.cpp, cmd+ping 지연)과 동일 계열 패턴.
  ///
  /// [killSelf] 면 스크립트가 이 프로세스를 taskkill 로 끝낸 뒤 재기동한다.
  /// Dart 의 exit()/WM_CLOSE teardown 은 엔진·서브엔진 소멸 레이스로
  /// 0xC0000005 를 내는 경로라(main.cpp 가 TerminateProcess 를 쓰는 이유)
  /// 종료 자체를 프로세스 밖으로 빼는 편이 안전하고, **앱이 완전히 얼어도
  /// 동작한다** — "멈춤 해소" 버튼의 목적에 정확히 부합.
  /// 호출 전에 clean 마커를 남길 것(크래시 오탐 방지).
  static Future<bool> scheduleRelaunch({bool killSelf = false}) async {
    if (!isDesktop) return false;
    try {
      final exe = Platform.resolvedExecutable;
      final bat = File(
        '${Directory.systemTemp.path}${Platform.pathSeparator}analog_timer_relaunch.bat',
      );
      await bat.writeAsString(
        '@echo off\r\n'
        'ping -n 3 127.0.0.1 >nul\r\n'
        '${killSelf ? 'taskkill /F /PID $pid >nul 2>&1\r\nping -n 3 127.0.0.1 >nul\r\n' : ''}'
        'start "" "$exe"\r\n'
        'del "%~f0"\r\n',
      );
      final p = await Process.start('cmd', [
        '/c',
        bat.path,
      ], mode: ProcessStartMode.detached);
      // detached 라도 spawn 자체가 실패하면 여기서 throw — pid 확인으로 방어.
      return p.pid > 0;
    } catch (_) {
      return false;
    }
  }

  /// "다시 시작(화면 멈춤 해소)" — 재기동 예약 후 정상 종료 경로(quit)를 탄다.
  /// 타이머/스톱워치는 savedAtMs 벽시계 보정으로 이어지므로 기록·경과시간이
  /// 보존된다. 메인 창 렌더가 얼어도(TDR 좀비) 트레이 메뉴는 OS가 그리므로
  /// 트레이 경로는 Dart 가 살아 있는 한 동작한다.
  /// 재시작 확인 문구 — 무엇이 보존되고 무엇이 일어나는지 명시(고지 후 동의).
  static const String restartTitle = 'Analog Timer — 다시 시작';
  static const String restartMessage =
      '화면 멈춤을 해소하기 위해 앱을 다시 시작합니다.\n\n'
      '· 타이머 기록과 경과 시간은 그대로 유지됩니다\n'
      '· 앱이 잠시 닫힌 뒤 약 5초 후 자동으로 다시 열립니다\n\n'
      '계속할까요?';

  bool _restarting = false;

  /// [confirm] 이면 네이티브 확인창으로 동의를 받은 뒤에만 진행한다.
  /// [reason] 은 텔레메트리 breadcrumb 에 남는 트리거 구분값.
  /// [confirmTimeoutSeconds] > 0 이면 카운트다운 확인창 — [proceedOnTimeout] 이
  /// true 일 때 무응답(타임아웃)을 "진행"으로 취급한다(자동 트리거용: 자리를
  /// 비웠거나 입력이 죽은 상황에서도 복구가 굴러가야 하므로).
  Future<void> restart({
    bool confirm = true,
    String reason = 'manual',
    int confirmTimeoutSeconds = 0,
    bool proceedOnTimeout = false,
  }) async {
    if (!isDesktop || _quitting || _restarting) return;
    _restarting = true;
    bool? ok;
    if (confirm) {
      ok = await nativeConfirm(
        title: restartTitle,
        message: restartMessage,
        timeoutSeconds: confirmTimeoutSeconds,
      );
      final proceed = ok == true || (ok == null && proceedOnTimeout);
      if (!proceed) {
        unawaited(
          TelemetryService.instance.logEvent('restart_declined', {
            'reason': reason,
          }),
        );
        // 복구 거절도 리포트 — "감지는 됐는데 사용자가 막음" 빈도 추적.
        unawaited(
          TelemetryService.instance.reportRecovery(
            'restart_declined',
            extra: {
              'reason': reason,
              'answer': ok == false ? 'cancel' : 'timeout',
            },
          ),
        );
        _restarting = false;
        return;
      }
    }
    unawaited(
      TelemetryService.instance.logEvent('manual_restart', {'reason': reason}),
    );
    // 복구 리포트 — 트리거(reason)·확인 방식·당시 상태를 디버깅 가능하게 동봉.
    // 큐 적재가 먼저라 재시작으로 프로세스가 죽어도 다음 실행이 재전송한다.
    await TelemetryService.instance.reportRecovery(
      'restart',
      extra: {
        'reason': reason,
        'confirmedBy': !confirm
            ? 'no_prompt'
            : ok == true
            ? 'user_ok'
            : 'countdown_timeout',
      },
    );
    // 상태 저장(타이머 연속성) — 실패해도 30초 주기 저장분으로 이어진다.
    final cb = onQuit;
    if (cb != null) {
      try {
        await cb().timeout(const Duration(milliseconds: 500));
      } catch (_) {}
    }
    // 종료를 스크립트에 위임하므로, 크래시 오탐 방지 마커를 먼저 남긴다.
    await TelemetryService.instance.markCleanExit();
    if (!await scheduleRelaunch(killSelf: true)) {
      _restarting = false; // 예약 실패 — 앱을 그대로 둔다("앱만 죽는" 사고 방지)
    }
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
      case 'multi':
        _showWindow();
        onOpenMultiTimer?.call();
      case 'restart':
        restart();
      case 'quit':
        quit();
    }
  }

  /// 트레이 '멀티 타이머' → 멀티 화면 열기. home_screen 이 등록.
  VoidCallback? onOpenMultiTimer;
}
