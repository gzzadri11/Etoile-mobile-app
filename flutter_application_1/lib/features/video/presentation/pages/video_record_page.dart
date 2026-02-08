import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/etoile_button.dart';

/// Video recording page
///
/// Implements the guided 40-second video recording flow:
/// - Phase 1 (0-10s): Introduction
/// - Phase 2 (10-30s): Skills
/// - Phase 3 (30-40s): Conclusion
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
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: AppConfig.videoDurationSeconds),
    );
    _timerController.addListener(_onTimerTick);
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  void _onTimerTick() {
    final elapsed = (_timerController.value * AppConfig.videoDurationSeconds).floor();
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

  void _startRecording() {
    setState(() {
      _state = _RecordingState.recording;
      _secondsRemaining = AppConfig.videoDurationSeconds;
      _currentPhase = 0;
    });
    _timerController.forward();
  }

  void _cancelRecording() {
    _timerController.stop();
    _timerController.reset();
    setState(() {
      _state = _RecordingState.preparation;
    });
  }

  void _onRecordingComplete() {
    setState(() {
      _state = _RecordingState.preview;
    });
  }

  void _reRecord() {
    _timerController.reset();
    setState(() {
      _state = _RecordingState.preparation;
      _currentPhase = 0;
    });
  }

  void _publishVideo() {
    // TODO: Implement video upload
    setState(() {
      _state = _RecordingState.success;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_state) {
      case _RecordingState.preparation:
        return _PreparationView(
          onStart: _startRecording,
          onClose: () => Navigator.of(context).pop(),
        );
      case _RecordingState.recording:
        return _RecordingView(
          phase: _phases[_currentPhase],
          phaseIndex: _currentPhase,
          totalPhases: _phases.length,
          secondsRemaining: _secondsRemaining,
          progress: _timerController.value,
          onCancel: _cancelRecording,
        );
      case _RecordingState.preview:
        return _PreviewView(
          onReRecord: _reRecord,
          onPublish: _publishVideo,
        );
      case _RecordingState.success:
        return _SuccessView(
          onViewProfile: () => Navigator.of(context).pop(),
          onExploreFeed: () => Navigator.of(context).pop(),
        );
    }
  }
}

enum _RecordingState {
  preparation,
  recording,
  preview,
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

/// Preparation view before recording
class _PreparationView extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onClose;

  const _PreparationView({
    required this.onStart,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview placeholder
        Container(
          color: AppColors.black,
          child: Center(
            child: Icon(
              Icons.person,
              size: 120,
              color: AppColors.white.withOpacity(0.3),
            ),
          ),
        ),

        // Close button
        Positioned(
          top: AppTheme.spaceMd,
          left: AppTheme.spaceMd,
          child: IconButton(
            icon: const Icon(Icons.close, color: AppColors.white),
            onPressed: onClose,
          ),
        ),

        // Help button
        Positioned(
          top: AppTheme.spaceMd,
          right: AppTheme.spaceMd,
          child: IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.white),
            onPressed: () {
              // Show help
            },
          ),
        ),

        // Bottom content
        Positioned(
          left: AppTheme.spaceMd,
          right: AppTheme.spaceMd,
          bottom: AppTheme.spaceLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tip
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.1),
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.white,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // Start button
              EtoileButton(
                label: AppStrings.startRecording,
                icon: Icons.videocam,
                onPressed: onStart,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Recording view with timer and prompts
class _RecordingView extends StatelessWidget {
  final _VideoPhase phase;
  final int phaseIndex;
  final int totalPhases;
  final int secondsRemaining;
  final double progress;
  final VoidCallback onCancel;

  const _RecordingView({
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
        // Camera preview placeholder
        Container(
          color: AppColors.black,
          child: Center(
            child: Icon(
              Icons.person,
              size: 120,
              color: AppColors.white.withOpacity(0.3),
            ),
          ),
        ),

        // Cancel button
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

        // Recording indicator
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

        // Bottom content
        Positioned(
          left: AppTheme.spaceMd,
          right: AppTheme.spaceMd,
          bottom: AppTheme.spaceLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Prompt
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.1),
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

              // Phase indicator
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
                          : AppColors.white.withOpacity(0.3),
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppTheme.spaceSm),

              Text(
                'Phase ${phaseIndex + 1}/$totalPhases',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.white.withOpacity(0.7),
                    ),
              ),

              const SizedBox(height: AppTheme.spaceMd),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.white.withOpacity(0.3),
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

/// Preview view after recording
class _PreviewView extends StatelessWidget {
  final VoidCallback onReRecord;
  final VoidCallback onPublish;

  const _PreviewView({
    required this.onReRecord,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video preview placeholder
        Container(
          color: AppColors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_filled,
                  size: 64,
                  color: AppColors.white.withOpacity(0.7),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                Text(
                  'Apercu de votre video',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.white,
                      ),
                ),
              ],
            ),
          ),
        ),

        // Bottom buttons
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

/// Success view after publishing
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
          // Success icon
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
                  color: AppColors.white.withOpacity(0.8),
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
              style: TextStyle(color: AppColors.white.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }
}
