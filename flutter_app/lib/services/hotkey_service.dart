import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'platform_info.dart';
import 'telemetry_service.dart';

/// 글로벌 핫키 — 다른 앱에서 일하는 중에도 타이머를 조작한다.
///
/// 기본 조합은 **Ctrl+Shift+Alt** + Space/N/L. 처음엔 Ctrl+Alt 였으나
/// IntelliJ(Reformat=Ctrl+Alt+L, Inline=Ctrl+Alt+N) 등 주요 도구를 시스템
/// 레벨에서 강탈하는 충돌이 확인돼 3-modifier 로 변경 — 기존 앱이 거의 쓰지
/// 않는 영역이고 유럽 키보드 AltGr(=Ctrl+Alt) 문자 입력과도 안 겹친다.
///
/// 조합은 설정에서 액션별로 직접 녹화해 바꿀 수 있다(prefs 저장).
/// 기본 ON, 설정 토글로 전체 해제. 콜백은 home_screen 이 배선한다.
class HotkeyService {
  HotkeyService._();
  static final HotkeyService instance = HotkeyService._();

  static const String _kEnabled = 'global_hotkeys_enabled';
  static const String _kBindPrefix = 'hotkey_bind_'; // + action = HotKey json

  /// 핫키를 제공하는 액션 목록(표시 순서).
  static const List<String> actions = ['timer_toggle', 'timer_next', 'sw_lap'];

  final ValueNotifier<bool> enabledListenable = ValueNotifier<bool>(true);
  bool get enabled => enabledListenable.value;

  /// 바인딩 변경 알림(설정 UI 갱신용) — 값은 의미 없는 리비전 카운터.
  final ValueNotifier<int> bindingsRev = ValueNotifier<int>(0);

  /// 액션 콜백 — home_screen 의 액션 핸들러('timer_toggle' 등)로 연결된다.
  void Function(String action)? onAction;

  final Map<String, HotKey> _bindings = {};
  bool _registered = false;

  Map<String, HotKey> _defaults() => {
        'timer_toggle': _key(PhysicalKeyboardKey.space),
        'timer_next': _key(PhysicalKeyboardKey.keyN),
        'sw_lap': _key(PhysicalKeyboardKey.keyL),
      };

  HotKey _key(PhysicalKeyboardKey code) => HotKey(
        key: code,
        modifiers: [
          HotKeyModifier.control,
          HotKeyModifier.shift,
          HotKeyModifier.alt,
        ],
        // inapp 이 아닌 system — 포커스가 다른 앱에 있어도 동작해야 한다.
        scope: HotKeyScope.system,
      );

  HotKey? binding(String action) => _bindings[action];

  /// 사람이 읽는 조합 문자열 — 설정·치트시트·툴팁 공용.
  String describe(String action) {
    final hk = _bindings[action];
    if (hk == null) return '';
    final parts = <String>[
      for (final m in hk.modifiers ?? <HotKeyModifier>[])
        switch (m) {
          HotKeyModifier.control => 'Ctrl',
          HotKeyModifier.shift => 'Shift',
          HotKeyModifier.alt => 'Alt',
          HotKeyModifier.meta => 'Win',
          _ => m.name,
        },
    ];
    // 'Key N' → 'N', 'Space' 는 그대로. (key 는 Physical/Logical 양쪽 가능)
    final k = hk.key;
    String keyName = switch (k) {
      PhysicalKeyboardKey() => k.debugName ?? '?',
      LogicalKeyboardKey() when k.keyLabel.isNotEmpty => k.keyLabel,
      LogicalKeyboardKey() => k.debugName ?? '?',
      _ => '?',
    };
    keyName = keyName.replaceFirst(RegExp(r'^Key '), '');
    parts.add(keyName);
    return parts.join('+');
  }

  Future<void> init() async {
    if (!isDesktop) return;
    try {
      // hot-restart 잔재 정리 — 패키지 권장 초기화 순서.
      await hotKeyManager.unregisterAll();
      final p = await SharedPreferences.getInstance();
      enabledListenable.value = p.getBool(_kEnabled) ?? true;
      _bindings.clear();
      final defaults = _defaults();
      for (final action in actions) {
        final raw = p.getString('$_kBindPrefix$action');
        HotKey? hk;
        if (raw != null) {
          try {
            hk = HotKey.fromJson(
                (jsonDecode(raw) as Map).cast<String, dynamic>());
          } catch (_) {}
        }
        _bindings[action] = hk ?? defaults[action]!;
      }
      bindingsRev.value++;
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

  /// 액션 조합 변경 — 녹화 UI 에서 호출. scope 는 항상 system 으로 강제.
  Future<void> setBinding(String action, HotKey recorded) async {
    final hk = HotKey(
      key: recorded.key,
      modifiers: recorded.modifiers,
      scope: HotKeyScope.system,
    );
    _bindings[action] = hk;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('$_kBindPrefix$action', jsonEncode(hk.toJson()));
    } catch (_) {}
    bindingsRev.value++;
    unawaited(TelemetryService.instance
        .logEvent('hotkey_rebind', {'action': action}));
    if (enabled) {
      await _unregister();
      await _register();
    }
  }

  /// 기본 조합으로 복원.
  Future<void> resetBindings() async {
    try {
      final p = await SharedPreferences.getInstance();
      for (final action in actions) {
        await p.remove('$_kBindPrefix$action');
      }
    } catch (_) {}
    _bindings
      ..clear()
      ..addAll(_defaults());
    bindingsRev.value++;
    if (enabled) {
      await _unregister();
      await _register();
    }
  }

  Future<void> _register() async {
    if (_registered || !isDesktop) return;
    _registered = true;
    for (final action in actions) {
      final hk = _bindings[action];
      if (hk == null) continue;
      try {
        await hotKeyManager.register(
          hk,
          keyDownHandler: (_) {
            unawaited(TelemetryService.instance
                .logEvent('global_hotkey', {'action': action}));
            onAction?.call(action);
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
