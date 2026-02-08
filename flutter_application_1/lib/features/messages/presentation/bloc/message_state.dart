part of 'message_bloc.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object?> get props => [];
}

class MessageInitial extends MessageState {
  const MessageInitial();
}

class MessageLoading extends MessageState {
  const MessageLoading();
}

class MessageLoaded extends MessageState {
  final String conversationId;
  final Conversation conversation;
  final List<Message> messages;
  final bool isSending;

  const MessageLoaded({
    required this.conversationId,
    required this.conversation,
    required this.messages,
    this.isSending = false,
  });

  MessageLoaded copyWith({
    List<Message>? messages,
    bool? isSending,
  }) {
    return MessageLoaded(
      conversationId: conversationId,
      conversation: conversation,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [conversationId, conversation, messages, isSending];
}

class MessageError extends MessageState {
  final String message;

  const MessageError({required this.message});

  @override
  List<Object?> get props => [message];
}
