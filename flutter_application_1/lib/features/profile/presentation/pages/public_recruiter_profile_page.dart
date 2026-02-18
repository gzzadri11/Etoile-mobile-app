import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/location_map_widget.dart';
import '../../../messages/data/repositories/conversation_repository.dart';
import '../../../video/data/models/video_model.dart';
import '../../../video/data/repositories/video_repository.dart';
import '../../data/models/recruiter_profile_model.dart';
import '../../data/repositories/profile_repository.dart';

const _contractTypeLabels = {
  'cdi': 'CDI',
  'cdd': 'CDD',
  'interim': 'Interim',
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
  String? _error;
  // Reverse-geocoded addresses keyed by "lat,lng"
  final Map<String, String> _markerAddresses = {};

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

      if (mounted) {
        setState(() {
          _profile = results[0] as RecruiterProfile?;
          _videos = results[1] as List<Video>;
          _isLoading = false;
        });
      }

      // Load addresses in background
      if (_profile != null && _profile!.hasMapMarkers) {
        _loadAddresses(_profile!.mapMarkers);
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

  Future<void> _loadAddresses(List<MapMarker> markers) async {
    final dio = Dio();
    for (final marker in markers) {
      try {
        final response = await dio.get(
          'https://photon.komoot.io/reverse',
          queryParameters: {
            'lat': marker.latitude,
            'lon': marker.longitude,
          },
        );
        final features = response.data['features'] as List?;
        if (features != null && features.isNotEmpty) {
          final props = features[0]['properties'] as Map<String, dynamic>;
          final parts = <String>[];
          if (props['street'] != null) {
            if (props['housenumber'] != null) {
              parts.add('${props['housenumber']} ${props['street']}');
            } else {
              parts.add(props['street'] as String);
            }
          }
          if (props['city'] != null) parts.add(props['city'] as String);
          if (props['postcode'] != null) parts.add(props['postcode'] as String);

          if (parts.isNotEmpty && mounted) {
            setState(() {
              _markerAddresses['${marker.latitude},${marker.longitude}'] =
                  parts.join(', ');
            });
          }
        }
      } catch (_) {
        // Ignore geocoding errors
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(_profile?.companyName ?? 'Profil entreprise'),
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
            logoUrl: profile.logoUrl,
            companyName: profile.companyName,
            sector: profile.sector ?? '',
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

                // 3. Map
                if (profile.hasMapMarkers) ...[
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
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(color: AppColors.greyLight),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: LocationMapWidget(
                      markers: profile.mapMarkers,
                      height: 250,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceMd),

                  // 4. Address list
                  ...profile.mapMarkers.map((marker) {
                    final key = '${marker.latitude},${marker.longitude}';
                    final address = _markerAddresses[key];
                    return ListTile(
                      leading: const Icon(Icons.domain,
                          color: AppColors.primaryOrange),
                      title: Text(marker.name),
                      subtitle: address != null ? Text(address) : null,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
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
                        'Presentations entreprise',
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
    if (!mounted) return;

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

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryYellow),
      ),
    );

    try {
      final conversationId = await conversationRepo.findOrCreateConversation(
        otherUserId: video.userId,
        videoId: video.id,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Pop loading dialog
      context.push(AppRoutes.chatWith(conversationId));
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Pop loading dialog

      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.replaceAll('Exception:', '').trim();
      }

      if (!mounted) return;
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
  final String? logoUrl;
  final String companyName;
  final String sector;
  final bool isVerified;

  const _PublicRecruiterHeader({
    this.coverUrl,
    this.logoUrl,
    required this.companyName,
    required this.sector,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    final hasCover = coverUrl != null && coverUrl!.isNotEmpty;
    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;

    return SizedBox(
      height: 240,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover photo
          Container(
            height: 180,
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
            bottom: 60,
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
          // Logo
          Positioned(
            bottom: 0,
            left: AppTheme.spaceMd,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.white,
                backgroundImage: hasLogo ? NetworkImage(logoUrl!) : null,
                child: !hasLogo
                    ? const Icon(Icons.business,
                        size: 36, color: AppColors.greyWarm)
                    : null,
              ),
            ),
          ),
          // Company name + sector
          Positioned(
            bottom: 16,
            left: 100,
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
                        color: AppColors.greyWarm,
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
                      placeholder: (_, __) => const Center(
                        child: Icon(Icons.play_circle_outline,
                            size: 32, color: AppColors.greyMedium),
                      ),
                      errorWidget: (_, __, ___) => const Center(
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
              video.title ?? 'Presentation',
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
                      placeholder: (_, __) => const Center(
                        child: Icon(Icons.play_circle_outline,
                            size: 32, color: AppColors.greyMedium),
                      ),
                      errorWidget: (_, __, ___) => const Center(
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
