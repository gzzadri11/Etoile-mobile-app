part of 'video_bloc.dart';

/// Base class for video states
sealed class VideoState extends Equatable {
  const VideoState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class VideoInitial extends VideoState {
  const VideoInitial();
}

/// Loading video
class VideoLoading extends VideoState {
  const VideoLoading();
}

/// No video exists yet
class VideoEmpty extends VideoState {
  const VideoEmpty();
}

/// Video loaded
class VideoLoaded extends VideoState {
  final Video video;

  const VideoLoaded({required this.video});

  @override
  List<Object?> get props => [video];
}

/// Currently recording
class VideoRecording extends VideoState {
  const VideoRecording();
}

/// Recording complete, ready for preview
class VideoRecordingComplete extends VideoState {
  final File videoFile;
  final File? thumbnailFile;

  const VideoRecordingComplete({
    required this.videoFile,
    this.thumbnailFile,
  });

  @override
  List<Object?> get props => [videoFile, thumbnailFile];
}

/// Uploading video
class VideoUploading extends VideoState {
  final int progress; // 0-100

  const VideoUploading({required this.progress});

  @override
  List<Object?> get props => [progress];
}

/// Upload successful
class VideoUploadSuccess extends VideoState {
  final Video video;

  const VideoUploadSuccess({required this.video});

  @override
  List<Object?> get props => [video];
}

/// Publishing video
class VideoPublishing extends VideoState {
  const VideoPublishing();
}

/// Publish successful
class VideoPublishSuccess extends VideoState {
  final Video video;

  const VideoPublishSuccess({required this.video});

  @override
  List<Object?> get props => [video];
}

/// Error state
class VideoError extends VideoState {
  final String message;

  const VideoError({required this.message});

  @override
  List<Object?> get props => [message];
}
