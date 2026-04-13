/// Etats du BLoC feed (initial, charge, pagination, erreur).

part of 'feed_bloc.dart';

/// Classe de base des etats feed.
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
  final bool hasMore;
  final bool isLoadingMore;
  final FeedFilters filters;
  final String userRole;
  final String feedTab;
  final Set<String> appliedVideoIds;

  const FeedLoaded({
    required this.items,
    this.hasMore = false,
    this.isLoadingMore = false,
    required this.filters,
    required this.userRole,
    this.feedTab = 'offers',
    this.appliedVideoIds = const {},
  });

  /// Check if feed is empty
  bool get isEmpty => items.isEmpty;

  /// Check if filters are active
  bool get hasActiveFilters => filters.hasFilters;

  bool get isSeeker => userRole == 'seeker';
  bool get isRecruiter => userRole == 'recruiter';

  FeedLoaded copyWith({
    List<FeedItem>? items,
    bool? hasMore,
    bool? isLoadingMore,
    FeedFilters? filters,
    String? userRole,
    String? feedTab,
    Set<String>? appliedVideoIds,
  }) {
    return FeedLoaded(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filters: filters ?? this.filters,
      userRole: userRole ?? this.userRole,
      feedTab: feedTab ?? this.feedTab,
      appliedVideoIds: appliedVideoIds ?? this.appliedVideoIds,
    );
  }

  @override
  List<Object?> get props => [items, hasMore, isLoadingMore, filters, userRole, feedTab, appliedVideoIds];
}

/// Error state
class FeedError extends FeedState {
  final String message;

  const FeedError({required this.message});

  @override
  List<Object?> get props => [message];
}
