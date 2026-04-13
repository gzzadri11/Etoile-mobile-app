library;

/// Service d'enregistrement video via la camera du device.
///
/// Gere l'initialisation camera, le demarrage/arret de l'enregistrement,
/// et la generation de thumbnail a partir d'une frame.

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Service d'enregistrement video camera.
class VideoRecordingService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isRecording = false;

  /// Vrai si la camera est initialisee et prete.
  bool get isInitialized => _isInitialized;

  /// Vrai si un enregistrement est en cours.
  bool get isRecording => _isRecording;

  /// Le controller camera courant (null si pas initialise).
  CameraController? get controller => _controller;

  /// Initialise la camera frontale (selfie) en qualite haute.
  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      throw CameraException('no_camera', 'Aucune camera disponible');
    }

    // Camera frontale en priorite (selfie video)
    final frontCamera = _cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.high, // 720p — bon compromis qualite/taille
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller!.initialize();
    _isInitialized = true;
  }

  /// Bascule entre camera frontale et arriere.
  Future<void> switchCamera() async {
    if (_cameras.length < 2 || _isRecording) return;

    final currentDirection = _controller?.description.lensDirection;
    final newCamera = _cameras.firstWhere(
      (c) => c.lensDirection != currentDirection,
      orElse: () => _cameras.first,
    );

    await _controller?.dispose();
    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await _controller!.initialize();
  }

  /// Demarre l'enregistrement video.
  Future<void> startRecording() async {
    if (_controller == null || !_isInitialized || _isRecording) return;
    await _controller!.startVideoRecording();
    _isRecording = true;
  }

  /// Arrete l'enregistrement et retourne le fichier video.
  Future<File> stopRecording() async {
    if (_controller == null || !_isRecording) {
      throw CameraException('not_recording', 'Aucun enregistrement en cours');
    }

    final xFile = await _controller!.stopVideoRecording();
    _isRecording = false;

    // Deplacer vers un chemin persistant avec extension .mp4
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final targetPath = p.join(dir.path, 'etoile_video_$timestamp.mp4');
    final file = File(xFile.path);
    final movedFile = await file.rename(targetPath);

    return movedFile;
  }

  /// Capture une frame en tant que thumbnail JPEG.
  Future<File?> captureThumbnail() async {
    if (_controller == null || !_isInitialized) return null;

    try {
      final xFile = await _controller!.takePicture();
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final targetPath = p.join(dir.path, 'etoile_thumb_$timestamp.jpg');
      final file = File(xFile.path);
      return await file.rename(targetPath);
    } catch (e) {
      debugPrint('[VideoRecordingService] Thumbnail capture failed: $e');
      return null;
    }
  }

  /// Libere les ressources camera.
  Future<void> dispose() async {
    _isRecording = false;
    _isInitialized = false;
    await _controller?.dispose();
    _controller = null;
  }
}
