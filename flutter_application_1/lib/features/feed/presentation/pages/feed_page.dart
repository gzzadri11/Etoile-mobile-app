import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../messages/data/repositories/conversation_repository.dart';
import '../../data/models/feed_item_model.dart';
import '../bloc/feed_bloc.dart';
import '../widgets/feed_video_player.dart';
import '../widgets/profile_bottom_sheet.dart';
import '../widgets/video_preload_manager.dart';

/// Main feed page with role-specific video content.
///
/// Seekers see recruiter offer videos. Recruiters see seeker presentations.
class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userRole = authState is AuthAuthenticated ? authState.role : 'seeker';

    return BlocProvider(
      create: (_) => GetIt.I<FeedBloc>()
        ..add(FeedLoadRequested(userRole: userRole)),
      child: const _FeedView(),
    );
  }
}

class _FeedView extends StatefulWidget {
  const _FeedView();

  @override
  State<_FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<_FeedView> {
  final PageController _pageController = PageController();
  final VideoPreloadManager _preloadManager = VideoPreloadManager(preloadCount: 2);
  int _currentPage = 0;
  bool _isRefreshing = false;
  List<String?> _videoUrls = [];

  @override
  void dispose() {
    _pageController.dispose();
    _preloadManager.dispose();
    super.dispose();
  }

  /// Preload videos around current index
  void _preloadVideos(int currentIndex) {
    if (_videoUrls.isEmpty) return;
    _preloadManager.preloadAround(
      currentIndex: currentIndex,
      videoUrls: _videoUrls,
    );
  }

  void _showFilters(BuildContext context, FeedLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<FeedBloc>(),
        child: _FilterSheet(
          currentFilters: state.filters,
          categories: state.categories,
          userRole: state.userRole,
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    context.read<FeedBloc>().add(const FeedRefreshRequested());

    // Wait for state change
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'ETOILE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            actions: [
              // Refresh button (since pull-to-refresh doesn't work with vertical PageView)
              if (state is FeedLoaded)
                IconButton(
                  icon: _isRefreshing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Icon(Icons.refresh, color: AppColors.white),
                  onPressed: _isRefreshing ? null : _onRefresh,
                ),
              if (state is FeedLoaded)
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.tune, color: AppColors.white),
                      onPressed: () => _showFilters(context, state),
                    ),
                    if (state.hasActiveFilters)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, FeedState state) {
    if (state is FeedLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryYellow,
        ),
      );
    }

    if (state is FeedError) {
      return _buildErrorState(context, state.message);
    }

    if (state is FeedLoaded) {
      if (state.isEmpty) {
        return _buildEmptyState(context, state);
      }

      // Update video URLs list for preloading
      _videoUrls = state.items.map((item) => item.video.videoUrl).toList();

      // Preload initial videos
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _preloadVideos(_currentPage);
      });

      return PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });

          // Preload videos around new position
          _preloadVideos(index);

          // Record view for previous video
          if (index > 0 && index <= state.items.length) {
            final previousItem = state.items[index - 1];
            context.read<FeedBloc>().add(FeedVideoViewed(
                  videoId: previousItem.video.id,
                  completed: true,
                ));
          }

          // Load more when near the end
          if (index >= state.items.length - 3 && state.hasMore) {
            context.read<FeedBloc>().add(const FeedLoadMoreRequested());
          }
        },
        itemBuilder: (context, index) {
          // Show loading indicator at the end
          if (index >= state.items.length) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryYellow,
              ),
            );
          }

          final item = state.items[index];
          final videoUrl = item.video.videoUrl;

          return _VideoCard(
            feedItem: item,
            isActive: index == _currentPage,
            userRole: state.userRole,
            preloadedController: videoUrl != null
                ? _preloadManager.getController(videoUrl)
                : null,
            isControllerReady: videoUrl != null
                ? _preloadManager.isReady(videoUrl)
                : false,
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState(BuildContext context, FeedLoaded state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off_outlined,
              size: 64,
              color: AppColors.greyWarm,
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              state.hasActiveFilters
                  ? 'Aucun resultat pour ces filtres'
                  : 'Aucune video disponible',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.greyWarm,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              state.hasActiveFilters
                  ? 'Essayez de modifier vos criteres de recherche'
                  : 'Les videos apparaitront ici une fois publiees',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyMedium,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceLg),
            if (state.hasActiveFilters)
              TextButton.icon(
                onPressed: () {
                  context.read<FeedBloc>().add(const FeedFiltersClear());
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Effacer les filtres'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              'Oups ! Une erreur est survenue',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyWarm,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceLg),
            ElevatedButton.icon(
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                final role = authState is AuthAuthenticated ? authState.role : 'seeker';
                context.read<FeedBloc>().add(FeedLoadRequested(userRole: role));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual video card in the feed
class _VideoCard extends StatelessWidget {
  final FeedItem feedItem;
  final bool isActive;
  final String userRole;
  final VideoPlayerController? preloadedController;
  final bool isControllerReady;

  const _VideoCard({
    required this.feedItem,
    required this.isActive,
    required this.userRole,
    this.preloadedController,
    this.isControllerReady = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video player or thumbnail fallback
        if (feedItem.video.videoUrl != null)
          FeedVideoPlayer(
            videoUrl: feedItem.video.videoUrl!,
            thumbnailUrl: feedItem.video.thumbnailUrl,
            isActive: isActive,
            externalController: preloadedController,
            isExternalReady: isControllerReady,
          )
        else
          Container(
            color: AppColors.black,
            child: feedItem.video.thumbnailUrl != null
                ? CachedNetworkImage(
                    imageUrl: feedItem.video.thumbnailUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _buildPlaceholder(),
                    errorWidget: (_, __, ___) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),

        // Gradient overlay at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 200,
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.videoOverlayGradient,
            ),
          ),
        ),

        // Video info
        Positioned(
          left: AppTheme.spaceMd,
          right: 80,
          bottom: AppTheme.spaceLg + MediaQuery.of(context).padding.bottom,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name and badge
              Row(
                children: [
                  Flexible(
                    child: Text(
                      feedItem.userName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (feedItem.isVerified) ...[
                    const SizedBox(width: AppTheme.spaceSm),
                    const _VerifiedBadge(),
                  ],
                  if (feedItem.isRecruiter) ...[
                    const SizedBox(width: AppTheme.spaceSm),
                    const _RecruiterBadge(),
                  ],
                ],
              ),
              const SizedBox(height: AppTheme.spaceXs),

              // Title or bio
              if (feedItem.userTitle != null)
                Text(
                  feedItem.userTitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: AppTheme.spaceXs),

              // Location
              if (feedItem.userLocation != null)
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      feedItem.userLocation!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Action buttons - role-specific
        Positioned(
          right: AppTheme.spaceMd,
          bottom: AppTheme.spaceLg + MediaQuery.of(context).padding.bottom,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (userRole == 'seeker')
                _ActionButton(
                  icon: Icons.send_outlined,
                  label: 'Postuler',
                  onTap: () => _onMessageTap(context),
                )
              else
                _ActionButton(
                  icon: Icons.person_add_outlined,
                  label: 'Contacter',
                  onTap: () => _onMessageTap(context),
                ),
              const SizedBox(height: AppTheme.spaceMd),
              _ActionButton(
                icon: Icons.person_outline,
                label: 'Profil',
                onTap: () => _onProfileTap(context),
              ),
            ],
          ),
        ),

        // Progress bar only shown if no video player (fallback)
        if (feedItem.video.videoUrl == null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LinearProgressIndicator(
              value: isActive ? null : 0,
              backgroundColor: AppColors.white.withValues(alpha: 0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryYellow),
              minHeight: 3,
            ),
          ),
      ],
    );
  }

  /// Open profile bottom sheet
  void _onProfileTap(BuildContext context) {
    ProfileBottomSheet.show(
      context,
      feedItem,
      onMessageTap: () => _onMessageTap(context),
    );
  }

  /// Open message / start conversation
  void _onMessageTap(BuildContext context) {
    debugPrint('[Feed] _onMessageTap called for user: ${feedItem.video.userId}');
    debugPrint('[Feed] feedItem.userName: ${feedItem.userName}');

    // Start conversation directly without confirmation dialog
    _startConversation(context);
  }

  /// Create or find conversation and navigate to chat
  Future<void> _startConversation(BuildContext context) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    debugPrint('[Feed] ========== START CONVERSATION ==========');
    debugPrint('[Feed] Video userId: ${feedItem.video.userId}');
    debugPrint('[Feed] Video id: ${feedItem.video.id}');

    // Get repository early
    final conversationRepo = GetIt.I<ConversationRepository>();
    final currentUserId = conversationRepo.currentUserId;

    debugPrint('[Feed] Current user: $currentUserId');
    debugPrint('[Feed] Other user: ${feedItem.video.userId}');

    // Check if trying to message self
    if (currentUserId == feedItem.video.userId) {
      debugPrint('[Feed] ERROR: Trying to message self');
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Vous ne pouvez pas vous envoyer un message'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryYellow),
      ),
    );

    try {
      debugPrint('[Feed] Creating/finding conversation...');

      final conversationId = await conversationRepo.findOrCreateConversation(
        otherUserId: feedItem.video.userId,
        videoId: feedItem.video.id,
      );

      debugPrint('[Feed] Conversation ID: $conversationId');

      // Close loading dialog
      navigator.pop();

      // Navigate to chat
      final chatRoute = AppRoutes.chatWith(conversationId);
      debugPrint('[Feed] Navigating to: $chatRoute');
      router.push(chatRoute);

      debugPrint('[Feed] ========== NAVIGATION DONE ==========');

    } catch (e, stackTrace) {
      debugPrint('[Feed] ERROR: $e');
      debugPrint('[Feed] Stack: $stackTrace');

      // Close loading dialog
      navigator.pop();

      // Show error
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.replaceAll('Exception:', '').trim();
      }

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildPlaceholder() {
    // Safe substring with bounds check
    final videoIdPreview = feedItem.video.id.length >= 8
        ? feedItem.video.id.substring(0, 8)
        : feedItem.video.id;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            size: 64,
            color: AppColors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            'Video $videoIdPreview...',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Verified badge widget
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryYellow,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            size: 12,
            color: AppColors.black,
          ),
          const SizedBox(width: 2),
          Text(
            'Verifie',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

/// Recruiter badge widget
class _RecruiterBadge extends StatelessWidget {
  const _RecruiterBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.business,
            size: 12,
            color: AppColors.white,
          ),
          const SizedBox(width: 2),
          Text(
            'Entreprise',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

/// Action button on video
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.white,
                ),
          ),
        ],
      ),
    );
  }
}

/// Filter bottom sheet with role-specific filters
class _FilterSheet extends StatefulWidget {
  final FeedFilters currentFilters;
  final List<Map<String, dynamic>> categories;
  final String userRole;

  const _FilterSheet({
    required this.currentFilters,
    required this.categories,
    required this.userRole,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late FeedFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusXl),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: AppColors.greyMedium,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.filters,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _filters = const FeedFilters.empty();
                        });
                      },
                      child: const Text(AppStrings.reset),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Role-specific filters
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppTheme.spaceMd),
                  children: widget.userRole == 'seeker'
                      ? _buildSeekerFilters()
                      : _buildRecruiterFilters(),
                ),
              ),

              // Apply button
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppTheme.spaceMd,
                  AppTheme.spaceMd,
                  AppTheme.spaceMd,
                  AppTheme.spaceMd + MediaQuery.of(context).padding.bottom,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context
                          .read<FeedBloc>()
                          .add(FeedFiltersChanged(filters: _filters));
                      Navigator.pop(context);
                    },
                    child: const Text(AppStrings.apply),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Seeker filters: Secteur, Localisation, Type de contrat
  List<Widget> _buildSeekerFilters() {
    return [
      // Sector filter
      _FilterSection(
        title: 'Secteur',
        options: const [
          'Informatique',
          'Commerce',
          'Marketing',
          'Finance',
          'Sante',
          'Education',
          'Ingenierie',
          'Restauration',
        ],
        selectedValue: _filters.sector,
        onChanged: (value) {
          setState(() {
            if (value == null) {
              _filters = _filters.copyWith(clearSector: true);
            } else {
              _filters = _filters.copyWith(sector: value);
            }
          });
        },
      ),
      const SizedBox(height: AppTheme.spaceLg),

      // Location filter
      _FilterSection(
        title: 'Localisation',
        options: const [
          'Paris',
          'Lyon',
          'Marseille',
          'Bordeaux',
          'Ile-de-France',
          'Remote',
        ],
        selectedValue: _filters.region,
        onChanged: (value) {
          setState(() {
            if (value == null) {
              _filters = _filters.copyWith(clearRegion: true);
            } else {
              _filters = _filters.copyWith(region: value);
            }
          });
        },
      ),
      const SizedBox(height: AppTheme.spaceLg),

      // Contract type filter
      _FilterSection(
        title: 'Type de contrat',
        options: const [
          AppStrings.contractCDI,
          AppStrings.contractCDD,
          AppStrings.contractAlternance,
          AppStrings.contractStage,
          AppStrings.contractInterim,
        ],
        selectedValue: _filters.contractType,
        onChanged: (value) {
          setState(() {
            if (value == null) {
              _filters = _filters.copyWith(clearContractType: true);
            } else {
              _filters = _filters.copyWith(contractType: value);
            }
          });
        },
      ),
    ];
  }

  /// Recruiter filters: Competences, Experience, Disponibilite, Salaire
  List<Widget> _buildRecruiterFilters() {
    return [
      // Category/competences filter
      if (widget.categories.isNotEmpty)
        _FilterSection(
          title: 'Competences',
          options: widget.categories
              .map((c) => c['name'] as String)
              .toList(),
          selectedValue: _filters.categoryName,
          onChanged: (value) {
            setState(() {
              if (value == null) {
                _filters = _filters.copyWith(
                  clearCategoryId: true,
                  clearCategoryName: true,
                );
              } else {
                _filters = _filters.copyWith(
                  categoryId: _getCategoryId(value),
                  categoryName: value,
                );
              }
            });
          },
        ),
      const SizedBox(height: AppTheme.spaceLg),

      // Experience level filter
      _FilterSection(
        title: "Niveau d'experience",
        options: const [
          'Junior (0-2 ans)',
          'Confirme (3-5 ans)',
          'Senior (6-10 ans)',
          'Expert (10+ ans)',
        ],
        selectedValue: _filters.experienceLevel,
        onChanged: (value) {
          setState(() {
            if (value == null) {
              _filters = _filters.copyWith(clearExperienceLevel: true);
            } else {
              _filters = _filters.copyWith(experienceLevel: value);
            }
          });
        },
      ),
      const SizedBox(height: AppTheme.spaceLg),

      // Availability filter
      _FilterSection(
        title: 'Disponibilite',
        options: const [
          AppStrings.availabilityImmediate,
          AppStrings.availability1Month,
          AppStrings.availability3Months,
        ],
        selectedValue: _filters.availability,
        onChanged: (value) {
          setState(() {
            if (value == null) {
              _filters = _filters.copyWith(clearAvailability: true);
            } else {
              _filters = _filters.copyWith(availability: value);
            }
          });
        },
      ),
      const SizedBox(height: AppTheme.spaceLg),

      // Salary range filter
      _FilterSection(
        title: 'Pretention salariale',
        options: const [
          '< 25k',
          '25k - 35k',
          '35k - 50k',
          '50k - 70k',
          '> 70k',
        ],
        selectedValue: _filters.salaryRange,
        onChanged: (value) {
          setState(() {
            if (value == null) {
              _filters = _filters.copyWith(clearSalaryRange: true);
            } else {
              _filters = _filters.copyWith(salaryRange: value);
            }
          });
        },
      ),
    ];
  }

  String? _getCategoryName(String? categoryId) {
    if (categoryId == null) return null;
    final category = widget.categories.firstWhere(
      (c) => c['id'] == categoryId,
      orElse: () => <String, dynamic>{},
    );
    return category['name'] as String?;
  }

  String? _getCategoryId(String? categoryName) {
    if (categoryName == null) return null;
    final category = widget.categories.firstWhere(
      (c) => c['name'] == categoryName,
      orElse: () => <String, dynamic>{},
    );
    return category['id'] as String?;
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const _FilterSection({
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Wrap(
          spacing: AppTheme.spaceSm,
          runSpacing: AppTheme.spaceSm,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                onChanged(selected ? option : null);
              },
              selectedColor: AppColors.tagBackground,
              checkmarkColor: AppColors.primaryOrange,
            );
          }).toList(),
        ),
      ],
    );
  }
}
