import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/sector_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/video_upload_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/etoile_button.dart';
import '../../../../shared/widgets/profile_gate.dart';
import '../../data/repositories/video_repository.dart';

/// Page for recruiters to publish a video offer or an image poster.
///
/// Flow: Pick (video or image) → Preview → Add title + category → Upload → Success
class PublishOfferPage extends StatefulWidget {
  const PublishOfferPage({super.key});

  @override
  State<PublishOfferPage> createState() => _PublishOfferPageState();
}

class _PublishOfferPageState extends State<PublishOfferPage> {
  _PublishStep _step = _PublishStep.pick;

  // Publish type: 'presentation', 'offer', or 'poster'
  String _publishType = 'offer';

  // Video
  XFile? _pickedVideo;
  Uint8List? _videoBytes;
  VideoPlayerController? _videoController;

  // Poster (image)
  XFile? _pickedImage;
  Uint8List? _imageBytes;

  // Form
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  String? _selectedContractType;
  final _formKey = GlobalKey<FormState>();

  // Upload
  int _uploadProgress = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickPresentation() async {
    final allowed = await checkProfileGate(context);
    if (!allowed || !mounted) return;
    _publishType = 'presentation';
    await _pickVideoFile();
  }

  Future<void> _pickVideo() async {
    final allowed = await checkProfileGate(context);
    if (!allowed || !mounted) return;
    _publishType = 'offer';
    await _pickVideoFile();
  }

  Future<void> _pickVideoFile() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 40),
    );

    if (video == null) return;

    setState(() {
      _pickedVideo = video;
      _errorMessage = null;
    });

    // Read bytes for upload later
    _videoBytes = await video.readAsBytes();

    // Initialize video player for preview
    if (kIsWeb) {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(video.path),
      );
    } else {
      _videoController = VideoPlayerController.file(File(video.path));
    }

    await _videoController!.initialize();
    await _videoController!.setLooping(true);
    await _videoController!.play();

    if (mounted) {
      setState(() => _step = _PublishStep.preview);
    }
  }

  Future<void> _pickPoster() async {
    final allowed = await checkProfileGate(context);
    if (!allowed || !mounted) return;

    final picker = ImagePicker();
    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image == null) return;

      setState(() {
        _pickedImage = image;
        _publishType = 'poster';
        _errorMessage = null;
      });

      _imageBytes = await image.readAsBytes();

      if (mounted) {
        setState(() => _step = _PublishStep.preview);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur lors de la selection de l\'image: $e';
        });
      }
    }
  }

  void _goToForm() {
    _videoController?.pause();
    setState(() => _step = _PublishStep.form);
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;

    if (_publishType == 'poster') {
      if (_imageBytes == null || _pickedImage == null) return;
    } else {
      if (_videoBytes == null || _pickedVideo == null) return;
    }

    setState(() {
      _step = _PublishStep.uploading;
      _uploadProgress = 0;
      _errorMessage = null;
    });

    try {
      final uploadService = GetIt.I<VideoUploadService>();
      final videoRepo = GetIt.I<VideoRepository>();

      if (_publishType == 'poster') {
        // Upload image to R2 (thumbnail bucket)
        final filename = _pickedImage!.name;
        final mime = _pickedImage!.mimeType;
        final ext = filename.split('.').last.toLowerCase();
        final contentType = mime ??
            switch (ext) {
              'png' => 'image/png',
              'webp' => 'image/webp',
              _ => 'image/jpeg',
            };

        final imageResult = await uploadService.uploadThumbnail(
          fileBytes: _imageBytes!,
          filename: filename,
          contentType: contentType,
          onProgress: (progress) {
            if (mounted) {
              setState(() => _uploadProgress = (progress * 0.9).round());
            }
          },
        );

        if (mounted) setState(() => _uploadProgress = 95);

        // Create DB entry as poster
        final video = await videoRepo.createVideo(
          type: 'poster',
          videoKey: imageResult.key,
          categoryId: null,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          fileSizeBytes: imageResult.size,
          durationSeconds: 0,
          contractType: _selectedContractType,
        );

        // Set active with URL (stored in video_url for consistency)
        await videoRepo.updateVideoAfterUpload(
          videoId: video.id,
          videoUrl: imageResult.url,
          thumbnailUrl: imageResult.url,
        );
      } else {
        // Upload video to R2
        final filename = _pickedVideo!.name;
        final ext = filename.split('.').last.toLowerCase();
        final contentType = ext == 'mov' ? 'video/quicktime' : 'video/mp4';

        final videoResult = await uploadService.uploadVideo(
          fileBytes: _videoBytes!,
          filename: filename,
          contentType: contentType,
          onProgress: (progress) {
            if (mounted) {
              setState(() => _uploadProgress = (progress * 0.9).round());
            }
          },
        );

        if (mounted) setState(() => _uploadProgress = 95);

        // Create DB entry
        final video = await videoRepo.createVideo(
          type: _publishType,
          videoKey: videoResult.key,
          categoryId: null,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          fileSizeBytes: videoResult.size,
          contractType: _selectedContractType,
        );

        // Set active with URL
        await videoRepo.updateVideoAfterUpload(
          videoId: video.id,
          videoUrl: videoResult.url,
        );
      }

      // Decrement credits (presentations are free)
      if (_publishType != 'presentation') {
        await videoRepo.decrementCredits(type: _publishType == 'poster' ? 'poster' : 'offer');
      }

      if (mounted) {
        setState(() {
          _uploadProgress = 100;
          _step = _PublishStep.success;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _step = _PublishStep.form;
        });
      }
    }
  }

  void _reset() {
    _videoController?.dispose();
    _videoController = null;
    _pickedVideo = null;
    _videoBytes = null;
    _pickedImage = null;
    _imageBytes = null;
    _publishType = 'offer';
    _titleController.clear();
    _descriptionController.clear();
    _selectedCategory = null;
    _selectedContractType = null;
    setState(() {
      _step = _PublishStep.pick;
      _uploadProgress = 0;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _step == _PublishStep.success
          ? null
          : AppBar(
              title: Text(switch (_publishType) {
                'presentation' => 'Presentation entreprise',
                'poster' => 'Publier une affiche',
                _ => 'Publier une offre',
              }),
              leading: _step == _PublishStep.pick
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        if (_step == _PublishStep.form) {
                          _videoController?.play();
                          setState(() => _step = _PublishStep.preview);
                        } else if (_step == _PublishStep.preview) {
                          _reset();
                        }
                      },
                    ),
            ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildStep(),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _PublishStep.pick:
        return _PickView(
          onPickPresentation: _pickPresentation,
          onPickVideo: _pickVideo,
          onPickPoster: _pickPoster,
        );
      case _PublishStep.preview:
        if (_publishType == 'poster') {
          return _ImagePreviewView(
            imageBytes: _imageBytes!,
            onConfirm: _goToForm,
            onRetry: _reset,
          );
        }
        return _PreviewView(
          controller: _videoController!,
          onConfirm: _goToForm,
          onRetry: _reset,
        );
      case _PublishStep.form:
        return _FormView(
          formKey: _formKey,
          titleController: _titleController,
          descriptionController: _descriptionController,
          selectedCategory: _selectedCategory,
          selectedContractType: _selectedContractType,
          errorMessage: _errorMessage,
          publishType: _publishType,
          onCategoryChanged: (v) => setState(() => _selectedCategory = v),
          onContractTypeChanged: (v) => setState(() => _selectedContractType = v),
          onPublish: _upload,
        );
      case _PublishStep.uploading:
        return _UploadingView(progress: _uploadProgress);
      case _PublishStep.success:
        return _SuccessView(
          publishType: _publishType,
          onPublishAnother: _reset,
          onGoToFeed: () => context.go(AppRoutes.feed),
        );
    }
  }
}

enum _PublishStep { pick, preview, form, uploading, success }

// =============================================================================
// Step 1: Pick video or poster
// =============================================================================

class _PickView extends StatelessWidget {
  final VoidCallback onPickPresentation;
  final VoidCallback onPickVideo;
  final VoidCallback? onPickPoster;

  const _PickView({
    required this.onPickPresentation,
    required this.onPickVideo,
    this.onPickPoster,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.movie_creation_outlined,
            size: 80,
            color: AppColors.primaryYellow,
          ),
          const SizedBox(height: AppTheme.spaceLg),
          Text(
            'Nouvelle publication',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            'Choisissez le type de publication',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.greyWarm,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.space2Xl),

          // Presentation entreprise (gratuit)
          EtoileButton(
            label: 'Presentation entreprise',
            icon: Icons.business,
            onPressed: onPickPresentation,
          ),
          const SizedBox(height: AppTheme.spaceXs),
          Text(
            'Gratuit - Presentez votre entreprise en 40s',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.success,
                ),
          ),
          const SizedBox(height: AppTheme.spaceLg),

          // Offre video
          EtoileButton.outlined(
            label: 'Offre video',
            icon: Icons.video_library,
            onPressed: onPickVideo,
          ),
          const SizedBox(height: AppTheme.spaceMd),

          // Offre affiche
          EtoileButton.outlined(
            label: 'Offre affiche',
            icon: Icons.image,
            onPressed: onPickPoster,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Step 2: Video preview
// =============================================================================

class _PreviewView extends StatelessWidget {
  final VideoPlayerController controller;
  final VoidCallback onConfirm;
  final VoidCallback onRetry;

  const _PreviewView({
    required this.controller,
    required this.onConfirm,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Video preview
        Expanded(
          child: Container(
            color: AppColors.black,
            child: Center(
              child: controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    )
                  : const CircularProgressIndicator(
                      color: AppColors.primaryYellow,
                    ),
            ),
          ),
        ),

        // Duration info
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceMd,
            vertical: AppTheme.spaceSm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer, size: 16, color: AppColors.greyWarm),
              const SizedBox(width: 4),
              Text(
                'Duree : ${controller.value.duration.inSeconds}s',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.greyWarm,
                    ),
              ),
              if (controller.value.duration.inSeconds > 40) ...[
                const SizedBox(width: AppTheme.spaceSm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    'Sera coupee a 40s',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.warning,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Buttons
        Padding(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Column(
            children: [
              EtoileButton(
                label: 'Continuer',
                icon: Icons.arrow_forward,
                onPressed: onConfirm,
              ),
              const SizedBox(height: AppTheme.spaceSm),
              EtoileButton.outlined(
                label: 'Choisir une autre video',
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Step 2b: Image preview (poster mode)
// =============================================================================

class _ImagePreviewView extends StatelessWidget {
  final Uint8List imageBytes;
  final VoidCallback onConfirm;
  final VoidCallback onRetry;

  const _ImagePreviewView({
    required this.imageBytes,
    required this.onConfirm,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image preview
        Expanded(
          child: Container(
            color: AppColors.black,
            child: Center(
              child: Image.memory(
                imageBytes,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        // Info
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceMd,
            vertical: AppTheme.spaceSm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image, size: 16, color: AppColors.greyWarm),
              const SizedBox(width: 4),
              Text(
                'Taille : ${(imageBytes.length / 1024).toStringAsFixed(0)} Ko',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.greyWarm,
                    ),
              ),
            ],
          ),
        ),

        // Buttons
        Padding(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Column(
            children: [
              EtoileButton(
                label: 'Continuer',
                icon: Icons.arrow_forward,
                onPressed: onConfirm,
              ),
              const SizedBox(height: AppTheme.spaceSm),
              EtoileButton.outlined(
                label: 'Choisir une autre image',
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Step 3: Form (title + category)
// =============================================================================

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? selectedCategory;
  final String? selectedContractType;
  final String? errorMessage;
  final String publishType;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onContractTypeChanged;
  final VoidCallback onPublish;

  const _FormView({
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.selectedCategory,
    this.selectedContractType,
    required this.errorMessage,
    this.publishType = 'offer',
    required this.onCategoryChanged,
    required this.onContractTypeChanged,
    required this.onPublish,
  });

  bool get _isPoster => publishType == 'poster';
  bool get _isPresentation => publishType == 'presentation';

  @override
  Widget build(BuildContext context) {
    final formTitle = _isPresentation
        ? 'Details de la presentation'
        : _isPoster
            ? 'Details de l\'affiche'
            : 'Details de l\'offre';
    final formSubtitle = _isPresentation
        ? 'Decrivez votre entreprise pour attirer des candidats'
        : _isPoster
            ? 'Ajoutez un titre et une categorie pour votre affiche'
            : 'Ajoutez un titre et une categorie pour que les candidats trouvent votre offre';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formTitle,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              formSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyWarm,
                  ),
            ),
            const SizedBox(height: AppTheme.spaceLg),

            // Title
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: _isPresentation ? 'Titre de la presentation' : 'Titre du poste',
                hintText: _isPresentation
                    ? 'Ex: Decouvrez notre entreprise'
                    : 'Ex: Developpeur Flutter Senior',
                prefixIcon: Icon(_isPresentation ? Icons.business : Icons.work_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.errorFieldRequired;
                }
                if (value.trim().length < 3) {
                  return 'Le titre doit faire au moins 3 caracteres';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppTheme.spaceMd),

            // Description
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: _isPresentation
                    ? 'Presentez votre entreprise, vos valeurs...'
                    : _isPoster
                        ? 'Decrivez votre affiche...'
                        : 'Decrivez le poste, les missions, les avantages...',
                prefixIcon: const Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              maxLength: 500,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppTheme.spaceMd),

            // Sector (beta: 2 sectors from SectorConstants)
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Secteur',
                hintText: 'Selectionnez un secteur',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: SectorConstants.sectorOptions.map((code) {
                return DropdownMenuItem<String>(
                  value: code,
                  child: Text(SectorConstants.sectorLabels[code] ?? code),
                );
              }).toList(),
              onChanged: onCategoryChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Selectionnez un secteur';
                }
                return null;
              },
            ),

            // Contract type (only for offers/posters, not presentations)
            if (!_isPresentation) ...[
              const SizedBox(height: AppTheme.spaceMd),
              DropdownButtonFormField<String>(
                initialValue: selectedContractType,
                decoration: const InputDecoration(
                  labelText: 'Type de contrat',
                  hintText: 'Selectionnez un type de contrat',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'cdi', child: Text('CDI')),
                  DropdownMenuItem(value: 'cdd', child: Text('CDD')),
                  DropdownMenuItem(value: 'interim', child: Text('Interim')),
                  DropdownMenuItem(value: 'freelance', child: Text('Freelance')),
                  DropdownMenuItem(value: 'alternance', child: Text('Alternance')),
                  DropdownMenuItem(value: 'stage', child: Text('Stage')),
                ],
                onChanged: onContractTypeChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selectionnez un type de contrat';
                  }
                  return null;
                },
              ),
            ],

            // Error message
            if (errorMessage != null) ...[
              const SizedBox(height: AppTheme.spaceMd),
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: AppTheme.spaceSm),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppTheme.space2Xl),

            // Publish button
            EtoileButton(
              label: _isPresentation
                  ? 'Publier la presentation'
                  : _isPoster
                      ? 'Publier l\'affiche'
                      : 'Publier l\'offre',
              icon: Icons.upload,
              onPressed: onPublish,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Step 4: Uploading
// =============================================================================

class _UploadingView extends StatelessWidget {
  final int progress;

  const _UploadingView({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space2Xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress / 100,
                    strokeWidth: 6,
                    backgroundColor: AppColors.greyLight,
                    color: AppColors.primaryYellow,
                  ),
                  Center(
                    child: Text(
                      '$progress%',
                      style:
                          Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Text(
              'Publication en cours...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              'Votre offre est en train d\'etre mise en ligne',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyWarm,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Step 5: Success
// =============================================================================

class _SuccessView extends StatelessWidget {
  final String publishType;
  final VoidCallback onPublishAnother;
  final VoidCallback onGoToFeed;

  const _SuccessView({
    this.publishType = 'offer',
    required this.onPublishAnother,
    required this.onGoToFeed,
  });

  @override
  Widget build(BuildContext context) {
    final title = switch (publishType) {
      'presentation' => 'Presentation publiee !',
      'poster' => 'Affiche publiee !',
      _ => 'Offre publiee !',
    };
    final subtitle = switch (publishType) {
      'presentation' => 'Votre presentation est maintenant visible par les candidats',
      'poster' => 'Votre affiche est maintenant visible par les candidats',
      _ => 'Votre offre est maintenant visible par les candidats',
    };

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.black,
              size: 40,
            ),
          ),
          const SizedBox(height: AppTheme.spaceLg),
          Text(
            title,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.greyWarm,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.space2Xl),
          EtoileButton(
            label: 'Voir le feed',
            icon: Icons.home,
            onPressed: onGoToFeed,
          ),
          const SizedBox(height: AppTheme.spaceMd),
          EtoileButton.outlined(
            label: 'Publier autre chose',
            icon: Icons.add,
            onPressed: onPublishAnother,
          ),
        ],
      ),
    );
  }
}
