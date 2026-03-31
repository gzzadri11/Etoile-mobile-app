library;

/// Page de gestion de l'abonnement recruteur.
///
/// Affiche le statut de l'abonnement actif, l'historique des factures
/// et permet d'acceder au portail Stripe pour modifier ou annuler.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

class SubscriptionManagementPage extends StatelessWidget {
  const SubscriptionManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon abonnement')),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<PaymentBloc>().add(const PaymentLoadHistory());
          } else if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryYellow),
            );
          }

          if (state is PaymentHistoryLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PaymentBloc>().add(const PaymentLoadHistory());
              },
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                children: [
                  _buildSubscriptionSection(context, state),
                  const SizedBox(height: AppTheme.spaceLg),
                  if (state.videoCredits > 0 || state.posterCredits > 0) ...[
                    _buildCreditsSection(context, state),
                    const SizedBox(height: AppTheme.spaceLg),
                  ],
                  _buildHistorySection(context, state),
                ],
              ),
            );
          }

          if (state is PaymentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: AppTheme.spaceMd),
                  Text(state.message),
                  const SizedBox(height: AppTheme.spaceMd),
                  ElevatedButton(
                    onPressed: () => context
                        .read<PaymentBloc>()
                        .add(const PaymentLoadHistory()),
                    child: const Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSubscriptionSection(
      BuildContext context, PaymentHistoryLoaded state) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  state.isPremium ? Icons.star : Icons.star_outline,
                  color: state.isPremium
                      ? AppColors.primaryYellow
                      : AppColors.greyMedium,
                ),
                const SizedBox(width: AppTheme.spaceSm),
                Text(
                  'Abonnement',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),
            if (!state.isPremium)
              const Text(
                'Vous n\'avez pas d\'abonnement actif.',
                style: TextStyle(color: AppColors.greyWarm),
              )
            else ...[
              _infoRow(
                'Type',
                'Premium Recruteur',
              ),
              _infoRow(
                'Statut',
                _statusLabel(state.subscriptionStatus),
              ),
              if (state.currentPeriodEnd != null)
                _infoRow(
                  state.subscriptionStatus == 'canceled'
                      ? 'Actif jusqu\'au'
                      : 'Renouvellement',
                  dateFormat.format(state.currentPeriodEnd!),
                ),
              const SizedBox(height: AppTheme.spaceMd),
              if (state.subscriptionStatus == 'active')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showCancelDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Annuler l\'abonnement'),
                  ),
                ),
              if (state.subscriptionStatus == 'canceled')
                Text(
                  'Votre abonnement reste actif jusqu\'a la date ci-dessus.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.greyWarm),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCreditsSection(
      BuildContext context, PaymentHistoryLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.token, color: AppColors.primaryOrange),
                const SizedBox(width: AppTheme.spaceSm),
                Text(
                  'Mes credits',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),
            _infoRow(
              'Publications video',
              '${state.videoCredits} credit${state.videoCredits > 1 ? 's' : ''}',
            ),
            _infoRow(
              'Affiches',
              '${state.posterCredits} credit${state.posterCredits > 1 ? 's' : ''}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection(
      BuildContext context, PaymentHistoryLoaded state) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historique des paiements',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spaceSm),
        if (state.transactions.isEmpty)
          const EmptyStateWidget(
            icon: Icons.receipt_long_outlined,
            title: 'Aucun paiement',
            compact: true,
          )
        else
          ...state.transactions.map((tx) {
            final date = DateTime.tryParse(tx['date'] as String? ?? '');
            return ListTile(
              leading: Icon(
                tx['type'] == 'subscription'
                    ? Icons.repeat
                    : Icons.shopping_cart_outlined,
                color: AppColors.greyWarm,
              ),
              title: Text(tx['description'] as String? ?? ''),
              subtitle: Text(
                date != null ? dateFormat.format(date) : '',
                style: const TextStyle(color: AppColors.greyMedium),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tx['amount'] as String? ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _statusLabel(tx['status'] as String?),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _statusColor(tx['status'] as String?),
                        ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.greyWarm)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'active':
        return 'Actif';
      case 'canceled':
        return 'Annule';
      case 'past_due':
        return 'Paiement en retard';
      case 'expired':
        return 'Expire';
      case 'succeeded':
        return 'Reussi';
      case 'pending':
        return 'En attente';
      default:
        return status ?? '-';
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'active':
      case 'succeeded':
        return AppColors.success;
      case 'canceled':
      case 'expired':
        return AppColors.greyWarm;
      case 'past_due':
      case 'pending':
        return AppColors.primaryOrange;
      default:
        return AppColors.greyMedium;
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Annuler l\'abonnement ?'),
        content: const Text(
          'Votre abonnement restera actif jusqu\'a la fin de la periode en cours. '
          'Vous ne serez plus debite par la suite.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context
                  .read<PaymentBloc>()
                  .add(const PaymentCancelSubscription());
            },
            child: const Text(
              'Annuler l\'abonnement',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
