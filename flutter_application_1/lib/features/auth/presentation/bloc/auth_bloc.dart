import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/push_notification_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Authentication BLoC
///
/// Manages authentication state across the application.
/// Handles login, registration, logout, and session management.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseClient _supabaseClient;

  AuthBloc({
    required SupabaseClient supabaseClient,
  })  : _supabaseClient = supabaseClient,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthDeleteAccountRequested>(_onDeleteAccountRequested);

    // Listen to auth state changes
    _supabaseClient.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        add(const AuthCheckRequested());
      }
    });
  }

  /// Check if user is already authenticated
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('[AuthBloc] Checking authentication...');
    emit(const AuthLoading());

    try {
      final session = _supabaseClient.auth.currentSession;
      debugPrint('[AuthBloc] Session: ${session != null ? 'exists' : 'null'}');

      if (session != null) {
        final user = _supabaseClient.auth.currentUser;
        debugPrint('[AuthBloc] User: ${user?.email ?? 'null'}');
        if (user != null) {
          debugPrint('[AuthBloc] Authenticated as ${user.email}');
          emit(AuthAuthenticated(
            userId: user.id,
            email: user.email ?? '',
            role: _getUserRole(user),
          ));
          return;
        }
      }

      debugPrint('[AuthBloc] Not authenticated');
      emit(const AuthUnauthenticated());
    } catch (e) {
      debugPrint('[AuthBloc] Error: $e');
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle login request
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        // Register FCM token for push notifications
        _registerPushToken();

        emit(AuthAuthenticated(
          userId: response.user!.id,
          email: response.user!.email ?? '',
          role: _getUserRole(response.user!),
        ));
      } else {
        emit(const AuthError(message: 'Email ou mot de passe incorrect'));
      }
    } on AuthException catch (e) {
      emit(AuthError(message: _mapAuthError(e)));
    } catch (e) {
      emit(AuthError(message: 'Une erreur est survenue: ${e.toString()}'));
    }
  }

  /// Handle registration request
  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final metadata = <String, dynamic>{
        'role': event.role,
        'first_name': event.firstName,
      };
      if (event.siret != null) metadata['siret'] = event.siret;
      if (event.companyName != null) {
        metadata['company_name'] = event.companyName;
      }
      if (event.siren != null) metadata['siren'] = event.siren;
      if (event.legalForm != null) metadata['legal_form'] = event.legalForm;

      final response = await _supabaseClient.auth.signUp(
        email: event.email,
        password: event.password,
        data: metadata,
      );

      if (response.user != null) {
        // Check if email confirmation is required
        if (response.session != null) {
          // Register FCM token for push notifications
          _registerPushToken();

          emit(AuthAuthenticated(
            userId: response.user!.id,
            email: response.user!.email ?? '',
            role: event.role,
          ));
        } else {
          emit(const AuthEmailVerificationRequired());
        }
      } else {
        emit(const AuthError(message: 'Erreur lors de l\'inscription'));
      }
    } on AuthException catch (e) {
      emit(AuthError(message: _mapAuthError(e)));
    } catch (e) {
      emit(AuthError(message: 'Une erreur est survenue: ${e.toString()}'));
    }
  }

  /// Handle logout request
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Remove FCM token before logout
      await _removePushToken();

      await _supabaseClient.auth.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handle password reset request
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

  /// Handle delete account request (RGPD soft delete)
  Future<void> _onDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        emit(const AuthError(message: 'Session expirée'));
        return;
      }

      // Verify password first
      try {
        await _supabaseClient.auth.signInWithPassword(
          email: user.email!,
          password: event.password,
        );
      } on AuthException {
        emit(const AuthError(message: 'Mot de passe incorrect'));
        return;
      }

      // Call Edge Function for soft delete
      final response = await _supabaseClient.functions.invoke(
        'delete-account',
        body: {'userId': user.id},
      );

      if (response.status != 200) {
        debugPrint('[AuthBloc] delete-account error: ${response.data}');
        emit(const AuthError(
          message: 'Erreur lors de la suppression. Réessayez.',
        ));
        return;
      }

      debugPrint('[AuthBloc] Account soft-deleted for ${user.email}');

      // Remove push token and sign out
      await _removePushToken();
      await _supabaseClient.auth.signOut();

      emit(const AuthAccountDeleted());
    } catch (e) {
      debugPrint('[AuthBloc] Delete account error: $e');
      emit(AuthError(message: 'Une erreur est survenue: ${e.toString()}'));
    }
  }

  /// Extract user role from metadata
  String _getUserRole(User user) {
    final metadata = user.userMetadata;
    if (metadata != null && metadata.containsKey('role')) {
      return metadata['role'] as String;
    }
    return 'seeker'; // Default role
  }

  /// Map Supabase auth errors to user-friendly messages
  String _mapAuthError(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid password') ||
        message.contains('user not found')) {
      return 'Email ou mot de passe incorrect';
    }

    if (message.contains('email not confirmed')) {
      return 'Veuillez confirmer votre email';
    }

    if (message.contains('user already registered') ||
        message.contains('email already exists')) {
      return 'Cet email est deja utilise';
    }

    if (message.contains('password') &&
        (message.contains('weak') || message.contains('short'))) {
      return 'Le mot de passe doit contenir au moins 8 caracteres';
    }

    if (message.contains('invalid email')) {
      return 'Veuillez entrer un email valide';
    }

    if (message.contains('rate limit') || message.contains('too many')) {
      return 'Trop de tentatives. Veuillez patienter.';
    }

    return e.message;
  }

  /// Register FCM push token (fire and forget, skip on web)
  void _registerPushToken() {
    if (kIsWeb) return;
    try {
      final pushService = GetIt.I<PushNotificationService>();
      pushService.registerToken();
    } catch (e) {
      debugPrint('[AuthBloc] Error registering push token: $e');
    }
  }

  /// Remove FCM push token before logout (skip on web)
  Future<void> _removePushToken() async {
    if (kIsWeb) return;
    try {
      final pushService = GetIt.I<PushNotificationService>();
      await pushService.removeToken();
    } catch (e) {
      debugPrint('[AuthBloc] Error removing push token: $e');
    }
  }
}
