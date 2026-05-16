library;

/// Page de profil d'une entreprise recruteuse.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_widgets.dart';
import '../models/company_model.dart';

class CompanyProfilePage extends StatelessWidget {
  final CompanyModel company;

  const CompanyProfilePage({required this.company, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSubtle,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── EN-TÊTE ENTREPRISE ──
            Container(
              color: AppColors.bgPrimary,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Column(
                children: [
                  company.logoUrl != null
                      ? CircleAvatar(
                          radius: 44,
                          backgroundImage: NetworkImage(company.logoUrl!),
                          backgroundColor: AppColors.accentBg,
                        )
                      : AppAvatar(
                          initials: company.initials,
                          color: AppColors.accent,
                          size: 88,
                        ),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    company.name,
                    style: AppTextStyles.h1(),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border:
                          Border.all(color: AppColors.successLight, width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: AppColors.success,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Entreprise vérifiée',
                          style: AppTextStyles.caption().copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── À PROPOS ──
            Container(
              color: AppColors.bgPrimary,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'À propos',
                    style: AppTextStyles.label()
                        .copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(company.description, style: AppTextStyles.body()),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── OFFRES ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Nos offres',
                        style: AppTextStyles.label()
                            .copyWith(color: AppColors.textTertiary),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentBg,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          '${company.offers.length}',
                          style: AppTextStyles.label()
                              .copyWith(color: AppColors.accent),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 320,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      0,
                      AppSpacing.xl,
                      AppSpacing.xl,
                    ),
                    itemCount: company.offers.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final offer = company.offers[index];
                      return _OfferCarouselCard(
                        offer: offer,
                        onTap: () => context.push(
                          AppRoutes.offerDetailFor(offer.id),
                          extra: offer,
                        ),
                      );
                    },
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

// ── CARTE DANS LE CARROUSEL ──
class _OfferCarouselCard extends StatelessWidget {
  final OfferModel offer;
  final VoidCallback onTap;

  const _OfferCarouselCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Miniature média — ratio 9:16, rien coupé
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
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
                            size: 28,
                          ),
                        ),
                      ),
              ),
            ),

            // Titre
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Text(
                offer.title,
                style: AppTextStyles.caption().copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
