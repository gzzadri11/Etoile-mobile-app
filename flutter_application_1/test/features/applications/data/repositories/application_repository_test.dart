import 'package:flutter_test/flutter_test.dart';
import 'package:etoile/features/applications/data/repositories/application_repository.dart';

void main() {
  group('OfferWithApplications', () {
    test('stores all fields correctly', () {
      final offer = OfferWithApplications(
        videoId: 'vid-1',
        title: 'Vendeur alternance',
        type: 'offer',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        contractType: 'Alternance',
        status: 'active',
        publishedAt: DateTime(2026, 3, 20),
        applicationCount: 5,
      );

      expect(offer.videoId, 'vid-1');
      expect(offer.title, 'Vendeur alternance');
      expect(offer.type, 'offer');
      expect(offer.thumbnailUrl, 'https://example.com/thumb.jpg');
      expect(offer.contractType, 'Alternance');
      expect(offer.status, 'active');
      expect(offer.applicationCount, 5);
    });

    test('equatable compares by videoId and applicationCount', () {
      final a = OfferWithApplications(
        videoId: 'vid-1',
        title: 'A',
        type: 'offer',
        status: 'active',
        applicationCount: 3,
      );
      final b = OfferWithApplications(
        videoId: 'vid-1',
        title: 'B',
        type: 'poster',
        status: 'active',
        applicationCount: 3,
      );
      expect(a, equals(b));
    });

    test('poster type is stored correctly', () {
      final offer = OfferWithApplications(
        videoId: 'vid-2',
        title: 'Affiche serveur',
        type: 'poster',
        status: 'active',
        applicationCount: 0,
      );
      expect(offer.type, 'poster');
      expect(offer.applicationCount, 0);
    });
  });

  group('OfferCandidate', () {
    test('stores all profile fields correctly', () {
      final candidate = OfferCandidate(
        seekerUserId: 'user-1',
        applicationId: 'app-1',
        applicationStatus: 'pending',
        appliedAt: DateTime(2026, 3, 15),
        name: 'Jean Dupont',
        photoUrl: 'https://example.com/photo.jpg',
        age: '22',
        school: 'ESSEC',
        studyLevel: 'bac_plus_3',
        city: 'Paris',
        domain: 'commerce_vente',
        specialty: 'vente_conseil',
        presentationVideoUrl: 'https://example.com/video.mp4',
        presentationThumbnailUrl: 'https://example.com/thumb.jpg',
        presentationVideoId: 'video-1',
      );

      expect(candidate.seekerUserId, 'user-1');
      expect(candidate.applicationId, 'app-1');
      expect(candidate.applicationStatus, 'pending');
      expect(candidate.name, 'Jean Dupont');
      expect(candidate.age, '22');
      expect(candidate.school, 'ESSEC');
      expect(candidate.studyLevel, 'bac_plus_3');
      expect(candidate.city, 'Paris');
      expect(candidate.domain, 'commerce_vente');
      expect(candidate.specialty, 'vente_conseil');
      expect(candidate.presentationVideoUrl, 'https://example.com/video.mp4');
      expect(candidate.presentationVideoId, 'video-1');
    });

    test('handles missing optional fields', () {
      final candidate = OfferCandidate(
        seekerUserId: 'user-2',
        applicationId: 'app-2',
        applicationStatus: 'contacted',
        appliedAt: DateTime(2026, 3, 18),
        name: 'Marie',
      );

      expect(candidate.name, 'Marie');
      expect(candidate.applicationStatus, 'contacted');
      expect(candidate.photoUrl, isNull);
      expect(candidate.age, isNull);
      expect(candidate.school, isNull);
      expect(candidate.city, isNull);
      expect(candidate.presentationVideoUrl, isNull);
    });

    test('equatable compares by seekerUserId and applicationId', () {
      final a = OfferCandidate(
        seekerUserId: 'user-1',
        applicationId: 'app-1',
        applicationStatus: 'pending',
        appliedAt: DateTime(2026, 3, 15),
        name: 'Jean',
      );
      final b = OfferCandidate(
        seekerUserId: 'user-1',
        applicationId: 'app-1',
        applicationStatus: 'contacted',
        appliedAt: DateTime(2026, 3, 20),
        name: 'Jean Dupont',
      );
      expect(a, equals(b));
    });
  });

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
