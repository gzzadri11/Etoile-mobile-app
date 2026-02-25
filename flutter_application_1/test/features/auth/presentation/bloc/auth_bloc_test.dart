import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import 'package:etoile/features/auth/presentation/bloc/auth_bloc.dart';

// ============================================================================
// Mocks
// ============================================================================

class MockSupabaseClient extends Mock implements supa.SupabaseClient {}

class MockGoTrueClient extends Mock implements supa.GoTrueClient {}

class MockFunctionsClient extends Mock implements supa.FunctionsClient {}

class MockUser extends Mock implements supa.User {}

class MockSession extends Mock implements supa.Session {}

// ============================================================================
// Tests
// ============================================================================

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockFunctionsClient mockFunctions;
  late StreamController<supa.AuthState> authStateController;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockFunctions = MockFunctionsClient();
    authStateController = StreamController<supa.AuthState>.broadcast();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockSupabase.functions).thenReturn(mockFunctions);
    when(() => mockAuth.onAuthStateChange)
        .thenAnswer((_) => authStateController.stream);
  });

  tearDown(() {
    authStateController.close();
  });

  AuthBloc buildBloc() => AuthBloc(supabaseClient: mockSupabase);

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when no session',
      build: () {
        when(() => mockAuth.currentSession).thenReturn(null);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when session exists',
      build: () {
        final mockSession = MockSession();
        final mockUser = MockUser();
        when(() => mockAuth.currentSession).thenReturn(mockSession);
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.id).thenReturn('user-123');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.userMetadata).thenReturn({'role': 'seeker'});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>()
            .having((s) => s.email, 'email', 'test@example.com')
            .having((s) => s.role, 'role', 'seeker'),
      ],
    );
  });

  group('AuthLoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful login',
      build: () {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('user-123');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.userMetadata).thenReturn({'role': 'seeker'});

        when(() => mockAuth.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => supa.AuthResponse(
              session: MockSession(),
              user: mockUser,
            ));

        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'test@example.com',
        password: 'password123',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>()
            .having((s) => s.email, 'email', 'test@example.com'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] on wrong password',
      build: () {
        when(() => mockAuth.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(const supa.AuthException('Invalid login credentials'));

        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'test@example.com',
        password: 'wrong',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>()
            .having((s) => s.message, 'message', 'Email ou mot de passe incorrect'),
      ],
    );
  });

  group('AuthRegisterRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on successful registration',
      build: () {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('user-456');
        when(() => mockUser.email).thenReturn('new@example.com');
        when(() => mockUser.userMetadata).thenReturn({'role': 'seeker'});

        when(() => mockAuth.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              data: any(named: 'data'),
            )).thenAnswer((_) async => supa.AuthResponse(
              session: MockSession(),
              user: mockUser,
            ));

        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthRegisterRequested(
        email: 'new@example.com',
        password: 'password123',
        firstName: 'Test',
        role: 'seeker',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>()
            .having((s) => s.role, 'role', 'seeker'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when email already exists',
      build: () {
        when(() => mockAuth.signUp(
              email: any(named: 'email'),
              password: any(named: 'password'),
              data: any(named: 'data'),
            )).thenThrow(const supa.AuthException('User already registered'));

        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthRegisterRequested(
        email: 'existing@example.com',
        password: 'password123',
        firstName: 'Test',
        role: 'seeker',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>()
            .having((s) => s.message, 'message', 'Cet email est deja utilise'),
      ],
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on logout',
      build: () {
        when(() => mockAuth.signOut()).thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
    );
  });

  group('AuthDeleteAccountRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when password is wrong',
      build: () {
        final mockUser = MockUser();
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockAuth.signInWithPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(
                const supa.AuthException('Invalid login credentials'));

        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthDeleteAccountRequested(
        password: 'wrong',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>()
            .having((s) => s.message, 'message', 'Mot de passe incorrect'),
      ],
    );
  });

  group('AuthPasswordResetRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthPasswordResetSent] on success',
      build: () {
        when(() => mockAuth.resetPasswordForEmail(any()))
            .thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AuthPasswordResetRequested(
        email: 'test@example.com',
      )),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthPasswordResetSent>(),
      ],
    );
  });
}
