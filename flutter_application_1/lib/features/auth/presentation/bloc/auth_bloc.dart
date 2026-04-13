/// BLoC d'authentification — singleton global.
///
/// Gere tout le cycle d'authentification : login, inscription, logout,
/// suppression de compte (RGPD), verification OTP, reset password.
///
/// Points de vigilance pour la maintenance :
/// - Ce BLoC est un **singleton** (enregistre via LazySingleton dans GetIt).
///   Tous les ecrans observent la meme instance.
/// - Le flag `_isProcessingAuth` empeche les race conditions entre les events
///   Supabase `onAuthStateChange` et nos propres handlers login/register.
///   Sans ce flag, GoRouter detecte un etat transitoire Loading et redirige
///   l'utilisateur vers /welcome en plein milieu d'un login.
/// - Le profil completion gate est mis a jour ici (via AppRouter.updateProfileComplete)
///   pour que le router puisse rediriger vers l'edition de profil si necessaire.
///   C'est un couplage accepte pour eviter un flash de page non autorisee.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../profile/data/repositories/profile_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabaseClient;
  final ProfileRepository _profileRepository;

  /// Empeche le listener `onAuthStateChange` de dispatcher AuthCheckRequested
  /// pendant qu'un login/register est en cours. Voir doc en haut du fichier.
  bool _isProcessingAuth = false;

  AuthBloc({
    required SupabaseClient supabaseClient,
    required ProfileRepository profileRepository,
  })  : _supabaseClient = supabaseClient,
        _profileRepository = profileRepository,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthDeleteAccountRequested>(_onDeleteAccountRequested);
    on<AuthVerifyOtpRequested>(_onVerifyOtpRequested);
    on<AuthResendOtpRequested>(_onResendOtpRequested);

    // Ecoute les changements d'etat auth Supabase (ex: token expire).
    // On ignore les events pendant un login/register en cours et
    // les simples refreshes de token pour eviter des redirections parasites.
    _supabaseClient.auth.onAuthStateChange.listen((data) {
      if (data.session != null &&
          !_isProcessingAuth &&
          state is! AuthAuthenticated &&
          data.event != AuthChangeEvent.tokenRefreshed) {
        add(const AuthCheckRequested());
      }
    });
  }

  // ===========================================================================
  // Verification de session
  // ===========================================================================

  /// Verifie si l'utilisateur a une session active.
  ///
  /// Si deja authentifie, n'emet PAS AuthLoading pour eviter que GoRouter
  /// ne detecte un etat transitoire et redirige vers /welcome.
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final previousState = state;
    final wasAuthenticated = previousState is AuthAuthenticated;

    if (!wasAuthenticated) emit(const AuthLoading());

    try {
      final session = _supabaseClient.auth.currentSession;
      if (session == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        emit(const AuthUnauthenticated());
        return;
      }

      final role = await _getUserRole(user);
      final newState = AuthAuthenticated(
        userId: user.id,
        email: user.email ?? '',
        role: role,
      );

      // Pre-charge la completude du profil pour le gate du router
      await _preloadProfileCompletion(role);

      // N'emet que si l'etat change (evite les refreshs GoRouter inutiles)
      if (previousState != newState) {
        emit(newState);
      }
    } catch (e) {
      debugPrint('[AuthBloc] Erreur check: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  // ===========================================================================
  // Login
  // ===========================================================================

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    _isProcessingAuth = true;

    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );

      if (response.user == null) {
        emit(const AuthError(message: 'Email ou mot de passe incorrect'));
        return;
      }

      _registerPushToken();
      emit(AuthAuthenticated(
        userId: response.user!.id,
        email: response.user!.email ?? '',
        role: await _getUserRole(response.user!),
      ));
    } on AuthException catch (e) {
      emit(AuthError(message: _mapAuthError(e)));
    } catch (e) {
      emit(AuthError(message: 'Une erreur est survenue: $e'));
    } finally {
      _clearProcessingFlagWithDelay();
    }
  }

  // ===========================================================================
  // Inscription
  // ===========================================================================

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    _isProcessingAuth = true;

    try {
      final metadata = <String, dynamic>{
        'role': event.role,
        'first_name': event.firstName,
      };

      final response = await _supabaseClient.auth.signUp(
        email: event.email,
        password: event.password,
        data: metadata,
      );

      if (response.user == null) {
        emit(const AuthError(message: 'Erreur lors de l\'inscription'));
        return;
      }

      // Verification email desactivee pour la beta — authentification immediate
      _registerPushToken();
      emit(AuthAuthenticated(
        userId: response.user!.id,
        email: response.user!.email ?? '',
        role: event.role,
      ));
    } on AuthException catch (e) {
      emit(AuthError(message: _mapAuthError(e)));
    } catch (e) {
      emit(AuthError(message: 'Une erreur est survenue: $e'));
    } finally {
      _clearProcessingFlagWithDelay();
    }
  }

  // ===========================================================================
  // Deconnexion
  // ===========================================================================

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _removePushToken();
      await _supabaseClient.auth.signOut();
      AppRouter.resetProfileCheck();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // ===========================================================================
  // Reset mot de passe
  // ===========================================================================

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _supabaseClient.auth.resetPasswordForEmail(event.email);
      emit(const AuthPasswordResetSent());
    } on AuthException catch (e) {
      emit(AuthError(message: _mapAuthError(e)));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // ===========================================================================
  // Suppression de compte (RGPD — soft delete 30 jours)
  // ===========================================================================

  /// Flux :
  /// 1. Verifie le mot de passe (re-sign-in)
  /// 2. Appelle l'Edge Function `delete-account` (soft delete en BDD)
  /// 3. Supprime le token FCM + sign out
  Future<void> _onDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    _isProcessingAuth = true;

    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        emit(const AuthError(message: 'Session expiree'));
        return;
      }

      // Verification du mot de passe avant suppression
      try {
        await _supabaseClient.auth.signInWithPassword(
          email: user.email!,
          password: event.password,
        );
      } on AuthException {
        emit(const AuthError(message: 'Mot de passe incorrect'));
        return;
      }

      // Soft delete via Edge Function Supabase
      final response = await _supabaseClient.functions.invoke(
        'delete-account',
        body: {'userId': user.id},
      );

      if (response.status != 200) {
        debugPrint('[AuthBloc] delete-account erreur: ${response.data}');
        emit(const AuthError(
          message: 'Erreur lors de la suppression. Reessayez.',
        ));
        return;
      }

      await _removePushToken();
      await _supabaseClient.auth.signOut();
      emit(const AuthAccountDeleted());
    } catch (e) {
      debugPrint('[AuthBloc] Erreur suppression compte: $e');
      emit(AuthError(message: 'Une erreur est survenue: $e'));
    } finally {
      _clearProcessingFlagWithDelay();
    }
  }

  // ===========================================================================
  // Verification OTP (desactivee en beta, prete pour reactivation)
  // ===========================================================================

  Future<void> _onVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    _isProcessingAuth = true;

    try {
      final response = await _supabaseClient.auth.verifyOTP(
        email: event.email,
        token: event.otpCode,
        type: OtpType.signup,
      );

      if (response.session != null && response.user != null) {
        _registerPushToken();
        emit(AuthAuthenticated(
          userId: response.user!.id,
          email: response.user!.email ?? '',
          role: await _getUserRole(response.user!),
        ));
      } else {
        emit(const AuthError(message: 'Code invalide ou expire'));
      }
    } on AuthException catch (e) {
      emit(AuthError(message: _mapAuthError(e)));
    } catch (e) {
      emit(AuthError(message: 'Erreur de verification: $e'));
    } finally {
      _clearProcessingFlagWithDelay();
    }
  }

  Future<void> _onResendOtpRequested(
    AuthResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _supabaseClient.auth.resend(
        type: OtpType.signup,
        email: event.email,
      );
      emit(AuthEmailVerificationRequired(
        email: event.email,
        role: event.role,
      ));
    } on AuthException catch (e) {
      emit(AuthError(message: _mapAuthError(e)));
    } catch (e) {
      emit(AuthError(message: 'Erreur lors du renvoi: $e'));
    }
  }

  // ===========================================================================
  // Helpers
  // ===========================================================================

  /// Recupere le role utilisateur. Priorite : table user_roles > metadata auth.
  /// Fallback 'seeker' si aucune info trouvee.
  Future<String> _getUserRole(User user) async {
    try {
      final dbRole = await _profileRepository.getUserRole();
      if (dbRole != null) return dbRole;
    } catch (_) {}
    final metadata = user.userMetadata;
    if (metadata != null && metadata.containsKey('role')) {
      return metadata['role'] as String;
    }
    return 'seeker';
  }

  /// Pre-charge la completude du profil pour le gate du router.
  /// En cas d'erreur, le ProfileBloc mettra a jour plus tard.
  Future<void> _preloadProfileCompletion(String role) async {
    if (role == 'admin') return;
    try {
      final pct = await _profileRepository.getProfileCompletionPercentage();
      AppRouter.updateProfileComplete(pct >= 100);
    } catch (_) {}
  }

  /// Traduit les erreurs Supabase Auth en messages utilisateur francais.
  String _mapAuthError(AuthException e) {
    final msg = e.message.toLowerCase();

    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid password') ||
        msg.contains('user not found')) {
      return 'Email ou mot de passe incorrect';
    }
    if (msg.contains('email not confirmed')) {
      return 'Veuillez confirmer votre email';
    }
    if (msg.contains('user already registered') ||
        msg.contains('email already exists')) {
      return 'Cet email est deja utilise';
    }
    if (msg.contains('password') &&
        (msg.contains('weak') || msg.contains('short'))) {
      return 'Le mot de passe doit contenir au moins 8 caracteres';
    }
    if (msg.contains('invalid email')) {
      return 'Veuillez entrer un email valide';
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return 'Trop de tentatives. Veuillez patienter.';
    }
    return e.message;
  }

  /// Remet `_isProcessingAuth` a false apres un delai de 500ms.
  ///
  /// Ce delai est necessaire car Supabase emet des events auth (signedIn,
  /// tokenRefreshed) de maniere asynchrone apres un signIn/signUp.
  /// Sans ce delai, le listener `onAuthStateChange` declenche un
  /// AuthCheckRequested qui emet AuthLoading et cause un flash de redirect.
  void _clearProcessingFlagWithDelay() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _isProcessingAuth = false;
    });
  }

  /// Enregistre le token FCM pour les push notifications (fire and forget).
  void _registerPushToken() {
    if (kIsWeb) return;
    try {
      GetIt.I<PushNotificationService>().registerToken();
    } catch (e) {
      debugPrint('[AuthBloc] Erreur enregistrement push token: $e');
    }
  }

  /// Supprime le token FCM avant deconnexion.
  Future<void> _removePushToken() async {
    if (kIsWeb) return;
    try {
      await GetIt.I<PushNotificationService>().removeToken();
    } catch (e) {
      debugPrint('[AuthBloc] Erreur suppression push token: $e');
    }
  }
}
