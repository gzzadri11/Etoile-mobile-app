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

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.role,
  });

  @override
  List<Object> get props => [email, password, firstName, role];
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

/// Email verification completed
class AuthEmailVerified extends AuthEvent {
  const AuthEmailVerified();
}
