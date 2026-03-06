import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/sector_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/etoile_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/models/seeker_profile_model.dart';
import '../../data/models/recruiter_profile_model.dart';
import '../../data/models/video_stats.dart';
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
            isPremium: state.isPremium,
            stats: state.stats,
          );
        }

        if (state is RecruiterProfileLoaded) {
          return _RecruiterProfileView(
            profile: state.profile,
            presentationCount: state.presentationCount,
            offerCount: state.offerCount,
            posterCount: state.posterCount,
            isPremium: state.isPremium,
            stats: state.stats,
          );
        }

        if (state is ProfileError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: AppTheme.spaceMd),
                  Text(state.message),
                  const SizedBox(height: AppTheme.spaceMd),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(const ProfileLoadRequested());
                    },
                    child: const Text('Reessayer'),
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
  final bool isPremium;
  final VideoStats stats;

  const _SeekerProfileView({
    required this.profile,
    required this.isPremium,
    required this.stats,
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
    return parts.isNotEmpty ? parts.join(' - ') : 'Non defini';
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
              _VideoPreviewCard(),

              const SizedBox(height: AppTheme.spaceLg),

              // Profile info
              _ProfileInfoCard(
                name: profile.fullName,
                domain: _getDomainLabel(profile),
                location: profile.location.isNotEmpty
                    ? profile.location
                    : 'Non defini',
                studyInfo: _buildStudyInfo(profile),
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // Profile completion indicator
              _ProfileCompletionCard(
                percentage: profile.completionPercentage,
                onComplete: () => context.push(AppRoutes.editProfile),
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // Statistics card
              StatsCard(
                isPremium: isPremium,
                stats: stats,
                isSeeker: true,
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // Action buttons
              EtoileButton(
                label: AppStrings.editVideo,
                icon: Icons.videocam_outlined,
                onPressed: () => context.push(AppRoutes.record),
              ),

              const SizedBox(height: AppTheme.spaceMd),

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
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: Text(
                  AppStrings.logout,
                  style: TextStyle(color: AppColors.error),
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

/// Recruiter profile view
class _RecruiterProfileView extends StatelessWidget {
  final RecruiterProfile profile;
  final int presentationCount;
  final int offerCount;
  final int posterCount;
  final bool isPremium;
  final VideoStats stats;

  const _RecruiterProfileView({
    required this.profile,
    this.presentationCount = 0,
    this.offerCount = 0,
    this.posterCount = 0,
    required this.isPremium,
    required this.stats,
  });

  static String _getSectorLabel(String? sector) {
    return SectorConstants.getSectorLabel(sector);
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
          child: Column(
            children: [
              // === Cover + Logo header ===
              _RecruiterHeader(
                coverUrl: profile.coverUrl,
                companyName: profile.companyName,
                sector: _getSectorLabel(profile.sector),
                isVerified: profile.isVerified,
              ),

              Padding(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                child: Column(
                  children: [
                    // Description
                    if (profile.description != null &&
                        profile.description!.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppTheme.spaceMd),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(color: AppColors.greyLight),
                        ),
                        child: Text(
                          profile.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),

                    if (profile.description != null &&
                        profile.description!.isNotEmpty)
                      const SizedBox(height: AppTheme.spaceLg),

                    // Location (beta: city text)
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

                    // Verification status
                    if (!profile.isVerified)
                      _VerificationStatusCard(
                        status: profile.verificationStatus,
                        rejectionReason: profile.rejectionReason,
                      ),

                    if (!profile.isVerified)
                      const SizedBox(height: AppTheme.spaceLg),

                    // Presentations section
                    GestureDetector(
                      onTap: () => context.push('${AppRoutes.myPublications}?tab=presentations'),
                      child: _PublicationSectionCard(
                        icon: Icons.business,
                        title: 'Presentations entreprise',
                        subtitle: 'Videos de presentation',
                        count: presentationCount,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spaceMd),

                    // Recruitment publications section
                    GestureDetector(
                      onTap: () => context.push('${AppRoutes.myPublications}?tab=recruitment'),
                      child: _PublicationSectionCard(
                        icon: Icons.work,
                        title: 'Publications de recrutement',
                        subtitle: '${profile.videoCredits} credits video, ${profile.posterCredits} credits affiche',
                        count: offerCount + posterCount,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spaceLg),

                    // Statistics card
                    StatsCard(
                      isPremium: isPremium,
                      stats: stats,
                      isSeeker: false,
                    ),

                    const SizedBox(height: AppTheme.spaceLg),

                    // Action buttons
                    EtoileButton(
                      label: 'Publier',
                      icon: Icons.add,
                      onPressed: () => context.go(AppRoutes.publish),
                    ),

                    const SizedBox(height: AppTheme.spaceMd),

                    EtoileButton.outlined(
                      label: AppStrings.editProfile,
                      icon: Icons.edit_outlined,
                      onPressed: () =>
                          context.push(AppRoutes.editRecruiterProfile),
                    ),

                    const SizedBox(height: AppTheme.spaceLg),

                    // Logout button
                    TextButton.icon(
                      onPressed: () {
                        context
                            .read<AuthBloc>()
                            .add(const AuthLogoutRequested());
                      },
                      icon: const Icon(Icons.logout, color: AppColors.error),
                      label: Text(
                        AppStrings.logout,
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spaceLg),
                  ],
                ),
              ),
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
        color: AppColors.info.withAlpha(25),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.info.withAlpha(100)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.info),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: Text(
                  'Completez votre profil pour etre visible',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.greyLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryYellow),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onComplete,
              child: const Text('Completer mon profil'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Verification status card for recruiters
class _VerificationStatusCard extends StatelessWidget {
  final String status;
  final String? rejectionReason;

  const _VerificationStatusCard({
    required this.status,
    this.rejectionReason,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'pending';
    final isRejected = status == 'rejected';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: isRejected
            ? AppColors.error.withAlpha(25)
            : AppColors.warning.withAlpha(25),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isRejected
              ? AppColors.error.withAlpha(100)
              : AppColors.warning.withAlpha(100),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPending ? Icons.hourglass_empty : Icons.error_outline,
                color: isRejected ? AppColors.error : AppColors.warning,
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: Text(
                  isPending
                      ? 'Verification en cours'
                      : 'Verification refusee',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          if (rejectionReason != null) ...[
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              rejectionReason!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Video preview card for seekers
class _VideoPreviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Espace video de presentation - Aucune video enregistree',
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam_outlined,
                  size: 48,
                  color: AppColors.white.withAlpha(180),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Text(
                  'Aucune video',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withAlpha(180),
                      ),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Text(
                  'Enregistrez votre video de presentation',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withAlpha(120),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.greyLight),
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
                  color: AppColors.greyWarm,
                ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.greyWarm,
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.greyWarm,
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
                color: AppColors.greyWarm,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  studyInfo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.greyWarm,
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

/// Recruiter header with cover photo + logo overlay
class _RecruiterHeader extends StatelessWidget {
  final String? coverUrl;
  final String companyName;
  final String sector;
  final bool isVerified;

  const _RecruiterHeader({
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
          // Gradient overlay for text readability
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

/// Publication section card for recruiter profile
class _PublicationSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int count;

  const _PublicationSectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withAlpha(25),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(icon, color: AppColors.primaryOrange),
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
                        color: AppColors.greyWarm,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.tagBackground,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
            ),
          ),
          const SizedBox(width: AppTheme.spaceSm),
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.greyWarm,
          ),
        ],
      ),
    );
  }
}


