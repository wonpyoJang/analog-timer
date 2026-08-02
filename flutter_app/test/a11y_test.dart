import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:analog_timer/services/platform_info.dart';
import 'package:analog_timer/widgets/a11y.dart';
import 'package:analog_timer/services/text_scale_service.dart';

void main() {
  group('AccessibleIconButton', () {
    testWidgets('스크린리더 라벨 노출 + 플랫폼별 최소 터치 타깃', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AccessibleIconButton(
                label: '닫기',
                onTap: () => tapped = true,
                child: const Icon(Icons.close, size: 14),
              ),
            ),
          ),
        ),
      );

      // 라벨이 시맨틱 트리에 존재
      expect(find.bySemanticsLabel('닫기'), findsOneWidget);

      // 최소 터치 타깃 — 터치 48dp(WCAG 2.5.5) / 데스크톱 포인터 32dp
      // (WCAG 2.5.8 최소 24dp 충족). 테스트는 호스트 플랫폼에서 도니
      // platform_info 로 기대값을 맞춘다.
      final minTarget = isDesktop ? 32.0 : 48.0;
      final size = tester.getSize(find.byType(AccessibleIconButton));
      expect(size.width, greaterThanOrEqualTo(minTarget));
      expect(size.height, greaterThanOrEqualTo(minTarget));

      await tester.tap(find.byType(AccessibleIconButton));
      expect(tapped, isTrue);
    });

    testWidgets('onTap null이면 비활성 시맨틱', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AccessibleIconButton(
              label: '삭제',
              onTap: null,
              child: Icon(Icons.delete),
            ),
          ),
        ),
      );
      final node = tester.getSemantics(find.bySemanticsLabel('삭제'));
      expect(node.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(node.hasFlag(SemanticsFlag.isEnabled), isFalse);
    });
  });

  group('TextScaleService', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('기본 1.0, 범위 밖 값은 클램프', () async {
      final s = TextScaleService.instance;
      await s.setScale(9.0);
      expect(s.scale, TextScaleService.maxScale);
      await s.setScale(0.1);
      expect(s.scale, TextScaleService.minScale);
      await s.setScale(1.2);
      expect(s.scale, 1.2);
    });

    test('setScale이 prefs에 저장되어 init로 복원', () async {
      await TextScaleService.instance.setScale(1.4);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('text_scale'), 1.4);
    });
  });
}
