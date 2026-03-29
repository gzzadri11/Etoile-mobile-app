import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../data/repositories/application_repository.dart';

/// Page listing recruiter's offers with candidate count
class OfferApplicationsPage extends StatefulWidget {
  const OfferApplicationsPage({super.key});

  @override
  State<OfferApplicationsPage> createState() => _OfferApplicationsPageState();
}

class _OfferApplicationsPageState extends State<OfferApplicationsPage> {
  List<OfferWithApplications> _offers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = GetIt.I<ApplicationRepository>();
      final offers = await repo.getOffersWithApplicationCount();
      if (mounted) {
        setState(() {
          _offers = offers;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[OfferApplications] Error: $e');
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
        title: const Text('Candidatures'),
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
              const Text(
                'Erreur de chargement',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.greyWarm),
              ),
              const SizedBox(height: AppTheme.spaceLg),
              ElevatedButton.icon(
                onPressed: _loadOffers,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_offers.isEmpty) {
      return EmptyStateWidget(
        showMascotte: true,
        title: 'Aucune offre publiée',
        subtitle: 'Publiez une offre vidéo ou affiche pour recevoir des candidatures',
        actionLabel: 'Publier une offre',
        onAction: () => context.push(AppRoutes.publish),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOffers,
      color: AppColors.primaryYellow,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        itemCount: _offers.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spaceSm),
        itemBuilder: (context, index) => _OfferCard(
          offer: _offers[index],
          onTap: () => context.push(
            AppRoutes.offerCandidatesFor(_offers[index].videoId),
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final OfferWithApplications offer;
  final VoidCallback onTap;

  const _OfferCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isVideo = offer.type == 'offer';
    final typeLabel = isVideo ? 'Vidéo' : 'Affiche';
    final typeIcon = isVideo ? Icons.videocam : Icons.image;

    return Material(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      clipBehavior: Clip.antiAlias,
      color: AppColors.white,
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 80,
              height: 80,
              child: offer.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: offer.thumbnailUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: AppColors.greyLight,
                        child: Icon(typeIcon, color: AppColors.greyWarm),
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: AppColors.greyLight,
                        child: Icon(typeIcon, color: AppColors.greyWarm),
                      ),
                    )
                  : Container(
                      color: AppColors.greyLight,
                      child: Icon(typeIcon, size: 32, color: AppColors.greyWarm),
                    ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spaceXs),
                    Row(
                      children: [
                        Icon(typeIcon, size: 14, color: AppColors.greyWarm),
                        const SizedBox(width: 4),
                        Text(
                          typeLabel,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.greyWarm,
                              ),
                        ),
                        if (offer.contractType != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            offer.contractType!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Candidate count badge
            Padding(
              padding: const EdgeInsets.only(right: AppTheme.spaceMd),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: offer.applicationCount > 0
                          ? AppColors.primaryYellow
                          : AppColors.greyLight,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      '${offer.applicationCount}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: offer.applicationCount > 0
                            ? AppColors.white
                            : AppColors.greyWarm,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    offer.applicationCount == 1 ? 'candidat' : 'candidats',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.greyWarm,
                          fontSize: 10,
                        ),
                  ),
                ],
              ),
            ),

            // Arrow
            const Padding(
              padding: EdgeInsets.only(right: AppTheme.spaceSm),
              child: Icon(Icons.chevron_right, color: AppColors.greyWarm),
            ),
          ],
        ),
      ),
    );
  }
}
