library;

/// Page de profil chercheur.
///
/// Affiche les informations du profil, la photo, les stats video,
/// et les actions d'edition.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

import '../../../video/data/repositories/video_repository.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/sector_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/etoile_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/models/seeker_profile_model.dart';
import '../../data/models/video_stats.dart';
import '../../../video/data/models/video_model.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/stats_card.dart';

/// User profile page
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<ProfileBloc>()..add(const ProfileLoadRequested()),
      child: const _ProfilePageContent(),
    );
  }
}

class _ProfilePageContent extends StatelessWidget {
  const _ProfilePageContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is SeekerProfileLoaded) {
          return _SeekerProfileView(
            profile: state.profile,
            stats: state.stats,
            presentationVideo: state.presentationVideo,
          );
        }

        if (state is ProfileError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                  const SizedBox(height: AppTheme.spaceMd),
                  Text(state.message),
                  const SizedBox(height: AppTheme.spaceMd),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(const ProfileLoadRequested());
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        return const Scaffold(
          body: Center(child: Text('Profil non disponible')),
        );
      },
    );
  }
}

/// Seeker profile view
class _SeekerProfileView extends StatelessWidget {
  final SeekerProfile profile;
  final VideoStats stats;
  final Video? presentationVideo;

  const _SeekerProfileView({
    required this.profile,
    required this.stats,
    this.presentationVideo,
  });

  static String _getDomainLabel(SeekerProfile profile) {
    final domain = SectorConstants.getSectorLabel(profile.domain);
    if (profile.specialty != null && profile.specialty!.isNotEmpty) {
      return '$domain — ${SectorConstants.getSpecialtyLabel(profile.specialty)}';
    }
    return domain;
  }

  static String _buildStudyInfo(SeekerProfile profile) {
    final parts = <String>[];
    if (profile.school != null && profile.school!.isNotEmpty) {
      parts.add(profile.school!);
    }
    if (profile.studyLevel != null && profile.studyLevel!.isNotEmpty) {
      parts.add(profile.studyLevel!);
    }
    return parts.isNotEmpty ? parts.join(' - ') : 'Non défini';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProfileBloc>().add(const ProfileRefreshRequested());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Column(
            children: [
              // Video preview card
              _VideoPreviewCard(video: presentationVideo),

              const SizedBox(height: AppTheme.spaceLg),

              // Profile photo
              if (profile.photoUrl != null && profile.photoUrl!.isNotEmpty)
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.bgSubtle,
                    backgroundImage: NetworkImage(profile.photoUrl!),
                  ),
                )
              else
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.bgSubtle,
                    child: const Icon(Icons.person, size: 48, color: AppColors.border),
                  ),
                ),

              const SizedBox(height: AppTheme.spaceMd),

              // Profile info
              _ProfileInfoCard(
                name: profile.fullName,
                domain: _getDomainLabel(profile),
                location: profile.location.isNotEmpty
                    ? profile.location
                    : 'Non défini',
                studyInfo: _buildStudyInfo(profile),
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // Skills section
              _SkillsSection(profile: profile),

              const SizedBox(height: AppTheme.spaceLg),

              // Profile completion indicator
              _ProfileCompletionCard(
                percentage: profile.completionPercentage,
                onComplete: () => context.push(AppRoutes.editProfile),
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // Statistics card
              StatsCard(
                stats: stats,
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // Mes favoris section
              GestureDetector(
                onTap: () {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    context.push(AppRoutes.seekerFavorites, extra: authState.userId);
                  }
                },
                child: const _PublicationSectionCard(
                  icon: Icons.favorite_rounded,
                  title: 'Mes favoris',
                  subtitle: 'Offres sauvegardées',
                  count: 0,
                  hideCount: true,
                ),
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // Mes statistiques section
              GestureDetector(
                onTap: () => context.push(AppRoutes.seekerStats),
                child: const _PublicationSectionCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'Mes statistiques',
                  subtitle: 'Recruteurs qui ont vu votre vidéo',
                  count: 0,
                  hideCount: true,
                ),
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // Mes candidatures section
              GestureDetector(
                onTap: () => context.push(AppRoutes.seekerApplications),
                child: const _PublicationSectionCard(
                  icon: Icons.send,
                  title: 'Mes candidatures',
                  subtitle: 'Suivez vos candidatures en cours',
                  count: 0,
                  hideCount: true,
                ),
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // Action buttons
              EtoileButton.outlined(
                label: AppStrings.editProfile,
                icon: Icons.edit_outlined,
                onPressed: () => context.push(AppRoutes.editProfile),
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // Logout button
              TextButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
                icon: const Icon(Icons.logout, color: AppColors.danger),
                label: Text(
                  AppStrings.logout,
                  style: TextStyle(color: AppColors.danger),
                ),
              ),

              const SizedBox(height: AppTheme.spaceLg),
            ],
          ),
        ),
      ),
    );
  }
}

/// Profile completion card with percentage and progress bar.
/// Shows a "Profil complet" badge when at 100%.
class _ProfileCompletionCard extends StatelessWidget {
  final int percentage;
  final VoidCallback onComplete;

  const _ProfileCompletionCard({
    required this.percentage,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    if (percentage >= 100) {
      // Completed badge
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.success.withAlpha(25),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppColors.success.withAlpha(100)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: AppTheme.spaceSm),
            Text(
              'Profil complet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.success,
                  ),
            ),
          ],
        ),
      );
    }

    // Incomplete: show progress
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(25),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.warning.withAlpha(100)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.warning),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: Text(
                  'Complétez votre profil pour être visible',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.bgSubtle,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.accent),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onComplete,
              child: const Text('Compléter mon profil'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Video preview card for seekers — affiche la thumbnail si une video existe,
/// sinon un placeholder invitant a enregistrer.
class _VideoPreviewCard extends StatefulWidget {
  final Video? video;

  const _VideoPreviewCard({this.video});

  @override
  State<_VideoPreviewCard> createState() => _VideoPreviewCardState();
}

class _VideoPreviewCardState extends State<_VideoPreviewCard> {
  bool _deleting = false;

  bool get _hasVideo => widget.video != null && widget.video!.status == 'active';

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la vidéo ?'),
        content: const Text(
          'Votre vidéo de présentation sera supprimée. Les recruteurs ne pourront plus la voir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    try {
      await GetIt.I<VideoRepository>().deleteVideo(widget.video!.id);
      if (mounted) {
        context.read<ProfileBloc>().add(const ProfileRefreshRequested());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _deleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (_hasVideo && widget.video!.videoUrl != null) {
              _showVideoPlayer(context, widget.video!.videoUrl!);
            } else {
              context.push(AppRoutes.record);
            }
          },
          child: Semantics(
            label: _hasVideo
                ? 'Vidéo de présentation — appuyez pour visionner'
                : 'Aucune vidéo enregistrée — appuyez pour enregistrer',
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              clipBehavior: Clip.antiAlias,
              child: _deleting
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : _hasVideo
                      ? _buildVideoPreview(context)
                      : _buildPlaceholder(context),
            ),
          ),
        ),
        if (_hasVideo) ...[
          const SizedBox(height: AppTheme.spaceSm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.videocam_outlined, size: 16),
                  label: const Text('Remplacer'),
                  onPressed: () => context.push(AppRoutes.record),
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Supprimer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  onPressed: _deleting ? null : _confirmDelete,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildVideoPreview(BuildContext context) {
    final hasThumbnail =
        widget.video!.thumbnailUrl != null && widget.video!.thumbnailUrl!.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasThumbnail)
          Image.network(
            widget.video!.thumbnailUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(
              color: AppColors.textPrimary,
              child: Center(
                child: Icon(Icons.videocam, size: 48, color: Colors.white54),
              ),
            ),
          )
        else
          const ColoredBox(
            color: AppColors.textPrimary,
            child: Center(
              child: Icon(Icons.videocam, size: 48, color: Colors.white54),
            ),
          ),
        // Play icon overlay
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(120),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, size: 36, color: Colors.white),
          ),
        ),
        // "Visionner" badge
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              'Visionner',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.bgPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  void _showVideoPlayer(BuildContext context, String videoUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (_, _, _) => _VideoPlayerScreen(videoUrl: videoUrl),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.videocam_outlined,
          size: 48,
          color: AppColors.bgPrimary.withAlpha(180),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Text(
          'Aucune vidéo',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.bgPrimary.withAlpha(180),
              ),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Text(
          'Appuyez pour enregistrer votre présentation',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.bgPrimary.withAlpha(120),
              ),
        ),
      ],
    );
  }
}

/// Profile info card
class _ProfileInfoCard extends StatelessWidget {
  final String name;
  final String domain;
  final String location;
  final String studyInfo;

  const _ProfileInfoCard({
    required this.name,
    required this.domain,
    required this.location,
    required this.studyInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.bgSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spaceXs),
          Text(
            domain,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Row(
            children: [
              const Icon(
                Icons.school_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  studyInfo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Publication section card
class _PublicationSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int count;
  final bool hideCount;

  const _PublicationSectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    this.hideCount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.bgSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(25),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(icon, color: AppColors.accent),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          if (!hideCount)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentBg,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Text(
                '$count',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
              ),
            ),
          if (!hideCount)
            const SizedBox(width: AppTheme.spaceSm),
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

/// Fullscreen video player for previewing presentation video.
///
/// Supporte : bouton retour, swipe-down pour fermer, tap pour play/pause,
/// controles auto-hide apres 3 secondes.
class _VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  const _VideoPlayerScreen({required this.videoUrl});

  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _showControls = true;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _initialized = true);
          _controller.play();
          _autoHideControls();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _autoHideControls() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying && _showControls) {
        setState(() => _showControls = false);
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _showControls = true;
      } else {
        _controller.play();
        _autoHideControls();
      }
    });
  }

  void _onTapVideo() {
    if (!_initialized) return;
    if (_controller.value.isPlaying) {
      setState(() => _showControls = !_showControls);
      if (_showControls) _autoHideControls();
    } else {
      _togglePlayPause();
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _onTapVideo,
        onVerticalDragUpdate: (details) {
          setState(() => _dragOffset += details.delta.dy);
        },
        onVerticalDragEnd: (details) {
          // Swipe down to dismiss (seuil 150px ou velocite rapide)
          if (_dragOffset > 150 ||
              details.velocity.pixelsPerSecond.dy > 500) {
            Navigator.pop(context);
          } else {
            setState(() => _dragOffset = 0);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _dragOffset.clamp(0, 400), 0),
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Video
              Center(
                child: _initialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : const CircularProgressIndicator(
                        color: AppColors.accent),
              ),

              // Top bar (retour + titre) — toujours au-dessus
              AnimatedOpacity(
                opacity: _showControls || !_controller.value.isPlaying ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring:
                      !_showControls && _controller.value.isPlaying,
                  child: Container(
                    alignment: Alignment.topLeft,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black54, Colors.transparent],
                        stops: [0.0, 1.0],
                      ),
                    ),
                    padding: EdgeInsets.only(top: topPadding),
                    child: SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 26),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            'Ma vidéo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Centre play/pause
              if (_initialized && !_controller.value.isPlaying)
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(120),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),

              // Hint swipe down (visible au debut)
              if (_showControls && _initialized)
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Glissez vers le bas pour fermer',
                      style: TextStyle(
                        color: Colors.white.withAlpha(150),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skills section with add/remove functionality
class _SkillsSection extends StatefulWidget {
  final SeekerProfile profile;

  const _SkillsSection({required this.profile});

  @override
  State<_SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends State<_SkillsSection> {
  List<String> _skills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _skills = List.from(widget.profile.skills);
    _isLoading = false;
  }

  Future<void> _saveSkills() async {
    try {
      await GetIt.I<SupabaseClient>()
          .from('seeker_profiles')
          .update({'skills': _skills})
          .eq('user_id', widget.profile.userId);

      // Recharger le profil via le BLoC pour synchroniser l'état
      if (mounted) {
        context.read<ProfileBloc>().add(const ProfileRefreshRequested());
      }
    } catch (e) {
      debugPrint('Error saving skills: $e');
    }
  }

  void _removeSkill(int index) {
    setState(() => _skills.removeAt(index));
    _saveSkills();
  }

  void _addSkill(String skill) {
    final trimmed = skill.trim();
    if (trimmed.isEmpty) return;
    if (_skills.contains(trimmed)) return; // Pas de doublon
    setState(() => _skills.add(trimmed));
    _saveSkills();
  }

  void _showAddSkillSheet() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(AppTheme.spaceLg, AppTheme.spaceMd, AppTheme.spaceLg, AppTheme.spaceLg),
          decoration: const BoxDecoration(
            color: AppColors.bgPrimary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(height: AppTheme.spaceMd),

              // Titre
              Text(
                'Ajouter une compétence',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Logiciel, outil, langue, méthode, technique…',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppTheme.spaceMd),

              // Champ texte libre
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Ex : Adobe Photoshop, Excel avancé, Anglais B2…',
                ),
                onSubmitted: (val) {
                  _addSkill(val);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: AppTheme.spaceMd),

              // Bouton ajouter
              EtoileButton(
                label: 'Ajouter à mon profil',
                onPressed: () {
                  _addSkill(controller.text);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      color: AppColors.bgPrimary,
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compétences',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Techniques acquises lors de vos études',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _showAddSkillSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentBg,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    border: Border.all(color: AppColors.accent, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_rounded, size: 14, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        'Ajouter',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.accent,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spaceMd),

          // État vide
          if (_skills.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: AppColors.bgSubtle,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                children: [
                  const Text('🎓', style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 6),
                  Text(
                    'Aucune compétence ajoutée.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
                  ),
                  Text(
                    'Logiciels, langues, outils, méthodes…',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            )

          // Liste des compétences
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.asMap().entries.map((entry) {
                return _SkillTag(
                  skill: entry.value,
                  onDelete: () => _removeSkill(entry.key),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

/// Skill tag with delete button
class _SkillTag extends StatelessWidget {
  final String skill;
  final VoidCallback onDelete;

  const _SkillTag({required this.skill, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
      decoration: BoxDecoration(
        color: AppColors.accentBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: AppColors.accent, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.accentDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            behavior: HitTestBehavior.opaque,
            child: const Icon(Icons.close_rounded, size: 14, color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}
