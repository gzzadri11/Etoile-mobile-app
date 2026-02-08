import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/feed_item_model.dart';
import '../../data/repositories/feed_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

/// BLoC for managing feed state
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final FeedRepository _feedRepository;

  FeedBloc({required FeedRepository feedRepository})
      : _feedRepository = feedRepository,
        super(const FeedInitial()) {
    on<FeedLoadRequested>(_onLoadRequested);
    on<FeedLoadMoreRequested>(_onLoadMoreRequested);
    on<FeedRefreshRequested>(_onRefreshRequested);
    on<FeedFiltersChanged>(_onFiltersChanged);
    on<FeedFiltersClear>(_onFiltersClear);
    on<FeedVideoViewed>(_onVideoViewed);
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
        limit: _pageSize,
        offset: 0,
      );

      final categories = await _feedRepository.getCategories();

      emit(FeedLoaded(
        items: items,
        categories: categories,
        hasMore: items.length >= _pageSize,
        filters: const FeedFilters.empty(),
        userRole: event.userRole,
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

    try {
      final items = await _getFeedByRole(
        role: role,
        limit: _pageSize,
        offset: 0,
        filters: filters,
      );

      final categories = currentState is FeedLoaded
          ? currentState.categories
          : await _feedRepository.getCategories();

      emit(FeedLoaded(
        items: items,
        categories: categories,
        hasMore: items.length >= _pageSize,
        filters: filters,
        userRole: role,
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

    emit(const FeedLoading());

    try {
      final items = await _getFeedByRole(
        role: role,
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

  /// Route feed loading to the correct repository method based on role
  Future<List<FeedItem>> _getFeedByRole({
    required String role,
    required int limit,
    required int offset,
    FeedFilters? filters,
  }) async {
    return switch (role) {
      'seeker' => _feedRepository.getSeekerFeed(
          limit: limit, offset: offset, filters: filters),
      'recruiter' => _feedRepository.getRecruiterFeed(
          limit: limit, offset: offset, filters: filters),
      _ => _feedRepository.getMixedFeed(
          limit: limit, offset: offset, filters: filters),
    };
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
}
