import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:etoile/features/messages/data/repositories/block_repository.dart';

// Mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late BlockRepository repo;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
    repo = BlockRepository(supabaseClient: mockClient);
  });

  group('blockUser', () {
    test('throws when not connected', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(
        () => repo.blockUser('other-user-id'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Non connecte'),
        )),
      );
    });

    test('throws when blocking self', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      expect(
        () => repo.blockUser('user-123'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('vous-meme'),
        )),
      );
    });
  });

  group('getBlockedUserIds', () {
    test('returns empty list when not connected', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await repo.getBlockedUserIds();
      expect(result, isEmpty);
    });
  });

  group('isBlocked', () {
    test('returns false when not connected', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = await repo.isBlocked('other-id');
      expect(result, false);
    });
  });

  group('unblockUser', () {
    test('does nothing when not connected', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      // Should not throw
      await repo.unblockUser('other-id');
    });
  });
}
