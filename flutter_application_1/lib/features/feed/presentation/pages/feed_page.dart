import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/sector_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../applications/presentation/widgets/apply_success_overlay.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../messages/data/repositories/conversation_repository.dart';
import '../../../report/presentation/widgets/report_dialog.dart';
import '../../data/models/feed_item_model.dart';
import '../bloc/feed_bloc.dart';
import '../widgets/feed_video_player.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/etoile_badge.dart';
import '../../../../shared/widgets/profile_gate.dart';
import '../widgets/video_preload_manager.dart';

/// Main feed page with role-specific video content.
///
/// Seekers see recruiter offer videos. Recruiters see seeker presentations.
class FeedPage extends StatelessWidget {
  final String? initialSector;
  final String? initialSpecialty;
  final String? initialCity;
  final String? initialStudyLevel;

  const FeedPage({
    super.key,
    this.initialSector,
    this.initialSpecialty,
    this.initialCity,
    this.initialStudyLevel,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userRole = authState is AuthAuthenticated ? authState.role : 'seeker';

    return BlocProvider(
      create: (_) {
        final bloc = GetIt.I<FeedBloc>()
          ..add(FeedLoadRequested(userRole: userRole));
        final hasFilters = initialSector != null ||
            initialSpecialty != null ||
            initialCity != null ||
            initialStudyLevel != null;
        if (hasFilters) {
          bloc.add(FeedFiltersChanged(
            filters: FeedFilters(
              sector: initialSector,
              specialty: initialSpecialty,
              city: initialCity,
              studyLevel: initialStudyLevel,
            ),
          ));
        }
        return bloc;
      },
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
  PageController _pageController = PageController();
  VideoPreloadManager _preloadManager = VideoPreloadManager();
  int _currentPage = 0;
  bool _isRefreshing = false;
  List<String?> _videoUrls = [];
  String _selectedTab = 'offers';

  @override
  void initState() {
    super.initState();
    _preloadManager.addListener(_onPreloadChanged);
  }

  void _onPreloadChanged() {
    // Rebuild when preload manager notifies (controller became ready)
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _preloadManager.removeListener(_onPreloadChanged);
    _pageController.dispose();
    _preloadManager.dispose();
    super.dispose();
  }

  void _switchTab(String tab) {
    if (tab == _selectedTab) return;
    _pageController.dispose();
    _preloadManager.removeListener(_onPreloadChanged);
    _preloadManager.dispose();
    setState(() {
      _selectedTab = tab;
      _currentPage = 0;
      _videoUrls = [];
      _pageController = PageController();
      _preloadManager = VideoPreloadManager();
      _preloadManager.addListener(_onPreloadChanged);
    });
    final authState = context.read<AuthBloc>().state;
    final role = authState is AuthAuthenticated ? authState.role : 'seeker';
    context.read<FeedBloc>().add(FeedLoadRequested(userRole: role, feedTab: tab));
  }

  /// Notify preload manager of page change
  void _onPageChangedPreload(int currentIndex) {
    if (_videoUrls.isEmpty) return;
    _preloadManager.onPageChanged(
      currentIndex: currentIndex,
      videoUrls: _videoUrls,
    );
  }

  /// Called when the current video starts playing — triggers next preload
  void _onCurrentVideoPlaying() {
    _preloadManager.onCurrentVideoPlaying();
  }

  void _showFilters(BuildContext context, FeedLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<FeedBloc>(),
        child: _FilterSheet(
          currentFilters: state.filters,
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

  Widget _buildAppBarTitle(FeedState state) {
    final authState = context.read<AuthBloc>().state;
    final userRole = authState is AuthAuthenticated ? authState.role : 'seeker';

    if (userRole != 'seeker') {
      return const Text(
        'ETOILE',
        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _switchTab('discover'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Entreprises',
                style: TextStyle(
                  fontWeight: _selectedTab == 'discover' ? FontWeight.bold : FontWeight.normal,
                  color: _selectedTab == 'discover'
                      ? AppColors.white
                      : AppColors.white.withValues(alpha: 0.6),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                height: 2,
                width: 60,
                color: _selectedTab == 'discover'
                    ? AppColors.primaryYellow
                    : Colors.transparent,
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: () => _switchTab('offers'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Offres',
                style: TextStyle(
                  fontWeight: _selectedTab == 'offers' ? FontWeight.bold : FontWeight.normal,
                  color: _selectedTab == 'offers'
                      ? AppColors.white
                      : AppColors.white.withValues(alpha: 0.6),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                height: 2,
                width: 40,
                color: _selectedTab == 'offers'
                    ? AppColors.primaryYellow
                    : Colors.transparent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Whether the feed has video content to display behind the AppBar.
  bool _hasVideoContent(FeedState state) {
    return state is FeedLoaded && !state.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        final hasContent = _hasVideoContent(state);
        return Scaffold(
          extendBodyBehindAppBar: hasContent,
          appBar: AppBar(
            backgroundColor: hasContent ? Colors.transparent : AppColors.black,
            elevation: 0,
            title: _buildAppBarTitle(state),
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
      return Container(
        color: AppColors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryYellow,
          ),
        ),
      );
    }

    if (state is FeedError) {
      return Container(
        color: AppColors.black,
        child: _buildErrorState(context, state.message),
      );
    }

    if (state is FeedLoaded) {
      if (state.isEmpty) {
        return _buildEmptyState(context, state);
      }

      // Update video URLs list for preloading (null for posters to skip them)
      _videoUrls = state.items.map((item) {
        if (item.video.type == 'poster') return null;
        return item.video.videoUrl;
      }).toList();

      // Notify preload manager of initial/current page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onPageChangedPreload(_currentPage);
      });

      return PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });

          // Notify preload manager of new position
          _onPageChangedPreload(index);

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
          final isApplied = state.appliedVideoIds.contains(item.video.id);

          return _VideoCard(
            feedItem: item,
            isActive: index == _currentPage,
            userRole: state.userRole,
            isApplied: isApplied,
            preloadedController: videoUrl != null
                ? _preloadManager.getController(videoUrl)
                : null,
            isControllerReady: videoUrl != null
                ? _preloadManager.isReady(videoUrl)
                : false,
            onVideoPlaying: index == _currentPage
                ? _onCurrentVideoPlaying
                : null,
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState(BuildContext context, FeedLoaded state) {
    return Container(
      color: AppColors.black,
      child: state.hasActiveFilters
          ? EmptyStateWidget(
              icon: Icons.videocam_off_outlined,
              iconColor: AppColors.greyWarm,
              title: 'Aucun résultat pour ces filtres',
              subtitle: 'Essayez de modifier vos critères de recherche',
              actionLabel: 'Effacer les filtres',
              darkMode: true,
              onAction: () {
                context.read<FeedBloc>().add(const FeedFiltersClear());
              },
            )
          : const EmptyStateWidget(
              icon: Icons.videocam_off_outlined,
              iconColor: AppColors.greyWarm,
              title: 'Aucune vidéo disponible',
              subtitle: 'Les vidéos apparaîtront ici une fois publiées',
              showMascotte: true,
              darkMode: true,
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
              'Oups\u00A0! Une erreur est survenue',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                  ),
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
              label: const Text('Réessayer'),
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
  final bool isApplied;
  final VideoPlayerController? preloadedController;
  final bool isControllerReady;
  final VoidCallback? onVideoPlaying;

  const _VideoCard({
    required this.feedItem,
    required this.isActive,
    required this.userRole,
    this.isApplied = false,
    this.preloadedController,
    this.isControllerReady = false,
    this.onVideoPlaying,
  });

  bool get _isPoster => feedItem.video.type == 'poster';

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Poster: full-screen image; Video: video player or thumbnail fallback
        if (_isPoster)
          Container(
            color: AppColors.black,
            child: feedItem.video.videoUrl != null
                ? CachedNetworkImage(
                    imageUrl: feedItem.video.videoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => _buildPlaceholder(),
                    errorWidget: (_, _, _) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          )
        else if (feedItem.video.videoUrl != null)
          FeedVideoPlayer(
            videoUrl: feedItem.video.videoUrl!,
            thumbnailUrl: feedItem.video.thumbnailUrl,
            isActive: isActive,
            externalController: preloadedController,
            isExternalReady: isControllerReady,
            onVideoPlaying: onVideoPlaying,
          )
        else
          Container(
            color: AppColors.black,
            child: feedItem.video.thumbnailUrl != null
                ? CachedNetworkImage(
                    imageUrl: feedItem.video.thumbnailUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => _buildPlaceholder(),
                    errorWidget: (_, _, _) => _buildPlaceholder(),
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
                    const EtoileBadge(
                      label: 'Vérifié',
                      icon: Icons.check_circle,
                      backgroundColor: AppColors.primaryYellow,
                      textColor: AppColors.black,
                      compact: true,
                    ),
                  ],
                  if (feedItem.isRecruiter) ...[
                    const SizedBox(width: AppTheme.spaceSm),
                    const EtoileBadge(
                      label: 'Entreprise',
                      icon: Icons.business,
                      backgroundColor: AppColors.primaryOrange,
                      textColor: AppColors.white,
                      compact: true,
                    ),
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
                isApplied
                    ? _ActionButton(
                        icon: Icons.check,
                        label: 'Postulé',
                        onTap: () {},
                        disabled: true,
                      )
                    : _ActionButton(
                        icon: Icons.send_outlined,
                        label: 'Postuler',
                        onTap: () => _onApplyTap(context),
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
              const SizedBox(height: AppTheme.spaceMd),
              _ActionButton(
                icon: Icons.flag_outlined,
                label: 'Signaler',
                onTap: () => showReportDialog(
                  context,
                  reportedUserId: feedItem.video.userId,
                  reportedVideoId: feedItem.video.id,
                ),
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

  /// Navigate to public recruiter profile
  void _onProfileTap(BuildContext context) {
    context.push(AppRoutes.publicProfileFor(feedItem.video.userId));
  }

  /// Apply to offer (seeker only, decoupled from conversations)
  Future<void> _onApplyTap(BuildContext context) async {
    // Check profile completion before allowing apply
    final allowed = await checkProfileGate(context);
    if (!allowed || !context.mounted) return;

    // Dispatch apply event to BLoC
    context.read<FeedBloc>().add(FeedApplyToOffer(
      videoId: feedItem.video.id,
      recruiterId: feedItem.video.userId,
    ));

    // Show success overlay
    if (context.mounted) {
      showApplySuccessOverlay(context);
    }
  }

  /// Open message / start conversation (recruiter only)
  Future<void> _onMessageTap(BuildContext context) async {
    debugPrint('[Feed] _onMessageTap called for user: ${feedItem.video.userId}');
    debugPrint('[Feed] feedItem.userName: ${feedItem.userName}');

    // Check profile completion before allowing contact
    final allowed = await checkProfileGate(context);
    if (!allowed || !context.mounted) return;

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

/// Action button on video
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool disabled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = disabled ? 0.5 : 1.0;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: Opacity(
          opacity: opacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: disabled
                      ? AppColors.white.withValues(alpha: 0.08)
                      : AppColors.white.withValues(alpha: 0.15),
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
        ),
      ),
    );
  }
}

/// Filter bottom sheet with role-specific filters
class _FilterSheet extends StatefulWidget {
  final FeedFilters currentFilters;
  final String userRole;

  const _FilterSheet({
    required this.currentFilters,
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

  /// Seeker filters (beta): Secteur + Spécialité
  List<Widget> _buildSeekerFilters() {
    final specialties = SectorConstants.getSpecialtiesForSector(_filters.sector);
    return [
      _FilterSection(
        title: 'Secteur',
        options: const [
          'commerce_vente',
          'restauration_hotellerie',
        ],
        optionLabels: const {
          'commerce_vente': 'Commerce / Vente',
          'restauration_hotellerie': 'Restauration / Hôtellerie',
        },
        selectedValue: _filters.sector,
        onChanged: (value) {
          setState(() {
            if (value == null) {
              _filters = _filters.copyWith(clearSector: true, clearSpecialty: true);
            } else {
              _filters = _filters.copyWith(sector: value, clearSpecialty: true);
            }
          });
        },
      ),
      if (specialties.isNotEmpty) ...[
        const SizedBox(height: AppTheme.spaceMd),
        _FilterSection(
          title: 'Spécialité',
          options: specialties,
          optionLabels: {
            for (final s in specialties) s: SectorConstants.getSpecialtyLabel(s),
          },
          selectedValue: _filters.specialty,
          onChanged: (value) {
            setState(() {
              if (value == null) {
                _filters = _filters.copyWith(clearSpecialty: true);
              } else {
                _filters = _filters.copyWith(specialty: value);
              }
            });
          },
        ),
      ],
    ];
  }

  /// Recruiter filters (beta): Domaine + Spécialité
  List<Widget> _buildRecruiterFilters() {
    final specialties = SectorConstants.getSpecialtiesForSector(_filters.sector);
    return [
      _FilterSection(
        title: 'Domaine',
        options: const [
          'commerce_vente',
          'restauration_hotellerie',
        ],
        optionLabels: const {
          'commerce_vente': 'Commerce / Vente',
          'restauration_hotellerie': 'Restauration / Hôtellerie',
        },
        selectedValue: _filters.sector,
        onChanged: (value) {
          setState(() {
            if (value == null) {
              _filters = _filters.copyWith(clearSector: true, clearSpecialty: true);
            } else {
              _filters = _filters.copyWith(sector: value, clearSpecialty: true);
            }
          });
        },
      ),
      if (specialties.isNotEmpty) ...[
        const SizedBox(height: AppTheme.spaceMd),
        _FilterSection(
          title: 'Spécialité',
          options: specialties,
          optionLabels: {
            for (final s in specialties) s: SectorConstants.getSpecialtyLabel(s),
          },
          selectedValue: _filters.specialty,
          onChanged: (value) {
            setState(() {
              if (value == null) {
                _filters = _filters.copyWith(clearSpecialty: true);
              } else {
                _filters = _filters.copyWith(specialty: value);
              }
            });
          },
        ),
      ],
    ];
  }

}

class _FilterSection extends StatelessWidget {
  final String title;
  final List<String> options;
  final Map<String, String>? optionLabels;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const _FilterSection({
    required this.title,
    required this.options,
    this.optionLabels,
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
            final label = optionLabels?[option] ?? option;
            return FilterChip(
              label: Text(label),
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
