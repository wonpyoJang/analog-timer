import 'package:flutter/foundation.dart';
import 'deep_link.dart';

/// 딥링크 라우팅 허브(디자인 "음성 어시스턴트 연동 기획" §7).
///
/// 컨텍스트 없는 딥링크 핸들러와 위젯 트리를 느슨하게 잇는다. MultiTimerBloc 을
/// 전역으로 승격하지 않고(=production 멀티타이머 생명주기 불변), "탭 전환 요청"과
/// "대기 액션" 두 신호만 노출한다. RootShell 이 탭을, MultiTimerScreen 이 액션을
/// 각자 자기 컨텍스트/로컬 bloc 으로 소비한다.
class DeepLinkRouter {
  DeepLinkRouter._();
  static final DeepLinkRouter instance = DeepLinkRouter._();

  static const tabTimer = 0;
  static const tabMulti = 1;
  static const tabWorkout = 2;

  /// RootShell 이 구독 — 요청된 탭 인덱스. 소비 후 null.
  final ValueNotifier<int?> requestedTab = ValueNotifier<int?>(null);

  /// MultiTimerScreen 이 구독 — 처리할 딥링크 액션. 소비 후 null.
  final ValueNotifier<DeepLinkAction?> pendingMulti =
      ValueNotifier<DeepLinkAction?>(null);

  void handle(DeepLinkAction a) {
    switch (a.kind) {
      case DeepLinkKind.unknown:
        return;
      case DeepLinkKind.workout:
        requestedTab.value = tabWorkout;
        break;
      default:
        // start/preset/loop/stop/ack/extend/status → 멀티 탭이 소비.
        pendingMulti.value = a;
        requestedTab.value = tabMulti;
    }
  }
}
