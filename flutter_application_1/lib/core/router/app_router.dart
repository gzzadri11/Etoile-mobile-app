import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/messages/presentation/pages/conversations_page.dart';
import '../../features/messages/presentation/pages/chat_page.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_seeker_profile_page.dart';
import '../../features/profile/presentation/pages/edit_recruiter_profile_page.dart';
import '../../features/video/presentation/pages/video_record_page.dart';
import '../../shared/widgets/main_scaffold.dart';

/// Application route names
abstract class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Onboarding routes
  static const String onboardingSeeker = '/onboarding/seeker';
  static const String onboardingRecruiter = '/onboarding/recruiter';

  // Main routes (with bottom navigation)
  static const String feed = '/feed';
  static const String messages = '/messages';
  static const String profile = '/profile';
  static const String record = '/record';

  // Detail routes
  static const String chat = '/messages/:conversationId';
  static const String videoDetail = '/video/:videoId';
  static const String publicProfile = '/profile/:userId';

  // Profile edit routes
  static const String editProfile = '/profile/edit';
  static const String editRecruiterProfile = '/profile/edit-recruiter';

  // Settings routes
  static const String settings = '/settings';
  static const String help = '/settings/help';
  static const String premium = '/premium';

  // Helper to build chat route
  static String chatWith(String conversationId) => '/messages/$conversationId';

  // Helper to build video detail route
  static String videoDetailFor(String videoId) => '/video/$videoId';

  // Helper to build public profile route
  static String publicProfileFor(String userId) => '/profile/$userId';
}

/// Application router configuration using GoRouter
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter? _router;

  /// Create the router with AuthBloc for refresh
  static GoRouter createRouter(AuthBloc authBloc) {
    _router ??= GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,

      // Redirect based on authentication state
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState is AuthAuthenticated;
        final isAuthRoute = state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.register ||
            state.matchedLocation == AppRoutes.forgotPassword ||
            state.matchedLocation == AppRoutes.welcome;
        final isSplash = state.matchedLocation == AppRoutes.splash;

        // If on splash, wait for auth check
        if (isSplash) {
          if (authState is AuthInitial || authState is AuthLoading) {
            return null; // Stay on splash while checking
          }
          return isAuthenticated ? AppRoutes.feed : AppRoutes.welcome;
        }

        // If not authenticated and not on auth route, redirect to welcome
        if (!isAuthenticated && !isAuthRoute) {
          return AppRoutes.welcome;
        }

        // If authenticated and on auth route, redirect to feed
        if (isAuthenticated && isAuthRoute) {
          return AppRoutes.feed;
        }

        return null;
      },

      // Listen to auth state changes
      refreshListenable: GoRouterRefreshStream(authBloc.stream),

    routes: [
      // Splash screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashPage(),
      ),

      // Welcome/Onboarding
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const _WelcomePage(),
      ),

      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Main app with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.feed,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FeedPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.messages,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ConversationsPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfilePage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.record,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VideoRecordPage(),
            ),
          ),
        ],
      ),

      // Chat detail (outside shell for full screen)
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          return ChatPage(conversationId: conversationId);
        },
      ),

      // Edit profile page
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => BlocProvider(
          create: (_) => GetIt.I<ProfileBloc>()..add(const ProfileLoadRequested()),
          child: const EditSeekerProfilePage(),
        ),
      ),

      // Edit recruiter profile page
      GoRoute(
        path: AppRoutes.editRecruiterProfile,
        builder: (context, state) => BlocProvider(
          create: (_) => GetIt.I<ProfileBloc>()..add(const ProfileLoadRequested()),
          child: const EditRecruiterProfilePage(),
        ),
      ),

      // Premium page
      GoRoute(
        path: AppRoutes.premium,
        builder: (context, state) => const _PremiumPage(),
      ),

      // Settings
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const _SettingsPage(),
        routes: [
          GoRoute(
            path: 'help',
            builder: (context, state) => const _HelpPage(),
          ),
        ],
      ),
    ],

      errorBuilder: (context, state) => _ErrorPage(error: state.error),
    );
    return _router!;
  }
}

/// GoRouter refresh stream helper that listens to a Stream
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// ============================================
// PLACEHOLDER PAGES (to be implemented in features)
// ============================================

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ETOILE',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFB800),
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(
              color: Color(0xFFFFB800),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Text(
                'ETOILE',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFB800),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '40 secondes pour briller',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push(AppRoutes.register),
                  child: const Text('Je cherche un emploi'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.push(AppRoutes.register),
                  child: const Text('Je recrute'),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.push(AppRoutes.login),
                child: const Text('Deja un compte ? Se connecter'),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumPage extends StatelessWidget {
  const _PremiumPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: const Center(child: Text('Premium Page - A implementer')),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parametres')),
      body: const Center(child: Text('Settings Page - A implementer')),
    );
  }
}

class _HelpPage extends StatelessWidget {
  const _HelpPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aide')),
      body: const Center(child: Text('Help Page - A implementer')),
    );
  }
}

class _ErrorPage extends StatelessWidget {
  final Exception? error;

  const _ErrorPage({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Oups ! Page introuvable',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Une erreur est survenue',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.feed),
              child: const Text('Retour a l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}
