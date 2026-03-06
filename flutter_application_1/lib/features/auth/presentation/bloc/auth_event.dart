part of 'auth_bloc.dart';

/// Base class for all auth events
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if user is authenticated (on app startup)
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Login with email and password
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

/// Register new user
class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String firstName;
  final String role; // 'seeker' or 'recruiter'
  final String? siret;
  final String? companyName;
  final String? siren;
  final String? legalForm;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.role,
    this.siret,
    this.companyName,
    this.siren,
    this.legalForm,
  });

  @override
  List<Object?> get props =>
      [email, password, firstName, role, siret, companyName];
}

/// Logout current user
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Request password reset email
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object> get props => [email];
}

/// Delete account (RGPD - soft delete)
class AuthDeleteAccountRequested extends AuthEvent {
  final String password;

  const AuthDeleteAccountRequested({required this.password});

  @override
  List<Object> get props => [password];
}

/// Email verification completed
class AuthEmailVerified extends AuthEvent {
  const AuthEmailVerified();
}

/// Verify OTP code entered by user
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

/// Resend OTP code
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
