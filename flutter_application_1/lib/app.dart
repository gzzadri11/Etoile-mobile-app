import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'core/constants/app_colors.dart';
import 'core/router/app_router.dart';
import 'core/services/push_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

/// Main application widget
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

  Future<void> _initializeAuth() async {
    debugPrint('[App] ========== INITIALIZING AUTH ==========');

    // Get the singleton AuthBloc instance
    _authBloc = GetIt.I<AuthBloc>();
    debugPrint('[App] AuthBloc instance obtained');

    // Check if session already exists (Supabase restores from storage automatically)
    final client = supabase.Supabase.instance.client;
    var session = client.auth.currentSession;
    debugPrint('[App] Initial session check: ${session?.user.email ?? 'NO SESSION'}');

    // If no session yet, wait for Supabase to potentially restore it
    if (session == null) {
      debugPrint('[App] No session found, waiting for potential restore...');

      // Listen for auth state change with timeout
      final completer = Completer<supabase.Session?>();
      late final StreamSubscription<supabase.AuthState> subscription;

      subscription = client.auth.onAuthStateChange.listen((data) {
        debugPrint('[App] Auth event: ${data.event}');
        if (data.event == supabase.AuthChangeEvent.initialSession ||
            data.event == supabase.AuthChangeEvent.signedIn ||
            data.event == supabase.AuthChangeEvent.tokenRefreshed) {
          if (!completer.isCompleted) {
            completer.complete(data.session);
          }
        }
      });

      // Wait for session or timeout after 2 seconds
      try {
        session = await completer.future.timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            debugPrint('[App] Session restore timeout - no session');
            return null;
          },
        );
      } finally {
        await subscription.cancel();
      }
    }

    debugPrint('[App] Final session: ${session?.user.email ?? 'NO SESSION'}');

    // Trigger auth check in bloc
    _authBloc!.add(const AuthCheckRequested());

    // Wait for bloc to resolve auth state
    try {
      final state = await _authBloc!.stream.firstWhere(
        (state) => state is AuthAuthenticated || state is AuthUnauthenticated || state is AuthError,
      ).timeout(const Duration(seconds: 3));
      debugPrint('[App] Auth state resolved: $state');
    } catch (e) {
      debugPrint('[App] Auth check error/timeout: $e');
    }

    debugPrint('[App] Current AuthBloc state: ${_authBloc!.state}');

    // Create router AFTER auth state is determined
    _router = AppRouter.createRouter(_authBloc!);
    debugPrint('[App] Router created');

    // Initialize push notifications with router reference
    final pushService = GetIt.I<PushNotificationService>();
    await pushService.initialize(router: _router);
    debugPrint('[App] Push notifications initialized');

    // If user is already authenticated, register FCM token
    if (_authBloc!.state is AuthAuthenticated) {
      pushService.registerToken();
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
      debugPrint('[App] ========== AUTH INITIALIZED ==========');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _router == null || _authBloc == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppColors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ETOILE',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryYellow,
                  ),
                ),
                const SizedBox(height: 24),
                CircularProgressIndicator(
                  color: AppColors.primaryYellow,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chargement...',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
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
