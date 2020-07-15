// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:twilio_programmable_chat_example/main.dart';

void main() {
  testWidgets('Creates Example', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(TwilioProgrammableChatExample());

    // Verify that platform version is retrieved.
    expect(
      find.text('Twilio Programmable Chat'),
      findsOneWidget,
    );
  });
}
