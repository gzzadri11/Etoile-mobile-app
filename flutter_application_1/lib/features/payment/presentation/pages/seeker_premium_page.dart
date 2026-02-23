import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/etoile_button.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

/// Premium subscription page for seekers (chercheurs)
///
/// Shows premium benefits, price, and subscribe CTA.
/// If already premium, shows status and manage options.
class SeekerPremiumPage extends StatelessWidget {
  const SeekerPremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Chercheur'),
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state is PaymentCancelled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Paiement annule.')),
            );
          }
        },
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PaymentStatusLoaded && state.isPremium) {
            return _PremiumActiveView(
              currentPeriodEnd: state.currentPeriodEnd,
              status: state.status,
            );
          }

          return const _PremiumOfferView();
        },
      ),
    );
  }
}

// =============================================================================
// VIEW: Offer (user is NOT premium)
// =============================================================================

class _PremiumOfferView extends StatelessWidget {
  const _PremiumOfferView();

  static const _benefits = [
    _Benefit(
      icon: Icons.visibility,
      title: 'Qui a vu ta video',
      description: 'Decouvre les recruteurs qui ont regarde ton profil.',
    ),
    _Benefit(
      icon: Icons.bar_chart,
      title: 'Statistiques detaillees',
      description: 'Nombre de vues, duree moyenne de visionnage, tendances.',
    ),
    _Benefit(
      icon: Icons.workspace_premium,
      title: 'Badge Premium',
      description: 'Ton profil se demarque dans le feed avec un badge dore.',
    ),
    _Benefit(
      icon: Icons.trending_up,
      title: 'Priorite dans les resultats',
      description: 'Apparais en premier quand les recruteurs parcourent le feed.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppTheme.spaceMd),

          // Header
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMd,
                vertical: AppTheme.spaceSm,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: AppColors.black, size: 20),
                  SizedBox(width: AppTheme.spaceXs),
                  Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spaceLg),

          // Title
          Text(
            'Booste ta visibilite',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            'Maximise tes chances de decrocher le poste ideal.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.greyWarm,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTheme.spaceXl),

          // Benefits list
          ...ListTile.divideTiles(
            context: context,
            tiles: _benefits.map((b) => _BenefitTile(benefit: b)),
          ),

          const SizedBox(height: AppTheme.spaceXl),

          // Price card
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Column(
              children: [
                Text(
                  '4,99 \u20AC',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppTheme.spaceXs),
                Text(
                  'par mois',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.greyWarm,
                      ),
                ),
                const SizedBox(height: AppTheme.spaceXs),
                Text(
                  'Sans engagement — annulable a tout moment',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.greyWarm,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spaceLg),

          // CTA
          BlocBuilder<PaymentBloc, PaymentState>(
            builder: (context, state) {
              return EtoileButton(
                label: 'S\'abonner — 4,99 \u20AC/mois',
                isLoading: state is PaymentLoading,
                onPressed: () {
                  context.read<PaymentBloc>().add(
                        const PaymentSubscribe(planType: 'seeker_premium'),
                      );
                },
              );
            },
          ),

          const SizedBox(height: AppTheme.spaceMd),

          // Legal
          Text(
            'Le paiement sera preleve sur votre carte bancaire. '
            'L\'abonnement se renouvelle automatiquement chaque mois. '
            'Vous pouvez annuler a tout moment depuis votre profil.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.greyWarm,
                  fontSize: 11,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTheme.spaceXl),
        ],
      ),
    );
  }
}

// =============================================================================
// VIEW: Active subscription
// =============================================================================

class _PremiumActiveView extends StatelessWidget {
  final DateTime? currentPeriodEnd;
  final String? status;

  const _PremiumActiveView({this.currentPeriodEnd, this.status});

  @override
  Widget build(BuildContext context) {
    final renewalDate = currentPeriodEnd != null
        ? DateFormat('d MMMM yyyy', 'fr_FR').format(currentPeriodEnd!)
        : 'Non defini';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppTheme.spaceXl),

          // Status badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceMd,
                vertical: AppTheme.spaceSm,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                border: Border.all(color: AppColors.success),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  SizedBox(width: AppTheme.spaceXs),
                  Text(
                    'PREMIUM ACTIF',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spaceXl),

          // Info card
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Column(
              children: [
                _InfoRow(label: 'Abonnement', value: 'Premium Chercheur'),
                const SizedBox(height: AppTheme.spaceMd),
                _InfoRow(label: 'Prix', value: '4,99 \u20AC/mois'),
                const SizedBox(height: AppTheme.spaceMd),
                _InfoRow(label: 'Prochain renouvellement', value: renewalDate),
                if (status == 'canceled') ...[
                  const SizedBox(height: AppTheme.spaceMd),
                  const _InfoRow(
                    label: 'Statut',
                    value: 'Annule (actif jusqu\'a la fin de la periode)',
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spaceXl),

          // Manage button
          if (status != 'canceled')
            EtoileButton.outlined(
              label: 'Gerer mon abonnement',
              onPressed: () {
                context
                    .read<PaymentBloc>()
                    .add(const PaymentCancelSubscription());
              },
            ),

          const SizedBox(height: AppTheme.spaceXl),
        ],
      ),
    );
  }
}

// =============================================================================
// COMPONENTS
// =============================================================================

class _Benefit {
  final IconData icon;
  final String title;
  final String description;

  const _Benefit({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _BenefitTile extends StatelessWidget {
  final _Benefit benefit;

  const _BenefitTile({required this.benefit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.tagBackground,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(benefit.icon, color: AppColors.primaryOrange, size: 22),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppTheme.spaceXs),
                Text(
                  benefit.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.greyWarm,
              ),
        ),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
