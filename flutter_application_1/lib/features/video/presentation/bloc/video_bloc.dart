import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/video_model.dart';
import '../../data/repositories/video_repository.dart';

part 'video_event.dart';
part 'video_state.dart';

/// BLoC for managing video recording and upload
class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final VideoRepository _videoRepository;

  VideoBloc({required VideoRepository videoRepository})
      : _videoRepository = videoRepository,
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

  /// Upload video to R2
  Future<void> _onUploadRequested(
    VideoUploadRequested event,
    Emitter<VideoState> emit,
  ) async {
    emit(VideoUploading(progress: 0));

    try {
      // Generate keys
      final videoKey = _videoRepository.generateVideoKey();
      final thumbnailKey = _videoRepository.generateThumbnailKey(videoKey);

      // Create video entry in database
      final video = await _videoRepository.createVideo(
        type: 'presentation',
        videoKey: videoKey,
        categoryId: event.categoryId,
        title: event.title,
        description: event.description,
      );

      // TODO: Upload to R2
      // For now, simulate upload progress
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        emit(VideoUploading(progress: i * 10));
      }

      // TODO: Get actual URLs from R2
      final videoUrl = 'https://example.com/$videoKey';
      final thumbnailUrl = 'https://example.com/$thumbnailKey';

      // Update video with URLs
      final updatedVideo = await _videoRepository.updateVideoAfterUpload(
        videoId: video.id,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
      );

      emit(VideoUploadSuccess(video: updatedVideo));
    } catch (e) {
      emit(VideoError(message: 'Erreur upload: ${e.toString()}'));
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

  /// Delete video
  Future<void> _onDeleteRequested(
    VideoDeleteRequested event,
    Emitter<VideoState> emit,
  ) async {
    try {
      await _videoRepository.deleteVideo(event.videoId);
      emit(const VideoEmpty());
    } catch (e) {
      emit(VideoError(message: 'Erreur suppression: ${e.toString()}'));
    }
  }
}
