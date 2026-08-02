import 'package:shared_preferences/shared_preferences.dart';

/// 단축키 맥락 힌트 — 같은 버튼을 마우스로 3번째 누른 순간, 그 동작의 단축키를
/// 스낵바로 1회만 알려준다(액션별 1회).
///
/// "미리 가르치기"가 아니라 "이미 하는 행동에 대안 붙이기" — 사용자가 방금 한
/// 조작 직후에 알려줘야 다음번에 손이 키보드로 간다. TTS 온보딩과 같은
/// 절제 원칙: 무시하면 다시 안 뜬다.
class ShortcutHintService {
  ShortcutHintService._();
  static final ShortcutHintService instance = ShortcutHintService._();

  static const int _threshold = 3;

  /// 힌트 표시 콜백 — home_screen 이 스낵바로 배선. (액션 키 전달)
  void Function(String action)? onHint;

  /// 버튼 클릭 보고 — 3회째 & 미노출이면 onHint 를 1회 발화.
  Future<void> buttonPressed(String action) async {
    try {
      final p = await SharedPreferences.getInstance();
      final shownKey = 'sc_hint_shown_$action';
      if (p.getBool(shownKey) ?? false) return;
      final countKey = 'sc_hint_count_$action';
      final n = (p.getInt(countKey) ?? 0) + 1;
      await p.setInt(countKey, n);
      if (n >= _threshold) {
        await p.setBool(shownKey, true);
        onHint?.call(action);
      }
    } catch (_) {}
  }
}
