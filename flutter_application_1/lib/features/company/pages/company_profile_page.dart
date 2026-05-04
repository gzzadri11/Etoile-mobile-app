library;

/// Page de profil d'une entreprise recruteuse.

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_widgets.dart';
import '../../offer/pages/offer_detail_page.dart';
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
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              child: Column(
                children: [
                  // Photo de profil entreprise
                  company.logoUrl != null
                      ? CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(company.logoUrl!),
                          backgroundColor: AppColors.accentBg,
                        )
                      : AppAvatar(
                          initials: company.initials,
                          color: AppColors.accent,
                          size: 80,
                        ),

                  const SizedBox(height: AppSpacing.md),

                  // Nom entreprise
                  Text(
                    company.name,
                    style: AppTextStyles.h1(),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  // Secteur
                  Text(
                    company.sector,
                    style: AppTextStyles.caption()
                        .copyWith(color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: 2),

                  // Ville
                  Text(
                    company.city,
                    style: AppTextStyles.caption()
                        .copyWith(color: AppColors.textTertiary),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Badge vérifié
                  AppChip(
                    label: '✓ Entreprise vérifiée',
                    bg: AppColors.accentBg,
                    textColor: AppColors.accentDark,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── DESCRIPTION ──
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
            Container(
              color: AppColors.bgPrimary,
              padding: const EdgeInsets.only(
                top: AppSpacing.xl,
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: AppSpacing.sm,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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

            // Carrousel des offres
            SizedBox(
              height: 300,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                itemCount: company.offers.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final offer = company.offers[index];
                  return _OfferCarouselCard(
                    offer: offer,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OfferDetailPage(offer: offer),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── APERÇU DANS LE FEED ──
            const SizedBox(height: AppSpacing.sm),
            Container(
              color: AppColors.bgPrimary,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Text(
                    'Aperçu dans le feed',
                    style: AppTextStyles.label()
                        .copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successBg,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'Vue chercheur',
                      style: AppTextStyles.label()
                          .copyWith(color: AppColors.success),
                    ),
                  ),
                ],
              ),
            ),
            ...company.offers
                .map((offer) => _FeedPreviewCard(offer: offer)),
            const SizedBox(height: AppSpacing.xl3),
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
            // Miniature média — ratio 9:16
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

// ── APERÇU DANS LE FEED (simulation) ──
class _FeedPreviewCard extends StatelessWidget {
  final OfferModel offer;
  const _FeedPreviewCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── HEADER FEED SIMULÉ : Reset + Filtres ──
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.bgSubtle,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Offres',
                  style: AppTextStyles.caption().copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                // Reset
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.bgMuted,
                    borderRadius: BorderRadius.circular(AppRadius.btn),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Reset',
                        style: AppTextStyles.label().copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Filtres
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accentBg,
                    borderRadius: BorderRadius.circular(AppRadius.btn),
                    border: Border.all(color: AppColors.accent, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.tune_rounded,
                        size: 12,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Filtres',
                        style: AppTextStyles.label().copyWith(
                          color: AppColors.accent,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── CORPS : Média + overlays ──
          Stack(
            children: [
              // Média 9:16 plein cadre, rien coupé
              AspectRatio(
                aspectRatio: 9 / 16,
                child: ClipRRect(
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
              ),

              // Gradient bas
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 130,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xCC000000)],
                    ),
                  ),
                ),
              ),

              // Username + titre — bas gauche
              Positioned(
                left: 12,
                bottom: 16,
                right: 68,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          '@${offer.companyName.toLowerCase().replaceAll(' ', '')}',
                          style: AppTextStyles.caption().copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      offer.title,
                      style: AppTextStyles.body().copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Boutons d'action — colonne droite
              Positioned(
                right: 10,
                bottom: 12,
                child: Column(
                  children: [
                    _FeedActionButton(
                      icon: Icons.send_rounded,
                      label: 'Postuler',
                      color: AppColors.accent,
                      bgColor: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    _FeedActionButton(
                      icon: Icons.person_rounded,
                      label: 'Profil',
                      color: Colors.white,
                      bgColor: Colors.white24,
                    ),
                    const SizedBox(height: 10),
                    _FeedActionButton(
                      icon: Icons.flag_rounded,
                      label: 'Signal',
                      color: Colors.white,
                      bgColor: Colors.white24,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeedActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  const _FeedActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: AppTextStyles.label().copyWith(
            color: Colors.white,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
