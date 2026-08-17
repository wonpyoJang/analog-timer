import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:analog_timer/services/hotkey_service.dart';
import 'package:analog_timer/services/platform_info.dart' as plat;

// macOS 호스트에서 실행되면 전역 핫키 라벨이 네이티브 기호(⌃⇧⌥⌘)로 나오는지,
// 그리고 KeyCaps 가 칩으로 쪼갤 수 있게 '+' 구분자가 유지되는지 확정한다.
void main() {
  test('modifier labels are macOS symbols on macOS, words elsewhere', () {
    final combo = HotkeyService.describeHotKey(
      HotKey(
        key: LogicalKeyboardKey.space,
        modifiers: const [
          HotKeyModifier.control,
          HotKeyModifier.shift,
          HotKeyModifier.alt,
        ],
      ),
    );
    final chips = combo.split('+'); // KeyCaps 가 실제로 쓰는 분리 방식

    if (plat.isMacOS) {
      expect(HotkeyService.modifierLabel(HotKeyModifier.control), '⌃');
      expect(HotkeyService.modifierLabel(HotKeyModifier.shift), '⇧');
      expect(HotkeyService.modifierLabel(HotKeyModifier.alt), '⌥');
      expect(HotkeyService.modifierLabel(HotKeyModifier.meta), '⌘');
      expect(combo, '⌃+⇧+⌥+Space');
      expect(chips, ['⌃', '⇧', '⌥', 'Space']);
    } else {
      expect(HotkeyService.modifierLabel(HotKeyModifier.meta), 'Win');
      expect(combo, 'Ctrl+Shift+Alt+Space');
      expect(chips, ['Ctrl', 'Shift', 'Alt', 'Space']);
    }
  });
}
