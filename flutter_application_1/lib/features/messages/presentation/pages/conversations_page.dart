import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/message_repository.dart';

/// Conversations list page
class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String? _error;
  RealtimeChannel? _conversationsChannel;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _subscribeToConversations();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  /// Subscribe to realtime changes on conversations table
  void _subscribeToConversations() {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    debugPrint('[ConversationsPage] Subscribing to realtime conversations...');
    _conversationsChannel = supabase
        .channel('conversations:list:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'conversations',
          callback: (payload) {
            debugPrint('[ConversationsPage] Realtime event: ${payload.eventType}');
            // Reload full list to get enriched data
            _loadConversations(silent: true);
          },
        )
        .subscribe();
  }

  void _unsubscribe() {
    if (_conversationsChannel != null) {
      Supabase.instance.client.removeChannel(_conversationsChannel!);
      _conversationsChannel = null;
    }
  }

  Future<void> _loadConversations({bool silent = false}) async {
    debugPrint('[ConversationsPage] Loading conversations...');
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final messageRepository = GetIt.I<MessageRepository>();
      debugPrint('[ConversationsPage] Repository obtained, fetching...');
      final conversations = await messageRepository.getConversations();
      debugPrint('[ConversationsPage] Got ${conversations.length} conversations');

      if (mounted) {
        setState(() {
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('[ConversationsPage] Error: $e');
      debugPrint('[ConversationsPage] Stack: $stackTrace');
      if (mounted && !silent) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.messages),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadConversations,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryYellow),
            SizedBox(height: AppTheme.spaceMd),
            Text('Chargement des conversations...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppTheme.spaceMd),
              const Text(
                'Erreur de chargement',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.greyWarm),
              ),
              const SizedBox(height: AppTheme.spaceLg),
              ElevatedButton.icon(
                onPressed: _loadConversations,
                icon: const Icon(Icons.refresh),
                label: const Text('Reessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_conversations.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      color: AppColors.primaryYellow,
      child: _buildConversationsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.primaryYellow,
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              'Pas encore de messages',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              'Contactez un candidat depuis le feed pour demarrer une conversation',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.greyWarm,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceLg),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.feed),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Voir le feed'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationsList() {
    final messageRepository = GetIt.I<MessageRepository>();
    final currentUserId = messageRepository.currentUserId ?? '';

    return ListView.separated(
      itemCount: _conversations.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return _ConversationTile(
          conversation: conversation,
          currentUserId: currentUserId,
          onTap: () => context.push(AppRoutes.chatWith(conversation.id)),
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String currentUserId;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  String _formatTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'maintenant';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return days[time.weekday - 1];
    } else {
      return '${time.day}/${time.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = conversation.hasUnread(currentUserId);
    final name = conversation.otherUserName ?? 'Utilisateur';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMd,
        vertical: AppTheme.spaceSm,
      ),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.primaryYellow,
        backgroundImage: conversation.otherUserAvatar != null
            ? NetworkImage(conversation.otherUserAvatar!)
            : null,
        child: conversation.otherUserAvatar == null
            ? Text(
                initial,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.white,
                ),
              )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (conversation.isOtherUserVerified) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.check_circle,
              size: 16,
              color: AppColors.primaryYellow,
            ),
          ],
          const SizedBox(width: 8),
          Text(
            _formatTime(conversation.lastMessageAt ?? conversation.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.greyWarm,
                ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                conversation.lastMessagePreview ?? 'Nouvelle conversation',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isUnread ? AppColors.black : AppColors.greyWarm,
                      fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                      fontStyle: conversation.lastMessagePreview == null
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: 8),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primaryYellow,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
