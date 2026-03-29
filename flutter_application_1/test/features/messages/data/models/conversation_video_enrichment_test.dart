import 'package:flutter_test/flutter_test.dart';
import 'package:etoile/features/messages/data/models/message_model.dart';

void main() {
  group('Conversation video enrichment', () {
    late Conversation baseConversation;

    setUp(() {
      baseConversation = Conversation(
        id: 'conv-1',
        participant1: 'user-a',
        participant2: 'user-b',
        videoId: 'vid-123',
        createdAt: DateTime(2026, 3, 20),
      );
    });

    test('new video fields default to null', () {
      expect(baseConversation.videoTitle, isNull);
      expect(baseConversation.videoType, isNull);
      expect(baseConversation.videoThumbnailUrl, isNull);
    });

    test('copyWith sets video fields', () {
      final enriched = baseConversation.copyWith(
        videoTitle: 'Vendeur alternance',
        videoType: 'offer',
        videoThumbnailUrl: 'https://example.com/thumb.jpg',
      );

      expect(enriched.videoTitle, 'Vendeur alternance');
      expect(enriched.videoType, 'offer');
      expect(enriched.videoThumbnailUrl, 'https://example.com/thumb.jpg');
      // Original fields preserved
      expect(enriched.id, 'conv-1');
      expect(enriched.videoId, 'vid-123');
      expect(enriched.participant1, 'user-a');
    });

    test('copyWith preserves existing video fields when not overridden', () {
      final step1 = baseConversation.copyWith(
        otherUserName: 'Jean Dupont',
        videoTitle: 'Serveur temps plein',
      );
      final step2 = step1.copyWith(
        otherUserRole: 'seeker',
      );

      expect(step2.otherUserName, 'Jean Dupont');
      expect(step2.videoTitle, 'Serveur temps plein');
      expect(step2.otherUserRole, 'seeker');
    });

    test('conversation without videoId has null video fields', () {
      final noVideo = Conversation(
        id: 'conv-2',
        participant1: 'user-a',
        participant2: 'user-b',
        createdAt: DateTime(2026, 3, 20),
      );

      expect(noVideo.videoId, isNull);
      expect(noVideo.videoTitle, isNull);
    });

    test('props includes videoTitle for equality checks', () {
      final a = baseConversation.copyWith(videoTitle: 'Offre A');
      final b = baseConversation.copyWith(videoTitle: 'Offre B');
      // Props includes videoTitle, so these should differ
      expect(a.props, isNot(equals(b.props)));
    });
  });
}
