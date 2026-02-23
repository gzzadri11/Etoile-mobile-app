import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/etoile_button.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

/// Premium subscription page for recruiters (recruteurs)
///
/// Shows premium benefits, price (499€/mois), credits purchase,
/// and subscribe CTA. If already premium, shows status and manage options.
class RecruiterPremiumPage extends StatelessWidget {
  const RecruiterPremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Recruteur'),
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
      icon: Icons.video_library,
      title: '2 videos + 2 affiches par semaine',
      description: 'Publications incluses dans votre abonnement, chaque semaine.',
    ),
    _Benefit(
      icon: Icons.analytics,
      title: 'Statistiques detaillees',
      description: 'Vues, profils qui ont regarde, taux d\'engagement.',
    ),
    _Benefit(
      icon: Icons.workspace_premium,
      title: 'Badge Premium',
      description: 'Votre entreprise se demarque avec un badge de confiance.',
    ),
    _Benefit(
      icon: Icons.person_search,
      title: 'Acces prioritaire aux profils',
      description: 'Consultez les candidats avant les recruteurs gratuits.',
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

          // Header badge
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
                    'PREMIUM RECRUTEUR',
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
            'Recrutez les meilleurs talents',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            'Publiez vos offres et trouvez les candidats ideaux.',
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

          // Price card — subscription
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Column(
              children: [
                Text(
                  'Abonnement',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.greyWarm,
                      ),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Text(
                  '499 \u20AC',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppTheme.spaceXs),
                Text(
                  'par mois — HT',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.greyWarm,
                      ),
                ),
                const SizedBox(height: AppTheme.spaceXs),
                Text(
                  'Sans engagement — annulable a tout moment\nFacture disponible chaque mois',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.greyWarm,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spaceMd),

          // CTA subscription
          BlocBuilder<PaymentBloc, PaymentState>(
            builder: (context, state) {
              return EtoileButton(
                label: 'S\'abonner — 499 \u20AC/mois',
                isLoading: state is PaymentLoading,
                onPressed: () {
                  context.read<PaymentBloc>().add(
                        const PaymentSubscribe(planType: 'recruiter_premium'),
                      );
                },
              );
            },
          ),

          const SizedBox(height: AppTheme.spaceXl),

          // Divider
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMd,
                ),
                child: Text(
                  'ou a l\'unite',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.greyWarm,
                      ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),

          const SizedBox(height: AppTheme.spaceLg),

          // Credits section
          Text(
            'Credits a l\'unite',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            'Achetez des publications sans abonnement.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.greyWarm,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTheme.spaceMd),

          // Credit cards
          _CreditCard(
            icon: Icons.videocam,
            title: '+1 publication video',
            price: '99 \u20AC',
            onBuy: () {
              context.read<PaymentBloc>().add(
                    const PaymentBuyCredit(productType: 'video_credit'),
                  );
            },
          ),
          const SizedBox(height: AppTheme.spaceMd),
          _CreditCard(
            icon: Icons.image,
            title: '+1 affiche',
            price: '49 \u20AC',
            onBuy: () {
              context.read<PaymentBloc>().add(
                    const PaymentBuyCredit(productType: 'poster_credit'),
                  );
            },
          ),

          const SizedBox(height: AppTheme.spaceLg),

          // Legal
          Text(
            'Le paiement sera preleve sur votre carte bancaire. '
            'L\'abonnement se renouvelle automatiquement chaque mois. '
            'Les credits achetes n\'expirent pas. '
            'Vous pouvez annuler votre abonnement a tout moment.',
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
                _InfoRow(label: 'Abonnement', value: 'Premium Recruteur'),
                const SizedBox(height: AppTheme.spaceMd),
                _InfoRow(label: 'Prix', value: '499 \u20AC/mois HT'),
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

          // Credits section (available even when premium)
          Text(
            'Acheter des credits supplementaires',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceMd),

          _CreditCard(
            icon: Icons.videocam,
            title: '+1 publication video',
            price: '99 \u20AC',
            onBuy: () {
              context.read<PaymentBloc>().add(
                    const PaymentBuyCredit(productType: 'video_credit'),
                  );
            },
          ),
          const SizedBox(height: AppTheme.spaceMd),
          _CreditCard(
            icon: Icons.image,
            title: '+1 affiche',
            price: '49 \u20AC',
            onBuy: () {
              context.read<PaymentBloc>().add(
                    const PaymentBuyCredit(productType: 'poster_credit'),
                  );
            },
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

class _CreditCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String price;
  final VoidCallback onBuy;

  const _CreditCard({
    required this.icon,
    required this.title,
    required this.price,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.tagBackground,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(icon, color: AppColors.primaryOrange, size: 24),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  price,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.greyWarm,
                      ),
                ),
              ],
            ),
          ),
          EtoileButton(
            label: 'Acheter',
            width: 100,
            onPressed: onBuy,
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
