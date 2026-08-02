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
  static const List<String> actions = [
    'timer_toggle',
    'timer_next',
    'sw_lap',
    'widget_focus',
  ];

  final ValueNotifier<bool> enabledListenable = ValueNotifier<bool>(true);
  bool get enabled => enabledListenable.value;

  /// 바인딩 변경 알림(설정 UI 갱신용) — 값은 의미 없는 리비전 카운터.
  final ValueNotifier<int> bindingsRev = ValueNotifier<int>(0);

  /// 등록에 실패한 액션들 — 다른 앱이 선점한 조합. Windows 는 원래 이 실패를
  /// 조용히 삼키므로(hotkey_manager_windows 로컬 패치로 전파) 설정에 ⚠ 로
  /// 노출해 "저장했는데 안 눌림"의 원인을 사용자가 알 수 있게 한다.
  final ValueNotifier<Set<String>> failedActions =
      ValueNotifier<Set<String>>(const {});

  /// 액션 콜백 — home_screen 의 액션 핸들러('timer_toggle' 등)로 연결된다.
  void Function(String action)? onAction;

  final Map<String, HotKey> _bindings = {};
  bool _registered = false;

  Map<String, HotKey> _defaults() => {
        'timer_toggle': _key(PhysicalKeyboardKey.space),
        'timer_next': _key(PhysicalKeyboardKey.keyN),
        'sw_lap': _key(PhysicalKeyboardKey.keyL),
        // 위젯은 skipTaskbar(툴윈도우)라 Alt+Tab 에 안 뜬다(위젯 관례) —
        // 마우스 없이 포커스하는 유일한 경로가 이 핫키다. 포커스 후
        // 1~9/화살표/Tab 으로 배치하고 Esc 로 이전 앱에 돌아간다.
        'widget_focus': _key(PhysicalKeyboardKey.keyW),
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
    return hk == null ? '' : describeHotKey(hk);
  }

  /// HotKey → Windows 관례 표기("Ctrl+Shift+Alt+L").
  /// 패키지의 HotKeyVirtualView 는 맥 기호(⌃⇧⌥)로 그려서 쓰지 않는다.
  static String describeHotKey(HotKey hk) {
    final order = [
      HotKeyModifier.control,
      HotKeyModifier.shift,
      HotKeyModifier.alt,
      HotKeyModifier.meta,
    ];
    final mods = hk.modifiers ?? <HotKeyModifier>[];
    final parts = <String>[
      for (final m in order)
        if (mods.contains(m))
          switch (m) {
            HotKeyModifier.control => 'Ctrl',
            HotKeyModifier.shift => 'Shift',
            HotKeyModifier.alt => 'Alt',
            HotKeyModifier.meta => 'Win',
            _ => m.name,
          },
    ];
    parts.add(_keyLabel(hk.key));
    return parts.join('+');
  }

  /// 키 라벨 — **release 안전 + 이벤트 무관**.
  /// debugName 은 릴리즈에서 null 이고, lookUpLayout 은 그 키를 실제로 누른
  /// 적이 있어야 매핑이 생긴다(둘 다 실화면 '?' 표기 버그의 원인이었음).
  /// USB HID usage 로 직접 라벨링한다.
  static String _keyLabel(KeyboardKey k) {
    if (k is LogicalKeyboardKey) {
      if (k == LogicalKeyboardKey.space) return 'Space';
      final label = k.keyLabel;
      if (label.trim().isNotEmpty) {
        return label.length == 1 ? label.toUpperCase() : label;
      }
      return '?';
    }
    if (k is! PhysicalKeyboardKey) return '?';
    final u = k.usbHidUsage;
    if (u >= 0x070004 && u <= 0x07001d) {
      return String.fromCharCode(0x41 + (u - 0x070004)); // A–Z
    }
    if (u >= 0x07001e && u <= 0x070026) {
      return String.fromCharCode(0x31 + (u - 0x07001e)); // 1–9
    }
    if (u >= 0x07003a && u <= 0x070045) {
      return 'F${u - 0x07003a + 1}'; // F1–F12
    }
    return switch (u) {
      0x070027 => '0',
      0x070028 => 'Enter',
      0x070029 => 'Esc',
      0x07002a => 'Backspace',
      0x07002b => 'Tab',
      0x07002c => 'Space',
      0x07002d => '-',
      0x07002e => '=',
      0x07002f => '[',
      0x070030 => ']',
      0x070031 => r'\',
      0x070033 => ';',
      0x070034 => "'",
      0x070035 => '`',
      0x070036 => ',',
      0x070037 => '.',
      0x070038 => '/',
      0x07004a => 'Home',
      0x07004b => 'PgUp',
      0x07004c => 'Del',
      0x07004d => 'End',
      0x07004e => 'PgDn',
      0x07004f => '→',
      0x070050 => '←',
      0x070051 => '↓',
      0x070052 => '↑',
      _ => '?',
    };
  }

  /// 안전한 전역 조합인지 — Ctrl/Alt/Win 중 하나는 필수.
  /// Shift 단독은 일반 타이핑(예: Shift+/ = '?')을 시스템 전역에서 강탈한다 —
  /// 실제로 구버전 녹화기가 Shift+/ 를 저장해 '?' 입력이 막히는 사고가 났다.
  static bool isSaneBinding(HotKey hk) {
    final mods = hk.modifiers ?? const <HotKeyModifier>[];
    return mods.contains(HotKeyModifier.control) ||
        mods.contains(HotKeyModifier.alt) ||
        mods.contains(HotKeyModifier.meta);
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
        // 불량 바인딩 정화 — 구버전 녹화기가 저장한 Shift 단독 조합 등은
        // 일반 타이핑을 전역 강탈하므로 기본값으로 되돌리고 prefs 를 지운다.
        if (hk != null && !isSaneBinding(hk)) {
          hk = null;
          await p.remove('$_kBindPrefix$action');
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

  /// 녹화 중 전역 핫키 일시 해제 — **필수**.
  ///
  /// system scope 핫키는 OS 가 키를 가로채(RegisterHotKey) 포커스 앱으로
  /// 전달하지 않는다. 등록된 상태로 녹화하면 사용자가 그 조합(특히 현재
  /// 조합)을 눌러도 마지막 키가 Flutter 에 도달하지 않아 "수식키 3개 이상은
  /// 녹화가 안 된다"처럼 보인다(실사용 지적). 녹화 창을 열 때 해제하고
  /// 닫을 때 되돌린다.
  /// 녹화 중 표식 — 인앱 단축키 핸들러(home_screen)도 이 동안 물러난다.
  /// (안 그러면 Space 를 녹화하려는 순간 타이머가 토글된다)
  bool recording = false;

  Future<void> suspendForRecording() async {
    recording = true;
    await _unregister();
  }

  Future<void> resumeAfterRecording() async {
    recording = false;
    if (enabled) await _register();
  }

  /// 기본 조합에서 하나라도 바뀌었는지 — "기본값 복원" 버튼은 이때만 노출
  /// (시안 결정 4: 평소엔 시각 소음 0).
  bool get isModified {
    final d = _defaults();
    for (final a in actions) {
      final cur = _bindings[a];
      final def = d[a];
      if (cur == null || def == null) continue;
      if (cur.key != def.key ||
          _modSet(cur.modifiers) != _modSet(def.modifiers)) {
        return true;
      }
    }
    return false;
  }

  /// 다른 액션이 이미 쓰는 조합인지 — 중복 등록은 둘 중 하나가 조용히 실패한다.
  String? conflictingAction(String action, HotKey hk) {
    for (final e in _bindings.entries) {
      if (e.key == action) continue;
      final o = e.value;
      if (o.key == hk.key &&
          _modSet(o.modifiers) == _modSet(hk.modifiers)) {
        return e.key;
      }
    }
    return null;
  }

  String _modSet(List<HotKeyModifier>? m) =>
      ((m ?? <HotKeyModifier>[]).map((e) => e.name).toList()..sort()).join(',');

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
    final failed = <String>{};
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
        // 다른 앱이 선점한 조합 — 해당 키만 포기하고 ⚠ 로 노출.
        failed.add(action);
      }
    }
    failedActions.value = failed;
  }

  Future<void> _unregister() async {
    _registered = false;
    failedActions.value = const {};
    try {
      await hotKeyManager.unregisterAll();
    } catch (_) {}
  }
}
