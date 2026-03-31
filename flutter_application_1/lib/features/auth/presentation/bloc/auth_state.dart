/// Etats du BLoC d'authentification (initial, charge, authentifie, erreur).

part of 'auth_bloc.dart';

/// Classe mere des etats d'authentification.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Etat initial avant toute verification.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Operation d'authentification en cours.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Utilisateur connecte. Contient le role pour les guards de navigation.
class AuthAuthenticated extends AuthState {
  final String userId;
  final String email;
  final String role;

  const AuthAuthenticated({
    required this.userId,
    required this.email,
    required this.role,
  });

  bool get isSeeker => role == 'seeker';
  bool get isRecruiter => role == 'recruiter';
  bool get isAdmin => role == 'admin';

  @override
  List<Object> get props => [userId, email, role];
}

/// Utilisateur non connecte.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Verification email requise apres inscription (OTP).
/// Desactive en beta — pret pour reactivation.
class AuthEmailVerificationRequired extends AuthState {
  final String email;
  final String role;

  const AuthEmailVerificationRequired({
    required this.email,
    required this.role,
  });

  @override
  List<Object> get props => [email, role];
}

/// Email de reset mot de passe envoye avec succes.
class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

/// Compte supprime (RGPD soft delete).
class AuthAccountDeleted extends AuthState {
  const AuthAccountDeleted();
}

/// Erreur d'authentification.
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
