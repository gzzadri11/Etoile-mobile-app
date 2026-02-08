part of 'video_bloc.dart';

/// Base class for video events
sealed class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object?> get props => [];
}

/// Load current user's presentation video
class VideoLoadMyVideo extends VideoEvent {
  const VideoLoadMyVideo();
}

/// Recording has started
class VideoRecordingStarted extends VideoEvent {
  const VideoRecordingStarted();
}

/// Recording completed with file
class VideoRecordingCompleted extends VideoEvent {
  final File videoFile;
  final File? thumbnailFile;

  const VideoRecordingCompleted({
    required this.videoFile,
    this.thumbnailFile,
  });

  @override
  List<Object?> get props => [videoFile, thumbnailFile];
}

/// Request to upload video
class VideoUploadRequested extends VideoEvent {
  final File videoFile;
  final File? thumbnailFile;
  final String? categoryId;
  final String? title;
  final String? description;

  const VideoUploadRequested({
    required this.videoFile,
    this.thumbnailFile,
    this.categoryId,
    this.title,
    this.description,
  });

  @override
  List<Object?> get props => [videoFile, thumbnailFile, categoryId, title, description];
}

/// Request to publish video
class VideoPublishRequested extends VideoEvent {
  final String videoId;
  final String videoUrl;

  const VideoPublishRequested({
    required this.videoId,
    required this.videoUrl,
  });

  @override
  List<Object?> get props => [videoId, videoUrl];
}

/// Request to delete video
class VideoDeleteRequested extends VideoEvent {
  final String videoId;

  const VideoDeleteRequested({required this.videoId});

  @override
  List<Object?> get props => [videoId];
}
