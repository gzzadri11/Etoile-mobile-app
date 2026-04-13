library;

/// Page d'enregistrement video guide en 40 secondes.
///
/// Flux en 3 phases : presentation (0-10s), competences (10-30s),
/// conclusion (30-40s). Utilise la camera frontale du device.

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/video_recording_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/etoile_button.dart';
import '../../../../shared/widgets/profile_gate.dart';
import '../bloc/video_bloc.dart';

/// Page d'enregistrement video (3 phases, 40 secondes).
class VideoRecordPage extends StatefulWidget {
  const VideoRecordPage({super.key});

  @override
  State<VideoRecordPage> createState() => _VideoRecordPageState();
}

class _VideoRecordPageState extends State<VideoRecordPage>
    with TickerProviderStateMixin {
  _RecordingState _state = _RecordingState.preparation;
  int _currentPhase = 0;
  int _secondsRemaining = 0;
  late AnimationController _timerController;

  // Camera
  late VideoRecordingService _recordingService;
  bool _cameraReady = false;
  String? _cameraError;

  // Preview du fichier enregistre
  File? _recordedFile;
  VideoPlayerController? _previewController;
  bool _previewReady = false;

  final List<_VideoPhase> _phases = [
    _VideoPhase(
      prompt: AppStrings.phase1Prompt,
      duration: AppConfig.videoPhases[0],
      color: AppColors.primaryYellow,
    ),
    _VideoPhase(
      prompt: AppStrings.phase2Prompt,
      duration: AppConfig.videoPhases[1],
      color: AppColors.primaryOrange,
    ),
    _VideoPhase(
      prompt: AppStrings.phase3Prompt,
      duration: AppConfig.videoPhases[2],
      color: AppColors.primaryOrange,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _recordingService = VideoRecordingService();
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: AppConfig.videoDurationSeconds),
    );
    _timerController.addListener(_onTimerTick);
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      await _recordingService.initialize();
      if (mounted) {
        setState(() => _cameraReady = true);
      }
    } on CameraException catch (e) {
      if (mounted) {
        setState(() => _cameraError = _translateCameraError(e));
      }
    } catch (e) {
      debugPrint('[VideoRecordPage] Camera init error: $e');
      if (mounted) {
        setState(() => _cameraError = 'Impossible d\'initialiser la camera');
      }
    }
  }

  String _translateCameraError(CameraException e) {
    if (e.code == 'no_camera') {
      return 'Aucune camera detectee sur cet appareil';
    }
    if (e.description?.contains('permission') == true ||
        e.code == 'CameraAccessDenied' ||
        e.code == 'AudioAccessDenied') {
      return 'Autorisez l\'acces a la camera et au micro dans les parametres';
    }
    return 'Erreur camera : ${e.description ?? e.code}';
  }

  @override
  void dispose() {
    _timerController.dispose();
    _recordingService.dispose();
    _previewController?.dispose();
    super.dispose();
  }

  void _onTimerTick() {
    final elapsed =
        (_timerController.value * AppConfig.videoDurationSeconds).floor();
    final remaining = AppConfig.videoDurationSeconds - elapsed;

    if (remaining != _secondsRemaining) {
      setState(() {
        _secondsRemaining = remaining;
        _updatePhase(elapsed);
      });
    }

    if (_timerController.isCompleted) {
      _onRecordingComplete();
    }
  }

  void _updatePhase(int elapsed) {
    int phaseStart = 0;
    for (int i = 0; i < _phases.length; i++) {
      final phaseEnd = phaseStart + _phases[i].duration;
      if (elapsed < phaseEnd) {
        if (_currentPhase != i) {
          setState(() => _currentPhase = i);
        }
        return;
      }
      phaseStart = phaseEnd;
    }
  }

  Future<void> _startRecording() async {
    final allowed = await checkProfileGate(context);
    if (!allowed || !mounted) return;

    try {
      await _recordingService.startRecording();
      if (!mounted) return;
      setState(() {
        _state = _RecordingState.recording;
        _secondsRemaining = AppConfig.videoDurationSeconds;
        _currentPhase = 0;
      });
      _timerController.forward();
    } catch (e) {
      debugPrint('[VideoRecordPage] Start recording error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de demarrer l\'enregistrement')),
        );
      }
    }
  }

  Future<void> _cancelRecording() async {
    _timerController.stop();
    _timerController.reset();
    try {
      if (_recordingService.isRecording) {
        await _recordingService.stopRecording();
      }
    } catch (_) {
      // Ignore — on annule
    }
    if (mounted) {
      setState(() {
        _state = _RecordingState.preparation;
        _recordedFile = null;
      });
    }
  }

  Future<void> _onRecordingComplete() async {
    try {
      final file = await _recordingService.stopRecording();
      if (!mounted) return;
      _recordedFile = file;
      await _initPreview(file);
      setState(() => _state = _RecordingState.preview);
    } catch (e) {
      debugPrint('[VideoRecordPage] Stop recording error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la finalisation de la video')),
        );
        setState(() => _state = _RecordingState.preparation);
      }
    }
  }

  Future<void> _initPreview(File file) async {
    _previewController?.dispose();
    _previewController = VideoPlayerController.file(file);
    await _previewController!.initialize();
    _previewController!.setLooping(true);
    _previewController!.play();
    if (mounted) setState(() => _previewReady = true);
  }

  Future<void> _reRecord() async {
    _timerController.reset();
    _previewController?.dispose();
    _previewController = null;
    _previewReady = false;

    // Supprimer le fichier temporaire
    if (_recordedFile != null) {
      try {
        await _recordedFile!.delete();
      } catch (_) {}
    }
    _recordedFile = null;

    if (mounted) {
      setState(() {
        _state = _RecordingState.preparation;
        _currentPhase = 0;
      });
    }
  }

  Future<void> _publishVideo() async {
    if (_recordedFile == null) return;

    // Capturer thumbnail avant de quitter la preview
    File? thumbnail;
    try {
      thumbnail = await _recordingService.captureThumbnail();
    } catch (_) {
      // Pas de thumbnail — pas bloquant
    }

    if (!mounted) return;

    // Dispatch upload vers le BLoC
    context.read<VideoBloc>().add(VideoUploadRequested(
          videoFile: _recordedFile!,
          thumbnailFile: thumbnail,
          type: 'presentation',
        ));

    setState(() => _state = _RecordingState.uploading);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: BlocListener<VideoBloc, VideoState>(
          listener: (context, state) {
            if (state is VideoUploadSuccess) {
              setState(() => _state = _RecordingState.success);
            } else if (state is VideoError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              setState(() => _state = _RecordingState.preview);
            }
          },
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_state) {
      case _RecordingState.preparation:
        return _PreparationView(
          cameraReady: _cameraReady,
          cameraError: _cameraError,
          controller: _recordingService.controller,
          onStart: _startRecording,
          onClose: () => context.go(AppRoutes.search),
          onRetryCamera: _initCamera,
          onSwitchCamera: () async {
            await _recordingService.switchCamera();
            if (mounted) setState(() {});
          },
        );
      case _RecordingState.recording:
        return _RecordingView(
          controller: _recordingService.controller,
          phase: _phases[_currentPhase],
          phaseIndex: _currentPhase,
          totalPhases: _phases.length,
          secondsRemaining: _secondsRemaining,
          progress: _timerController.value,
          onCancel: _cancelRecording,
        );
      case _RecordingState.preview:
        return _PreviewView(
          previewController: _previewController,
          previewReady: _previewReady,
          onReRecord: _reRecord,
          onPublish: _publishVideo,
        );
      case _RecordingState.uploading:
        return BlocBuilder<VideoBloc, VideoState>(
          builder: (context, state) {
            final progress =
                state is VideoUploading ? state.progress : 0;
            return _UploadingView(progress: progress);
          },
        );
      case _RecordingState.success:
        return _SuccessView(
          onViewProfile: () => context.go(AppRoutes.profile),
          onExploreFeed: () => context.go(AppRoutes.search),
        );
    }
  }
}

enum _RecordingState {
  preparation,
  recording,
  preview,
  uploading,
  success,
}

class _VideoPhase {
  final String prompt;
  final int duration;
  final Color color;

  _VideoPhase({
    required this.prompt,
    required this.duration,
    required this.color,
  });
}

// ---------------------------------------------------------------------------
// Sous-vues
// ---------------------------------------------------------------------------

/// Vue camera (utilisee par preparation et recording).
class _CameraPreviewWidget extends StatelessWidget {
  final CameraController? controller;

  const _CameraPreviewWidget({this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container(color: AppColors.black);
    }
    // Remplir l'ecran avec crop au centre
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller!.value.previewSize?.height ?? 1,
          height: controller!.value.previewSize?.width ?? 1,
          child: CameraPreview(controller!),
        ),
      ),
    );
  }
}

/// Vue de preparation avant enregistrement.
class _PreparationView extends StatelessWidget {
  final bool cameraReady;
  final String? cameraError;
  final CameraController? controller;
  final VoidCallback onStart;
  final VoidCallback onClose;
  final VoidCallback onRetryCamera;
  final VoidCallback onSwitchCamera;

  const _PreparationView({
    required this.cameraReady,
    required this.cameraError,
    required this.controller,
    required this.onStart,
    required this.onClose,
    required this.onRetryCamera,
    required this.onSwitchCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview ou erreur
        if (cameraReady)
          _CameraPreviewWidget(controller: controller)
        else if (cameraError != null)
          _CameraErrorWidget(
            error: cameraError!,
            onRetry: onRetryCamera,
          )
        else
          const Center(
            child: CircularProgressIndicator(color: AppColors.primaryYellow),
          ),

        // Bouton fermer
        Positioned(
          top: AppTheme.spaceMd,
          left: AppTheme.spaceMd,
          child: IconButton(
            icon: const Icon(Icons.close, color: AppColors.white),
            onPressed: onClose,
          ),
        ),

        // Bouton switch camera
        if (cameraReady)
          Positioned(
            top: AppTheme.spaceMd,
            right: AppTheme.spaceMd,
            child: IconButton(
              icon: const Icon(Icons.cameraswitch, color: AppColors.white),
              onPressed: onSwitchCamera,
            ),
          ),

        // Contenu bas
        Positioned(
          left: AppTheme.spaceMd,
          right: AppTheme.spaceMd,
          bottom: AppTheme.spaceLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Astuce
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.primaryYellow,
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    Expanded(
                      child: Text(
                        AppStrings.videoTip,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.white,
                                ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // Bouton demarrer
              EtoileButton(
                label: AppStrings.startRecording,
                icon: Icons.videocam,
                onPressed: cameraReady ? onStart : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget d'erreur camera avec retry.
class _CameraErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _CameraErrorWidget({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.videocam_off,
                size: 64,
                color: AppColors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppTheme.spaceMd),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.white,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spaceLg),
              EtoileButton.outlined(
                label: 'Reessayer',
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vue d'enregistrement avec timer et prompts.
class _RecordingView extends StatelessWidget {
  final CameraController? controller;
  final _VideoPhase phase;
  final int phaseIndex;
  final int totalPhases;
  final int secondsRemaining;
  final double progress;
  final VoidCallback onCancel;

  const _RecordingView({
    required this.controller,
    required this.phase,
    required this.phaseIndex,
    required this.totalPhases,
    required this.secondsRemaining,
    required this.progress,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        _CameraPreviewWidget(controller: controller),

        // Bouton annuler
        Positioned(
          top: AppTheme.spaceMd,
          left: AppTheme.spaceMd,
          child: TextButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.close, color: AppColors.white),
            label: const Text(
              'Annuler',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ),

        // Indicateur REC
        Positioned(
          top: AppTheme.spaceMd,
          right: AppTheme.spaceMd,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceSm,
              vertical: AppTheme.spaceXs,
            ),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'REC',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Contenu bas
        Positioned(
          left: AppTheme.spaceMd,
          right: AppTheme.spaceMd,
          bottom: AppTheme.spaceLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Prompt de la phase
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Text(
                  phase.prompt,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppTheme.spaceMd),

              // Indicateur de phase (dots)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalPhases, (index) {
                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index <= phaseIndex
                          ? AppColors.primaryYellow
                          : AppColors.white.withValues(alpha: 0.3),
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppTheme.spaceSm),

              Text(
                'Phase ${phaseIndex + 1}/$totalPhases',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
              ),

              const SizedBox(height: AppTheme.spaceMd),

              // Barre de progression
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.white.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(phase.color),
                  minHeight: 4,
                ),
              ),

              const SizedBox(height: AppTheme.spaceMd),

              // Timer
              Text(
                secondsRemaining.toString().padLeft(2, '0'),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Vue de preview de la video enregistree.
class _PreviewView extends StatelessWidget {
  final VideoPlayerController? previewController;
  final bool previewReady;
  final VoidCallback onReRecord;
  final VoidCallback onPublish;

  const _PreviewView({
    required this.previewController,
    required this.previewReady,
    required this.onReRecord,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video preview
        if (previewReady && previewController != null)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: previewController!.value.size.width,
                height: previewController!.value.size.height,
                child: VideoPlayer(previewController!),
              ),
            ),
          )
        else
          Container(
            color: AppColors.black,
            child: const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primaryYellow),
            ),
          ),

        // Boutons bas
        Positioned(
          left: AppTheme.spaceMd,
          right: AppTheme.spaceMd,
          bottom: AppTheme.spaceLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EtoileButton(
                label: AppStrings.publishVideo,
                icon: Icons.upload,
                onPressed: onPublish,
              ),
              const SizedBox(height: AppTheme.spaceMd),
              EtoileButton.outlined(
                label: AppStrings.reRecord,
                icon: Icons.refresh,
                onPressed: onReRecord,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Vue d'upload en cours.
class _UploadingView extends StatelessWidget {
  final int progress;

  const _UploadingView({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ColoredBox(
        color: AppColors.black,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress > 0 ? progress / 100 : null,
                  color: AppColors.primaryYellow,
                  strokeWidth: 6,
                ),
              ),
              const SizedBox(height: AppTheme.spaceLg),
              Text(
                'Publication en cours...',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                    ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                '$progress%',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.primaryYellow,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vue de succes apres publication.
class _SuccessView extends StatelessWidget {
  final VoidCallback onViewProfile;
  final VoidCallback onExploreFeed;

  const _SuccessView({
    required this.onViewProfile,
    required this.onExploreFeed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.black,
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
            'Bravo !',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.white,
                ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            AppStrings.successVideoPublished,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.space2Xl),
          EtoileButton(
            label: 'Voir mon profil',
            onPressed: onViewProfile,
          ),
          const SizedBox(height: AppTheme.spaceMd),
          TextButton(
            onPressed: onExploreFeed,
            child: Text(
              'Explorer le feed',
              style:
                  TextStyle(color: AppColors.white.withValues(alpha: 0.7)),
            ),
          ),
        ],
      ),
    );
  }
}
