import 'dart:async';
import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'desktop_service.dart';
import 'telemetry_service.dart';

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
  bool _creating = false; // create 인플라이트 가드 — heartbeat 와의 동시 생성 차단
  DateTime? _lastCreate;
  int _updateFails = 0;

  // 재생성 폭주(cascading failure) 방지 — 위젯이 비정상적으로 반복해서 죽는
  // 환경(예: GPU 드라이버 반복 크래시)에서 무한 재생성으로 핸들이 폭증하는 것을
  // 차단한다. 30초 내 재생성이 임계를 넘으면 일정 시간 백오프한다.
  DateTime? _recreateWindowStart;
  int _recreateCount = 0;
  DateTime? _backoffUntil;
  DateTime? _lastRecreateAttempt;

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
  /// 생성 실패(TDR 직후 등)해도 던지지 않는다 — update 루프가 재시도한다.
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
    try {
      await _create(initialState);
    } catch (_) {}
  }

  Future<void> _create(Map<String, dynamic> state) async {
    // create 는 수백 ms~수 초(TDR 직후) 걸릴 수 있고, 그 동안 ~1초 heartbeat 가
    // _overlay==null 을 보고 두 번째 생성에 진입하면 update 를 못 받는
    // always-on-top 유령 창이 남는다 — 인플라이트 가드로 차단.
    if (_creating) return;
    _creating = true;
    try {
      final args = <String, dynamic>{
        ...state,
        'role': 'overlay',
        'mainWindowId': selfWindowId,
      };
      final controller = await WindowController.create(
        WindowConfiguration(arguments: jsonEncode(args), hiddenAtLaunch: true),
      );
      _overlay = controller;
      _lastCreate = DateTime.now();
      _updateFails = 0;
      // 생성 중 사용자가 위젯을 껐다면(hide 는 인플라이트 create 를 취소하지
      // 못한다) — 서브윈도우는 기동 시 무조건 스스로 show() 하므로 '꺼진 상태의
      // 유령 위젯'이 뜬다. 완료 시점에 의도를 재확인해 즉시 숨긴다.
      if (!_shouldShow) {
        try {
          await controller.hide();
        } catch (_) {}
      }
      // 서브윈도우가 자체적으로 window_manager 로 frameless/always-on-top 구성 후 show().
    } finally {
      _creating = false;
    }
  }

  /// 위젯 창에 키보드 포커스 — 전역 핫키(widget_focus)용.
  /// 핫키 이벤트를 받은 프로세스는 포그라운드 활성화 권한을 얻으므로
  /// 같은 프로세스의 서브윈도우 focus 가 OS 포커스 잠금에 막히지 않는다.
  Future<void> focusOverlay() async {
    final ov = _overlay;
    if (ov == null || !_shouldShow) return;
    try {
      await ov.invokeMethod('focus');
    } catch (_) {}
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
    if (ov == null) {
      // 위젯이 켜져 있어야 하는데 컨트롤러가 없음(TDR 직후 생성 실패 등) —
      // 아래 백오프 규칙 안에서 재생성을 재시도한다. 생성 진행 중이면 대기.
      if (_shouldShow && !_creating) await _recreateWithBackoff(state);
      return;
    }
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

      await _recreateWithBackoff(state);
    }
  }

  /// 수동 새로고침 — "위젯이 이상할 때" 버튼용.
  ///
  /// **살아있는 위젯을 절대 재생성하지 않는다.** desktop_multi_window 0.3.0 에는
  /// close() 가 없어 기존 서브윈도우를 파괴할 수 없다. 살아있는 창을 두고 두 번째
  /// 엔진을 만들면 두 라이브 엔진이 always-on-top/window_manager 상태를 두고
  /// 경합해 0xC0000005(액세스 위반)로 프로세스가 죽는다 — 실제로 재현됨.
  ///
  /// 그래서 IPC 로 생사를 먼저 판정한다:
  ///  - 응답함(살아있음) → 새 엔진 없이 hide/show 로 창만 다시 띄워 렌더 재개 유도
  ///  - 무응답/부재(죽음) → 그때만 재생성(자동 경로와 동일, 백오프는 리셋)
  Future<void> refresh(Map<String, dynamic> state) async {
    if (!isDesktop || _creating) return;
    _shouldShow = true;
    unawaited(TelemetryService.instance.logEvent('widget_manual_refresh'));

    final ov = _overlay;
    if (ov != null) {
      try {
        await ov
            .invokeMethod('update', jsonEncode(state))
            .timeout(const Duration(seconds: 2));
        // 살아있음 — 창만 다시 띄운다(새 엔진 생성 없음 = 안전).
        _updateFails = 0;
        try {
          await ov.hide();
          await ov.show();
        } catch (_) {}
        return;
      } catch (_) {
        // 무응답 — 진짜 죽은 위젯. 아래 재생성 경로로 내려간다.
      }
    }

    // 죽었거나 없음 → 재생성. 사용자의 명시적 요청이므로 백오프를 리셋한다.
    _backoffUntil = null;
    _recreateWindowStart = null;
    _recreateCount = 0;
    _lastRecreateAttempt = null;
    _updateFails = 0;
    await _recreateWithBackoff(state);
  }

  /// 위젯 재생성(백오프 포함) — update 실패 누적 시와 '컨트롤러 부재' 시 공용.
  ///
  /// NOTE: 위젯이 죽은 뒤 재생성을 "반복"하면 핸들이 누수된다(~3/cycle). 근본
  /// 원인은 desktop_multi_window 가 아니라, 서브윈도우가 닫힐 때 Flutter 의
  /// FlutterViewController(엔진)가 소멸하며 핸들을 완전히 회수하지 못하는 Flutter
  /// Windows 엔진 레벨 이슈다. 라이브러리에 window_close 를 추가해도 결국 같은
  /// DestroyWindow→WM_DESTROY→OnDestroy 소멸 경로를 타므로 해결되지 않는다.
  /// 정상 작동에선 위젯이 죽지 않아 재생성이 0회 → 누수 노출 없음(검증됨).
  Future<void> _recreateWithBackoff(Map<String, dynamic> state) async {
    if (_creating) return; // 생성 인플라이트 중 중복 진입 금지
    final now = DateTime.now();

    // 48ms update 루프에서 불리므로 시도 간 최소 2초 간격 유지.
    if (_lastRecreateAttempt != null &&
        now.difference(_lastRecreateAttempt!) < const Duration(seconds: 2)) {
      return;
    }
    _lastRecreateAttempt = now;

    // 백오프 중이면 재생성 보류 — 폭주로 인한 핸들 누적 차단.
    if (_backoffUntil != null && now.isBefore(_backoffUntil!)) return;

    // 30초 윈도우 내 재생성 횟수 집계. 임계(5회) 초과 시 60초 백오프.
    if (_recreateWindowStart == null ||
        now.difference(_recreateWindowStart!) > const Duration(seconds: 30)) {
      _recreateWindowStart = now;
      _recreateCount = 0;
    }
    if (++_recreateCount > 5) {
      _backoffUntil = now.add(const Duration(seconds: 60));
      _recreateCount = 0;
      return;
    }

    // 위젯이 혼자 사라짐 — 앱 프로세스는 생존하므로 네이티브 크래시 마커로는
    // 안 잡힌다. 이 순간 직접 텔레메트리 전송(그 시점 GPU TDR/이벤트로그 포함)해
    // '위젯 단독 사라짐'을 어드민에서 볼 수 있게 한다.
    // 위젯 재생성 직전에 breadcrumb 를 읽어둔다(재생성 중엔 파일 접근이 깨짐).
    final crumbs = await TelemetryService.instance.snapshotCrumbs();
    unawaited(
      TelemetryService.instance.reportWidgetGone(
        lastState: {
          'overlayOn': true,
          'event': 'auto_recreate',
          'recreateCount': _recreateCount,
        },
        breadcrumbsOverride: crumbs,
      ),
    );

    // IPC 만 일시 실패한 '살아있는 창'일 수도 있다 — 그대로 버리면 update 를
    // 영영 못 받는 always-on-top 유령이 된다. 베스트에포트로 숨기고 교체한다.
    final old = _overlay;
    _overlay = null;
    if (old != null) {
      try {
        await old.hide();
      } catch (_) {}
    }
    try {
      await _create(state);
    } catch (_) {}
  }
}
