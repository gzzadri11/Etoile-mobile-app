part of 'feed_bloc.dart';

/// Base class for feed events
sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial feed with role-specific content
class FeedLoadRequested extends FeedEvent {
  final String userRole;

  const FeedLoadRequested({required this.userRole});

  @override
  List<Object?> get props => [userRole];
}

/// Load more items (pagination)
class FeedLoadMoreRequested extends FeedEvent {
  const FeedLoadMoreRequested();
}

/// Refresh feed (pull to refresh)
class FeedRefreshRequested extends FeedEvent {
  const FeedRefreshRequested();
}

/// Apply new filters
class FeedFiltersChanged extends FeedEvent {
  final FeedFilters filters;

  const FeedFiltersChanged({required this.filters});

  @override
  List<Object?> get props => [filters];
}

/// Clear all filters
class FeedFiltersClear extends FeedEvent {
  const FeedFiltersClear();
}

/// Record video view
class FeedVideoViewed extends FeedEvent {
  final String videoId;
  final int? watchDuration;
  final bool completed;

  const FeedVideoViewed({
    required this.videoId,
    this.watchDuration,
    this.completed = false,
  });

  @override
  List<Object?> get props => [videoId, watchDuration, completed];
}
