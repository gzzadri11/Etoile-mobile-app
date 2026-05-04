library;

/// Lecteur video pour les elements du feed.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';

/// Lecteur video avec autoplay, boucle et miniature.
///
/// Waits for preloaded controller from the manager. Falls back to creating
/// its own after a short timeout. Shows buffering progress while loading.
class FeedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final bool isActive;
  final VoidCallback? onVideoEnd;
  final VoidCallback? onVideoPlaying;
  final VideoPlayerController? externalController;
  final bool isExternalReady;

  const FeedVideoPlayer({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.isActive,
    this.onVideoEnd,
    this.onVideoPlaying,
    this.externalController,
    this.isExternalReady = false,
  });

  @override
  State<FeedVideoPlayer> createState() => _FeedVideoPlayerState();
}

class _FeedVideoPlayerState extends State<FeedVideoPlayer> {
  VideoPlayerController? _ownController;
  bool _isOwnInitialized = false;
  bool _isPlaying = false;
  bool _showControls = false;
  bool _hasError = false;
  bool _hasNotifiedPlaying = false;

  VideoPlayerController? get _controller =>
      widget.externalController ?? _ownController;

  bool get _isInitialized =>
      widget.externalController != null
          ? widget.isExternalReady
          : _isOwnInitialized;

  @override
  void initState() {
    super.initState();

    if (widget.externalController != null) {
      widget.externalController!.addListener(_videoListener);
      if (widget.isActive && widget.isExternalReady) {
        _playVideo();
      }
    } else {
      // No external controller — wait briefly, then create own
      _scheduleFallbackInit();
    }
  }

  void _scheduleFallbackInit() {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      if (widget.externalController == null && _ownController == null) {
        _initializeOwnVideo();
      }
    });
  }

  @override
  void didUpdateWidget(FeedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // External controller appeared or changed
    if (widget.externalController != oldWidget.externalController) {
      oldWidget.externalController?.removeListener(_videoListener);

      if (widget.externalController != null) {
        widget.externalController!.addListener(_videoListener);
        _disposeOwnController();
      } else if (widget.externalController == null && _ownController == null) {
        _scheduleFallbackInit();
      }
    }

    // Active state changed
    if (widget.isActive != oldWidget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.isActive) {
          _hasNotifiedPlaying = false;
          _playVideo();
        } else {
          _pauseVideo();
        }
      });
    }

    // External controller became ready
    if (widget.isExternalReady != oldWidget.isExternalReady) {
      if (widget.isActive && widget.isExternalReady) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _playVideo();
        });
      }
    }

    // Video URL changed
    if (widget.videoUrl != oldWidget.videoUrl &&
        widget.externalController == null) {
      _disposeOwnController();
      _hasNotifiedPlaying = false;
      _scheduleFallbackInit();
    }
  }

  Future<void> _initializeOwnVideo() async {
    try {
      _ownController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        httpHeaders: const {'Connection': 'keep-alive'},
      );

      await _ownController!.initialize();
      _ownController!.setLooping(true);
      _ownController!.addListener(_videoListener);

      if (mounted) {
        setState(() {
          _isOwnInitialized = true;
          _hasError = false;
        });

        if (widget.isActive) {
          _playVideo();
        }
      }
    } catch (e) {
      debugPrint('[FeedVideoPlayer] Init error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isOwnInitialized = false;
        });
      }
    }
  }

  void _videoListener() {
    final controller = _controller;
    if (controller == null) return;

    final isPlaying = controller.value.isPlaying;
    if (isPlaying != _isPlaying && mounted) {
      setState(() {
        _isPlaying = isPlaying;
      });
    }

    // Notify parent that video is playing (for preload trigger)
    if (isPlaying && !_hasNotifiedPlaying) {
      _hasNotifiedPlaying = true;
      widget.onVideoPlaying?.call();
    }

    // Trigger rebuild for buffering progress updates
    if (mounted) {
      setState(() {});
    }

    // Detect video end
    final position = controller.value.position;
    final duration = controller.value.duration;
    if (duration > Duration.zero && position >= duration) {
      widget.onVideoEnd?.call();
    }
  }

  void _playVideo() {
    final controller = _controller;
    if (controller != null && _isInitialized) {
      controller.play();
      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  void _pauseVideo() {
    final controller = _controller;
    if (controller != null) {
      controller.pause();
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;

    if (_isPlaying) {
      _pauseVideo();
    } else {
      _playVideo();
    }

    setState(() => _showControls = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _disposeOwnController() {
    _ownController?.removeListener(_videoListener);
    _ownController?.dispose();
    _ownController = null;
    _isOwnInitialized = false;
  }

  @override
  void dispose() {
    widget.externalController?.removeListener(_videoListener);
    _disposeOwnController();
    super.dispose();
  }

  bool get _isBuffering {
    final controller = _controller;
    if (controller == null || !_isInitialized) return false;
    return controller.value.isBuffering;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        color: AppColors.textPrimary,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video or thumbnail
            if (_isInitialized && _controller != null)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              )
            else if (_hasError)
              _buildErrorState()
            else
              _buildLoadingState(),

            // Buffering overlay (video initialized but still buffering)
            if (_isInitialized && _isBuffering)
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 3,
                ),
              ),

            // Play/Pause overlay
            if (_showControls) _buildPlayPauseOverlay(),

            // Progress bar at bottom
            if (_isInitialized && _controller != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildProgressBar(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.thumbnailUrl != null)
          CachedNetworkImage(
            imageUrl: widget.thumbnailUrl!,
            fit: BoxFit.cover,
            placeholder: (_, _) => const SizedBox.shrink(),
            errorWidget: (_, _, _) => const SizedBox.shrink(),
          ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppColors.accent,
              ),
              const SizedBox(height: 12),
              Text(
                'Chargement...',
                style: TextStyle(
                  color: AppColors.bgPrimary.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.thumbnailUrl != null)
          CachedNetworkImage(
            imageUrl: widget.thumbnailUrl!,
            fit: BoxFit.cover,
            errorWidget: (_, _, _) => Container(color: AppColors.textPrimary),
          )
        else
          Container(color: AppColors.textPrimary),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.bgPrimary.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 8),
              Text(
                'Impossible de lire la vidéo',
                style: TextStyle(
                  color: AppColors.bgPrimary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  setState(() => _hasError = false);
                  _initializeOwnVideo();
                },
                icon: const Icon(Icons.refresh, color: AppColors.bgPrimary),
                label: const Text(
                  'Réessayer',
                  style: TextStyle(color: AppColors.bgPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayPauseOverlay() {
    return Center(
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            size: 48,
            color: AppColors.bgPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return VideoProgressIndicator(
      _controller!,
      allowScrubbing: true,
      colors: VideoProgressColors(
        playedColor: AppColors.accent,
        bufferedColor: AppColors.border,
        backgroundColor: AppColors.textPrimary.withValues(alpha: 0.5),
      ),
      padding: EdgeInsets.zero,
    );
  }
}
