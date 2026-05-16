library;

/// Point d'entree de l'application Etoile.
///
/// Initialise les services externes (Firebase, Supabase)
/// puis lance l'interface graphique. Si un service echoue,
/// un ecran d'erreur de secours est affiche.

import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/services/push_notification_service.dart';
import 'di/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // En debug : log les erreurs Flutter sans afficher l'écran rouge.
  // En production : géré par Crashlytics via _setupCrashlytics().
  if (kDebugMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('=== FLUTTER ERROR ===');
      debugPrint(details.exceptionAsString());
      debugPrint(details.stack?.toString() ?? '');
    };
  }

  // Verrouiller l'orientation portrait — le feed video TikTok-style
  // n'est pas concu pour le paysage.
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  try {
    await AppConfig.initialize();
    debugPrint('[Main] Configuration chargee');

    // Firebase : Crashlytics + Push — non supporte sur web
    if (!kIsWeb) {
      await Firebase.initializeApp();

      // Handler pour les notifications recues quand l'app est fermee.
      // Doit etre une fonction top-level (exigence Firebase).
      FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler,
      );

      _setupCrashlytics();
      debugPrint('[Main] Firebase initialise');
    }

    // Supabase : auth + BDD + realtime + storage
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      debug: kDebugMode,
      authOptions: const FlutterAuthClientOptions(
        // PKCE : flow OAuth securise (code + verifier) recommande pour mobile
        authFlowType: AuthFlowType.pkce,
      ),
    );
    debugPrint('[Main] Supabase initialise');

    // Injection de dependances : repositories, BLoCs, services
    await di.init();
    debugPrint('[Main] Dependances enregistrees');

    runApp(const EtoileApp());
  } on ConfigurationException catch (e) {
    debugPrint('[Main] Erreur de configuration : $e');
    runApp(_BootErrorApp(
      icon: Icons.error_outline,
      title: 'Erreur de configuration',
      detail: e.message,
      hint: 'Verifiez votre fichier .env et relancez l\'app.',
    ));
  } catch (e, stackTrace) {
    debugPrint('[Main] Erreur d\'initialisation : $e');
    debugPrint('[Main] Stack trace : $stackTrace');
    runApp(_BootErrorApp(
      icon: Icons.warning_amber_rounded,
      title: 'Erreur d\'initialisation',
      detail: e.toString(),
      hint: 'Relancez l\'app. Si le probleme persiste, verifiez la configuration.',
      isScrollable: true,
    ));
  }
}

/// Configure Crashlytics : actif en production, desactive en debug
/// pour ne pas polluer le dashboard avec les erreurs de dev.
void _setupCrashlytics() {
  if (AppConfig.enableCrashReporting) {
    // Intercepte les erreurs Flutter (widgets, rendering, layout)
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Intercepte les erreurs Dart non-attrapees (Futures sans try/catch)
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    debugPrint('[Main] Crashlytics actif');
  } else {
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    debugPrint('[Main] Crashlytics desactive (debug)');
  }
}

// ---------------------------------------------------------------------------
// Ecran de secours generique en cas d'echec au demarrage.
//
// N'utilise PAS AppColors/AppTheme car ces classes pourraient ne pas
// etre disponibles si l'initialisation a echoue.
// ---------------------------------------------------------------------------
class _BootErrorApp extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final String hint;
  final bool isScrollable;

  const _BootErrorApp({
    required this.icon,
    required this.title,
    required this.detail,
    required this.hint,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isScrollable) const SizedBox(height: 100),
        Icon(icon, color: const Color(0xFFFF8C00), size: 64),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (isScrollable)
          // Affiche l'erreur technique en monospace (style terminal)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              detail,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.left,
            ),
          )
        else
          Text(
            detail,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 32),
        Text(
          hint,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );

    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        body: SafeArea(
          child: isScrollable
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: content,
                )
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: content,
                ),
        ),
      ),
    );
  }
}
