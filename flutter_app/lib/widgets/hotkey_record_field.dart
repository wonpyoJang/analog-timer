import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../services/hotkey_service.dart';
import '../theme/app_theme.dart';

/// 자체 핫키 녹화 필드 — 패키지 HotKeyRecorder 를 쓰지 않는 이유:
/// 1) 표기가 맥 기호(⌃⇧⌥)라 Windows 사용자에게 오독을 유발
/// 2) 내부 로직이 블랙박스라 "조합이 안 잡힘" 류 문제를 진단·수정할 수 없음
///
/// 동작: HardwareKeyboard 전역 핸들러로 키다운을 수집.
/// - 수식키만 눌린 상태도 진행형으로 표시("Ctrl+Shift+Alt+…")
/// - 일반 키가 눌리면 그 시점의 수식키 조합으로 확정해 [onRecorded] 호출
class HotkeyRecordField extends StatefulWidget {
  final HotKey? initial;
  final ValueChanged<HotKey> onRecorded;
  const HotkeyRecordField({super.key, this.initial, required this.onRecorded});

  @override
  State<HotkeyRecordField> createState() => _HotkeyRecordFieldState();
}

class _HotkeyRecordFieldState extends State<HotkeyRecordField> {
  HotKey? _recorded;
  List<HotKeyModifier> _heldMods = const [];

  @override
  void initState() {
    super.initState();
    _recorded = widget.initial;
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  // PhysicalKeyboardKey 는 ==/hashCode 를 재정의해 const map 키로 못 쓴다.
  static final _modKeys = {
    PhysicalKeyboardKey.controlLeft: HotKeyModifier.control,
    PhysicalKeyboardKey.controlRight: HotKeyModifier.control,
    PhysicalKeyboardKey.shiftLeft: HotKeyModifier.shift,
    PhysicalKeyboardKey.shiftRight: HotKeyModifier.shift,
    PhysicalKeyboardKey.altLeft: HotKeyModifier.alt,
    PhysicalKeyboardKey.altRight: HotKeyModifier.alt,
    PhysicalKeyboardKey.metaLeft: HotKeyModifier.meta,
    PhysicalKeyboardKey.metaRight: HotKeyModifier.meta,
  };

  List<HotKeyModifier> _currentMods() {
    final pressed = HardwareKeyboard.instance.physicalKeysPressed;
    final mods = <HotKeyModifier>{
      for (final e in _modKeys.entries)
        if (pressed.contains(e.key)) e.value,
    };
    return mods.toList();
  }

  bool _onKey(KeyEvent event) {
    if (!mounted) return false;
    if (event is KeyUpEvent) {
      // 수식키를 뗐을 때 진행형 표시 갱신(확정본은 유지).
      setState(() => _heldMods = _currentMods());
      return true;
    }
    if (event is! KeyDownEvent) return false;
    final key = event.physicalKey;
    if (_modKeys.containsKey(key)) {
      setState(() => _heldMods = _currentMods());
      return true;
    }
    // 일반 키 확정 — 이 시점에 눌려 있는 수식키가 조합이 된다.
    final hk = HotKey(
      key: key,
      modifiers: _currentMods(),
      scope: HotKeyScope.system,
    );
    setState(() {
      _recorded = hk;
      _heldMods = const [];
    });
    widget.onRecorded(hk);
    return true; // 소비 — 다이얼로그 버튼 등으로 전파 방지
  }

  @override
  Widget build(BuildContext context) {
    String text;
    if (_heldMods.isNotEmpty) {
      // 진행형: 수식키 누르는 중.
      final preview = HotKey(
        key: PhysicalKeyboardKey.f24, // 표시용 더미 — 아래에서 잘라냄
        modifiers: _heldMods,
        scope: HotKeyScope.system,
      );
      final full = HotkeyService.describeHotKey(preview);
      text = '${full.substring(0, full.lastIndexOf('+') + 1)}…';
    } else if (_recorded != null) {
      text = HotkeyService.describeHotKey(_recorded!);
    } else {
      text = '…';
    }
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.text,
        fontFamily: 'Pretendard',
        letterSpacing: 0.5,
      ),
    );
  }
}
