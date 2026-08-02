import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// 시스템 "굵은 글씨"(MediaQuery.boldText)는 Flutter Text가 자동 반영한다.
// 앱은 이 플래그를 클램프/제거하지 않으므로(withUserTextScale는 copyWith로
// textScaler만 바꿈 → boldText 보존) 모든 Text가 시스템 설정을 따른다.
void main() {
  testWidgets('Text는 boldText를 자동 반영(w400→bold)', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(boldText: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text('가', style: TextStyle(fontWeight: FontWeight.w400)),
        ),
      ),
    );
    final rt = tester.widget<RichText>(find.byType(RichText));
    expect(rt.text.style?.fontWeight, FontWeight.bold);
  });

  test('MediaQueryData.copyWith(textScaler:)는 boldText를 보존', () {
    const base = MediaQueryData(boldText: true);
    final wrapped = base.copyWith(textScaler: const TextScaler.linear(1.4));
    expect(wrapped.boldText, isTrue);
  });
}
