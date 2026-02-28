import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/feed/presentation/pages/search_page.dart';
import '../../features/messages/presentation/pages/conversations_page.dart';
import '../../features/messages/presentation/pages/chat_page.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_seeker_profile_page.dart';
import '../../features/profile/presentation/pages/edit_recruiter_profile_page.dart';
import '../../features/video/presentation/pages/my_publications_page.dart';
import '../../features/video/presentation/pages/publish_offer_page.dart';
import '../../features/video/presentation/pages/video_record_page.dart';
import '../../features/payment/data/repositories/payment_repository.dart';
import '../../features/payment/presentation/bloc/payment_bloc.dart';
import '../../features/payment/presentation/bloc/payment_event.dart';
import '../../features/payment/presentation/pages/recruiter_premium_page.dart';
import '../../features/payment/presentation/pages/subscription_management_page.dart';
import '../../features/profile/presentation/pages/public_recruiter_profile_page.dart';
import '../../features/admin/data/repositories/admin_repository.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';
import '../../features/admin/presentation/bloc/admin_event.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/verification_queue_page.dart';
import '../../features/admin/presentation/pages/recruiter_verification_page.dart';
import '../../features/admin/presentation/pages/reports_page.dart';
import '../../features/admin/presentation/pages/admin_stats_page.dart';
import '../../features/settings/presentation/pages/contact_support_page.dart';
import '../../features/settings/presentation/pages/faq_page.dart';
import '../../features/settings/presentation/pages/legal_page.dart';
import '../../features/settings/presentation/pages/blocked_users_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../shared/widgets/splash_screen.dart';

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
  static const String search = '/search';
  static const String feed = '/feed';
  static const String messages = '/messages';
  static const String profile = '/profile';
  static const String record = '/record';
  static const String publish = '/publish';

  // Detail routes
  static const String chat = '/messages/:conversationId';
  static const String videoDetail = '/video/:videoId';
  static const String publicProfile = '/profile/:userId';

  // Profile edit routes
  static const String editProfile = '/profile/edit';
  static const String editRecruiterProfile = '/profile/edit-recruiter';
  static const String myPublications = '/my-publications';

  // Settings routes
  static const String settings = '/settings';
  static const String help = '/settings/help';
  static const String faq = '/settings/faq';
  static const String contactSupport = '/settings/contact';
  static const String blockedUsers = '/settings/blocked';
  static const String termsOfService = '/settings/terms';
  static const String privacyPolicy = '/settings/privacy';
  static const String premium = '/premium';
  static const String premiumRecruiter = '/premium/recruiter';
  static const String premiumManage = '/premium/manage';

  // Admin routes
  static const String admin = '/admin';
  static const String adminVerifications = '/admin/verifications';
  static const String adminReports = '/admin/reports';
  static const String adminStats = '/admin/stats';

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
        final isOnboarding =
            state.matchedLocation == AppRoutes.onboardingSeeker ||
                state.matchedLocation == AppRoutes.onboardingRecruiter;
        final isSplash = state.matchedLocation == AppRoutes.splash;

        // If on splash, wait for auth check
        if (isSplash) {
          if (authState is AuthInitial || authState is AuthLoading) {
            return null; // Stay on splash while checking
          }
          return isAuthenticated ? AppRoutes.search : AppRoutes.welcome;
        }

        // If not authenticated and not on auth route, redirect to welcome
        if (!isAuthenticated && !isAuthRoute && !isOnboarding) {
          return AppRoutes.welcome;
        }

        // If authenticated and on auth route, redirect to search
        // (but allow onboarding routes through)
        if (isAuthenticated && isAuthRoute) {
          return AppRoutes.search;
        }

        return null;
      },

      // Listen to auth state changes
      refreshListenable: GoRouterRefreshStream(authBloc.stream),

    routes: [
      // Splash screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const _SplashRedirect(),
      ),

      // Welcome/Onboarding
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: AppRoutes.onboardingSeeker,
        builder: (context, state) => const OnboardingPage(role: 'seeker'),
      ),
      GoRoute(
        path: AppRoutes.onboardingRecruiter,
        builder: (context, state) => const OnboardingPage(role: 'recruiter'),
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
            path: AppRoutes.search,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SearchPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.feed,
            pageBuilder: (context, state) {
              final sector = state.uri.queryParameters['sector'];
              return NoTransitionPage(
                child: FeedPage(initialSector: sector),
              );
            },
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
            redirect: (context, state) {
              final authState = authBloc.state;
              if (authState is AuthAuthenticated && authState.isRecruiter) {
                return AppRoutes.publish;
              }
              return null;
            },
            pageBuilder: (context, state) => const NoTransitionPage(
              child: VideoRecordPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.publish,
            redirect: (context, state) {
              final authState = authBloc.state;
              if (authState is AuthAuthenticated && authState.isSeeker) {
                return AppRoutes.record;
              }
              return null;
            },
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PublishOfferPage(),
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

      // My publications page
      GoRoute(
        path: AppRoutes.myPublications,
        builder: (context, state) {
          final tab = state.uri.queryParameters['tab'] ?? 'recruitment';
          return MyPublicationsPage(initialTab: tab);
        },
      ),

      // Public recruiter profile (read-only, for seekers)
      GoRoute(
        path: AppRoutes.publicProfile,
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return PublicRecruiterProfilePage(userId: userId);
        },
      ),

      // Premium pages
      GoRoute(
        path: AppRoutes.premium,
        builder: (context, state) => const _PremiumPage(),
      ),
      GoRoute(
        path: AppRoutes.premiumRecruiter,
        builder: (context, state) => BlocProvider(
          create: (_) => PaymentBloc(
            paymentRepository: GetIt.I<PaymentRepository>(),
          )..add(const PaymentLoadStatus()),
          child: const RecruiterPremiumPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.premiumManage,
        builder: (context, state) => BlocProvider(
          create: (_) => PaymentBloc(
            paymentRepository: GetIt.I<PaymentRepository>(),
          )..add(const PaymentLoadHistory()),
          child: const SubscriptionManagementPage(),
        ),
      ),

      // Settings
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'help',
            builder: (context, state) => LegalPage.legalNotice(),
          ),
          GoRoute(
            path: 'faq',
            builder: (context, state) => const FaqPage(),
          ),
          GoRoute(
            path: 'contact',
            builder: (context, state) => const ContactSupportPage(),
          ),
          GoRoute(
            path: 'blocked',
            builder: (context, state) => const BlockedUsersPage(),
          ),
          GoRoute(
            path: 'terms',
            builder: (context, state) => LegalPage.termsOfService(),
          ),
          GoRoute(
            path: 'privacy',
            builder: (context, state) => LegalPage.privacyPolicy(),
          ),
        ],
      ),

      // Admin (guard: redirect non-admin to feed)
      GoRoute(
        path: AppRoutes.admin,
        redirect: (context, state) {
          final authState = authBloc.state;
          if (authState is! AuthAuthenticated || !authState.isAdmin) {
            return AppRoutes.search;
          }
          return null;
        },
        builder: (context, state) => BlocProvider(
          create: (_) => AdminBloc(
            adminRepository: GetIt.I<AdminRepository>(),
          )..add(const AdminDashboardLoadRequested()),
          child: const AdminDashboardPage(),
        ),
        routes: [
          GoRoute(
            path: 'verifications',
            builder: (context, state) => BlocProvider(
              create: (_) => AdminBloc(
                adminRepository: GetIt.I<AdminRepository>(),
              )..add(const AdminVerificationListLoadRequested()),
              child: const VerificationQueuePage(),
            ),
            routes: [
              GoRoute(
                path: ':userId',
                builder: (context, state) {
                  final userId = state.pathParameters['userId']!;
                  return BlocProvider(
                    create: (_) => AdminBloc(
                      adminRepository: GetIt.I<AdminRepository>(),
                    ),
                    child: RecruiterVerificationPage(userId: userId),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'reports',
            builder: (context, state) => BlocProvider(
              create: (_) => AdminBloc(
                adminRepository: GetIt.I<AdminRepository>(),
              )..add(const AdminReportsListLoadRequested()),
              child: const ReportsPage(),
            ),
          ),
          GoRoute(
            path: 'stats',
            builder: (context, state) => BlocProvider(
              create: (_) => AdminBloc(
                adminRepository: GetIt.I<AdminRepository>(),
              )..add(const AdminStatsLoadRequested()),
              child: const AdminStatsPage(),
            ),
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

class _SplashRedirect extends StatelessWidget {
  const _SplashRedirect();

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
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
              onPressed: () => context.go(AppRoutes.search),
              child: const Text('Retour a l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}
