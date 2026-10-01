import 'package:flutter_test/flutter_test.dart';

import 'package:astrea/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app shows the initial text.
    expect(find.text('Astrea App'), findsOneWidget);
  });
}
