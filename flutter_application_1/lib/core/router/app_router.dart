/// Routeur principal de l'application Etoile (GoRouter).
///
/// Architecture de navigation :
/// - **ShellRoute** (MainScaffold) : ecrans avec bottom nav (search, feed, messages, profil)
/// - **ShellRoute** (AdminScaffold) : ecrans admin avec nav dediee
/// - **Routes plein ecran** : chat, edition profil, parametres, etc.
///
/// Redirections :
/// - Non authentifie → /welcome
/// - Authentifie + profil incomplet → edit profil (sauf routes autorisees)
/// - Admin non verifie → /verify-admin (double authentification)
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/admin/data/repositories/admin_repository.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';
import '../../features/admin/presentation/bloc/admin_event.dart';
import '../../features/admin/presentation/pages/admin_auth_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_stats_page.dart';
import '../../features/admin/presentation/pages/recruiter_verification_page.dart';
import '../../features/admin/presentation/pages/reports_page.dart';
import '../../features/admin/presentation/pages/verification_queue_page.dart';
import '../../features/admin/presentation/widgets/admin_scaffold.dart';
import '../../features/applications/presentation/pages/seeker_applications_page.dart';
import '../../features/favorites/presentation/pages/seeker_favorites_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/company/models/company_model.dart';
import '../../features/company/pages/company_profile_page.dart';
import '../../features/feed/presentation/pages/feed_page.dart';
import '../../features/feed/presentation/pages/search_page.dart';
import '../../features/messages/presentation/pages/chat_page.dart';
import '../../features/messages/presentation/pages/conversations_page.dart';
import '../../features/offer/pages/offer_detail_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/stats/presentation/pages/seeker_stats_page.dart';
import '../../features/profile/data/models/recruiter_profile_model.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/pages/edit_seeker_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/public_recruiter_profile_page.dart';
import '../../features/profile/presentation/pages/public_seeker_profile_page.dart';
import '../../features/settings/presentation/pages/blocked_users_page.dart';
import '../../features/settings/presentation/pages/contact_support_page.dart';
import '../../features/settings/presentation/pages/faq_page.dart';
import '../../features/settings/presentation/pages/legal_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/video/data/models/video_model.dart';
import '../../features/video/data/repositories/video_repository.dart';
import '../../features/video/presentation/bloc/video_bloc.dart';
import '../../features/video/presentation/pages/video_record_page.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../../shared/widgets/splash_screen.dart';

// =============================================================================
// Routes — Constantes de nommage centralisees
// =============================================================================

abstract class AppRoutes {
  // Auth
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/verify-email';

  // Onboarding
  static const String onboardingSeeker = '/onboarding/seeker';

  // Navigation principale (bottom nav)
  static const String search = '/search';
  static const String feed = '/feed';
  static const String messages = '/messages';
  static const String profile = '/profile';
  static const String record = '/record';

  // Detail
  static const String chat = '/messages/:conversationId';
  static const String videoDetail = '/video/:videoId';
  static const String publicProfile = '/profile/:userId';

  // Profil
  static const String editProfile = '/profile/edit';

  // Parametres
  static const String settings = '/settings';
  static const String help = '/settings/help';
  static const String faq = '/settings/faq';
  static const String contactSupport = '/settings/contact';
  static const String blockedUsers = '/settings/blocked';
  static const String termsOfService = '/settings/terms';
  static const String privacyPolicy = '/settings/privacy';


  // Admin
  static const String admin = '/admin';
  static const String adminAuth = '/verify-admin';
  static const String adminVerifications = '/admin/verifications';
  static const String adminReports = '/admin/reports';
  static const String adminStats = '/admin/stats';

  // Candidatures
  static const String seekerApplications = '/my-applications';

  // Entreprise
  static const String companyProfile = '/company/:recruiterId';
  static const String offerDetail = '/offer/:offerId';

  // Stats chercheur
  static const String seekerStats = '/stats';

  // Favoris chercheur
  static const String seekerFavorites = '/favorites';

  // Helpers pour les routes parametrees
  static String chatWith(String id) => '/messages/$id';
  static String videoDetailFor(String id) => '/video/$id';
  static String publicProfileFor(String id) => '/profile/$id';
  static String companyProfileFor(String id) => '/company/$id';
  static String offerDetailFor(String id) => '/offer/$id';
}

// =============================================================================
// Router
// =============================================================================

class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();
  static final _adminShellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter? _router;

  // --- Etat admin : double authentification ---
  // Vigilance : etat statique mutable. Acceptable ici car lie au cycle de vie
  // de l'app (reset au logout). A migrer vers un service injectable si le
  // projet grandit significativement.
  static bool _adminSessionVerified = false;
  static void verifyAdminSession() => _adminSessionVerified = true;
  static void resetAdminSession() => _adminSessionVerified = false;

  // --- Onboarding : affiche une seule fois apres login/inscription explicite ---
  static bool _onboardingDone = true; // true par defaut → evite de bloquer les utilisateurs existants
  static bool _isNewAuthSession = false; // true uniquement apres login/inscription explicite (jamais au lancement)

  static void setOnboardingDone() {
    _onboardingDone = true;
    _isNewAuthSession = false;
  }

  /// Declenche l'affichage de l'onboarding lors du prochain redirect.
  /// Doit etre appele avant emit(AuthAuthenticated) dans le BLoC.
  static void markFreshLogin() => _isNewAuthSession = true;

  static Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingDone = prefs.getBool('onboarding_done') ?? false;
    // _isNewAuthSession reste false : le lancement de l'app ne declenche pas l'onboarding
  }

  // --- Etat profil : gate de completude ---
  static bool _profileComplete = true;
  static bool _profileChecked = false;

  static void updateProfileComplete(bool complete) {
    _profileComplete = complete;
    _profileChecked = true;
  }

  static bool get isProfileComplete => _profileComplete;

  static void resetProfileCheck() {
    _profileChecked = false;
    _profileComplete = true;
    _isNewAuthSession = false;
  }

  /// Cree le router GoRouter. Appele une seule fois depuis [EtoileApp].
  static GoRouter createRouter(AuthBloc authBloc) {
    _router ??= GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: true,
      refreshListenable: _GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) =>
          _handleRedirect(authBloc, state),
      routes: [
        _splashRoute(),
        ..._authRoutes(),
        ..._onboardingRoutes(),
        _mainShellRoute(authBloc),
        ..._profileRoutes(),
        ..._detailRoutes(),
        ..._applicationRoutes(),
        _settingsRoute(),
        _adminAuthRoute(),
        _adminShellRoute(authBloc),
        _adminVerificationDetailRoute(authBloc),
      ],
      errorBuilder: (context, state) => _ErrorPage(error: state.error),
    );
    return _router!;
  }

  // ===========================================================================
  // Logique de redirection centralisee
  // ===========================================================================

  /// Gere toutes les redirections auth, role et profil.
  ///
  /// Ordre de priorite :
  /// 1. Splash : attend la resolution auth
  /// 2. Loading hors splash : ne pas rediriger (evite les race conditions)
  /// 3. Non authentifie hors auth → welcome
  /// 4. Authentifie sur auth route → search/admin
  /// 5. Admin non verifie → /verify-admin
  /// 6. Profil incomplet → edit profil
  static String? _handleRedirect(AuthBloc authBloc, GoRouterState state) {
    final authState = authBloc.state;
    final isAuthenticated = authState is AuthAuthenticated;
    final isLoading = authState is AuthLoading || authState is AuthInitial;
    final location = state.matchedLocation;

    // Routes qui ne necessitent pas d'etre authentifie
    final isAuthRoute = _authLocations.contains(location);
    final isOnboarding = location == AppRoutes.onboardingSeeker;

    // 1. Splash : attend la resolution auth
    if (location == AppRoutes.splash) {
      if (isLoading) return null;
      if (authState is AuthAuthenticated) {
        return authState.isAdmin ? AppRoutes.adminAuth : AppRoutes.search;
      }
      return AppRoutes.welcome;
    }

    // 2. Auth en cours hors splash : ne pas rediriger
    // Evite qu'un AuthLoading transitoire (re-check onAuthStateChange)
    // redirige un admin loin de /verify-admin vers /welcome.
    if (isLoading) return null;

    // 3. Non authentifie → welcome
    if (!isAuthenticated && !isAuthRoute && !isOnboarding) {
      _adminSessionVerified = false;
      return AppRoutes.welcome;
    }

    // 4. Authentifie sur page auth → redirection selon role
    if (authState is AuthAuthenticated && isAuthRoute) {
      return authState.isAdmin ? AppRoutes.adminAuth : AppRoutes.search;
    }

    // 4.5. Premiere connexion → onboarding (chercheur uniquement, apres login/register explicite)
    if (authState is AuthAuthenticated && !authState.isAdmin &&
        _isNewAuthSession && !_onboardingDone &&
        location != AppRoutes.onboardingSeeker) {
      return AppRoutes.onboardingSeeker;
    }

    // 5. Double auth admin
    if (authState is AuthAuthenticated && location.startsWith('/admin') &&
        location != AppRoutes.adminAuth) {
      if (authState.isAdmin && !_adminSessionVerified) {
        return AppRoutes.adminAuth;
      }
    }

    // 6. Profil incomplet → formulaire d'edition
    if (authState is AuthAuthenticated && _profileChecked && !_profileComplete) {
      if (!authState.isAdmin && !_isAllowedWhenIncomplete(location)) {
        return AppRoutes.editProfile;
      }
    }

    return null;
  }

  static const _authLocations = {
    AppRoutes.login,
    AppRoutes.register,
    AppRoutes.forgotPassword,
    AppRoutes.welcome,
  };

  /// Routes accessibles meme avec un profil incomplet
  static bool _isAllowedWhenIncomplete(String location) {
    return location == AppRoutes.editProfile ||
        location == AppRoutes.profile ||
        location == AppRoutes.onboardingSeeker ||
        location == AppRoutes.settings ||
        location == AppRoutes.seekerStats ||
        location == AppRoutes.seekerApplications ||
        location == AppRoutes.seekerFavorites ||
        location.startsWith('/settings/');
  }

  // ===========================================================================
  // Definition des routes — regroupees par domaine
  // ===========================================================================

  static GoRoute _splashRoute() => GoRoute(
    path: AppRoutes.splash,
    builder: (_, _) => const SplashScreen(),
  );

  static List<GoRoute> _authRoutes() => [
    GoRoute(
      path: AppRoutes.welcome,
      builder: (_, _) => const WelcomePage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (_, _) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (_, _) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (_, _) => const ForgotPasswordPage(),
    ),
  ];

  static List<GoRoute> _onboardingRoutes() => [
    GoRoute(
      path: AppRoutes.onboardingSeeker,
      builder: (_, _) => const OnboardingPage(),
    ),
  ];

  /// Navigation principale avec bottom nav bar (ShellRoute)
  static ShellRoute _mainShellRoute(AuthBloc authBloc) => ShellRoute(
    navigatorKey: _shellNavigatorKey,
    builder: (_, _, child) => MainScaffold(child: child),
    routes: [
      GoRoute(
        path: AppRoutes.search,
        pageBuilder: (_, _) => const NoTransitionPage(child: SearchPage()),
      ),
      GoRoute(
        path: AppRoutes.feed,
        pageBuilder: (_, state) {
          final qp = state.uri.queryParameters;
          return NoTransitionPage(
            child: FeedPage(
              initialSector: qp['sector'],
              initialSpecialty: qp['specialty'],
              initialCity: qp['city'],
              initialStudyLevel: qp['studyLevel'],
              initialProximityKm: qp['proximityKm'] != null
                  ? double.tryParse(qp['proximityKm']!)
                  : null,
              initialUserLat: qp['userLat'] != null
                  ? double.tryParse(qp['userLat']!)
                  : null,
              initialUserLng: qp['userLng'] != null
                  ? double.tryParse(qp['userLng']!)
                  : null,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.messages,
        pageBuilder: (_, _) =>
            const NoTransitionPage(child: ConversationsPage()),
      ),
      GoRoute(
        path: AppRoutes.profile,
        redirect: (_, _) {
          final s = authBloc.state;
          return (s is AuthAuthenticated && s.isAdmin) ? AppRoutes.admin : null;
        },
        pageBuilder: (_, _) =>
            const NoTransitionPage(child: ProfilePage()),
      ),
      GoRoute(
        path: AppRoutes.record,
        pageBuilder: (_, _) => NoTransitionPage(
              child: BlocProvider(
                create: (_) => GetIt.I<VideoBloc>(),
                child: const VideoRecordPage(),
              ),
            ),
      ),
    ],
  );

  static List<GoRoute> _detailRoutes() => [
    GoRoute(
      path: AppRoutes.chat,
      builder: (_, state) => ChatPage(
        conversationId: state.pathParameters['conversationId']!,
      ),
    ),
    // Profil public : detecte automatiquement seeker ou recruiter
    GoRoute(
      path: AppRoutes.publicProfile,
      builder: (_, state) => _PublicProfileRouter(
        userId: state.pathParameters['userId']!,
      ),
    ),
    // Page entreprise complète (depuis profil recruteur ou feed)
    GoRoute(
      path: AppRoutes.companyProfile,
      builder: (_, state) => _CompanyProfileLoader(
        recruiterId: state.pathParameters['recruiterId']!,
      ),
    ),
    // Détail d'une offre (objet passé via extra)
    GoRoute(
      path: AppRoutes.offerDetail,
      builder: (_, state) => OfferDetailPage(
        offer: state.extra! as OfferModel,
      ),
    ),
  ];

  static List<GoRoute> _profileRoutes() => [
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (_, _) => BlocProvider(
        create: (_) => GetIt.I<ProfileBloc>()
          ..add(const ProfileLoadRequested()),
        child: const EditSeekerProfilePage(),
      ),
    ),
  ];

  static List<GoRoute> _applicationRoutes() => [
    GoRoute(
      path: AppRoutes.seekerApplications,
      builder: (_, _) => const SeekerApplicationsPage(),
    ),
    GoRoute(
      path: AppRoutes.seekerStats,
      builder: (_, _) => const SeekerStatsPage(),
    ),
    GoRoute(
      path: AppRoutes.seekerFavorites,
      builder: (_, state) => SeekerFavoritesPage(
        seekerId: state.extra as String? ?? '',
      ),
    ),
  ];

  static GoRoute _settingsRoute() => GoRoute(
    path: AppRoutes.settings,
    builder: (_, _) => const SettingsPage(),
    routes: [
      GoRoute(
        path: 'help',
        builder: (_, _) => LegalPage.legalNotice(),
      ),
      GoRoute(
        path: 'faq',
        builder: (_, _) => const FaqPage(),
      ),
      GoRoute(
        path: 'contact',
        builder: (_, _) => const ContactSupportPage(),
      ),
      GoRoute(
        path: 'blocked',
        builder: (_, _) => const BlockedUsersPage(),
      ),
      GoRoute(
        path: 'terms',
        builder: (_, _) => LegalPage.termsOfService(),
      ),
      GoRoute(
        path: 'privacy',
        builder: (_, _) => LegalPage.privacyPolicy(),
      ),
    ],
  );

  // --- Admin ---

  static GoRoute _adminAuthRoute() => GoRoute(
    path: AppRoutes.adminAuth,
    builder: (_, _) => const AdminAuthPage(),
  );

  /// Guard commun pour les routes admin
  static String? _adminGuard(AuthBloc authBloc) {
    final s = authBloc.state;
    return (s is! AuthAuthenticated || !s.isAdmin)
        ? AppRoutes.search
        : null;
  }

  static ShellRoute _adminShellRoute(AuthBloc authBloc) => ShellRoute(
    navigatorKey: _adminShellNavigatorKey,
    builder: (_, _, child) => AdminScaffold(child: child),
    routes: [
      GoRoute(
        path: AppRoutes.admin,
        redirect: (_, _) => _adminGuard(authBloc),
        pageBuilder: (_, _) => NoTransitionPage(
          child: BlocProvider(
            create: (_) => AdminBloc(
              adminRepository: GetIt.I<AdminRepository>(),
            )..add(const AdminDashboardLoadRequested()),
            child: const AdminDashboardPage(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminVerifications,
        redirect: (_, _) => _adminGuard(authBloc),
        pageBuilder: (_, _) => NoTransitionPage(
          child: BlocProvider(
            create: (_) => AdminBloc(
              adminRepository: GetIt.I<AdminRepository>(),
            )..add(const AdminVerificationListLoadRequested()),
            child: const VerificationQueuePage(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminReports,
        redirect: (_, _) => _adminGuard(authBloc),
        pageBuilder: (_, _) => NoTransitionPage(
          child: BlocProvider(
            create: (_) => AdminBloc(
              adminRepository: GetIt.I<AdminRepository>(),
            )..add(const AdminReportsListLoadRequested()),
            child: const ReportsPage(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminStats,
        redirect: (_, _) => _adminGuard(authBloc),
        pageBuilder: (_, _) => NoTransitionPage(
          child: BlocProvider(
            create: (_) => AdminBloc(
              adminRepository: GetIt.I<AdminRepository>(),
            )..add(const AdminStatsLoadRequested()),
            child: const AdminStatsPage(),
          ),
        ),
      ),
    ],
  );

  static GoRoute _adminVerificationDetailRoute(AuthBloc authBloc) => GoRoute(
    path: '${AppRoutes.adminVerifications}/:userId',
    redirect: (_, _) => _adminGuard(authBloc),
    builder: (_, state) {
      final userId = state.pathParameters['userId']!;
      return BlocProvider(
        create: (_) => AdminBloc(
          adminRepository: GetIt.I<AdminRepository>(),
        )..add(AdminRecruiterDetailLoadRequested(userId: userId)),
        child: RecruiterVerificationPage(userId: userId),
      );
    },
  );
}

// =============================================================================
// Widgets internes au routeur
// =============================================================================

/// Ecoute un Stream et notifie GoRouter pour declencher un re-check
/// des redirections (utilise pour reagir aux changements d'etat auth).
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Resout automatiquement si un userId correspond a un seeker ou recruiter
/// puis affiche la bonne page de profil public.
class _PublicProfileRouter extends StatefulWidget {
  final String userId;
  const _PublicProfileRouter({required this.userId});

  @override
  State<_PublicProfileRouter> createState() => _PublicProfileRouterState();
}

class _PublicProfileRouterState extends State<_PublicProfileRouter> {
  String? _resolvedRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _resolveRole();
  }

  Future<void> _resolveRole() async {
    try {
      final repo = GetIt.I<ProfileRepository>();
      // Charge les deux profils en parallele pour determiner le role
      final results = await Future.wait([
        repo.getSeekerProfileById(widget.userId),
        repo.getRecruiterProfileById(widget.userId),
      ]);

      if (mounted) {
        setState(() {
          if (results[0] != null) {
            _resolvedRole = 'seeker';
          } else if (results[1] != null) {
            _resolvedRole = 'recruiter';
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_resolvedRole == 'seeker') {
      return PublicSeekerProfilePage(userId: widget.userId);
    }
    return PublicRecruiterProfilePage(userId: widget.userId);
  }
}

/// Charge les données d'une entreprise depuis Supabase et affiche [CompanyProfilePage].
class _CompanyProfileLoader extends StatefulWidget {
  final String recruiterId;
  const _CompanyProfileLoader({required this.recruiterId});

  @override
  State<_CompanyProfileLoader> createState() => _CompanyProfileLoaderState();
}

class _CompanyProfileLoaderState extends State<_CompanyProfileLoader> {
  CompanyModel? _company;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final profileRepo = GetIt.I<ProfileRepository>();
      final videoRepo = GetIt.I<VideoRepository>();

      final results = await Future.wait([
        profileRepo.getRecruiterProfileById(widget.recruiterId),
        videoRepo.getVideosForUser(widget.recruiterId),
      ]);

      final profile = results[0] as RecruiterProfile?;
      final videos = results[1] as List<Video>;

      if (profile == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final city =
          profile.locations.isNotEmpty ? profile.locations.first : '';
      final offerVideos =
          videos.where((v) => v.type != 'presentation' && v.isActive).toList();

      final company = CompanyModel(
        id: profile.userId,
        name: profile.companyName,
        sector: profile.sector ?? '',
        city: city,
        description: profile.description ?? '',
        logoUrl: profile.logoUrl,
        offers: offerVideos
            .map(
              (v) => OfferModel(
                id: v.id,
                title: v.title ?? 'Offre',
                companyName: profile.companyName,
                sector: profile.sector ?? '',
                city: city,
                contractType: v.contractType ?? 'alternance',
                mediaType: v.type == 'poster' ? 'image' : 'video',
                mediaUrl: v.type == 'poster' ? v.thumbnailUrl : v.videoUrl,
                description: v.description,
                recruiterId: profile.userId,
              ),
            )
            .toList(),
      );

      if (mounted) {
        setState(() {
          _company = company;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_company == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Entreprise introuvable')),
      );
    }
    return CompanyProfilePage(company: _company!);
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
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Oups ! Page introuvable',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
