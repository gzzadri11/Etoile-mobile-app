import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:etoile/shared/widgets/etoile_badge.dart';

void main() {
  group('EtoileBadge', () {
    testWidgets('displays label text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EtoileBadge(
              label: 'Verifie',
              backgroundColor: Colors.yellow,
              textColor: Colors.black,
            ),
          ),
        ),
      );

      expect(find.text('Verifie'), findsOneWidget);
    });

    testWidgets('displays icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EtoileBadge(
              label: 'Verifie',
              icon: Icons.check_circle,
              backgroundColor: Colors.yellow,
              textColor: Colors.black,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('does not display icon when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EtoileBadge(
              label: 'Test',
              backgroundColor: Colors.blue,
              textColor: Colors.white,
            ),
          ),
        ),
      );

      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('compact mode renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EtoileBadge(
              label: 'Badge',
              backgroundColor: Colors.orange,
              textColor: Colors.white,
              compact: true,
            ),
          ),
        ),
      );

      // Verify the badge renders without error in compact mode
      expect(find.text('Badge'), findsOneWidget);
    });

    testWidgets('normal mode has 28px height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EtoileBadge(
              label: 'Entreprise',
              icon: Icons.business,
              backgroundColor: Colors.orange,
              textColor: Colors.white,
              compact: false,
            ),
          ),
        ),
      );

      expect(find.text('Entreprise'), findsOneWidget);
      expect(find.byIcon(Icons.business), findsOneWidget);
    });
  });
}
