import 'package:equatable/equatable.dart';

/// Model representing a message
class Message extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String contentType; // 'text' or 'system'
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.contentType = 'text',
    this.isRead = false,
    this.readAt,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      contentType: json['content_type'] as String? ?? 'text',
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'content_type': contentType,
    };
  }

  @override
  List<Object?> get props => [id, conversationId, senderId, content, createdAt];
}

/// Model representing a conversation with participant info
class Conversation extends Equatable {
  final String id;
  final String participant1;
  final String participant2;
  final String? videoId;
  final DateTime? lastMessageAt;
  final String? lastMessagePreview;
  final DateTime? participant1ReadAt;
  final DateTime? participant2ReadAt;
  final DateTime createdAt;

  // Populated fields
  final String? otherUserName;
  final String? otherUserAvatar;
  final String? otherUserTitle;
  final bool isOtherUserVerified;

  const Conversation({
    required this.id,
    required this.participant1,
    required this.participant2,
    this.videoId,
    this.lastMessageAt,
    this.lastMessagePreview,
    this.participant1ReadAt,
    this.participant2ReadAt,
    required this.createdAt,
    this.otherUserName,
    this.otherUserAvatar,
    this.otherUserTitle,
    this.isOtherUserVerified = false,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      participant1: json['participant_1'] as String,
      participant2: json['participant_2'] as String,
      videoId: json['video_id'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      lastMessagePreview: json['last_message_preview'] as String?,
      participant1ReadAt: json['participant_1_read_at'] != null
          ? DateTime.parse(json['participant_1_read_at'] as String)
          : null,
      participant2ReadAt: json['participant_2_read_at'] != null
          ? DateTime.parse(json['participant_2_read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Check if current user has unread messages
  bool hasUnread(String currentUserId) {
    if (lastMessageAt == null) return false;

    final readAt = currentUserId == participant1
        ? participant1ReadAt
        : participant2ReadAt;

    if (readAt == null) return true;
    return lastMessageAt!.isAfter(readAt);
  }

  /// Get the other participant's ID
  String getOtherParticipantId(String currentUserId) {
    return currentUserId == participant1 ? participant2 : participant1;
  }

  Conversation copyWith({
    String? otherUserName,
    String? otherUserAvatar,
    String? otherUserTitle,
    bool? isOtherUserVerified,
  }) {
    return Conversation(
      id: id,
      participant1: participant1,
      participant2: participant2,
      videoId: videoId,
      lastMessageAt: lastMessageAt,
      lastMessagePreview: lastMessagePreview,
      participant1ReadAt: participant1ReadAt,
      participant2ReadAt: participant2ReadAt,
      createdAt: createdAt,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserAvatar: otherUserAvatar ?? this.otherUserAvatar,
      otherUserTitle: otherUserTitle ?? this.otherUserTitle,
      isOtherUserVerified: isOtherUserVerified ?? this.isOtherUserVerified,
    );
  }

  @override
  List<Object?> get props => [id, participant1, participant2, lastMessageAt];
}
