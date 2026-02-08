import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

/// Centralized Supabase service for easy access to all Supabase features
///
/// Provides typed access to:
/// - Authentication (auth)
/// - Database queries (from)
/// - Storage (storage)
/// - Realtime subscriptions (realtime)
/// - Edge Functions (functions)
class SupabaseService {
  final SupabaseClient _client;

  SupabaseService({required SupabaseClient client}) : _client = client;

  // ===========================================================================
  // CLIENT ACCESS
  // ===========================================================================

  /// Raw Supabase client (for advanced use cases)
  SupabaseClient get client => _client;

  // ===========================================================================
  // AUTHENTICATION
  // ===========================================================================

  /// Supabase Auth instance for authentication operations
  GoTrueClient get auth => _client.auth;

  /// Current authenticated user (null if not logged in)
  User? get currentUser => _client.auth.currentUser;

  /// Current session (null if not logged in)
  Session? get currentSession => _client.auth.currentSession;

  /// Check if user is currently logged in
  bool get isAuthenticated => currentUser != null;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ===========================================================================
  // DATABASE
  // ===========================================================================

  /// Query builder for a specific table
  ///
  /// Example:
  /// ```dart
  /// final users = await supabase.from('users').select();
  /// ```
  SupabaseQueryBuilder from(String table) => _client.from(table);

  /// RPC call for stored procedures/functions
  ///
  /// Example:
  /// ```dart
  /// final result = await supabase.rpc('my_function', params: {'arg': 'value'});
  /// ```
  PostgrestFilterBuilder<T> rpc<T>(
    String fn, {
    Map<String, dynamic>? params,
  }) =>
      _client.rpc(fn, params: params);

  // ===========================================================================
  // STORAGE
  // ===========================================================================

  /// Supabase Storage instance
  SupabaseStorageClient get storage => _client.storage;

  /// Get a storage bucket by name
  StorageFileApi bucket(String name) => _client.storage.from(name);

  // ===========================================================================
  // REALTIME
  // ===========================================================================

  /// Supabase Realtime instance
  RealtimeClient get realtime => _client.realtime;

  /// Create a realtime channel
  ///
  /// Example:
  /// ```dart
  /// final channel = supabase.channel('messages')
  ///   .onPostgresChanges(
  ///     event: PostgresChangeEvent.insert,
  ///     schema: 'public',
  ///     table: 'messages',
  ///     callback: (payload) => print(payload),
  ///   )
  ///   .subscribe();
  /// ```
  RealtimeChannel channel(String name) => _client.channel(name);

  // ===========================================================================
  // EDGE FUNCTIONS
  // ===========================================================================

  /// Supabase Functions client for Edge Functions
  FunctionsClient get functions => _client.functions;

  /// Invoke an Edge Function
  ///
  /// Example:
  /// ```dart
  /// final response = await supabase.invokeFunction(
  ///   'generate-presigned-url',
  ///   body: {'filename': 'video.mp4'},
  /// );
  /// ```
  Future<FunctionResponse> invokeFunction(
    String functionName, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) =>
      _client.functions.invoke(
        functionName,
        headers: headers,
        body: body,
      );

  // ===========================================================================
  // CONNECTION VERIFICATION
  // ===========================================================================

  /// Verify connection to Supabase by testing a simple query
  ///
  /// Returns true if connection is successful, false otherwise.
  /// Logs any errors in debug mode.
  Future<bool> verifyConnection() async {
    try {
      // Try to query the categories table (should always exist)
      await _client.from('categories').select('id').limit(1);

      if (AppConfig.enableDebugMode) {
        debugPrint('[SupabaseService] Connection verified successfully');
      }
      return true;
    } catch (e) {
      if (AppConfig.enableDebugMode) {
        debugPrint('[SupabaseService] Connection verification failed: $e');
      }
      return false;
    }
  }

  /// Get connection status with detailed info
  Future<ConnectionStatus> getConnectionStatus() async {
    try {
      final stopwatch = Stopwatch()..start();
      await _client.from('categories').select('id').limit(1);
      stopwatch.stop();

      return ConnectionStatus(
        isConnected: true,
        latencyMs: stopwatch.elapsedMilliseconds,
        error: null,
      );
    } catch (e) {
      return ConnectionStatus(
        isConnected: false,
        latencyMs: null,
        error: e.toString(),
      );
    }
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Get the current user's ID (throws if not authenticated)
  String get userId {
    final user = currentUser;
    if (user == null) {
      throw StateError('User is not authenticated');
    }
    return user.id;
  }

  /// Get the current user's email
  String? get userEmail => currentUser?.email;

  /// Get the current user's role from app_metadata
  String? get userRole => currentUser?.appMetadata['role'] as String?;

  /// Sign out the current user
  Future<void> signOut() async {
    await auth.signOut();
  }

  /// Refresh the current session
  Future<AuthResponse> refreshSession() async {
    return await auth.refreshSession();
  }
}

/// Connection status result
class ConnectionStatus {
  /// Whether the connection is successful
  final bool isConnected;

  /// Latency in milliseconds (null if not connected)
  final int? latencyMs;

  /// Error message (null if connected)
  final String? error;

  const ConnectionStatus({
    required this.isConnected,
    this.latencyMs,
    this.error,
  });

  @override
  String toString() {
    if (isConnected) {
      return 'Connected (latency: ${latencyMs}ms)';
    }
    return 'Disconnected: $error';
  }
}
