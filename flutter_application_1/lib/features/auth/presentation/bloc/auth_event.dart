/// Evenements du BLoC d'authentification (connexion, inscription, deconnexion).

part of 'auth_bloc.dart';

/// Classe mere des events d'authentification.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Verification de session au demarrage de l'app.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Connexion par email/mot de passe.
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Inscription d'un nouveau chercheur.
class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String role;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.firstName,
    this.role = 'seeker',
  });

  @override
  List<Object?> get props => [email, password, firstName, role];
}

/// Deconnexion.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Demande de reinitialisation du mot de passe par email.
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object> get props => [email];
}

/// Suppression de compte (RGPD soft delete).
/// Necessite le mot de passe pour verification.
class AuthDeleteAccountRequested extends AuthEvent {
  final String password;

  const AuthDeleteAccountRequested({required this.password});

  @override
  List<Object> get props => [password];
}

/// Verification du code OTP 6 chiffres (email confirmation).
/// Desactive en beta, pret pour reactivation.
class AuthVerifyOtpRequested extends AuthEvent {
  final String email;
  final String otpCode;

  const AuthVerifyOtpRequested({
    required this.email,
    required this.otpCode,
  });

  @override
  List<Object> get props => [email, otpCode];
}

/// Renvoi du code OTP.
class AuthResendOtpRequested extends AuthEvent {
  final String email;
  final String role;

  const AuthResendOtpRequested({
    required this.email,
    required this.role,
  });

  @override
  List<Object> get props => [email, role];
}
