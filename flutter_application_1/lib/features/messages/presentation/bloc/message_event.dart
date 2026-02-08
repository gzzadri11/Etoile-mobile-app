part of 'message_bloc.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

/// Load messages for a conversation
class MessageLoadRequested extends MessageEvent {
  final String conversationId;

  const MessageLoadRequested({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];
}

/// Send a new message
class MessageSendRequested extends MessageEvent {
  final String content;

  const MessageSendRequested({required this.content});

  @override
  List<Object?> get props => [content];
}

/// New message received (realtime)
class MessageReceived extends MessageEvent {
  final Message message;

  const MessageReceived({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Mark messages as read
class MessageMarkAsRead extends MessageEvent {
  final String conversationId;

  const MessageMarkAsRead({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];
}
