import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../errors/failures.dart';
import 'supabase_service.dart';

/// Service for interacting with Cloudflare R2 storage via the video worker
///
/// Handles:
/// - Requesting presigned URLs for upload
/// - Uploading videos and thumbnails with progress tracking
/// - Getting public URLs for stored content
/// - Deleting content
class R2Service {
  final Dio _dio;
  final SupabaseService _supabaseService;

  R2Service({
    required SupabaseService supabaseService,
  }) : _supabaseService = supabaseService,
       _dio = Dio(
         BaseOptions(
           baseUrl: AppConfig.r2BaseUrl,
           connectTimeout: const Duration(seconds: 30),
           receiveTimeout: const Duration(minutes: 5),
           sendTimeout: const Duration(minutes: 5),
         ),
       ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Add logging in debug mode
    if (kDebugMode && AppConfig.enableDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false, // Don't log binary data
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (log) => debugPrint('[R2] $log'),
        ),
      );
    }
  }

  /// Get authorization headers with current JWT token
  Map<String, String> _getAuthHeaders() {
    final session = _supabaseService.currentSession;
    if (session == null) {
      throw const AuthFailure(message: 'Not authenticated');
    }
    return {
      'Authorization': 'Bearer ${session.accessToken}',
      'Content-Type': 'application/json',
    };
  }

  // ===========================================================================
  // PRESIGNED URL
  // ===========================================================================

  /// Request a presigned URL for uploading a file
  ///
  /// Returns [PresignedUrlResponse] with upload URL and file key.
  Future<PresignedUrlResponse> getPresignedUploadUrl({
    required String filename,
    required String contentType,
    required FileType type,
    String? category,
  }) async {
    try {
      final response = await _dio.post(
        '/presigned-url',
        data: {
          'filename': filename,
          'contentType': contentType,
          'type': type.name,
          if (category != null) 'category': category,
        },
        options: Options(headers: _getAuthHeaders()),
      );

      return PresignedUrlResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ===========================================================================
  // UPLOAD
  // ===========================================================================

  /// Upload a video file with progress tracking
  ///
  /// [file] - The video file to upload
  /// [contentType] - MIME type (e.g., 'video/mp4')
  /// [onProgress] - Optional callback for upload progress (0.0 to 1.0)
  ///
  /// Returns [UploadResult] with the uploaded file's key and URL.
  Future<UploadResult> uploadVideo({
    required File file,
    String contentType = 'video/mp4',
    void Function(double progress)? onProgress,
  }) async {
    return _uploadFile(
      file: file,
      contentType: contentType,
      type: FileType.video,
      onProgress: onProgress,
    );
  }

  /// Upload a thumbnail image with progress tracking
  Future<UploadResult> uploadThumbnail({
    required File file,
    String contentType = 'image/jpeg',
    void Function(double progress)? onProgress,
  }) async {
    return _uploadFile(
      file: file,
      contentType: contentType,
      type: FileType.thumbnail,
      onProgress: onProgress,
    );
  }

  /// Upload raw bytes (useful for generated thumbnails)
  Future<UploadResult> uploadBytes({
    required Uint8List bytes,
    required String filename,
    required String contentType,
    required FileType type,
    void Function(double progress)? onProgress,
  }) async {
    // Get presigned URL
    final presigned = await getPresignedUploadUrl(
      filename: filename,
      contentType: contentType,
      type: type,
    );

    try {
      // Upload to the presigned URL
      final response = await _dio.put(
        presigned.uploadUrl,
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {
            'Content-Type': contentType,
            'Content-Length': bytes.length,
          },
        ),
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
      );

      return UploadResult(
        key: presigned.key,
        url: response.data['url'] ?? _getPublicUrl(presigned.key, type),
        size: bytes.length,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<UploadResult> _uploadFile({
    required File file,
    required String contentType,
    required FileType type,
    void Function(double progress)? onProgress,
  }) async {
    // Get presigned URL
    final filename = file.path.split('/').last;
    final presigned = await getPresignedUploadUrl(
      filename: filename,
      contentType: contentType,
      type: type,
    );

    // Get file size
    final fileSize = await file.length();

    try {
      // Upload to the presigned URL
      final response = await _dio.put(
        presigned.uploadUrl,
        data: file.openRead(),
        options: Options(
          headers: {
            'Content-Type': contentType,
            'Content-Length': fileSize,
          },
        ),
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
      );

      return UploadResult(
        key: presigned.key,
        url: response.data['url'] ?? _getPublicUrl(presigned.key, type),
        size: fileSize,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ===========================================================================
  // PUBLIC URLS
  // ===========================================================================

  /// Get the public URL for a video
  String getVideoUrl(String key) => _getPublicUrl(key, FileType.video);

  /// Get the public URL for a thumbnail
  String getThumbnailUrl(String key) => _getPublicUrl(key, FileType.thumbnail);

  String _getPublicUrl(String key, FileType type) {
    final baseUrl = AppConfig.r2BaseUrl;
    return '$baseUrl/${type.name}/$key';
  }

  // ===========================================================================
  // DELETE
  // ===========================================================================

  /// Delete a video from R2
  Future<void> deleteVideo(String key) async {
    await _deleteFile(key, FileType.video);
  }

  /// Delete a thumbnail from R2
  Future<void> deleteThumbnail(String key) async {
    await _deleteFile(key, FileType.thumbnail);
  }

  Future<void> _deleteFile(String key, FileType type) async {
    try {
      await _dio.delete(
        '/${type.name}/$key',
        options: Options(headers: _getAuthHeaders()),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ===========================================================================
  // HEALTH CHECK
  // ===========================================================================

  /// Check if the R2 worker is healthy
  Future<bool> isHealthy() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[R2Service] Health check failed: $e');
      }
      return false;
    }
  }

  // ===========================================================================
  // ERROR HANDLING
  // ===========================================================================

  Failure _handleDioError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      if (statusCode == 401) {
        return const AuthFailure(message: 'Authentication required');
      }

      if (statusCode == 403) {
        return const AuthFailure(message: 'Access denied');
      }

      if (statusCode == 413) {
        return const ValidationFailure(
          message: 'File too large',
          code: 'FILE_TOO_LARGE',
        );
      }

      final errorMessage = data is Map ? data['error'] : data?.toString();
      return ServerFailure(
        message: errorMessage ?? 'Upload failed',
        code: 'R2_ERROR',
        statusCode: statusCode,
      );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const NetworkFailure(
        message: 'Upload timed out. Please try again.',
        code: 'TIMEOUT',
      );
    }

    return const NetworkFailure(
      message: 'Network error during upload',
      code: 'NETWORK_ERROR',
    );
  }
}

// =============================================================================
// DATA CLASSES
// =============================================================================

/// Type of file being uploaded
enum FileType {
  video,
  thumbnail,
}

/// Response from presigned URL request
class PresignedUrlResponse {
  final String uploadUrl;
  final String key;
  final String expiresAt;
  final String method;
  final Map<String, String> headers;

  const PresignedUrlResponse({
    required this.uploadUrl,
    required this.key,
    required this.expiresAt,
    required this.method,
    required this.headers,
  });

  factory PresignedUrlResponse.fromJson(Map<String, dynamic> json) {
    return PresignedUrlResponse(
      uploadUrl: json['uploadUrl'] as String,
      key: json['key'] as String,
      expiresAt: json['expiresAt'] as String,
      method: json['method'] as String? ?? 'PUT',
      headers: Map<String, String>.from(json['headers'] as Map? ?? {}),
    );
  }
}

/// Result of a successful upload
class UploadResult {
  final String key;
  final String url;
  final int size;

  const UploadResult({
    required this.key,
    required this.url,
    required this.size,
  });

  @override
  String toString() => 'UploadResult(key: $key, url: $url, size: $size)';
}
