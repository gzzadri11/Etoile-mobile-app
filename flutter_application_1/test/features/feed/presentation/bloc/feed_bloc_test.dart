import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:etoile/features/feed/data/models/feed_item_model.dart';
import 'package:etoile/features/feed/data/repositories/feed_repository.dart';
import 'package:etoile/features/feed/presentation/bloc/feed_bloc.dart';
import 'package:etoile/features/messages/data/repositories/block_repository.dart';
import 'package:etoile/features/video/data/models/video_model.dart';

// ============================================================================
// Mocks
// ============================================================================

class MockFeedRepository extends Mock implements FeedRepository {}

class MockBlockRepository extends Mock implements BlockRepository {}

// ============================================================================
// Helpers
// ============================================================================

final _now = DateTime.now();

Video _makeVideo({String id = 'v1', String userId = 'u1'}) => Video(
      id: id,
      userId: userId,
      type: 'offer',
      videoKey: 'key-$id',
      createdAt: _now,
      updatedAt: _now,
    );

FeedItem _makeItem({String id = 'v1', String userId = 'u1'}) => FeedItem(
      video: _makeVideo(id: id, userId: userId),
      userName: 'User $id',
    );

const _categories = <Map<String, dynamic>>[
  {'id': 'cat1', 'name': 'Dev', 'is_active': true},
];

// ============================================================================
// Tests
// ============================================================================

void main() {
  late MockFeedRepository mockFeedRepo;
  late MockBlockRepository mockBlockRepo;

  setUp(() {
    mockFeedRepo = MockFeedRepository();
    mockBlockRepo = MockBlockRepository();

    // Register fallback values for named parameters
    registerFallbackValue(const FeedFilters.empty());
  });

  FeedBloc buildBloc() => FeedBloc(
        feedRepository: mockFeedRepo,
        blockRepository: mockBlockRepo,
      );

  void stubFeed(List<FeedItem> items) {
    when(() => mockFeedRepo.getSeekerOffersFeed(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          filters: any(named: 'filters'),
        )).thenAnswer((_) async => items);
    when(() => mockFeedRepo.getCategories())
        .thenAnswer((_) async => _categories);
    when(() => mockBlockRepo.getBlockedUserIds())
        .thenAnswer((_) async => []);
  }

  group('FeedLoadRequested', () {
    blocTest<FeedBloc, FeedState>(
      'emits [FeedLoading, FeedLoaded] with items on success',
      build: () {
        stubFeed([_makeItem(id: 'v1'), _makeItem(id: 'v2')]);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const FeedLoadRequested(userRole: 'seeker')),
      expect: () => [
        isA<FeedLoading>(),
        isA<FeedLoaded>()
            .having((s) => s.items.length, 'items count', 2)
            .having((s) => s.userRole, 'userRole', 'seeker'),
      ],
    );

    blocTest<FeedBloc, FeedState>(
      'emits [FeedLoading, FeedLoaded] with empty list when no videos',
      build: () {
        stubFeed([]);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const FeedLoadRequested(userRole: 'seeker')),
      expect: () => [
        isA<FeedLoading>(),
        isA<FeedLoaded>()
            .having((s) => s.items.length, 'items count', 0)
            .having((s) => s.isEmpty, 'isEmpty', true),
      ],
    );

    blocTest<FeedBloc, FeedState>(
      'emits [FeedLoading, FeedError] on repository error',
      build: () {
        when(() => mockFeedRepo.getSeekerOffersFeed(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
              filters: any(named: 'filters'),
            )).thenThrow(Exception('Network error'));
        when(() => mockFeedRepo.getCategories())
            .thenAnswer((_) async => _categories);
        when(() => mockBlockRepo.getBlockedUserIds())
            .thenAnswer((_) async => []);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const FeedLoadRequested(userRole: 'seeker')),
      expect: () => [
        isA<FeedLoading>(),
        isA<FeedError>(),
      ],
    );
  });

  group('Blocked users filtering', () {
    blocTest<FeedBloc, FeedState>(
      'excludes blocked users from feed results',
      build: () {
        when(() => mockFeedRepo.getSeekerOffersFeed(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
              filters: any(named: 'filters'),
            )).thenAnswer((_) async => [
              _makeItem(id: 'v1', userId: 'user-ok'),
              _makeItem(id: 'v2', userId: 'user-blocked'),
              _makeItem(id: 'v3', userId: 'user-ok-2'),
            ]);
        when(() => mockFeedRepo.getCategories())
            .thenAnswer((_) async => _categories);
        when(() => mockBlockRepo.getBlockedUserIds())
            .thenAnswer((_) async => ['user-blocked']);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const FeedLoadRequested(userRole: 'seeker')),
      expect: () => [
        isA<FeedLoading>(),
        isA<FeedLoaded>()
            .having((s) => s.items.length, 'items count', 2)
            .having(
              (s) => s.items.every((i) => i.video.userId != 'user-blocked'),
              'no blocked user',
              true,
            ),
      ],
    );
  });

  group('FeedRefreshRequested', () {
    blocTest<FeedBloc, FeedState>(
      'refreshes feed with fresh data',
      build: () {
        stubFeed([_makeItem(id: 'v1')]);
        return buildBloc();
      },
      seed: () => FeedLoaded(
        items: [_makeItem(id: 'old')],
        categories: _categories,
        filters: const FeedFilters.empty(),
        userRole: 'seeker',
      ),
      act: (bloc) => bloc.add(const FeedRefreshRequested()),
      expect: () => [
        isA<FeedLoaded>()
            .having((s) => s.items.first.video.id, 'new item id', 'v1'),
      ],
    );
  });

  group('FeedFiltersChanged', () {
    blocTest<FeedBloc, FeedState>(
      'reloads feed with new filters applied',
      build: () {
        when(() => mockFeedRepo.getSeekerOffersFeed(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
              filters: any(named: 'filters'),
            )).thenAnswer((_) async => [_makeItem(id: 'filtered')]);
        when(() => mockFeedRepo.getCategories())
            .thenAnswer((_) async => _categories);
        when(() => mockBlockRepo.getBlockedUserIds())
            .thenAnswer((_) async => []);
        return buildBloc();
      },
      seed: () => FeedLoaded(
        items: [_makeItem(id: 'old')],
        categories: _categories,
        filters: const FeedFilters.empty(),
        userRole: 'seeker',
      ),
      act: (bloc) => bloc.add(
        const FeedFiltersChanged(
          filters: FeedFilters(categoryId: 'cat1'),
        ),
      ),
      expect: () => [
        isA<FeedLoading>(),
        isA<FeedLoaded>()
            .having((s) => s.filters.categoryId, 'categoryId', 'cat1')
            .having(
                (s) => s.items.first.video.id, 'filtered item', 'filtered'),
      ],
    );
  });
}
