import 'package:flutter_test/flutter_test.dart';
import 'package:analog_timer/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AnalogTimerApp());
    await tester.pump();
    expect(find.text('⏱ ANALOG TIMER'), findsOneWidget);
  });
}
