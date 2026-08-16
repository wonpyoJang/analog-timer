import 'dart:async';
import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'desktop_service.dart';
import 'desktop_overlay_service.dart';

/// 데스크톱 멀티 오버레이 — 실행 중 카운트다운마다 독립 pill 서브윈도우.
///
/// Android [MultiOverlayService](네이티브 뷰)와 달리 데스크톱은 창마다 Flutter
/// 서브엔진이 뜬다(엔진당 메모리 수십~수백 MB). 그래서:
///  - 동시 창 수를 [maxWindows]로 제한하고,
///  - **창을 파괴하지 않는다** — 서브윈도우 소멸 시 핸들이 사이클당 ~3개 누수되는
///    Flutter Windows 엔진 레벨 이슈가 있어(desktop_overlay_service.dart 참고),
///    닫기는 hide 로 처리하고 창은 풀에 보관해 다음 타이머에 재사용한다.
///
/// push 는 Android 와 동일하게 상태 전이 시에만 하고, pill 이 [deadlineMs] 로
/// 잔여 시간을 자체 계산한다(매초 IPC 불필요).
class DesktopMultiOverlayService {
  DesktopMultiOverlayService._();
  static final DesktopMultiOverlayService instance =
      DesktopMultiOverlayService._();

  /// 동시 표시 상한 — 서브엔진 메모리 부담(디버그 기준 창당 ~180MB) 때문에 보수적.
  static const int maxWindows = 3;

  /// 타이머 id → 표시 중인 창.
  final Map<String, WindowController> _active = {};

  /// 숨겨진 재사용 대기 창(파괴 금지 — 핸들 누수).
  final List<WindowController> _idle = [];

  /// 모든 창 조작을 직렬화 — 생성(수백 ms) 중 다른 show/close 가 끼어들어
  /// 풀 상태가 꼬이는 것을 방지한다.
  Future<void> _lastOp = Future.value();

  Future<void> _op(Future<void> Function() f) {
    return _lastOp = _lastOp.then((_) => f()).catchError((_) {});
  }

  int get shownCount => _active.length;

  /// id 창을 만들거나(없으면) 갱신한다. 상한 초과 시 무시(화면이 사전 차단).
  Future<void> show({
    required String id,
    required String name,
    required int colorValue,
    required int totalMs,
    required int remainMs,
    required bool running,
    bool done = false,
    String doneText = '',
  }) {
    if (!isDesktop) return Future.value();
    // 마감 절대시각을 push 시점에 계산 — pill 이 도착 지연과 무관하게 정확.
    final state = <String, dynamic>{
      'timerId': id,
      'name': name,
      'colorValue': colorValue,
      'totalMs': totalMs,
      'remainMs': remainMs,
      'running': running,
      'done': done,
      'doneText': doneText,
      'deadlineMs': running
          ? DateTime.now().millisecondsSinceEpoch + remainMs
          : 0,
    };
    return _op(() async {
      final existing = _active[id];
      if (existing != null) {
        try {
          await existing.invokeMethod('update', jsonEncode(state));
        } catch (_) {}
        return;
      }
      // 풀에 잠자는 창이 있으면 재사용 — 새 엔진을 만들지 않는다.
      if (_idle.isNotEmpty) {
        final c = _idle.removeLast();
        _active[id] = c;
        try {
          await c.invokeMethod('update', jsonEncode(state));
          await c.show();
        } catch (_) {}
        return;
      }
      if (_active.length + _idle.length >= maxWindows) return;
      final controller = await WindowController.create(
        WindowConfiguration(
          arguments: jsonEncode({
            ...state,
            'role': 'overlay', // main.dart 서브윈도우 라우팅 재사용
            'variant': 'multi',
            'slot': _active.length + _idle.length, // 초기 위치 캐스케이드
            'mainWindowId': DesktopOverlayService.instance.selfWindowId,
          }),
          hiddenAtLaunch: true,
        ),
      );
      // 서브윈도우가 스스로 frameless/topmost 구성 후 show() 한다.
      _active[id] = controller;
    });
  }

  /// id 창을 숨기고 풀로 되돌린다(파괴 아님).
  Future<void> close(String id) {
    if (!isDesktop) return Future.value();
    return _op(() async {
      final c = _active.remove(id);
      if (c == null) return;
      try {
        await c.hide();
      } catch (_) {}
      _idle.add(c);
    });
  }

  Future<void> closeAll() {
    if (!isDesktop) return Future.value();
    return _op(() async {
      for (final e in _active.entries) {
        try {
          await e.value.hide();
        } catch (_) {}
        _idle.add(e.value);
      }
      _active.clear();
    });
  }
}
