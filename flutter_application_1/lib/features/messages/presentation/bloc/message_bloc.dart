import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/message_model.dart';
import '../../data/repositories/message_repository.dart';

part 'message_event.dart';
part 'message_state.dart';

/// BLoC for managing chat messages
class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final MessageRepository _messageRepository;
  RealtimeChannel? _messageChannel;

  MessageBloc({required MessageRepository messageRepository})
      : _messageRepository = messageRepository,
        super(const MessageInitial()) {
    on<MessageLoadRequested>(_onLoadRequested);
    on<MessageSendRequested>(_onSendRequested);
    on<MessageReceived>(_onMessageReceived);
    on<MessageMarkAsRead>(_onMarkAsRead);
  }

  String? get currentUserId => _messageRepository.currentUserId;

  Future<void> _onLoadRequested(
    MessageLoadRequested event,
    Emitter<MessageState> emit,
  ) async {
    emit(const MessageLoading());

    try {
      // Load conversation info
      final conversation = await _messageRepository.getConversation(
        event.conversationId,
      );

      if (conversation == null) {
        emit(const MessageError(message: 'Conversation introuvable'));
        return;
      }

      // Load messages
      final messages = await _messageRepository.getMessages(event.conversationId);

      // Subscribe to realtime updates
      _unsubscribe();
      _messageChannel = _messageRepository.subscribeToMessages(
        event.conversationId,
        (message) => add(MessageReceived(message: message)),
      );

      emit(MessageLoaded(
        conversationId: event.conversationId,
        conversation: conversation,
        messages: messages,
      ));

      // Mark as read
      add(MessageMarkAsRead(conversationId: event.conversationId));
    } catch (e) {
      emit(MessageError(message: 'Erreur: ${e.toString()}'));
    }
  }

  Future<void> _onSendRequested(
    MessageSendRequested event,
    Emitter<MessageState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MessageLoaded) return;

    try {
      // Optimistic UI: add message immediately
      final optimisticMessage = Message(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: currentState.conversationId,
        senderId: currentUserId ?? '',
        content: event.content,
        createdAt: DateTime.now(),
      );

      emit(currentState.copyWith(
        messages: [...currentState.messages, optimisticMessage],
        isSending: true,
      ));

      // Send to server
      final sentMessage = await _messageRepository.sendMessage(
        conversationId: currentState.conversationId,
        content: event.content,
      );

      // Replace optimistic message with real one
      final updatedMessages = currentState.messages
          .where((m) => !m.id.startsWith('temp_'))
          .toList()
        ..add(sentMessage);

      emit(currentState.copyWith(
        messages: updatedMessages,
        isSending: false,
      ));
    } catch (e) {
      // Remove optimistic message on error
      final currentMessages = (state as MessageLoaded).messages;
      emit((state as MessageLoaded).copyWith(
        messages: currentMessages.where((m) => !m.id.startsWith('temp_')).toList(),
        isSending: false,
      ));
    }
  }

  void _onMessageReceived(
    MessageReceived event,
    Emitter<MessageState> emit,
  ) {
    final currentState = state;
    if (currentState is! MessageLoaded) return;

    // Don't add if it's our own message (already added optimistically)
    if (event.message.senderId == currentUserId) return;

    // Don't add duplicates
    if (currentState.messages.any((m) => m.id == event.message.id)) return;

    emit(currentState.copyWith(
      messages: [...currentState.messages, event.message],
    ));

    // Mark as read
    add(MessageMarkAsRead(conversationId: currentState.conversationId));
  }

  Future<void> _onMarkAsRead(
    MessageMarkAsRead event,
    Emitter<MessageState> emit,
  ) async {
    try {
      await _messageRepository.markMessagesAsRead(event.conversationId);
    } catch (e) {
      // Silently fail
    }
  }

  void _unsubscribe() {
    if (_messageChannel != null) {
      _messageRepository.unsubscribeFromMessages(_messageChannel!);
      _messageChannel = null;
    }
  }

  @override
  Future<void> close() {
    _unsubscribe();
    return super.close();
  }
}
