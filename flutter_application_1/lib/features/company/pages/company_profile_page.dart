library;

/// Page de profil d'une entreprise recruteuse.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

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
class _OfferCarouselCard extends StatefulWidget {
  final OfferModel offer;
  final VoidCallback onTap;

  const _OfferCarouselCard({required this.offer, required this.onTap});

  @override
  State<_OfferCarouselCard> createState() => _OfferCarouselCardState();
}

class _OfferCarouselCardState extends State<_OfferCarouselCard> {
  Uint8List? _videoThumb;
  bool _thumbLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    if (widget.offer.mediaType == 'video' && widget.offer.mediaUrl != null) {
      try {
        final thumb = await VideoThumbnail.thumbnailData(
          video: widget.offer.mediaUrl!,
          imageFormat: ImageFormat.JPEG,
          timeMs: 0,
          quality: 85,
        );
        if (!mounted) return;
        setState(() {
          _videoThumb = thumb;
          _thumbLoading = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _thumbLoading = false);
      }
    } else {
      if (!mounted) return;
      setState(() => _thumbLoading = false);
    }
  }

  void _showPreview(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final bottomPad = MediaQuery.of(context).padding.bottom;
        final maxHeight = MediaQuery.of(context).size.height * 0.75;
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                // Contenu scrollable
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.md,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.offer.title, style: AppTextStyles.h2()),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          widget.offer.description != null &&
                                  widget.offer.description!.isNotEmpty
                              ? widget.offer.description!
                              : 'Aucune description disponible.',
                          style: AppTextStyles.body().copyWith(
                            color: widget.offer.description != null &&
                                    widget.offer.description!.isNotEmpty
                                ? AppColors.textSecondary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.xl + bottomPad),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPreview(context),
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
            // ── MINIATURE ──
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: _buildThumbnail(),
              ),
            ),

            // ── TITRE ──
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Text(
                widget.offer.title,
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

  Widget _buildThumbnail() {
    // CAS 1 — Image (affiche)
    if (widget.offer.mediaType == 'image' && widget.offer.mediaUrl != null) {
      return Image.network(
        widget.offer.mediaUrl!,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const _LoadingPlaceholder();
        },
        errorBuilder: (_, _, _) => const _ErrorPlaceholder(),
      );
    }

    // CAS 2 — Vidéo : première frame extraite
    if (widget.offer.mediaType == 'video') {
      if (_thumbLoading) return const _LoadingPlaceholder();
      if (_videoThumb != null) {
        return Image.memory(
          _videoThumb!,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        );
      }
      return const _ErrorPlaceholder();
    }

    // CAS 3 — Pas de média
    return const _ErrorPlaceholder();
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgMuted,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.accentBg,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.accent,
          size: 28,
        ),
      ),
    );
  }
}
