library;

/// Page affichant les candidats ayant postule a une offre donnee (fiche candidat + video).

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/sector_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../messages/data/repositories/conversation_repository.dart';
import '../../data/repositories/application_repository.dart';

/// Page listing candidates who applied to a specific offer
class OfferCandidatesPage extends StatefulWidget {
  final String videoId;
  final String? offerTitle;

  const OfferCandidatesPage({
    super.key,
    required this.videoId,
    this.offerTitle,
  });

  @override
  State<OfferCandidatesPage> createState() => _OfferCandidatesPageState();
}

class _OfferCandidatesPageState extends State<OfferCandidatesPage> {
  List<OfferCandidate> _candidates = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = GetIt.I<ApplicationRepository>();
      final candidates = await repo.getCandidatesForOffer(widget.videoId);
      if (mounted) {
        setState(() {
          _candidates = candidates;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[OfferCandidates] Error: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.offerTitle ?? 'Candidats'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryYellow),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppTheme.spaceMd),
              Text(_error!, textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.greyWarm)),
              const SizedBox(height: AppTheme.spaceLg),
              ElevatedButton.icon(
                onPressed: _loadCandidates,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_candidates.isEmpty) {
      return EmptyStateWidget(
        showMascotte: true,
        title: 'Aucune candidature',
        subtitle: 'Personne n\'a encore postulé à cette offre',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCandidates,
      color: AppColors.primaryYellow,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        itemCount: _candidates.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spaceSm),
        itemBuilder: (context, index) => _CandidateCard(
          candidate: _candidates[index],
          onContact: () => _openChat(_candidates[index]),
        ),
      ),
    );
  }

  Future<void> _openChat(OfferCandidate candidate) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryYellow),
      ),
    );

    try {
      // Find or create conversation
      final conversationRepo = GetIt.I<ConversationRepository>();
      final conversationId = await conversationRepo.findOrCreateConversation(
        otherUserId: candidate.seekerUserId,
      );

      // Mark application as contacted
      final appRepo = GetIt.I<ApplicationRepository>();
      await appRepo.markAsContacted(candidate.applicationId);

      // Close loading dialog
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      // Update local state
      if (mounted) {
        setState(() {
          final idx = _candidates.indexWhere(
            (c) => c.applicationId == candidate.applicationId,
          );
          if (idx >= 0) {
            _candidates[idx] = OfferCandidate(
              seekerUserId: candidate.seekerUserId,
              applicationId: candidate.applicationId,
              applicationStatus: 'contacted',
              appliedAt: candidate.appliedAt,
              name: candidate.name,
              photoUrl: candidate.photoUrl,
              age: candidate.age,
              school: candidate.school,
              studyLevel: candidate.studyLevel,
              city: candidate.city,
              domain: candidate.domain,
              specialty: candidate.specialty,
              presentationVideoUrl: candidate.presentationVideoUrl,
              presentationThumbnailUrl: candidate.presentationThumbnailUrl,
              presentationVideoId: candidate.presentationVideoId,
            );
          }
        });
      }

      // Navigate to chat
      router.push(AppRoutes.chatWith(conversationId));
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erreur : ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

/// Card showing candidate info + video + contact button
class _CandidateCard extends StatelessWidget {
  final OfferCandidate candidate;
  final VoidCallback onContact;

  const _CandidateCard({required this.candidate, required this.onContact});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: photo + name + age + status badge
          _buildHeader(context),

          // Info rows
          _buildInfoSection(context),

          // Video presentation
          if (candidate.presentationVideoUrl != null)
            _CandidateVideo(videoUrl: candidate.presentationVideoUrl!),

          // Contact button
          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onContact,
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Contacter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryYellow,
            backgroundImage: candidate.photoUrl != null
                ? NetworkImage(candidate.photoUrl!)
                : null,
            child: candidate.photoUrl == null
                ? Text(
                    candidate.name.isNotEmpty
                        ? candidate.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppTheme.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (candidate.age != null)
                  Text(
                    '${candidate.age} ans',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.greyWarm,
                        ),
                  ),
              ],
            ),
          ),
          // Status badge
          _StatusBadge(status: candidate.applicationStatus),
          const SizedBox(width: AppTheme.spaceSm),
          // Date of application
          Text(
            _formatDate(candidate.appliedAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.greyWarm,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final infos = <Widget>[];

    if (candidate.school != null && candidate.school!.isNotEmpty) {
      final level = candidate.studyLevel != null
          ? ' (${SectorConstants.getStudyLevelLabel(candidate.studyLevel)})'
          : '';
      infos.add(_InfoRow(
        icon: Icons.school,
        text: '${candidate.school}$level',
      ));
    }

    if (candidate.city != null && candidate.city!.isNotEmpty) {
      infos.add(_InfoRow(
        icon: Icons.location_on,
        text: candidate.city!,
      ));
    }

    if (candidate.domain != null && candidate.domain!.isNotEmpty) {
      final domainLabel = SectorConstants.getSectorLabel(candidate.domain);
      final specialtyLabel = candidate.specialty != null
          ? ' — ${SectorConstants.getSpecialtyLabel(candidate.specialty)}'
          : '';
      infos.add(_InfoRow(
        icon: Icons.work_outline,
        text: '$domainLabel$specialtyLabel',
      ));
    }

    if (infos.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
      child: Column(children: infos),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return "Aujourd'hui";
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Status badge for application state
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'contacted' => ('Contacté', AppColors.success),
      'withdrawn' => ('Retiré', AppColors.greyWarm),
      _ => ('En attente', AppColors.primaryOrange),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceXs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryOrange),
          const SizedBox(width: AppTheme.spaceSm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline video player for candidate presentation
class _CandidateVideo extends StatefulWidget {
  final String videoUrl;

  const _CandidateVideo({required this.videoUrl});

  @override
  State<_CandidateVideo> createState() => _CandidateVideoState();
}

class _CandidateVideoState extends State<_CandidateVideo> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('[CandidateVideo] Error initializing: $e');
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      if (_isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off, color: AppColors.greyWarm, size: 32),
              SizedBox(height: AppTheme.spaceXs),
              Text('Vidéo indisponible',
                  style: TextStyle(color: AppColors.greyWarm)),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryYellow),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller!),
            // Play/Pause overlay
            GestureDetector(
              onTap: _togglePlay,
              child: Container(
                color: Colors.transparent,
                child: AnimatedOpacity(
                  opacity: _isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: AppColors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            // Progress bar at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: AppColors.primaryYellow,
                  bufferedColor: AppColors.greyMedium,
                  backgroundColor: AppColors.greyLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
