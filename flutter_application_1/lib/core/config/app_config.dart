library;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration de l'application chargee depuis le fichier .env
///
/// Toutes les valeurs sensibles viennent du .env (jamais en dur dans le code).
/// Voir .env.example pour la liste des variables requises.
///
/// Securite : les cles secretes (R2, Stripe secret) ne sont PAS exposees ici.
/// Seules les cles publiques (anon key Supabase, publishable key Stripe)
/// sont accessibles cote client. Les operations sensibles passent par
/// le Cloudflare Worker ou les Edge Functions Supabase.
class AppConfig {
  AppConfig._();

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
    _validateRequiredVariables();

    if (enableDebugMode) {
      debugPrint('[AppConfig] Environnement: ${environment.name}');
    }
  }

  /// Verifie que les variables obligatoires sont presentes dans le .env.
  /// Lance une [ConfigurationException] si une variable manque.
  static void _validateRequiredVariables() {
    const requiredVars = ['SUPABASE_URL', 'SUPABASE_ANON_KEY'];

    final missing = requiredVars
        .where((v) => dotenv.env[v]?.isEmpty ?? true)
        .toList();

    if (missing.isNotEmpty) {
      throw ConfigurationException(
        'Variables d\'environnement manquantes : ${missing.join(', ')}\n'
        'Verifiez votre fichier .env (voir .env.example).',
      );
    }
  }

  // ===========================================================================
  // Supabase — Backend principal (auth, BDD, realtime, storage)
  // ===========================================================================

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  /// Cle publique Supabase — securisee par les Row Level Security (RLS).
  /// Cette cle ne donne acces qu'aux donnees autorisees par les policies.
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // ===========================================================================
  // Cloudflare R2 — Stockage video via Worker
  // ===========================================================================
  // IMPORTANT : Les cles secretes R2 ne sont PAS dans l'app Flutter.
  // Toutes les operations R2 (upload, stream) passent par le Cloudflare Worker
  // qui detient les credentials. L'app utilise uniquement des presigned URLs.

  /// URL du Cloudflare Worker pour les operations video (upload, stream)
  static String get cloudflareWorkerUrl =>
      dotenv.env['R2_WORKER_URL'] ?? '';

  /// Alias pour compatibilite — preferer [cloudflareWorkerUrl]
  static String get r2BaseUrl => cloudflareWorkerUrl;

  /// Nom du bucket videos
  static String get r2BucketVideos =>
      dotenv.env['R2_BUCKET_VIDEOS'] ?? 'etoile-videos';

  /// Nom du bucket thumbnails
  static String get r2BucketThumbnails =>
      dotenv.env['R2_BUCKET_THUMBNAILS'] ?? 'etoile-thumbnails';

  // ===========================================================================
  // Stripe — Paiements (abonnements recruteurs, credits)
  // ===========================================================================

  /// Cle publique Stripe — safe cote client, identifie le compte marchand
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';

  static String get stripeMerchantId =>
      dotenv.env['STRIPE_MERCHANT_ID'] ?? 'merchant.com.etoile.app';

  // ===========================================================================
  // Environnement
  // ===========================================================================

  static Environment get environment {
    final env = dotenv.env['ENVIRONMENT']?.toLowerCase() ?? 'development';
    return Environment.values.firstWhere(
      (e) => e.name == env,
      orElse: () => Environment.development,
    );
  }

  static bool get enableDebugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true' || kDebugMode;

  static bool get isProduction => environment == Environment.production;
  static bool get isDevelopment => environment == Environment.development;

  // ===========================================================================
  // Constantes metier
  // ===========================================================================

  /// Duree max d'une video en secondes (format Etoile : 40s)
  static const int videoDurationSeconds = 40;

  /// Taille max d'une video en MB (limite MVP, ffmpeg Phase 2)
  static const int videoMaxSizeMB = 50;

  /// Phases de la video : intro (10s) + contenu principal (20s) + conclusion (10s)
  static const List<int> videoPhases = [10, 20, 10];

  /// Nombre de videos a precharger dans le feed
  static const int feedPreloadCount = 3;

  /// Taille par defaut des listes paginées
  static const int defaultPageSize = 20;

  /// Timeout des requetes API
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Nombre de tentatives en cas d'echec reseau
  static const int apiRetryCount = 3;

  // ===========================================================================
  // Feature flags
  // ===========================================================================

  static bool get enableAnalytics => isProduction;
  static bool get enableCrashReporting => isProduction;

  // ===========================================================================
  // Informations applicatives
  // ===========================================================================

  static const String appName = 'Etoile';
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@etoile-app.fr';
  static const String privacyPolicyUrl = 'https://etoile-app.fr/privacy';
  static const String termsOfServiceUrl = 'https://etoile-app.fr/terms';
}

enum Environment { development, staging, production }

/// Exception lancee quand la configuration est invalide ou incomplete.
class ConfigurationException implements Exception {
  final String message;
  const ConfigurationException(this.message);

  @override
  String toString() => 'ConfigurationException: $message';
}
