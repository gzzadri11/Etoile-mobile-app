import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:etoile/shared/widgets/mascotte_message.dart';

void main() {
  group('MascotteMessage', () {
    testWidgets('displays title and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MascotteMessage(
              title: 'Bon debut !',
              message: 'Continue a completer ton profil',
            ),
          ),
        ),
      );

      expect(find.text('Bon debut !'), findsOneWidget);
      expect(find.text('Continue a completer ton profil'), findsOneWidget);
    });

    testWidgets('shows dismiss button when onDismiss is provided',
        (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MascotteMessage(
              title: 'Test',
              message: 'Message',
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, true);
    });

    testWidgets('does not show dismiss button when onDismiss is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MascotteMessage(
              title: 'Test',
              message: 'Message',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  group('MascotteMessage.forCompletion', () {
    test('returns null for 20%', () {
      expect(MascotteMessage.forCompletion(20), isNull);
    });

    test('returns info message for 40%', () {
      final msg = MascotteMessage.forCompletion(40);
      expect(msg, isNotNull);
      expect(msg!.title, 'Bon debut !');
      expect(msg.variant, MascotteVariant.info);
    });

    test('returns encouragement message for 60%', () {
      final msg = MascotteMessage.forCompletion(60);
      expect(msg, isNotNull);
      expect(msg!.title, 'Tu progresses bien !');
      expect(msg.variant, MascotteVariant.encouragement);
    });

    test('returns success message for 80%', () {
      final msg = MascotteMessage.forCompletion(80);
      expect(msg, isNotNull);
      expect(msg!.title, 'Presque fini !');
      expect(msg.variant, MascotteVariant.success);
    });

    test('returns null for 100%', () {
      expect(MascotteMessage.forCompletion(100), isNull);
    });
  });
}
