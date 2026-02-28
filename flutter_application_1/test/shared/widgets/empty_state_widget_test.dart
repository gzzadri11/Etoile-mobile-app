import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:etoile/shared/widgets/empty_state_widget.dart';

void main() {
  group('EmptyStateWidget', () {
    testWidgets('displays title text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(title: 'Aucune video'),
          ),
        ),
      );

      expect(find.text('Aucune video'), findsOneWidget);
    });

    testWidgets('displays subtitle when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'Aucune video',
              subtitle: 'Revenez plus tard',
            ),
          ),
        ),
      );

      expect(find.text('Aucune video'), findsOneWidget);
      expect(find.text('Revenez plus tard'), findsOneWidget);
    });

    testWidgets('displays icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.videocam_off,
              title: 'Aucune video',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.videocam_off), findsOneWidget);
    });

    testWidgets('displays action button when actionLabel and onAction provided',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'Aucune video',
              actionLabel: 'Voir le feed',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Voir le feed'), findsOneWidget);

      await tester.tap(find.text('Voir le feed'));
      expect(tapped, true);
    });

    testWidgets('does not display action button without onAction',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'Aucune video',
              actionLabel: 'Voir le feed',
            ),
          ),
        ),
      );

      // The button text should not be shown since onAction is null
      expect(find.text('Voir le feed'), findsNothing);
    });

    testWidgets('compact mode renders smaller layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.block,
              title: 'Aucun paiement',
              compact: true,
            ),
          ),
        ),
      );

      expect(find.text('Aucun paiement'), findsOneWidget);
      expect(find.byIcon(Icons.block), findsOneWidget);
    });
  });
}
