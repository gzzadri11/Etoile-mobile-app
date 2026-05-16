library;

/// Page du feed video vertical (TikTok-style) avec swipe et postulation.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/sector_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_widgets.dart';
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
  final double? initialProximityKm;
  final double? initialUserLat;
  final double? initialUserLng;

  const FeedPage({
    super.key,
    this.initialSector,
    this.initialSpecialty,
    this.initialCity,
    this.initialStudyLevel,
    this.initialProximityKm,
    this.initialUserLat,
    this.initialUserLng,
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
            initialStudyLevel != null ||
            initialProximityKm != null;
        if (hasFilters) {
          bloc.add(FeedFiltersChanged(
            filters: FeedFilters(
              sector: initialSector,
              specialty: initialSpecialty,
              city: initialCity,
              studyLevel: initialStudyLevel,
              proximityKm: initialProximityKm,
              userLatitude: initialUserLat,
              userLongitude: initialUserLng,
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
  final PageController _pageController = PageController();
  final VideoPreloadManager _preloadManager = VideoPreloadManager();
  int _currentPage = 0;
  bool _isRefreshing = false;
  bool _preloadInitialized = false;
  List<String?> _videoUrls = [];

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

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isRefreshing = false);
  }

  Widget _buildAppBarTitle(FeedState state) {
    final authState = context.read<AuthBloc>().state;
    final userRole = authState is AuthAuthenticated ? authState.role : 'seeker';

    if (userRole != 'seeker') {
      return const Text(
        'ETOILE',
        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.bgPrimary),
      );
    }

    return const Text(
      'Offres',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.bgPrimary,
        fontSize: 16,
      ),
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
            backgroundColor: hasContent ? Colors.transparent : AppColors.textPrimary,
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
                            color: AppColors.bgPrimary,
                          ),
                        )
                      : const Icon(Icons.refresh, color: AppColors.bgPrimary),
                  onPressed: _isRefreshing ? null : _onRefresh,
                ),
              if (state is FeedLoaded)
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.tune, color: AppColors.bgPrimary),
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
                            color: AppColors.accent,
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
        color: AppColors.textPrimary,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.accent,
          ),
        ),
      );
    }

    if (state is FeedError) {
      return Container(
        color: AppColors.textPrimary,
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

      // Kick off preloading once on first successful load
      if (!_preloadInitialized) {
        _preloadInitialized = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _onPageChangedPreload(_currentPage);
        });
      }

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
                color: AppColors.accent,
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
      color: AppColors.textPrimary,
      child: state.hasActiveFilters
          ? EmptyStateWidget(
              icon: Icons.videocam_off_outlined,
              iconColor: AppColors.textSecondary,
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
              iconColor: AppColors.textSecondary,
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
              color: AppColors.danger,
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              'Oups\u00A0! Une erreur est survenue',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.bgPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
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
            color: AppColors.textPrimary,
            child: feedItem.video.thumbnailUrl != null
                ? CachedNetworkImage(
                    imageUrl: feedItem.video.thumbnailUrl!,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
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
            color: AppColors.textPrimary,
            child: feedItem.video.thumbnailUrl != null
                ? CachedNetworkImage(
                    imageUrl: feedItem.video.thumbnailUrl!,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
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
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0xB3000000),
                ],
              ),
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
                            color: AppColors.bgPrimary,
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
                      backgroundColor: AppColors.accent,
                      textColor: AppColors.textPrimary,
                      compact: true,
                    ),
                  ],
                  if (feedItem.isRecruiter) ...[
                    const SizedBox(width: AppTheme.spaceSm),
                    const EtoileBadge(
                      label: 'Entreprise',
                      icon: Icons.business,
                      backgroundColor: AppColors.accent,
                      textColor: AppColors.bgPrimary,
                      compact: true,
                    ),
                  ],
                ],
              ),

              // Description button (inline, not overlay)
              if (feedItem.video.description != null && feedItem.video.description!.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spaceXs),
                GestureDetector(
                  onTap: () => _showDescription(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: AppColors.bgPrimary.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Voir la description',
                        style: AppTextStyles.caption().copyWith(
                          color: AppColors.bgPrimary.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppTheme.spaceXs),

              // Title or bio
              if (feedItem.userTitle != null)
                Text(
                  feedItem.userTitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.bgPrimary.withValues(alpha: 0.9),
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
                      color: AppColors.bgPrimary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      feedItem.userLocation!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.bgPrimary.withValues(alpha: 0.7),
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
              backgroundColor: AppColors.bgPrimary.withValues(alpha: 0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 3,
            ),
          ),
      ],
    );
  }

  /// Navigate to company profile page
  void _onProfileTap(BuildContext context) {
    preloadedController?.pause();
    context.push(AppRoutes.companyProfileFor(feedItem.video.userId));
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

  /// Ouvre la messagerie / demarre une conversation (recruteur).
  Future<void> _onMessageTap(BuildContext context) async {
    // Check profile completion before allowing contact
    final allowed = await checkProfileGate(context);
    if (!allowed || !context.mounted) return;

    // Start conversation directly without confirmation dialog
    _startConversation(context);
  }

  /// Cree ou retrouve une conversation et navigue vers le chat.
  Future<void> _startConversation(BuildContext context) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final conversationRepo = GetIt.I<ConversationRepository>();
    final currentUserId = conversationRepo.currentUserId;

    if (currentUserId == feedItem.video.userId) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Vous ne pouvez pas vous envoyer un message'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
    );

    try {
      final conversationId = await conversationRepo.findOrCreateConversation(
        otherUserId: feedItem.video.userId,
        videoId: feedItem.video.id,
      );

      // Close loading dialog
      navigator.pop();

      // Navigate to chat
      router.push(AppRoutes.chatWith(conversationId));

    } catch (e) {
      debugPrint('[Feed] Erreur conversation: $e');

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
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Affiche un bottom sheet avec la description complete de l'offre
  void _showDescription(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl + MediaQuery.of(context).padding.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              feedItem.video.title ?? 'Offre d\'alternance',
              style: AppTextStyles.h2(),
            ),
            const SizedBox(height: 4),

            // Company name
            Text(
              feedItem.userName,
              style: AppTextStyles.caption().copyWith(
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Badges (sector, city, contract)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (feedItem.sector != null)
                  AppChip(
                    label: feedItem.sector!,
                    bg: AppColors.accentBg,
                    textColor: AppColors.accentDark,
                  ),
                if (feedItem.city != null)
                  AppChip(
                    label: feedItem.city!,
                    bg: AppColors.bgMuted,
                    textColor: AppColors.textSecondary,
                  ),
                if (feedItem.video.contractType != null)
                  AppChip(
                    label: feedItem.video.contractType!,
                    bg: AppColors.bgMuted,
                    textColor: AppColors.textSecondary,
                  ),
              ],
            ),

            if (feedItem.video.description != null &&
                feedItem.video.description!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Description du poste',
                style: AppTextStyles.label().copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                feedItem.video.description!,
                style: AppTextStyles.body(),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            // Apply button (seeker only)
            if (userRole == 'seeker')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isApplied ? null : () {
                    Navigator.pop(context);
                    _onApplyTap(context);
                  },
                  child: Text(
                    isApplied ? 'Déjà postulé' : 'Postuler',
                    style: AppTextStyles.button().copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
        ),
      ),
    );
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
            color: AppColors.bgPrimary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            'Video $videoIdPreview...',
            style: TextStyle(
              color: AppColors.bgPrimary.withValues(alpha: 0.5),
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
                      ? AppColors.bgPrimary.withValues(alpha: 0.08)
                      : AppColors.bgPrimary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppColors.bgPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.bgPrimary,
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
  bool _gpsAvailable = false;
  bool _gpsChecking = true;
  Position? _cachedPosition;

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
    _checkGps();
  }

  Future<void> _checkGps() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _gpsChecking = false);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _gpsChecking = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      _cachedPosition = position;

      if (mounted) {
        setState(() {
          _gpsAvailable = true;
          _gpsChecking = false;
          // Pre-fill user coordinates into filters
          _filters = _filters.copyWith(
            userLatitude: position.latitude,
            userLongitude: position.longitude,
          );
        });
      }
    } catch (e) {
      debugPrint('GPS error: $e');
      if (mounted) setState(() => _gpsChecking = false);
    }
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
            color: AppColors.bgPrimary,
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
                  color: AppColors.border,
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

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppTheme.spaceMd),
                  children: _buildSeekerFilters(),
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

  /// Seeker filters: Secteur (searchable) + Spécialité (chips)
  List<Widget> _buildSeekerFilters() {
    final specialties = SectorConstants.getSpecialtiesForSector(_filters.sector);
    return [
      // Sector picker (ListTile → modal bottom sheet)
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Secteur',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            title: Text(
              _filters.sector != null
                  ? SectorConstants.getSectorLabel(_filters.sector)
                  : 'Tous les secteurs',
              style: TextStyle(
                color: _filters.sector != null ? null : AppColors.textSecondary,
              ),
            ),
            trailing: _filters.sector != null
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      setState(() {
                        _filters = _filters.copyWith(clearSector: true, clearSpecialty: true);
                      });
                    },
                  )
                : const Icon(Icons.chevron_right),
            onTap: () => _showSectorPicker(),
          ),
        ],
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
      const SizedBox(height: AppTheme.spaceMd),
      _buildProximitySection(),
    ];
  }

  /// Build proximity filter section
  Widget _buildProximitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'À proximité',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spaceSm),
        if (_gpsChecking)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: AppTheme.spaceSm),
                Text('Localisation en cours...'),
              ],
            ),
          )
        else if (!_gpsAvailable)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
            child: Row(
              children: [
                const Icon(Icons.location_off, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: AppTheme.spaceSm),
                Text(
                  'Activez la localisation pour filtrer',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: AppTheme.spaceSm,
            runSpacing: AppTheme.spaceSm,
            children: [5.0, 10.0, 15.0, 25.0, 50.0].map((km) {
              final isSelected = _filters.proximityKm == km;
              return FilterChip(
                label: Text('${km.toInt()} km'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _filters = _filters.copyWith(
                        proximityKm: km,
                        userLatitude: _cachedPosition?.latitude,
                        userLongitude: _cachedPosition?.longitude,
                      );
                    } else {
                      _filters = _filters.copyWith(
                        clearProximityKm: true,
                        clearUserLatitude: true,
                        clearUserLongitude: true,
                      );
                    }
                  });
                },
                selectedColor: AppColors.accentBg,
                checkmarkColor: AppColors.accent,
              );
            }).toList(),
          ),
      ],
    );
  }

  /// Show searchable sector picker bottom sheet
  void _showSectorPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SectorPickerSheet(
        selectedSector: _filters.sector,
        onSectorSelected: (sector) {
          setState(() {
            _filters = _filters.copyWith(sector: sector, clearSpecialty: true);
          });
          Navigator.pop(context);
        },
      ),
    );
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
              selectedColor: AppColors.accentBg,
              checkmarkColor: AppColors.accent,
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Searchable sector picker bottom sheet
class _SectorPickerSheet extends StatefulWidget {
  final String? selectedSector;
  final ValueChanged<String> onSectorSelected;

  const _SectorPickerSheet({
    required this.selectedSector,
    required this.onSectorSelected,
  });

  @override
  State<_SectorPickerSheet> createState() => _SectorPickerSheetState();
}

class _SectorPickerSheetState extends State<_SectorPickerSheet> {
  final _searchController = TextEditingController();
  List<String> _filtered = SectorConstants.sectorOptions;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = SectorConstants.sectorOptions;
      } else {
        _filtered = SectorConstants.sectorOptions.where((code) {
          final label = SectorConstants.getSectorLabel(code).toLowerCase();
          return label.contains(query);
        }).toList();
      }
    });
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
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusXl),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                child: Text(
                  'Choisir un secteur',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un secteur...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final code = _filtered[index];
                    final isSelected = code == widget.selectedSector;
                    return ListTile(
                      title: Text(SectorConstants.getSectorLabel(code)),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.accent)
                          : null,
                      selected: isSelected,
                      onTap: () => widget.onSectorSelected(code),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
