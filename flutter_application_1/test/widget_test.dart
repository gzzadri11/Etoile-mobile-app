// Basic Flutter widget test for Etoile app

import 'package:flutter_test/flutter_test.dart';
import 'package:etoile/shared/widgets/splash_screen.dart';

void main() {
  testWidgets('SplashScreen shows app name and loading', (WidgetTester tester) async {
    await tester.pumpWidget(const SplashScreen());

    // Verify that the splash screen shows the app name
    expect(find.text('ETOILE'), findsOneWidget);

    // Verify tagline
    expect(find.text('Recrutement par video'), findsOneWidget);
  });
}
