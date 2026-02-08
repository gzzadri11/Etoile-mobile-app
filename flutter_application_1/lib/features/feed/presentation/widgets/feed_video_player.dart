import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';

/// Video player widget for feed items
/// Handles autoplay, pause on swipe, and tap to play/pause
/// Can use an external controller (for preloading) or create its own
class FeedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final bool isActive;
  final VoidCallback? onVideoEnd;
  final VideoPlayerController? externalController;
  final bool isExternalReady;

  const FeedVideoPlayer({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.isActive,
    this.onVideoEnd,
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

  VideoPlayerController? get _controller =>
      widget.externalController ?? _ownController;

  bool get _isInitialized =>
      widget.externalController != null
          ? widget.isExternalReady
          : _isOwnInitialized;

  @override
  void initState() {
    super.initState();
    // Only create own controller if no external one provided
    if (widget.externalController == null) {
      _initializeOwnVideo();
    } else if (widget.isActive && widget.isExternalReady) {
      _playVideo();
    }
  }

  @override
  void didUpdateWidget(FeedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle external controller changes
    if (widget.externalController != oldWidget.externalController) {
      if (widget.externalController != null) {
        // Dispose own controller if we now have an external one
        _disposeOwnController();
      } else if (widget.externalController == null && _ownController == null) {
        // Create own controller if external was removed
        _initializeOwnVideo();
      }
    }

    // Handle active state changes - defer to avoid setState during build
    if (widget.isActive != oldWidget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.isActive) {
          _playVideo();
        } else {
          _pauseVideo();
        }
      });
    }

    // Handle external ready state changes - defer to avoid setState during build
    if (widget.isExternalReady != oldWidget.isExternalReady) {
      if (widget.isActive && widget.isExternalReady) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _playVideo();
        });
      }
    }

    // Handle video URL changes (only for own controller)
    if (widget.videoUrl != oldWidget.videoUrl &&
        widget.externalController == null) {
      _disposeOwnController();
      _initializeOwnVideo();
    }
  }

  Future<void> _initializeOwnVideo() async {
    try {
      _ownController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
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

    if (controller.value.position >= controller.value.duration) {
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

    setState(() {
      _showControls = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
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
    // Only dispose our own controller, not external ones
    _disposeOwnController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        color: AppColors.black,
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

            // Play/Pause overlay - only show when user taps (not on pause from scroll)
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
          Image.network(
            widget.thumbnailUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryYellow,
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
          Image.network(
            widget.thumbnailUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: AppColors.black),
          )
        else
          Container(color: AppColors.black),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 8),
              Text(
                'Impossible de lire la vidéo',
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                  });
                  _initializeOwnVideo();
                },
                icon: const Icon(Icons.refresh, color: AppColors.white),
                label: const Text(
                  'Réessayer',
                  style: TextStyle(color: AppColors.white),
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
            color: AppColors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            size: 48,
            color: AppColors.white,
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
        playedColor: AppColors.primaryYellow,
        bufferedColor: AppColors.greyMedium,
        backgroundColor: AppColors.black.withValues(alpha: 0.5),
      ),
      padding: EdgeInsets.zero,
    );
  }
}
