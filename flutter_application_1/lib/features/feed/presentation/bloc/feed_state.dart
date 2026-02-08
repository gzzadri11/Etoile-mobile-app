part of 'feed_bloc.dart';

/// Base class for feed states
sealed class FeedState extends Equatable {
  const FeedState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FeedInitial extends FeedState {
  const FeedInitial();
}

/// Loading feed
class FeedLoading extends FeedState {
  const FeedLoading();
}

/// Feed loaded successfully
class FeedLoaded extends FeedState {
  final List<FeedItem> items;
  final List<Map<String, dynamic>> categories;
  final bool hasMore;
  final bool isLoadingMore;
  final FeedFilters filters;
  final String userRole;

  const FeedLoaded({
    required this.items,
    required this.categories,
    this.hasMore = false,
    this.isLoadingMore = false,
    required this.filters,
    required this.userRole,
  });

  /// Check if feed is empty
  bool get isEmpty => items.isEmpty;

  /// Check if filters are active
  bool get hasActiveFilters => filters.hasFilters;

  bool get isSeeker => userRole == 'seeker';
  bool get isRecruiter => userRole == 'recruiter';

  FeedLoaded copyWith({
    List<FeedItem>? items,
    List<Map<String, dynamic>>? categories,
    bool? hasMore,
    bool? isLoadingMore,
    FeedFilters? filters,
    String? userRole,
  }) {
    return FeedLoaded(
      items: items ?? this.items,
      categories: categories ?? this.categories,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filters: filters ?? this.filters,
      userRole: userRole ?? this.userRole,
    );
  }

  @override
  List<Object?> get props => [items, categories, hasMore, isLoadingMore, filters, userRole];
}

/// Error state
class FeedError extends FeedState {
  final String message;

  const FeedError({required this.message});

  @override
  List<Object?> get props => [message];
}
