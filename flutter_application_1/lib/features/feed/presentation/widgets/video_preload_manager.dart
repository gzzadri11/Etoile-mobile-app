import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

/// Manages video preloading for smooth feed scrolling
/// Keeps a cache of initialized video controllers for nearby videos
class VideoPreloadManager {
  final int preloadCount;
  final Map<String, VideoPlayerController> _controllers = {};
  final Map<String, bool> _isInitialized = {};
  final List<String> _loadOrder = []; // Track order for LRU eviction

  VideoPreloadManager({this.preloadCount = 2});

  /// Get or create a controller for the given video URL
  /// Returns null if not yet initialized (will trigger async init)
  VideoPlayerController? getController(String videoUrl) {
    return _controllers[videoUrl];
  }

  /// Check if controller is initialized and ready
  bool isReady(String videoUrl) {
    return _isInitialized[videoUrl] == true;
  }

  /// Preload videos around the current index
  Future<void> preloadAround({
    required int currentIndex,
    required List<String?> videoUrls,
  }) async {
    // Calculate which indexes to preload
    final indexesToPreload = <int>[];

    // Current video (highest priority)
    indexesToPreload.add(currentIndex);

    // Next videos
    for (int i = 1; i <= preloadCount; i++) {
      if (currentIndex + i < videoUrls.length) {
        indexesToPreload.add(currentIndex + i);
      }
    }

    // Previous video (for back-swiping)
    if (currentIndex > 0) {
      indexesToPreload.add(currentIndex - 1);
    }

    // Get URLs to preload
    final urlsToPreload = <String>[];
    for (final index in indexesToPreload) {
      final url = videoUrls[index];
      if (url != null && url.isNotEmpty) {
        urlsToPreload.add(url);
      }
    }

    // Initialize controllers for URLs that don't have one yet
    for (final url in urlsToPreload) {
      if (!_controllers.containsKey(url)) {
        await _initializeController(url);
      }
      // Update load order (move to end = most recently used)
      _loadOrder.remove(url);
      _loadOrder.add(url);
    }

    // Evict old controllers if we have too many
    _evictOldControllers(urlsToPreload);
  }

  Future<void> _initializeController(String videoUrl) async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );

      _controllers[videoUrl] = controller;
      _isInitialized[videoUrl] = false;

      await controller.initialize();
      controller.setLooping(true);

      _isInitialized[videoUrl] = true;

      debugPrint('[VideoPreload] Initialized: ${videoUrl.substring(0, 50)}...');
    } catch (e) {
      debugPrint('[VideoPreload] Failed to initialize: $e');
      _controllers.remove(videoUrl);
      _isInitialized.remove(videoUrl);
    }
  }

  void _evictOldControllers(List<String> keepUrls) {
    // Keep at most (preloadCount * 2 + 1) controllers
    final maxControllers = preloadCount * 2 + 2;

    while (_controllers.length > maxControllers && _loadOrder.isNotEmpty) {
      final oldestUrl = _loadOrder.first;

      // Don't evict if it's in the keep list
      if (keepUrls.contains(oldestUrl)) {
        _loadOrder.removeAt(0);
        _loadOrder.add(oldestUrl); // Move to end
        continue;
      }

      // Dispose and remove
      final controller = _controllers.remove(oldestUrl);
      controller?.dispose();
      _isInitialized.remove(oldestUrl);
      _loadOrder.removeAt(0);

      debugPrint('[VideoPreload] Evicted: ${oldestUrl.substring(0, 50)}...');
    }
  }

  /// Play a specific video (pause all others)
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

  /// Pause all videos
  void pauseAll() {
    for (final controller in _controllers.values) {
      controller.pause();
    }
  }

  /// Dispose all controllers
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _isInitialized.clear();
    _loadOrder.clear();
  }
}
