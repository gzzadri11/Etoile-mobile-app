import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/profile_gate.dart';
import '../../../messages/data/repositories/block_repository.dart';
import '../../../messages/data/repositories/conversation_repository.dart';
import '../../../video/data/models/video_model.dart';
import '../../../video/data/repositories/video_repository.dart';
import '../../data/models/recruiter_profile_model.dart';
import '../../data/repositories/profile_repository.dart';

const _contractTypeLabels = {
  'cdi': 'CDI',
  'cdd': 'CDD',
  'interim': 'Intérim',
  'freelance': 'Freelance',
  'alternance': 'Alternance',
  'stage': 'Stage',
};

/// Public read-only recruiter profile page (viewed by seekers from the feed).
class PublicRecruiterProfilePage extends StatefulWidget {
  final String userId;

  const PublicRecruiterProfilePage({super.key, required this.userId});

  @override
  State<PublicRecruiterProfilePage> createState() =>
      _PublicRecruiterProfilePageState();
}

class _PublicRecruiterProfilePageState
    extends State<PublicRecruiterProfilePage> {
  RecruiterProfile? _profile;
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
        profileRepo.getRecruiterProfileById(widget.userId),
        videoRepo.getVideosForUser(widget.userId),
      ]);

      // Check if this user is blocked
      bool blocked = false;
      try {
        final blockRepo = GetIt.I<BlockRepository>();
        blocked = await blockRepo.isBlocked(widget.userId);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _profile = results[0] as RecruiterProfile?;
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

  static const Map<String, String> _sectorLabels = {
    'commerce_vente': 'Commerce / Vente',
    'restauration_hotellerie': 'Restauration / Hôtellerie',
  };

  static String _getSectorLabel(String? sector) {
    if (sector == null || sector.isEmpty) return '';
    return _sectorLabels[sector] ?? sector;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(_profile?.companyName ?? 'Profil entreprise'),
      ),
      body: Stack(
        children: [
          _buildBody(),
          if (_isContacting)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryYellow),
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
    final presentations = _videos
        .where((v) => v.type == 'presentation' && v.isActive)
        .toList();
    final offers = _videos
        .where((v) => v.type != 'presentation' && v.isActive)
        .toList();

    // Group offers by contract type
    final offersByType = <String, List<Video>>{};
    for (final offer in offers) {
      final key = offer.contractType ?? 'other';
      offersByType.putIfAbsent(key, () => []).add(offer);
    }

    // Sort keys: known types first, then 'other'
    final sortedKeys = offersByType.keys.toList()
      ..sort((a, b) {
        if (a == 'other') return 1;
        if (b == 'other') return -1;
        return a.compareTo(b);
      });

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header
          _PublicRecruiterHeader(
            coverUrl: profile.coverUrl,
            companyName: profile.companyName,
            sector: _getSectorLabel(profile.sector),
            isVerified: profile.isVerified,
          ),

          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Description
                if (profile.description != null &&
                    profile.description!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spaceMd),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(color: AppColors.greyLight),
                    ),
                    child: Text(
                      profile.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),
                ],

                // 3. Location (beta: city text)
                if (profile.locations.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppColors.primaryOrange, size: 20),
                      const SizedBox(width: AppTheme.spaceXs),
                      Text(
                        'Localisation',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  Text(
                    profile.locations.first,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppTheme.spaceLg),
                ],

                // 5. Presentations
                if (presentations.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.business,
                          color: AppColors.primaryOrange, size: 20),
                      const SizedBox(width: AppTheme.spaceXs),
                      Text(
                        'Présentations entreprise',
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
                    children: presentations
                        .map((v) => _VideoThumbnailCard(video: v))
                        .toList(),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),
                ],

                // 6. Offers grouped by contract type
                if (offers.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.work_outline,
                          color: AppColors.primaryOrange, size: 20),
                      const SizedBox(width: AppTheme.spaceXs),
                      Text(
                        'Offres',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  for (final key in sortedKeys) ...[
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppTheme.spaceXs),
                      child: Text(
                        _contractTypeLabels[key] ?? 'Autres',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AppTheme.spaceSm,
                      mainAxisSpacing: AppTheme.spaceSm,
                      childAspectRatio: 0.65,
                      children: offersByType[key]!
                          .map((v) => _OfferThumbnailCard(
                                video: v,
                                onContact: () => _startConversation(v),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startConversation(Video video) async {
    if (!mounted || _isContacting) return;

    // Check profile completion before allowing contact
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

    if (currentUserId == video.userId) {
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
        otherUserId: video.userId,
        videoId: video.id,
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

/// Header with cover + logo + company info
class _PublicRecruiterHeader extends StatelessWidget {
  final String? coverUrl;
  final String companyName;
  final String sector;
  final bool isVerified;

  const _PublicRecruiterHeader({
    this.coverUrl,
    required this.companyName,
    required this.sector,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    final hasCover = coverUrl != null && coverUrl!.isNotEmpty;

    return SizedBox(
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover photo
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              image: hasCover
                  ? DecorationImage(
                      image: NetworkImage(coverUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: !hasCover
                ? const Center(
                    child: Icon(
                      Icons.photo_camera_outlined,
                      size: 40,
                      color: AppColors.greyMedium,
                    ),
                  )
                : null,
          ),
          // Gradient overlay
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ),
          // Company name + sector
          Positioned(
            bottom: 16,
            left: AppTheme.spaceMd,
            right: AppTheme.spaceMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        companyName,
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: AppTheme.spaceSm),
                      const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: AppColors.primaryYellow,
                      ),
                    ],
                  ],
                ),
                Text(
                  sector,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withAlpha(200),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Thumbnail card for presentation videos (no contact button)
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

/// Thumbnail card for offers (with contact button)
class _OfferThumbnailCard extends StatelessWidget {
  final Video video;
  final VoidCallback onContact;

  const _OfferThumbnailCard({
    required this.video,
    required this.onContact,
  });

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
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceSm,
              vertical: AppTheme.spaceXs,
            ),
            child: Text(
              video.title ?? 'Offre',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: AppTheme.spaceSm,
              right: AppTheme.spaceSm,
              bottom: AppTheme.spaceSm,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 30,
              child: ElevatedButton(
                onPressed: onContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.zero,
                  textStyle: const TextStyle(fontSize: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                ),
                child: const Text('Contacter'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
