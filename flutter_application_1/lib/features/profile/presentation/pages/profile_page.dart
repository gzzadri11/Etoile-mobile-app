import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/etoile_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/models/seeker_profile_model.dart';
import '../../data/models/recruiter_profile_model.dart';
import '../bloc/profile_bloc.dart';

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
          return _SeekerProfileView(profile: state.profile);
        }

        if (state is RecruiterProfileLoaded) {
          return _RecruiterProfileView(profile: state.profile);
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

  const _SeekerProfileView({required this.profile});

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
                jobTitle: profile.categories.isNotEmpty
                    ? profile.categories.first
                    : 'Non defini',
                location: profile.location.isNotEmpty
                    ? profile.location
                    : 'Non defini',
                availability: profile.availability ?? 'Non defini',
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // Profile completion indicator
              if (!profile.profileComplete)
                _ProfileCompletionCard(
                  onComplete: () => context.push(AppRoutes.editProfile),
                ),

              if (!profile.profileComplete)
                const SizedBox(height: AppTheme.spaceLg),

              // Statistics card
              _StatisticsCard(isPremium: false),

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

  const _RecruiterProfileView({required this.profile});

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
              // Company card
              _CompanyCard(
                name: profile.companyName,
                sector: profile.sector ?? 'Non defini',
                description: profile.description ?? '',
                isVerified: profile.isVerified,
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // Verification status
              if (!profile.isVerified)
                _VerificationStatusCard(
                  status: profile.verificationStatus,
                  rejectionReason: profile.rejectionReason,
                ),

              if (!profile.isVerified)
                const SizedBox(height: AppTheme.spaceLg),

              // Publications summary
              _PublicationsCard(
                videoCount: 0, // TODO: Get from videos table
                posterCount: 0,
                videoCredits: profile.videoCredits,
                posterCredits: profile.posterCredits,
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // Statistics card
              _StatisticsCard(isPremium: false),

              const SizedBox(height: AppTheme.spaceLg),

              // Action buttons
              EtoileButton(
                label: 'Publier une offre',
                icon: Icons.add,
                onPressed: () {
                  // TODO: Navigate to publish
                },
              ),

              const SizedBox(height: AppTheme.spaceMd),

              EtoileButton.outlined(
                label: AppStrings.editProfile,
                icon: Icons.edit_outlined,
                onPressed: () => context.push(AppRoutes.editRecruiterProfile),
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

/// Profile completion card
class _ProfileCompletionCard extends StatelessWidget {
  final VoidCallback onComplete;

  const _ProfileCompletionCard({required this.onComplete});

  @override
  Widget build(BuildContext context) {
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
            ],
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
    return Container(
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
    );
  }
}

/// Profile info card
class _ProfileInfoCard extends StatelessWidget {
  final String name;
  final String jobTitle;
  final String location;
  final String availability;

  const _ProfileInfoCard({
    required this.name,
    required this.jobTitle,
    required this.location,
    required this.availability,
  });

  String _getAvailabilityLabel(String value) {
    const labels = {
      'immediate': 'immediatement',
      '1_week': 'sous 1 semaine',
      '2_weeks': 'sous 2 semaines',
      '1_month': 'sous 1 mois',
      '3_months': 'sous 3 mois',
    };
    return labels[value] ?? value;
  }

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
            jobTitle,
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
                Icons.check_circle_outline,
                size: 16,
                color: AppColors.success,
              ),
              const SizedBox(width: 4),
              Text(
                'Disponible ${_getAvailabilityLabel(availability)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Company card for recruiters
class _CompanyCard extends StatelessWidget {
  final String name;
  final String sector;
  final String description;
  final bool isVerified;

  const _CompanyCard({
    required this.name,
    required this.sector,
    required this.description,
    required this.isVerified,
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
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: const Icon(
                  Icons.business,
                  color: AppColors.greyWarm,
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: AppTheme.spaceSm),
                          const Icon(
                            Icons.check_circle,
                            size: 16,
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
          if (description.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Publications card for recruiters
class _PublicationsCard extends StatelessWidget {
  final int videoCount;
  final int posterCount;
  final int videoCredits;
  final int posterCredits;

  const _PublicationsCard({
    required this.videoCount,
    required this.posterCount,
    required this.videoCredits,
    required this.posterCredits,
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
            'Mes publications',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Row(
            children: [
              Expanded(
                child: _PublicationStat(
                  icon: Icons.videocam_outlined,
                  count: videoCount,
                  label: 'Videos',
                  credits: videoCredits,
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: _PublicationStat(
                  icon: Icons.image_outlined,
                  count: posterCount,
                  label: 'Affiches',
                  credits: posterCredits,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PublicationStat extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final int credits;

  const _PublicationStat({
    required this.icon,
    required this.count,
    required this.label,
    required this.credits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryOrange),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.greyWarm,
                ),
          ),
          if (credits > 0) ...[
            const SizedBox(height: AppTheme.spaceXs),
            Text(
              '+$credits credits',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Statistics card
class _StatisticsCard extends StatelessWidget {
  final bool isPremium;

  const _StatisticsCard({required this.isPremium});

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
          Row(
            children: [
              const Icon(
                Icons.bar_chart,
                color: AppColors.primaryOrange,
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Text(
                AppStrings.statistics,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          if (isPremium)
            const Text('Stats detaillees ici')
          else
            Column(
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
                  onPressed: () => context.push(AppRoutes.premium),
                  icon: const Icon(Icons.star_outline),
                  label: const Text(AppStrings.goPremium),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryOrange,
                    side: const BorderSide(color: AppColors.primaryOrange),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
