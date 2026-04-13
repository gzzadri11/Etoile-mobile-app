import 'package:flutter_test/flutter_test.dart';
import 'package:etoile/features/applications/data/repositories/application_repository.dart';

void main() {
  group('SeekerApplication', () {
    test('stores all fields correctly', () {
      final app = SeekerApplication(
        id: 'app-1',
        videoId: 'vid-1',
        status: 'pending',
        appliedAt: DateTime(2026, 3, 20),
        offerTitle: 'Vendeur alternance',
        companyName: 'ACME Corp',
        contractType: 'Alternance',
      );

      expect(app.id, 'app-1');
      expect(app.videoId, 'vid-1');
      expect(app.status, 'pending');
      expect(app.offerTitle, 'Vendeur alternance');
      expect(app.companyName, 'ACME Corp');
      expect(app.contractType, 'Alternance');
    });

    test('equatable compares by id, videoId, status', () {
      final a = SeekerApplication(
        id: 'app-1',
        videoId: 'vid-1',
        status: 'pending',
        appliedAt: DateTime(2026, 3, 15),
        offerTitle: 'A',
        companyName: 'X',
      );
      final b = SeekerApplication(
        id: 'app-1',
        videoId: 'vid-1',
        status: 'pending',
        appliedAt: DateTime(2026, 3, 20),
        offerTitle: 'B',
        companyName: 'Y',
      );
      expect(a, equals(b));
    });

    test('different status means different objects', () {
      final a = SeekerApplication(
        id: 'app-1',
        videoId: 'vid-1',
        status: 'pending',
        appliedAt: DateTime(2026, 3, 20),
        offerTitle: 'A',
        companyName: 'X',
      );
      final b = SeekerApplication(
        id: 'app-1',
        videoId: 'vid-1',
        status: 'contacted',
        appliedAt: DateTime(2026, 3, 20),
        offerTitle: 'A',
        companyName: 'X',
      );
      expect(a, isNot(equals(b)));
    });

    test('contractType is optional', () {
      final app = SeekerApplication(
        id: 'app-2',
        videoId: 'vid-2',
        status: 'withdrawn',
        appliedAt: DateTime(2026, 3, 18),
        offerTitle: 'Serveur',
        companyName: 'Restaurant XYZ',
      );
      expect(app.contractType, isNull);
      expect(app.status, 'withdrawn');
    });
  });
}
