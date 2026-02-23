import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/video_stats.dart';

/// Statistics card displayed on the profile page.
///
/// - Premium users see real stats (total views, unique viewers, trend).
/// - Non-premium users see a teaser message + CTA to upgrade.
class StatsCard extends StatelessWidget {
  final bool isPremium;
  final VideoStats stats;
  final bool isSeeker;

  const StatsCard({
    super.key,
    required this.isPremium,
    required this.stats,
    this.isSeeker = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.tagBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.primaryYellow.withAlpha(75)),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.bar_chart, color: AppColors.primaryOrange),
              const SizedBox(width: AppTheme.spaceSm),
              Text(
                AppStrings.statistics,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),

          if (isPremium)
            _PremiumStatsContent(stats: stats, isSeeker: isSeeker)
          else
            _NonPremiumContent(isSeeker: isSeeker),
        ],
      ),
    );
  }
}

/// Premium stats content: real data with trend indicator
class _PremiumStatsContent extends StatelessWidget {
  final VideoStats stats;
  final bool isSeeker;

  const _PremiumStatsContent({
    required this.stats,
    required this.isSeeker,
  });

  @override
  Widget build(BuildContext context) {
    if (!stats.hasData) {
      return Text(
        'Aucune vue pour le moment. Partagez votre profil !',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.greyWarm,
            ),
        textAlign: TextAlign.center,
      );
    }

    final viewerLabel = isSeeker ? 'recruteurs' : 'chercheurs';

    return Column(
      children: [
        // Stats row
        Row(
          children: [
            Expanded(
              child: _StatItem(
                icon: Icons.visibility_outlined,
                value: '${stats.totalViews}',
                label: 'vues totales',
              ),
            ),
            Expanded(
              child: _StatItem(
                icon: Icons.people_outline,
                value: '${stats.uniqueViewers}',
                label: '$viewerLabel uniques',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),

        // Trend indicator
        _TrendIndicator(
          thisWeekViews: stats.thisWeekViews,
          trendPercent: stats.trendPercent,
        ),
      ],
    );
  }
}

/// Single stat display (icon + value + label)
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryOrange, size: 28),
        const SizedBox(height: AppTheme.spaceXs),
        Text(
          value,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.greyWarm,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Weekly trend indicator (green = up, red = down)
class _TrendIndicator extends StatelessWidget {
  final int thisWeekViews;
  final double trendPercent;

  const _TrendIndicator({
    required this.thisWeekViews,
    required this.trendPercent,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = trendPercent > 0;
    final isNegative = trendPercent < 0;
    final color = isPositive
        ? AppColors.success
        : isNegative
            ? AppColors.error
            : AppColors.greyWarm;
    final icon = isPositive
        ? Icons.trending_up
        : isNegative
            ? Icons.trending_down
            : Icons.trending_flat;

    final trendText = isPositive
        ? '+${trendPercent.toStringAsFixed(0)}%'
        : isNegative
            ? '${trendPercent.toStringAsFixed(0)}%'
            : '0%';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMd,
        vertical: AppTheme.spaceSm,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppTheme.spaceSm),
          Text(
            '$thisWeekViews vues cette semaine ($trendText)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Non-premium content: teaser + CTA
class _NonPremiumContent extends StatelessWidget {
  final bool isSeeker;

  const _NonPremiumContent({required this.isSeeker});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppStrings.infoStatsNonPremium,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.greyWarm,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spaceMd),
        OutlinedButton.icon(
          onPressed: () => context.push(
            isSeeker
                ? AppRoutes.premiumSeeker
                : AppRoutes.premiumRecruiter,
          ),
          icon: const Icon(Icons.star_outline),
          label: const Text(AppStrings.goPremium),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryOrange,
            side: const BorderSide(color: AppColors.primaryOrange),
          ),
        ),
      ],
    );
  }
}
