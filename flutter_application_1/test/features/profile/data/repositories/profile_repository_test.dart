import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:etoile/features/profile/data/repositories/profile_repository.dart';

// ============================================================================
// Mocks
// ============================================================================

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

// ============================================================================
// Tests
// ============================================================================

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late ProfileRepository repository;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();

    when(() => mockSupabase.auth).thenReturn(mockAuth);

    repository = ProfileRepository(supabaseClient: mockSupabase);
  });

  group('currentUserId', () {
    test('returns null when no user is logged in', () {
      when(() => mockAuth.currentUser).thenReturn(null);
      expect(repository.currentUserId, isNull);
    });

    test('returns user ID when user is logged in', () {
      final mockUser = MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.id).thenReturn('user-123');
      expect(repository.currentUserId, 'user-123');
    });
  });

  group('currentUserRole', () {
    test('returns null when no user is logged in', () {
      when(() => mockAuth.currentUser).thenReturn(null);
      expect(repository.currentUserRole, isNull);
    });

    test('returns role from user metadata', () {
      final mockUser = MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.userMetadata).thenReturn({'role': 'recruiter'});
      expect(repository.currentUserRole, 'recruiter');
    });

    test('returns null when metadata has no role', () {
      final mockUser = MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.userMetadata).thenReturn({});
      expect(repository.currentUserRole, isNull);
    });
  });

  group('getSeekerProfile', () {
    test('returns null when no user is logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      final result = await repository.getSeekerProfile();
      expect(result, isNull);
    });
  });

}
