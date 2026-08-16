import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'deep_link.dart';
import 'platform_info.dart';

/// 딥링크 수신 브리지(디자인 "음성 어시스턴트 연동 기획" §7).
///
/// 네이티브(MainActivity)가 `anytime://` intent 를 채널로 넘긴다. 콜드/웜 두 경로
/// 모두 처리 — 콜드는 앱 초기화 완료 후 getInitialLink 로 1회 흡수, 웜은 스트림.
/// 루틴이 같은 링크를 연달아 쏘는 경우가 있어 동일 URI 3초 내 재수신은 무시(§7).
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  static const _channel = MethodChannel('dev.analogtimer/deeplink');

  /// 앱 루트가 등록 — 파싱된 동작을 실제 화면/블록에 연결.
  void Function(DeepLinkAction action)? onAction;

  String? _lastRaw;
  int _lastAtMs = 0;
  bool _started = false;

  /// 채널 리스너 등록 + 콜드 스타트 초기 링크 흡수. main 에서 1회 호출.
  /// Android=MainActivity, iOS=AppDelegate/SceneDelegate 가 같은 채널로 넘긴다.
  Future<void> init() async {
    if (_started || (!isAndroid && !isIOS)) return;
    _started = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'link') {
        _dispatch(call.arguments as String? ?? '');
      }
    });
    try {
      final initial = await _channel.invokeMethod<String>('getInitialLink');
      if (initial != null && initial.isNotEmpty) _dispatch(initial);
    } catch (_) {}
  }

  /// 갤럭시 "모드와 루틴" 앱 실행. 실패(미설치 등) 시 false.
  Future<bool> openRoutinesApp() async {
    if (!isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>('openRoutines') ?? false;
    } catch (_) {
      return false;
    }
  }

  void _dispatch(String raw) {
    if (raw.isEmpty) return;
    // 3초 규칙 — 루틴 중복 발동·재발화 흡수(§7).
    final now = DateTime.now().millisecondsSinceEpoch;
    if (raw == _lastRaw && now - _lastAtMs < 3000) return;
    _lastRaw = raw;
    _lastAtMs = now;

    final action = parseDeepLink(raw);
    if (action.kind == DeepLinkKind.unknown) {
      debugPrint('[deeplink] ignored: $raw');
      return;
    }
    onAction?.call(action);
  }
}
