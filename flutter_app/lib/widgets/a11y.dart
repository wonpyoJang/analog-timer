import 'package:flutter/material.dart';

/// 아이콘 전용 버튼을 스크린리더가 읽을 수 있게 감싸는 공통 헬퍼.
///
/// 기존 아이콘 버튼은 대부분 `GestureDetector` + `Icon` 조합이라 TalkBack/
/// VoiceOver에서 라벨 없이 무의미하게 읽혔다. 이 위젯으로 감싸면
/// (1) `Semantics(label, button:true)`로 용도가 읽히고
/// (2) 최소 48dp 터치 타깃을 보장한다(WCAG / Material 권장).
class AccessibleIconButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Widget child;

  /// 데스크톱 호버 툴팁(선택) — 없으면 label을 툴팁으로도 쓴다.
  final String? tooltip;

  /// 히트 테스트 동작 — 반투명 배경 위 버튼은 opaque 유지.
  final HitTestBehavior behavior;

  const AccessibleIconButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.child,
    this.tooltip,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
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
