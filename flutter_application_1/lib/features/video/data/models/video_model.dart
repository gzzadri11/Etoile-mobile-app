import 'package:equatable/equatable.dart';

/// Model representing a video
class Video extends Equatable {
  final String id;
  final String userId;
  final String type; // 'presentation' or 'offer'
  final String? categoryId;
  final String? title;
  final String? description;
  final String videoKey;
  final String? videoUrl;
  final String? thumbnailKey;
  final String? thumbnailUrl;
  final int durationSeconds;
  final int? fileSizeBytes;
  final String? resolution;
  final String status; // 'processing', 'active', 'suspended', 'deleted'
  final String? processingError;
  final int viewsCount;
  final int uniqueViewers;
  final DateTime? publishedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Video({
    required this.id,
    required this.userId,
    required this.type,
    this.categoryId,
    this.title,
    this.description,
    required this.videoKey,
    this.videoUrl,
    this.thumbnailKey,
    this.thumbnailUrl,
    this.durationSeconds = 40,
    this.fileSizeBytes,
    this.resolution,
    this.status = 'processing',
    this.processingError,
    this.viewsCount = 0,
    this.uniqueViewers = 0,
    this.publishedAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if video is active
  bool get isActive => status == 'active';

  /// Check if video is processing
  bool get isProcessing => status == 'processing';

  /// Check if video has error
  bool get hasError => processingError != null;

  /// Create from Supabase JSON
  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      categoryId: json['category_id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      videoKey: json['video_key'] as String,
      videoUrl: json['video_url'] as String?,
      thumbnailKey: json['thumbnail_key'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      durationSeconds: json['duration_seconds'] as int? ?? 40,
      fileSizeBytes: json['file_size_bytes'] as int?,
      resolution: json['resolution'] as String?,
      status: json['status'] as String? ?? 'processing',
      processingError: json['processing_error'] as String?,
      viewsCount: json['views_count'] as int? ?? 0,
      uniqueViewers: json['unique_viewers'] as int? ?? 0,
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase insert
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'type': type,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'video_key': videoKey,
      'video_url': videoUrl,
      'thumbnail_key': thumbnailKey,
      'thumbnail_url': thumbnailUrl,
      'duration_seconds': durationSeconds,
      'file_size_bytes': fileSizeBytes,
      'resolution': resolution,
      'status': status,
    };
  }

  /// Create a copy with updated fields
  Video copyWith({
    String? title,
    String? description,
    String? categoryId,
    String? videoUrl,
    String? thumbnailUrl,
    String? status,
    DateTime? publishedAt,
  }) {
    return Video(
      id: id,
      userId: userId,
      type: type,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      videoKey: videoKey,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailKey: thumbnailKey,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationSeconds: durationSeconds,
      fileSizeBytes: fileSizeBytes,
      resolution: resolution,
      status: status ?? this.status,
      processingError: processingError,
      viewsCount: viewsCount,
      uniqueViewers: uniqueViewers,
      publishedAt: publishedAt ?? this.publishedAt,
      expiresAt: expiresAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        categoryId,
        title,
        description,
        videoKey,
        videoUrl,
        status,
        viewsCount,
      ];
}
