import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration loaded from environment variables
///
/// All sensitive values are loaded from .env file.
/// Use .env.example as a template for required variables.
class AppConfig {
  /// Private constructor to prevent instantiation
  AppConfig._();

  /// Initialize configuration - must be called before accessing any values
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    _validateRequiredVariables();

    if (enableDebugMode) {
      debugPrint('[AppConfig] Configuration loaded successfully');
      debugPrint('[AppConfig] Environment: ${environment.name}');
      debugPrint('[AppConfig] Supabase URL: $supabaseUrl');
    }
  }

  /// Validate that all required environment variables are present
  static void _validateRequiredVariables() {
    final requiredVars = [
      'SUPABASE_URL',
      'SUPABASE_ANON_KEY',
    ];

    final missingVars = requiredVars
        .where((v) => dotenv.env[v]?.isEmpty ?? true)
        .toList();

    if (missingVars.isNotEmpty) {
      throw ConfigurationException(
        'Missing required environment variables: ${missingVars.join(', ')}\n'
        'Please check your .env file. See .env.example for reference.',
      );
    }
  }

  // ===========================================================================
  // SUPABASE
  // ===========================================================================

  /// Supabase project URL
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? '';

  /// Supabase anonymous key (safe for client-side)
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // ===========================================================================
  // CLOUDFLARE R2
  // ===========================================================================

  /// Cloudflare Account ID
  static String get r2AccountId =>
      dotenv.env['R2_ACCOUNT_ID'] ?? '';

  /// R2 Access Key ID
  static String get r2AccessKeyId =>
      dotenv.env['R2_ACCESS_KEY_ID'] ?? '';

  /// R2 Secret Access Key
  static String get r2SecretAccessKey =>
      dotenv.env['R2_SECRET_ACCESS_KEY'] ?? '';

  /// R2 Endpoint URL (constructed from account ID)
  static String get r2Endpoint =>
      'https://$r2AccountId.r2.cloudflarestorage.com';

  /// R2 Worker base URL for video operations
  /// This will be configured once the Cloudflare Worker is deployed
  static String get r2BaseUrl =>
      dotenv.env['R2_WORKER_URL'] ?? 'https://video-worker.etoile-app.workers.dev';

  /// R2 bucket for videos
  static String get r2BucketVideos =>
      dotenv.env['R2_BUCKET_VIDEOS'] ?? 'etoile-videos';

  /// R2 bucket for thumbnails
  static String get r2BucketThumbnails =>
      dotenv.env['R2_BUCKET_THUMBNAILS'] ?? 'etoile-thumbnails';

  /// Check if R2 is configured
  static bool get isR2Configured =>
      r2AccountId.isNotEmpty && r2AccessKeyId.isNotEmpty && r2SecretAccessKey.isNotEmpty;

  // ===========================================================================
  // STRIPE
  // ===========================================================================

  /// Stripe publishable key
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';

  /// Stripe merchant ID
  static String get stripeMerchantId =>
      dotenv.env['STRIPE_MERCHANT_ID'] ?? 'merchant.com.etoile.app';

  // ===========================================================================
  // ENVIRONMENT
  // ===========================================================================

  /// Current environment
  static Environment get environment {
    final env = dotenv.env['ENVIRONMENT']?.toLowerCase() ?? 'development';
    return Environment.values.firstWhere(
      (e) => e.name == env,
      orElse: () => Environment.development,
    );
  }

  /// Debug mode flag
  static bool get enableDebugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true' || kDebugMode;

  /// Is production environment
  static bool get isProduction => environment == Environment.production;

  /// Is development environment
  static bool get isDevelopment => environment == Environment.development;

  // ===========================================================================
  // API CONFIGURATION (static values)
  // ===========================================================================

  /// API request timeout
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Number of retry attempts for failed requests
  static const int apiRetryCount = 3;

  // ===========================================================================
  // VIDEO CONFIGURATION (static values)
  // ===========================================================================

  /// Video recording duration in seconds
  static const int videoDurationSeconds = 40;

  /// Maximum video file size in MB
  static const int videoMaxSizeMB = 50;

  /// Video resolution
  static const String videoResolution = '1080p';

  /// Video phases duration (intro, main, conclusion)
  static const List<int> videoPhases = [10, 20, 10];

  // ===========================================================================
  // CACHE CONFIGURATION (static values)
  // ===========================================================================

  /// Maximum cache age
  static const Duration cacheMaxAge = Duration(hours: 24);

  /// Maximum number of cached items
  static const int cacheMaxItems = 100;

  // ===========================================================================
  // PAGINATION (static values)
  // ===========================================================================

  /// Default page size for lists
  static const int defaultPageSize = 20;

  /// Number of videos to preload in feed
  static const int feedPreloadCount = 3;

  // ===========================================================================
  // FEATURE FLAGS
  // ===========================================================================

  /// Enable analytics tracking
  static bool get enableAnalytics => isProduction;

  /// Enable crash reporting
  static bool get enableCrashReporting => isProduction;

  // ===========================================================================
  // APP INFO (static values)
  // ===========================================================================

  /// Application name
  static const String appName = 'Etoile';

  /// Application version
  static const String appVersion = '1.0.0';

  /// Support email
  static const String supportEmail = 'support@etoile-app.fr';

  /// Privacy policy URL
  static const String privacyPolicyUrl = 'https://etoile-app.fr/privacy';

  /// Terms of service URL
  static const String termsOfServiceUrl = 'https://etoile-app.fr/terms';
}

/// Environment types
enum Environment {
  development,
  staging,
  production,
}

/// Exception thrown when configuration is invalid
class ConfigurationException implements Exception {
  final String message;

  const ConfigurationException(this.message);

  @override
  String toString() => 'ConfigurationException: $message';
}
