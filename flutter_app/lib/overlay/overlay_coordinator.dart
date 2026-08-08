/// 두 오버레이 시스템의 상호 배타 조정자.
///
/// 단일 오버레이(flutter_overlay_window, 별도 FlutterEngine)와 멀티 네이티브
/// 오버레이(엔진 0개)를 동시에 켜면, 살아있는 2nd 엔진이 플랫폼 스레드를 60fps로
/// 잠식해 멀티 오버레이의 표시 지연·드래그 지연·서비스 ANR을 유발한다.
/// 하나를 켜면 다른 하나를 끄도록 각 화면이 훅을 등록한다.
class OverlayCoordinator {
  OverlayCoordinator._();
  static final OverlayCoordinator instance = OverlayCoordinator._();

  /// 단일 오버레이를 끄는 훅 — home_screen 이 등록.
  Future<void> Function()? hideSingleOverlay;

  /// 멀티 오버레이를 전부 끄는 훅 — multi_timer_screen 이 등록.
  Future<void> Function()? closeMultiOverlays;

  /// 멀티 오버레이가 켜졌다 → 단일 오버레이를 끈다.
  Future<void> onMultiOverlayEnabled() async => hideSingleOverlay?.call();

  /// 단일 오버레이가 켜졌다 → 멀티 오버레이를 전부 끈다.
  Future<void> onSingleOverlayEnabled() async => closeMultiOverlays?.call();
}
