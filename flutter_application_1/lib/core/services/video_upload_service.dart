import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

/// Result of a file upload to R2
class UploadResult {
  final String key;
  final String url;
  final int size;

  const UploadResult({
    required this.key,
    required this.url,
    required this.size,
  });
}

/// Service for uploading files (video/image) to Cloudflare R2 via Worker.
///
/// Flow: POST /presigned-url → PUT file bytes → public URL returned.
class VideoUploadService {
  final SupabaseClient _supabaseClient;
  final Dio _dio;

  VideoUploadService({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient,
        _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 5),
        ));

  String get _workerUrl => AppConfig.r2BaseUrl;

  String? get _accessToken =>
      _supabaseClient.auth.currentSession?.accessToken;

  /// Upload a video file to R2.
  Future<UploadResult> uploadVideo({
    required Uint8List fileBytes,
    required String filename,
    String contentType = 'video/mp4',
    void Function(int progress)? onProgress,
  }) async {
    return _uploadFile(
      fileBytes: fileBytes,
      filename: filename,
      contentType: contentType,
      type: 'video',
      onProgress: onProgress,
    );
  }

  /// Upload a thumbnail image to R2.
  Future<UploadResult> uploadThumbnail({
    required Uint8List fileBytes,
    required String filename,
    String contentType = 'image/jpeg',
    void Function(int progress)? onProgress,
  }) async {
    return _uploadFile(
      fileBytes: fileBytes,
      filename: filename,
      contentType: contentType,
      type: 'thumbnail',
      onProgress: onProgress,
    );
  }

  /// Generic upload: get presigned URL then PUT file bytes.
  Future<UploadResult> _uploadFile({
    required Uint8List fileBytes,
    required String filename,
    required String contentType,
    required String type,
    void Function(int progress)? onProgress,
  }) async {
    final token = _accessToken;
    if (token == null) {
      throw Exception('Not authenticated');
    }

    // Step 1: Get presigned URL from Cloudflare Worker
    debugPrint('[Upload] Requesting presigned URL for $filename ($type)');

    final Response presignedResponse;
    try {
      presignedResponse = await _dio.post(
        '$_workerUrl/presigned-url',
        data: {
          'filename': filename,
          'contentType': contentType,
          'type': type,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      throw Exception(
        'Failed to get presigned URL: ${e.response?.data ?? e.message}',
      );
    }

    final presignedData = presignedResponse.data as Map<String, dynamic>;
    final uploadUrl = presignedData['uploadUrl'] as String;
    final key = presignedData['key'] as String;

    debugPrint('[Upload] Got presigned URL, key: $key');
    debugPrint('[Upload] Uploading ${fileBytes.length} bytes...');

    // Step 2: PUT file bytes to the upload URL
    final Response uploadResponse;
    try {
      uploadResponse = await _dio.put(
        uploadUrl,
        data: Stream.fromIterable([fileBytes]),
        options: Options(
          headers: {
            'Content-Type': contentType,
            'Content-Length': fileBytes.length.toString(),
          },
        ),
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = ((sent / total) * 100).round();
            onProgress?.call(progress);
          }
        },
      );
    } on DioException catch (e) {
      throw Exception(
        'Upload failed: ${e.response?.data ?? e.message}',
      );
    }

    final uploadData = uploadResponse.data as Map<String, dynamic>;
    final result = UploadResult(
      key: uploadData['key'] as String,
      url: uploadData['url'] as String,
      size: uploadData['size'] as int,
    );

    debugPrint('[Upload] Success! URL: ${result.url}');
    return result;
  }

  /// Delete a file from R2.
  Future<void> deleteFile({
    required String key,
    required String type,
  }) async {
    final token = _accessToken;
    if (token == null) throw Exception('Not authenticated');

    await _dio.delete(
      '$_workerUrl/$type/$key',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    debugPrint('[Upload] Deleted $type: $key');
  }

  void dispose() {
    _dio.close();
  }
}
