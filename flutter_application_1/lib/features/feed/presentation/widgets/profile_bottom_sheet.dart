import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/feed_item_model.dart';

/// Bottom sheet displaying user profile from feed
class ProfileBottomSheet extends StatelessWidget {
  final FeedItem feedItem;
  final VoidCallback? onMessageTap;

  const ProfileBottomSheet({
    super.key,
    required this.feedItem,
    this.onMessageTap,
  });

  /// Show the profile bottom sheet
  static void show(BuildContext context, FeedItem feedItem, {VoidCallback? onMessageTap}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileBottomSheet(
        feedItem: feedItem,
        onMessageTap: onMessageTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
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

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppTheme.spaceMd),
                  children: [
                    // Avatar and name
                    _buildHeader(context),
                    const SizedBox(height: AppTheme.spaceLg),

                    // Info cards
                    if (feedItem.userLocation != null)
                      _buildInfoRow(
                        context,
                        icon: Icons.location_on_outlined,
                        label: 'Localisation',
                        value: feedItem.userLocation!,
                      ),

                    if (feedItem.categories.isNotEmpty)
                      _buildInfoRow(
                        context,
                        icon: Icons.work_outline,
                        label: 'Secteur',
                        value: feedItem.categories.join(', '),
                      ),

                    if (feedItem.availability != null)
                      _buildInfoRow(
                        context,
                        icon: Icons.schedule,
                        label: 'Disponibilite',
                        value: feedItem.availability!,
                      ),

                    if (feedItem.contractTypes.isNotEmpty)
                      _buildInfoRow(
                        context,
                        icon: Icons.description_outlined,
                        label: 'Type de contrat',
                        value: feedItem.contractTypes.join(', '),
                      ),

                    if (feedItem.userTitle != null) ...[
                      const SizedBox(height: AppTheme.spaceLg),
                      Text(
                        'A propos',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spaceSm),
                      Text(
                        feedItem.userTitle!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.greyWarm,
                            ),
                      ),
                    ],

                    const SizedBox(height: AppTheme.spaceLg),
                  ],
                ),
              ),

              // Action button
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppTheme.spaceMd,
                  0,
                  AppTheme.spaceMd,
                  AppTheme.spaceMd + MediaQuery.of(context).padding.bottom,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onMessageTap?.call();
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Contacter'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 36,
          backgroundColor: feedItem.isRecruiter
              ? AppColors.primaryOrange
              : AppColors.primaryYellow,
          backgroundImage: feedItem.userAvatarUrl != null
              ? NetworkImage(feedItem.userAvatarUrl!)
              : null,
          child: feedItem.userAvatarUrl == null
              ? Text(
                  feedItem.userName.isNotEmpty
                      ? feedItem.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                )
              : null,
        ),
        const SizedBox(width: AppTheme.spaceMd),

        // Name and badges
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      feedItem.userName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (feedItem.isVerified) ...[
                    const SizedBox(width: AppTheme.spaceSm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 12, color: AppColors.black),
                          SizedBox(width: 2),
                          Text(
                            'Verifie',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                feedItem.isRecruiter ? 'Recruteur' : 'Candidat',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.greyWarm,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, color: AppColors.greyWarm, size: 20),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.greyMedium,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
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
