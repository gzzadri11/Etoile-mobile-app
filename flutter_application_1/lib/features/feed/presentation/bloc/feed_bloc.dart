library;

/// BLoC du feed video TikTok-style avec pagination et filtres.

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../applications/data/repositories/application_repository.dart';
import '../../../messages/data/repositories/block_repository.dart';
import '../../data/models/feed_item_model.dart';
import '../../data/repositories/feed_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

/// BLoC for managing feed state
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedRepository _feedRepository;
  final BlockRepository _blockRepository;
  final ApplicationRepository _applicationRepository;

  FeedBloc({
    required FeedRepository feedRepository,
    required BlockRepository blockRepository,
    required ApplicationRepository applicationRepository,
  })  : _feedRepository = feedRepository,
        _blockRepository = blockRepository,
        _applicationRepository = applicationRepository,
        super(const FeedInitial()) {
    on<FeedLoadRequested>(_onLoadRequested);
    on<FeedLoadMoreRequested>(_onLoadMoreRequested);
    on<FeedRefreshRequested>(_onRefreshRequested);
    on<FeedFiltersChanged>(_onFiltersChanged);
    on<FeedFiltersClear>(_onFiltersClear);
    on<FeedVideoViewed>(_onVideoViewed);
    on<FeedApplyToOffer>(_onApplyToOffer);
  }

  static const int _pageSize = 20;

  /// Load initial feed based on user role
  Future<void> _onLoadRequested(
    FeedLoadRequested event,
    Emitter<FeedState> emit,
  ) async {
    emit(const FeedLoading());

    try {
      final items = await _getFeedByRole(
        role: event.userRole,
        feedTab: event.feedTab,
        limit: _pageSize,
        offset: 0,
      );

      final categories = await _feedRepository.getCategories();

      // Load applied video IDs for seekers
      Set<String> appliedVideoIds = {};
      if (event.userRole == 'seeker') {
        try {
          appliedVideoIds = await _applicationRepository.getAppliedVideoIds();
        } catch (e) {
          debugPrint('[FeedBloc] Error loading applied video IDs: $e');
        }
      }

      emit(FeedLoaded(
        items: items,
        categories: categories,
        hasMore: items.length >= _pageSize,
        filters: const FeedFilters.empty(),
        userRole: event.userRole,
        feedTab: event.feedTab,
        appliedVideoIds: appliedVideoIds,
      ));
    } catch (e) {
      emit(FeedError(message: 'Erreur de chargement: ${e.toString()}'));
    }
  }

  /// Load more items (pagination)
  Future<void> _onLoadMoreRequested(
    FeedLoadMoreRequested event,
    Emitter<FeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FeedLoaded || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final newItems = await _getFeedByRole(
        role: currentState.userRole,
        feedTab: currentState.feedTab,
        limit: _pageSize,
        offset: currentState.items.length,
        filters: currentState.filters,
      );

      emit(currentState.copyWith(
        items: [...currentState.items, ...newItems],
        hasMore: newItems.length >= _pageSize,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  /// Refresh feed (pull to refresh)
  Future<void> _onRefreshRequested(
    FeedRefreshRequested event,
    Emitter<FeedState> emit,
  ) async {
    final currentState = state;
    final filters = currentState is FeedLoaded
        ? currentState.filters
        : const FeedFilters.empty();
    final role = currentState is FeedLoaded
        ? currentState.userRole
        : 'seeker';
    final feedTab = currentState is FeedLoaded
        ? currentState.feedTab
        : 'offers';

    try {
      final items = await _getFeedByRole(
        role: role,
        feedTab: feedTab,
        limit: _pageSize,
        offset: 0,
        filters: filters,
      );

      final categories = currentState is FeedLoaded
          ? currentState.categories
          : await _feedRepository.getCategories();

      // Reload applied video IDs for seekers
      Set<String> appliedVideoIds = currentState is FeedLoaded
          ? currentState.appliedVideoIds
          : {};
      if (role == 'seeker') {
        try {
          appliedVideoIds = await _applicationRepository.getAppliedVideoIds();
        } catch (_) {}
      }

      emit(FeedLoaded(
        items: items,
        categories: categories,
        hasMore: items.length >= _pageSize,
        filters: filters,
        userRole: role,
        feedTab: feedTab,
        appliedVideoIds: appliedVideoIds,
      ));
    } catch (e) {
      if (currentState is FeedLoaded) {
        emit(currentState);
      } else {
        emit(FeedError(message: 'Erreur de rafraichissement: ${e.toString()}'));
      }
    }
  }

  /// Apply new filters
  Future<void> _onFiltersChanged(
    FeedFiltersChanged event,
    Emitter<FeedState> emit,
  ) async {
    final currentState = state;
    final role = currentState is FeedLoaded
        ? currentState.userRole
        : 'seeker';
    final feedTab = currentState is FeedLoaded
        ? currentState.feedTab
        : 'offers';

    emit(const FeedLoading());

    try {
      final items = await _getFeedByRole(
        role: role,
        feedTab: feedTab,
        limit: _pageSize,
        offset: 0,
        filters: event.filters,
      );

      final categories = await _feedRepository.getCategories();

      emit(FeedLoaded(
        items: items,
        categories: categories,
        hasMore: items.length >= _pageSize,
        filters: event.filters,
        userRole: role,
        feedTab: feedTab,
      ));
    } catch (e) {
      emit(FeedError(message: 'Erreur de filtrage: ${e.toString()}'));
    }
  }

  /// Clear all filters
  Future<void> _onFiltersClear(
    FeedFiltersClear event,
    Emitter<FeedState> emit,
  ) async {
    add(const FeedFiltersChanged(filters: FeedFilters.empty()));
  }

  /// Route feed loading to the correct repository method based on role and tab
  Future<List<FeedItem>> _getFeedByRole({
    required String role,
    String feedTab = 'offers',
    required int limit,
    required int offset,
    FeedFilters? filters,
  }) async {
    List<FeedItem> items;
    if (feedTab == 'discover') {
      items = await _feedRepository.getSeekerDiscoverFeed(
          limit: limit, offset: offset, filters: filters);
    } else {
      items = await _feedRepository.getSeekerOffersFeed(
          limit: limit, offset: offset, filters: filters);
    }

    // Filter out blocked users
    try {
      final blockedIds = await _blockRepository.getBlockedUserIds();
      if (blockedIds.isNotEmpty) {
        items = items
            .where((item) => !blockedIds.contains(item.video.userId))
            .toList();
      }
    } catch (_) {
      // Silently fail - don't break feed if block check fails
    }

    return items;
  }

  /// Record video view
  Future<void> _onVideoViewed(
    FeedVideoViewed event,
    Emitter<FeedState> emit,
  ) async {
    try {
      await _feedRepository.recordView(
        videoId: event.videoId,
        watchDuration: event.watchDuration,
        completed: event.completed,
      );
    } catch (e) {
      // Silently fail - view tracking shouldn't block UI
    }
  }

  /// Apply to an offer (seeker only)
  Future<void> _onApplyToOffer(
    FeedApplyToOffer event,
    Emitter<FeedState> emit,
  ) async {
    final currentState = state;
    if (currentState is! FeedLoaded) return;

    // Optimistic update: add videoId to applied set immediately
    final updatedIds = {...currentState.appliedVideoIds, event.videoId};
    emit(currentState.copyWith(appliedVideoIds: updatedIds));

    try {
      await _applicationRepository.applyToOffer(
        videoId: event.videoId,
        recruiterId: event.recruiterId,
      );
      debugPrint('[FeedBloc] Applied to offer: ${event.videoId}');
    } catch (e) {
      debugPrint('[FeedBloc] Error applying to offer: $e');
      // Rollback optimistic update
      emit(currentState.copyWith(
        appliedVideoIds: currentState.appliedVideoIds,
      ));
    }
  }
}
