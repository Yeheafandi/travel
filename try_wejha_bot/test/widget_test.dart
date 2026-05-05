// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:try_wejha_bot/main.dart';

void main() {
  testWidgets('App shows bot runner screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(autoStart: false));

    expect(find.text('Telegram Bot Runner'), findsOneWidget);
    expect(find.text('Start Bot'), findsOneWidget);
    expect(find.text('Stop Bot'), findsOneWidget);
  });
}
