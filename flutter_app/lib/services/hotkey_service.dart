import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'platform_info.dart';
import 'telemetry_service.dart';

/// 글로벌 핫키 — 다른 앱에서 일하는 중에도 타이머를 조작한다.
///
/// 이 앱의 실사용 패턴(위젯 띄워두고 다른 앱에서 작업)에선 창 포커스가
/// 거의 항상 다른 곳에 있으므로, 글로벌 핫키가 인앱 단축키보다 본질적이다.
///
///   Ctrl+Alt+Space  타이머 시작/일시정지
///   Ctrl+Alt+N      다음 세그먼트 (뽀모도로 "지금 휴식으로")
///   Ctrl+Alt+L      스톱워치 랩
///
/// 기본 ON — Ctrl+Alt 조합은 충돌이 드물고 설치 즉시 가치를 체감하도록.
/// 설정 토글로 끌 수 있다(등록 해제). 콜백은 home_screen 이 배선한다.
class HotkeyService {
  HotkeyService._();
  static final HotkeyService instance = HotkeyService._();

  static const String _kEnabled = 'global_hotkeys_enabled';

  final ValueNotifier<bool> enabledListenable = ValueNotifier<bool>(true);
  bool get enabled => enabledListenable.value;

  /// 액션 콜백 — home_screen 의 액션 핸들러('timer_toggle' 등)로 연결된다.
  void Function(String action)? onAction;

  bool _registered = false;

  Future<void> init() async {
    if (!isDesktop) return;
    try {
      // hot-restart 잔재 정리 — 패키지 권장 초기화 순서.
      await hotKeyManager.unregisterAll();
      final p = await SharedPreferences.getInstance();
      enabledListenable.value = p.getBool(_kEnabled) ?? true;
      if (enabled) await _register();
    } catch (_) {}
  }

  Future<void> setEnabled(bool v) async {
    enabledListenable.value = v;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kEnabled, v);
    } catch (_) {}
    if (v) {
      await _register();
    } else {
      await _unregister();
    }
  }

  HotKey _key(PhysicalKeyboardKey code) => HotKey(
        key: code,
        modifiers: [HotKeyModifier.control, HotKeyModifier.alt],
        // inapp 이 아닌 system — 포커스가 다른 앱에 있어도 동작해야 한다.
        scope: HotKeyScope.system,
      );

  Future<void> _register() async {
    if (_registered || !isDesktop) return;
    _registered = true;
    final map = <PhysicalKeyboardKey, String>{
      PhysicalKeyboardKey.space: 'timer_toggle',
      PhysicalKeyboardKey.keyN: 'timer_next',
      PhysicalKeyboardKey.keyL: 'sw_lap',
    };
    for (final e in map.entries) {
      try {
        await hotKeyManager.register(
          _key(e.key),
          keyDownHandler: (_) {
            unawaited(TelemetryService.instance
                .logEvent('global_hotkey', {'action': e.value}));
            onAction?.call(e.value);
          },
        );
      } catch (_) {
        // 다른 앱이 선점한 조합 — 해당 키만 조용히 포기(나머지는 동작).
      }
    }
  }

  Future<void> _unregister() async {
    _registered = false;
    try {
      await hotKeyManager.unregisterAll();
    } catch (_) {}
  }
}
