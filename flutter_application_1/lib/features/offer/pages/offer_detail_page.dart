library;

/// Page de detail d'une offre d'emploi.

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_widgets.dart';
import '../../company/models/company_model.dart';

class OfferDetailPage extends StatelessWidget {
  final OfferModel offer;

  const OfferDetailPage({required this.offer, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSubtle,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(offer.companyName, style: AppTextStyles.h2()),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Media — ratio 9:16 complet
                  AspectRatio(
                    aspectRatio: 9 / 16,
                    child: offer.mediaUrl != null
                        ? Image.network(
                            offer.mediaUrl!,
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            color: AppColors.bgMuted,
                            colorBlendMode: BlendMode.dstOver,
                          )
                        : Container(
                            color: AppColors.accentBg,
                            child: const Center(
                              child: Icon(
                                Icons.play_circle_outline,
                                color: AppColors.accent,
                                size: 48,
                              ),
                            ),
                          ),
                  ),

                  // Details
                  Container(
                    color: AppColors.bgPrimary,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(offer.title, style: AppTextStyles.h1()),
                        const SizedBox(height: 4),
                        Text(
                          offer.companyName,
                          style: AppTextStyles.caption().copyWith(
                            color: AppColors.accent,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            AppChip(
                              label: offer.sector,
                              bg: AppColors.accentBg,
                              textColor: AppColors.accentDark,
                            ),
                            AppChip(
                              label: offer.city,
                              bg: AppColors.bgMuted,
                              textColor: AppColors.textSecondary,
                            ),
                            AppChip(
                              label: offer.contractType,
                              bg: AppColors.bgMuted,
                              textColor: AppColors.textSecondary,
                            ),
                          ],
                        ),

                        if (offer.description != null) ...[
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            'Description du poste',
                            style: AppTextStyles.label().copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(offer.description!, style: AppTextStyles.body()),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bouton postuler — fixe en bas
          Container(
            color: AppColors.bgPrimary,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.md + MediaQuery.of(context).padding.bottom,
            ),
            child: AppButtonPrimary(
              label: 'Postuler',
              onTap: () {
                // TODO: logique candidature
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité en cours de développement'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
