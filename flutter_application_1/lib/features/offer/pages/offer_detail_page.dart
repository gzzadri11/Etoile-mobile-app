library;

/// Page de detail d'une offre d'emploi avec bouton Postuler.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_widgets.dart';
import '../../../shared/widgets/profile_gate.dart';
import '../../applications/data/repositories/application_repository.dart';
import '../../company/models/company_model.dart';
import '../../video/data/repositories/video_repository.dart';

class OfferDetailPage extends StatefulWidget {
  final OfferModel offer;

  const OfferDetailPage({required this.offer, super.key});

  @override
  State<OfferDetailPage> createState() => _OfferDetailPageState();
}

class _OfferDetailPageState extends State<OfferDetailPage> {
  bool _hasApplied = false;
  bool _isApplying = false;
  bool _loadingStatus = true;
  Uint8List? _videoThumb;
  bool _thumbLoading = true;

  @override
  void initState() {
    super.initState();
    _checkApplicationStatus();
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

  Widget _buildMedia() {
    final offer = widget.offer;

    if (offer.mediaType == 'image' && offer.mediaUrl != null) {
      return Image.network(
        offer.mediaUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _mediaSkeleton();
        },
        errorBuilder: (_, _, _) => _mediaPlaceholder(),
      );
    }

    if (offer.mediaType == 'video') {
      if (_thumbLoading) return _mediaSkeleton();
      if (_videoThumb != null) {
        return Image.memory(
          _videoThumb!,
          fit: BoxFit.cover,
          width: double.infinity,
        );
      }
      return _mediaPlaceholder();
    }

    return _mediaPlaceholder();
  }

  Widget _mediaSkeleton() => Container(
        color: AppColors.bgMuted,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent,
            ),
          ),
        ),
      );

  Widget _mediaPlaceholder() => Container(
        color: AppColors.accentBg,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.accent,
            size: 48,
          ),
        ),
      );

  Future<void> _checkApplicationStatus() async {
    final recruiterId = widget.offer.recruiterId;
    if (recruiterId == null) {
      if (mounted) setState(() => _loadingStatus = false);
      return;
    }
    try {
      // Get the seeker's own video to check if they've applied via that video
      final videoRepo = GetIt.I<VideoRepository>();
      final myVideo = await videoRepo.getMyPresentationVideo();
      if (myVideo == null) {
        if (mounted) setState(() => _loadingStatus = false);
        return;
      }
      final appRepo = GetIt.I<ApplicationRepository>();
      final appliedVideoIds = await appRepo.getAppliedVideoIds();
      if (mounted) {
        setState(() {
          _hasApplied = appliedVideoIds.contains(myVideo.id);
          _loadingStatus = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingStatus = false);
    }
  }

  Future<void> _onPostuler() async {
    final offer = widget.offer;
    final recruiterId = offer.recruiterId;

    if (recruiterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offre non disponible pour candidature')),
      );
      return;
    }

    final allowed = await checkProfileGate(context);
    if (!allowed || !mounted) return;

    // Get the seeker's presentation video ID
    final videoRepo = GetIt.I<VideoRepository>();
    final myVideo = await videoRepo.getMyPresentationVideo();
    final videoId = myVideo?.id;

    if (!mounted) return;

    if (videoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enregistrez votre vidéo de présentation pour postuler'),
        ),
      );
      return;
    }

    setState(() => _isApplying = true);

    try {
      final appRepo = GetIt.I<ApplicationRepository>();
      await appRepo.applyToOffer(
        videoId: videoId,
        recruiterId: recruiterId,
      );

      if (mounted) {
        setState(() {
          _hasApplied = true;
          _isApplying = false;
        });
        _showSuccessOverlay();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isApplying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la candidature : $e')),
        );
      }
    }
  }

  void _showSuccessOverlay() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _ApplySuccessDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
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
                  // Media — hauteur fixe pour laisser la description visible
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: _buildMedia(),
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
            child: _hasApplied
                ? _AppliedBanner()
                : AppButtonPrimary(
                    label: _isApplying ? 'Envoi en cours…' : 'Postuler',
                    onTap: (_isApplying || _loadingStatus) ? null : _onPostuler,
                  ),
          ),
        ],
      ),
    );
  }
}

class _AppliedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(25),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.success.withAlpha(80)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
          const SizedBox(width: 8),
          Text(
            'Candidature envoyée',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ApplySuccessDialog extends StatelessWidget {
  const _ApplySuccessDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.accentBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.accent,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Candidature envoyée !',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Le recruteur recevra votre vidéo de présentation.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Super !'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
