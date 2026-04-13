library;

/// BLoC de gestion des videos (upload, publication, suppression).

import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/video_upload_service.dart';
import '../../data/models/video_model.dart';
import '../../data/repositories/video_repository.dart';

part 'video_event.dart';
part 'video_state.dart';

/// BLoC for managing video recording and upload
class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final VideoRepository _videoRepository;
  final VideoUploadService _uploadService;

  VideoBloc({
    required VideoRepository videoRepository,
    required VideoUploadService uploadService,
  })  : _videoRepository = videoRepository,
        _uploadService = uploadService,
        super(const VideoInitial()) {
    on<VideoLoadMyVideo>(_onLoadMyVideo);
    on<VideoRecordingStarted>(_onRecordingStarted);
    on<VideoRecordingCompleted>(_onRecordingCompleted);
    on<VideoUploadRequested>(_onUploadRequested);
    on<VideoPublishRequested>(_onPublishRequested);
    on<VideoDeleteRequested>(_onDeleteRequested);
  }

  /// Load current user's presentation video
  Future<void> _onLoadMyVideo(
    VideoLoadMyVideo event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoLoading());

    try {
      final video = await _videoRepository.getMyPresentationVideo();
      if (video != null) {
        emit(VideoLoaded(video: video));
      } else {
        emit(const VideoEmpty());
      }
    } catch (e) {
      emit(VideoError(message: 'Erreur: ${e.toString()}'));
    }
  }

  /// Recording started
  Future<void> _onRecordingStarted(
    VideoRecordingStarted event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoRecording());
  }

  /// Recording completed, file is ready
  Future<void> _onRecordingCompleted(
    VideoRecordingCompleted event,
    Emitter<VideoState> emit,
  ) async {
    emit(VideoRecordingComplete(
      videoFile: event.videoFile,
      thumbnailFile: event.thumbnailFile,
    ));
  }

  /// Upload video to R2 via Cloudflare Worker
  Future<void> _onUploadRequested(
    VideoUploadRequested event,
    Emitter<VideoState> emit,
  ) async {
    emit(VideoUploading(progress: 0));

    try {
      // Read file bytes
      final videoBytes = await event.videoFile.readAsBytes();

      // Upload video to R2
      final videoResult = await _uploadService.uploadVideo(
        fileBytes: videoBytes,
        filename: event.videoFile.path.split('/').last,
        onProgress: (progress) {
          // Weight: video = 90% of total progress
          emit(VideoUploading(progress: (progress * 0.9).round()));
        },
      );

      // Upload thumbnail if available
      String? thumbnailUrl;
      if (event.thumbnailFile != null) {
        final thumbBytes = await event.thumbnailFile!.readAsBytes();
        final thumbResult = await _uploadService.uploadThumbnail(
          fileBytes: thumbBytes,
          filename: event.thumbnailFile!.path.split('/').last,
        );
        thumbnailUrl = thumbResult.url;
      }

      emit(VideoUploading(progress: 95));

      // Create video entry in database
      final video = await _videoRepository.createVideo(
        type: event.type ?? 'presentation',
        videoKey: videoResult.key,
        categoryId: event.categoryId,
        title: event.title,
        description: event.description,
        fileSizeBytes: videoResult.size,
      );

      // Update with public URLs and set active
      final updatedVideo = await _videoRepository.updateVideoAfterUpload(
        videoId: video.id,
        videoUrl: videoResult.url,
        thumbnailUrl: thumbnailUrl,
      );

      emit(VideoUploadSuccess(video: updatedVideo));
    } catch (e, stackTrace) {
      debugPrint('[VideoBloc] Upload error: $e');
      debugPrint('[VideoBloc] Stack trace: $stackTrace');
      emit(VideoError(message: 'Erreur upload: $e'));
    }
  }

  /// Publish video (make it visible)
  Future<void> _onPublishRequested(
    VideoPublishRequested event,
    Emitter<VideoState> emit,
  ) async {
    emit(const VideoPublishing());

    try {
      final video = await _videoRepository.updateVideoAfterUpload(
        videoId: event.videoId,
        videoUrl: event.videoUrl,
      );
      emit(VideoPublishSuccess(video: video));
    } catch (e) {
      emit(VideoError(message: 'Erreur publication: ${e.toString()}'));
    }
  }

  /// Delete video (soft delete in DB + delete from R2)
  Future<void> _onDeleteRequested(
    VideoDeleteRequested event,
    Emitter<VideoState> emit,
  ) async {
    try {
      // Soft delete in DB
      await _videoRepository.deleteVideo(event.videoId);

      // Delete from R2 if key is provided
      if (event.videoKey != null) {
        try {
          await _uploadService.deleteFile(
            key: event.videoKey!,
            type: 'video',
          );
        } catch (e) {
          debugPrint('[VideoBloc] R2 delete failed (non-blocking): $e');
        }
      }

      emit(const VideoEmpty());
    } catch (e) {
      emit(VideoError(message: 'Erreur suppression: ${e.toString()}'));
    }
  }
}
