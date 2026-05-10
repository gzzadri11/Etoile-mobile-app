/// Widget racine de l'application Etoile.
///
/// Gere le cycle d'initialisation de l'authentification :
/// 1. Restauration eventuelle de la session Supabase
/// 2. Resolution de l'etat auth (connecte / deconnecte)
/// 3. Creation du router GoRouter (depend de l'etat auth)
/// 4. Initialisation des push notifications (mobile uniquement)
///
/// Affiche un SplashScreen pendant ce processus.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'core/router/app_router.dart';
import 'core/services/push_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'shared/widgets/splash_screen.dart';

class EtoileApp extends StatefulWidget {
  const EtoileApp({super.key});

  @override
  State<EtoileApp> createState() => _EtoileAppState();
}

class _EtoileAppState extends State<EtoileApp> {
  AuthBloc? _authBloc;
  GoRouter? _router;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  @override
  void dispose() {
    _router?.dispose();
    super.dispose();
  }

  /// Initialise l'authentification et le routeur.
  ///
  /// Flux :
  /// - Supabase restaure automatiquement la session depuis le stockage local.
  ///   On ecoute `onAuthStateChange` avec un timeout de 2s pour capter cet event.
  /// - On dispatch `AuthCheckRequested` dans le BLoC pour resoudre le role
  ///   (seeker / recruiter / admin) et la completude du profil.
  /// - Le router est cree APRES que l'etat auth soit determine, car la
  ///   fonction redirect de GoRouter depend du role utilisateur.
  Future<void> _initializeAuth() async {
    debugPrint('[App] Initialisation auth...');

    _authBloc = GetIt.I<AuthBloc>();

    final session = await _restoreSession();
    debugPrint('[App] Session: ${session?.user.email ?? 'aucune'}');

    // Demande au BLoC de verifier le role et la completude profil
    _authBloc!.add(const AuthCheckRequested());
    await _waitForAuthResolution();

    // Charge les preferences locales (onboarding vu, etc.)
    await AppRouter.loadPreferences();

    // Le router est cree apres resolution de l'auth car les redirections
    // (admin → /verify-admin, profil incomplet → /profile/edit) en dependent.
    _router = AppRouter.createRouter(_authBloc!);

    if (!kIsWeb) {
      await _initPushNotifications();
    }

    if (mounted) {
      setState(() => _isInitialized = true);
      debugPrint('[App] Initialisation terminee');
    }
  }

  /// Attend que Supabase restaure une session existante (timeout 2s).
  ///
  /// Supabase stocke le token JWT dans le stockage local. Au demarrage,
  /// il emet un event `initialSession` si une session valide est trouvee.
  /// Si aucun event n'arrive en 2s, on considere qu'il n'y a pas de session.
  Future<supabase.Session?> _restoreSession() async {
    final client = supabase.Supabase.instance.client;
    final existingSession = client.auth.currentSession;
    if (existingSession != null) return existingSession;

    final completer = Completer<supabase.Session?>();
    final subscription = client.auth.onAuthStateChange.listen((data) {
      final isSessionEvent =
          data.event == supabase.AuthChangeEvent.initialSession ||
          data.event == supabase.AuthChangeEvent.signedIn ||
          data.event == supabase.AuthChangeEvent.tokenRefreshed;
      if (isSessionEvent && !completer.isCompleted) {
        completer.complete(data.session);
      }
    });

    try {
      return await completer.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
    } finally {
      await subscription.cancel();
    }
  }

  /// Attend que le BLoC auth emette un etat final (timeout 3s).
  Future<void> _waitForAuthResolution() async {
    try {
      await _authBloc!.stream.firstWhere(
        (state) =>
            state is AuthAuthenticated ||
            state is AuthUnauthenticated ||
            state is AuthError,
      ).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[App] Timeout resolution auth: $e');
    }
  }

  /// Initialise les push notifications (non-bloquant).
  /// Si l'utilisateur est deja connecte, enregistre le token FCM.
  Future<void> _initPushNotifications() async {
    try {
      final pushService = GetIt.I<PushNotificationService>();
      await pushService.initialize(router: _router);

      if (_authBloc!.state is AuthAuthenticated) {
        pushService.registerToken();
      }
      debugPrint('[App] Push notifications initialisees');
    } catch (e) {
      // Non-bloquant : l'app fonctionne sans push
      debugPrint('[App] Push init echouee (non-bloquant): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _router == null || _authBloc == null) {
      return const SplashScreen();
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc!),
      ],
      child: MaterialApp.router(
        title: 'Etoile',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: _router,
      ),
    );
  }
}
