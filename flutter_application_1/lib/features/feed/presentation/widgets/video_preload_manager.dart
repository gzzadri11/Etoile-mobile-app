library;

/// Gestionnaire de prechargement video pour un defilement fluide.
///
/// Strategie : prioriser la bande passante de la video courante,
/// ne precharger la suivante qu'apres le debut de lecture.

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

/// Precharge la video suivante apres le debut de lecture de la courante.
class VideoPreloadManager extends ChangeNotifier {
  final Map<String, VideoPlayerController> _controllers = {};
  final Map<String, bool> _isInitialized = {};
  final List<String> _loadOrder = [];

  /// Current index the user is viewing
  int _currentIndex = -1;
  List<String?> _videoUrls = [];

  /// Whether we've started preloading the next video
  bool _nextPreloaded = false;

  /// Max controllers in cache (current + next + previous = 3)
  static const int _maxControllers = 4;

  /// Get cached controller for the given video URL
  VideoPlayerController? getController(String videoUrl) {
    return _controllers[videoUrl];
  }

  /// Check if controller is initialized and ready to play
  bool isReady(String videoUrl) {
    return _isInitialized[videoUrl] == true;
  }

  /// Called when user swipes to a new page.
  ///
  /// Immediately starts loading the current video. Does NOT preload
  /// next videos — that happens via [onCurrentVideoPlaying] once the
  /// current video has enough buffer to play smoothly.
  void onPageChanged({
    required int currentIndex,
    required List<String?> videoUrls,
  }) {
    _currentIndex = currentIndex;
    _videoUrls = videoUrls;
    _nextPreloaded = false;

    final currentUrl = _urlAt(currentIndex);
    if (currentUrl == null) return;

    // Priority: initialize current video immediately
    if (!_controllers.containsKey(currentUrl)) {
      _initializeController(currentUrl);
    }

    // Update LRU
    _loadOrder.remove(currentUrl);
    _loadOrder.add(currentUrl);

    // Pause all other videos
    for (final entry in _controllers.entries) {
      if (entry.key != currentUrl) {
        entry.value.pause();
      }
    }

    // Evict old controllers to free memory & network
    _evictOldControllers(currentIndex);
  }

  /// Call this when the current video starts playing (has enough buffer).
  /// Triggers preloading of the NEXT video only.
  void onCurrentVideoPlaying() {
    if (_nextPreloaded) return;
    _nextPreloaded = true;

    final nextUrl = _urlAt(_currentIndex + 1);
    if (nextUrl != null && !_controllers.containsKey(nextUrl)) {
      debugPrint('[VideoPreload] Current playing → preloading next');
      _initializeController(nextUrl);
      _loadOrder.remove(nextUrl);
      _loadOrder.add(nextUrl);
    }

    // Also ensure previous is cached (for back-swipe)
    final prevUrl = _urlAt(_currentIndex - 1);
    if (prevUrl != null && !_controllers.containsKey(prevUrl)) {
      _initializeController(prevUrl);
      _loadOrder.remove(prevUrl);
      _loadOrder.add(prevUrl);
    }
  }

  String? _urlAt(int index) {
    if (index < 0 || index >= _videoUrls.length) return null;
    final url = _videoUrls[index];
    return (url != null && url.isNotEmpty) ? url : null;
  }

  Future<void> _initializeController(String videoUrl) async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        httpHeaders: const {'Connection': 'keep-alive'},
      );

      _controllers[videoUrl] = controller;
      _isInitialized[videoUrl] = false;
      notifyListeners();

      await controller.initialize();

      // Verify controller still exists (might have been evicted)
      if (_controllers[videoUrl] != controller) {
        controller.dispose();
        return;
      }

      controller.setLooping(true);
      _isInitialized[videoUrl] = true;

      debugPrint('[VideoPreload] Ready: ${_shortUrl(videoUrl)}');
      notifyListeners();
    } catch (e) {
      debugPrint('[VideoPreload] Failed: ${_shortUrl(videoUrl)} — $e');
      final existing = _controllers[videoUrl];
      if (existing != null) {
        existing.dispose();
      }
      _controllers.remove(videoUrl);
      _isInitialized.remove(videoUrl);
    }
  }

  void _evictOldControllers(int currentIndex) {
    // Keep controllers for current, prev, next only
    final keepUrls = <String>{};
    for (final i in [currentIndex - 1, currentIndex, currentIndex + 1]) {
      final url = _urlAt(i);
      if (url != null) keepUrls.add(url);
    }

    while (_controllers.length > _maxControllers && _loadOrder.isNotEmpty) {
      final oldestUrl = _loadOrder.first;

      if (keepUrls.contains(oldestUrl)) {
        _loadOrder.removeAt(0);
        _loadOrder.add(oldestUrl);
        continue;
      }

      final controller = _controllers.remove(oldestUrl);
      controller?.dispose();
      _isInitialized.remove(oldestUrl);
      _loadOrder.removeAt(0);

      debugPrint('[VideoPreload] Evicted: ${_shortUrl(oldestUrl)}');
    }
  }

  /// Play a specific video and pause all others.
  void playVideo(String videoUrl) {
    for (final entry in _controllers.entries) {
      if (entry.key == videoUrl) {
        if (_isInitialized[entry.key] == true) {
          entry.value.play();
        }
      } else {
        entry.value.pause();
      }
    }
  }

  /// Pause all videos.
  void pauseAll() {
    for (final controller in _controllers.values) {
      controller.pause();
    }
  }

  String _shortUrl(String url) {
    return url.length > 60 ? '${url.substring(0, 60)}...' : url;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _isInitialized.clear();
    _loadOrder.clear();
    super.dispose();
  }
}
