import 'package:etoile/features/feed/data/models/feed_item_model.dart';
import 'package:etoile/features/feed/data/repositories/feed_repository.dart';
import 'package:etoile/features/video/data/models/video_model.dart';
import 'package:flutter_test/flutter_test.dart';

Video _testVideo() => Video(
      id: 'v1',
      userId: 'u1',
      type: 'offer',
      videoKey: 'key',
      durationSeconds: 40,
      status: 'active',
      viewsCount: 0,
      uniqueViewers: 0,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  group('Haversine distance', () {
    test('Paris to Lyon is approximately 390-395 km', () {
      final distance = FeedRepository.haversineDistance(
        48.8566, 2.3522, 45.7640, 4.8357,
      );
      expect(distance, greaterThan(389));
      expect(distance, lessThan(396));
    });

    test('same point returns 0', () {
      final distance = FeedRepository.haversineDistance(
        48.8566, 2.3522, 48.8566, 2.3522,
      );
      expect(distance, equals(0.0));
    });

    test('Paris to Creteil is approximately 10-13 km', () {
      final distance = FeedRepository.haversineDistance(
        48.8566, 2.3522, 48.7905, 2.4559,
      );
      expect(distance, greaterThan(9));
      expect(distance, lessThan(14));
    });

    test('Paris to Marseille is approximately 660-665 km', () {
      final distance = FeedRepository.haversineDistance(
        48.8566, 2.3522, 43.2965, 5.3698,
      );
      expect(distance, greaterThan(659));
      expect(distance, lessThan(666));
    });
  });

  group('FeedFilters proximity', () {
    test('hasFilters returns true when proximityKm is set', () {
      const filters = FeedFilters(proximityKm: 10.0);
      expect(filters.hasFilters, isTrue);
    });

    test('hasFilters returns false when empty', () {
      const filters = FeedFilters.empty();
      expect(filters.hasFilters, isFalse);
    });

    test('copyWith sets proximityKm and user coordinates', () {
      const filters = FeedFilters.empty();
      final updated = filters.copyWith(
        proximityKm: 25.0,
        userLatitude: 48.8566,
        userLongitude: 2.3522,
      );
      expect(updated.proximityKm, equals(25.0));
      expect(updated.userLatitude, equals(48.8566));
      expect(updated.userLongitude, equals(2.3522));
    });

    test('copyWith clears proximityKm', () {
      const filters = FeedFilters(
        proximityKm: 10.0,
        userLatitude: 48.8566,
        userLongitude: 2.3522,
      );
      final cleared = filters.copyWith(
        clearProximityKm: true,
        clearUserLatitude: true,
        clearUserLongitude: true,
      );
      expect(cleared.proximityKm, isNull);
      expect(cleared.userLatitude, isNull);
      expect(cleared.userLongitude, isNull);
    });

    test('clear() resets all filters including proximity', () {
      const filters = FeedFilters(
        sector: 'informatique_tech',
        proximityKm: 15.0,
        userLatitude: 48.8566,
        userLongitude: 2.3522,
      );
      final cleared = filters.clear();
      expect(cleared.sector, isNull);
      expect(cleared.proximityKm, isNull);
      expect(cleared.userLatitude, isNull);
    });
  });

  group('FeedItem coordinates', () {
    test('FeedItem stores latitude and longitude', () {
      final item = FeedItem(
        video: _testVideo(),
        userName: 'Test',
        latitude: 48.8566,
        longitude: 2.3522,
      );
      expect(item.latitude, equals(48.8566));
      expect(item.longitude, equals(2.3522));
    });

    test('FeedItem without coordinates has null lat/lng', () {
      final item = FeedItem(
        video: _testVideo(),
        userName: 'Test',
      );
      expect(item.latitude, isNull);
      expect(item.longitude, isNull);
    });

    test('FeedItem equality includes coordinates', () {
      final item1 = FeedItem(
        video: _testVideo(),
        userName: 'Test',
        latitude: 48.8566,
        longitude: 2.3522,
      );
      final item2 = FeedItem(
        video: _testVideo(),
        userName: 'Test',
        latitude: 45.7640,
        longitude: 4.8357,
      );
      expect(item1, isNot(equals(item2)));
    });
  });
}
