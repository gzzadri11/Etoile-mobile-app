part of 'auth_bloc.dart';

/// Base class for all auth states
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before checking authentication
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during authentication operations
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated
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

/// User is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Email verification required after registration
class AuthEmailVerificationRequired extends AuthState {
  const AuthEmailVerificationRequired();
}

/// Password reset email sent successfully
class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

/// Authentication error occurred
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
