// Basic Flutter widget test for Etoile app

import 'package:flutter_test/flutter_test.dart';
import 'package:etoile/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EtoileApp());

    // Verify that the app starts without errors
    expect(find.text('ETOILE'), findsOneWidget);
  });
}
