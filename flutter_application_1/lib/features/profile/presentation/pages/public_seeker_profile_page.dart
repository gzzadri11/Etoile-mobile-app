library;

/// Page de profil public d'un chercheur (vue recruteur).
///
/// Affiche la photo, le prenom, le domaine, la ville, la video
/// et les actions (contacter, signaler, bloquer).

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/sector_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/profile_gate.dart';
import '../../../messages/data/repositories/block_repository.dart';
import '../../../messages/data/repositories/conversation_repository.dart';
import '../../../video/data/models/video_model.dart';
import '../../../video/data/repositories/video_repository.dart';
import '../../data/models/seeker_profile_model.dart';
import '../../data/repositories/profile_repository.dart';

/// Public read-only seeker profile page (viewed by recruiters from feed/messages).
class PublicSeekerProfilePage extends StatefulWidget {
  final String userId;

  const PublicSeekerProfilePage({super.key, required this.userId});

  @override
  State<PublicSeekerProfilePage> createState() =>
      _PublicSeekerProfilePageState();
}

class _PublicSeekerProfilePageState extends State<PublicSeekerProfilePage> {
  SeekerProfile? _profile;
  List<Video> _videos = [];
  bool _isLoading = true;
  bool _isContacting = false;
  bool _isBlocked = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profileRepo = GetIt.I<ProfileRepository>();
      final videoRepo = GetIt.I<VideoRepository>();

      final results = await Future.wait([
        profileRepo.getSeekerProfileById(widget.userId),
        videoRepo.getVideosForUser(widget.userId),
      ]);

      bool blocked = false;
      try {
        final blockRepo = GetIt.I<BlockRepository>();
        blocked = await blockRepo.isBlocked(widget.userId);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _profile = results[0] as SeekerProfile?;
          _videos = results[1] as List<Video>;
          _isBlocked = blocked;
          _isLoading = false;
        });
      }
    } catch (e) {
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
        leading: const BackButton(),
        title: Text(_profile?.fullName ?? 'Profil chercheur'),
      ),
      body: Stack(
        children: [
          _buildBody(),
          if (_isContacting)
            Container(
              color: Colors.black26,
              child: const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryYellow),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryYellow),
      );
    }

    if (_error != null || _profile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              _error ?? 'Profil introuvable',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final profile = _profile!;
    final activeVideos =
        _videos.where((v) => v.isActive).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header with photo + name + age
          _SeekerHeader(
            photoUrl: profile.photoUrl,
            fullName: profile.fullName,
            age: profile.age,
          ),

          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Info cards
                if (profile.school != null || profile.studyLevel != null) ...[
                  _InfoRow(
                    icon: Icons.school_outlined,
                    label: _buildStudyInfo(profile),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                ],
                if (profile.city != null && profile.city!.isNotEmpty) ...[
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: profile.city!,
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                ],
                if (profile.domain != null && profile.domain!.isNotEmpty) ...[
                  _InfoRow(
                    icon: Icons.work_outline,
                    label: _getDomainLabel(profile),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                ],

                const SizedBox(height: AppTheme.spaceLg),

                // 3. Videos grid
                if (activeVideos.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.videocam_outlined,
                          color: AppColors.primaryOrange, size: 20),
                      const SizedBox(width: AppTheme.spaceXs),
                      Text(
                        'Vidéos',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppTheme.spaceSm,
                    mainAxisSpacing: AppTheme.spaceSm,
                    childAspectRatio: 0.75,
                    children: activeVideos
                        .map((v) => _VideoThumbnailCard(video: v))
                        .toList(),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),
                ],

                // 4. Contact button (visible for recruiters)
                _ContactButton(
                  isBlocked: _isBlocked,
                  onContact: _startConversation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildStudyInfo(SeekerProfile profile) {
    final parts = <String>[];
    if (profile.school != null && profile.school!.isNotEmpty) {
      parts.add(profile.school!);
    }
    if (profile.studyLevel != null && profile.studyLevel!.isNotEmpty) {
      parts.add(profile.studyLevel!);
    }
    return parts.isNotEmpty ? parts.join(' - ') : '';
  }

  String _getDomainLabel(SeekerProfile profile) {
    final domain = SectorConstants.getSectorLabel(profile.domain);
    if (profile.specialty != null && profile.specialty!.isNotEmpty) {
      return '$domain — ${SectorConstants.getSpecialtyLabel(profile.specialty)}';
    }
    return domain;
  }

  Future<void> _startConversation() async {
    if (!mounted || _isContacting) return;

    final allowed = await checkProfileGate(context);
    if (!allowed || !mounted) return;

    if (_isBlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous avez bloqué cet utilisateur'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final conversationRepo = GetIt.I<ConversationRepository>();
    final currentUserId = conversationRepo.currentUserId;

    if (currentUserId == widget.userId) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous ne pouvez pas vous envoyer un message'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isContacting = true);

    try {
      final conversationId = await conversationRepo.findOrCreateConversation(
        otherUserId: widget.userId,
      );

      if (!mounted) return;
      setState(() => _isContacting = false);
      context.push(AppRoutes.chatWith(conversationId));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isContacting = false);

      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.replaceAll('Exception:', '').trim();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class _SeekerHeader extends StatelessWidget {
  final String? photoUrl;
  final String fullName;
  final String? age;

  const _SeekerHeader({
    this.photoUrl,
    required this.fullName,
    this.age,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryYellow.withValues(alpha: 0.15),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 56,
            backgroundColor: AppColors.greyLight,
            backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
            child: !hasPhoto
                ? const Icon(Icons.person, size: 56, color: AppColors.greyMedium)
                : null,
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Text(
            fullName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          if (age != null && age!.isNotEmpty)
            Text(
              '$age ans',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.greyWarm,
                  ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryOrange),
        const SizedBox(width: AppTheme.spaceSm),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _VideoThumbnailCard extends StatelessWidget {
  final Video video;

  const _VideoThumbnailCard({required this.video});

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = video.thumbnailUrl ?? video.videoUrl;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.greyLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.greyLight,
              child: thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const Center(
                        child: Icon(Icons.play_circle_outline,
                            size: 32, color: AppColors.greyMedium),
                      ),
                      errorWidget: (_, _, _) => const Center(
                        child: Icon(Icons.play_circle_outline,
                            size: 32, color: AppColors.greyMedium),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.play_circle_outline,
                          size: 32, color: AppColors.greyMedium),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceSm),
            child: Text(
              video.title ?? 'Présentation',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final bool isBlocked;
  final VoidCallback onContact;

  const _ContactButton({
    required this.isBlocked,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    // Check if current user is a recruiter
    final profileRepo = GetIt.I<ProfileRepository>();
    final role = profileRepo.currentUserRole;
    final isRecruiter = role == 'recruiter';

    if (!isRecruiter) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isBlocked ? null : onContact,
        icon: const Icon(Icons.message_outlined),
        label: const Text('Envoyer un message'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
      ),
    );
  }
}
