import 'package:flutter/material.dart';
import '../services/platform_info.dart';

/// 아이콘 전용 버튼을 스크린리더가 읽을 수 있게 감싸는 공통 헬퍼.
///
/// 기존 아이콘 버튼은 대부분 `GestureDetector` + `Icon` 조합이라 TalkBack/
/// VoiceOver에서 라벨 없이 무의미하게 읽혔다. 이 위젯으로 감싸면
/// (1) `Semantics(label, button:true)`로 용도가 읽히고
/// (2) 최소 터치 타깃을 보장한다 — 터치 플랫폼 48dp(WCAG 2.5.5/Material),
///     데스크톱(마우스 포인터)은 32dp: WCAG 2.5.8 포인터 최소(24dp)를 여유
///     있게 충족하면서, 행마다 버튼이 붙는 촘촘한 리스트(세그먼트 편집 등)의
///     세로 밀도를 회복한다.
class AccessibleIconButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Widget child;

  /// 데스크톱 호버 툴팁(선택) — 없으면 label을 툴팁으로도 쓴다.
  final String? tooltip;

  /// 히트 테스트 동작 — 반투명 배경 위 버튼은 opaque 유지.
  final HitTestBehavior behavior;

  /// 최소 타깃 크기 재정의(선택) — 기본은 플랫폼별(터치 48 / 데스크톱 32).
  final double? minSize;

  const AccessibleIconButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.child,
    this.tooltip,
    this.behavior = HitTestBehavior.opaque,
    this.minSize,
  });

  @override
  Widget build(BuildContext context) {
    final min = minSize ?? (isDesktop ? 32.0 : 48.0);
    Widget result = ConstrainedBox(
      constraints: BoxConstraints(minWidth: min, minHeight: min),
      child: Center(widthFactor: 1, heightFactor: 1, child: child),
    );
    result = Tooltip(message: tooltip ?? label, child: result);
    return Semantics(
      label: label,
      button: true,
      enabled: onTap != null,
      excludeSemantics: true,
      child: GestureDetector(onTap: onTap, behavior: behavior, child: result),
    );
  }
}
