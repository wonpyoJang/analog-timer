import 'package:flutter/services.dart';
import 'platform_info.dart';

/// 동적 앱 단축어 브리지(디자인 "음성 어시스턴트 연동 기획" §4).
///
/// 런처 아이콘 롱프레스 목록에 고정 명령 + 자주 쓰는 프리셋 상위 3개를 올린다.
/// 각 단축어는 anytime:// 딥링크를 호출 — 어시스턴트가 없어도 롱프레스로 쓸 수 있고,
/// 어시스턴트 단축어 인식이 되는 기기에서는 이름이 곧 발화 문구가 된다.
class ShortcutsService {
  ShortcutsService._();
  static const _channel = MethodChannel('dev.analogtimer/shortcuts');

  /// [items] 각 원소: {id, short, long, link}. 최대 8개(네이티브에서 take(8)).
  static Future<void> setShortcuts(List<Map<String, String>> items) async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod('setShortcuts', {'items': items});
    } catch (_) {}
  }
}
