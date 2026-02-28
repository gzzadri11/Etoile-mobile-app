import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../messages/data/repositories/block_repository.dart';

/// Page listing all blocked users with the ability to unblock.
class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  List<Map<String, dynamic>> _blockedUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() => _isLoading = true);
    try {
      final blockRepo = GetIt.I<BlockRepository>();
      final users = await blockRepo.getBlockedUsersWithDetails();
      if (mounted) {
        setState(() {
          _blockedUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _unblockUser(String userId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Debloquer cet utilisateur ?'),
        content: Text('Voulez-vous debloquer $name ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Debloquer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final blockRepo = GetIt.I<BlockRepository>();
      await blockRepo.unblockUser(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name a ete debloque')),
        );
        _loadBlockedUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utilisateurs bloques'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _blockedUsers.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.block,
                  title: 'Aucun utilisateur bloque',
                  subtitle:
                      'Les utilisateurs que vous bloquez apparaitront ici.',
                )
              : RefreshIndicator(
                  onRefresh: _loadBlockedUsers,
                  child: ListView.separated(
                    itemCount: _blockedUsers.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = _blockedUsers[index];
                      final name = user['name'] as String;
                      final blockedAt =
                          DateTime.tryParse(user['blockedAt'] as String);
                      final dateStr = blockedAt != null
                          ? DateFormat('dd/MM/yyyy').format(blockedAt)
                          : '';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.greyLight,
                          child: const Icon(Icons.person,
                              color: AppColors.greyMedium),
                        ),
                        title: Text(name),
                        subtitle: Text(
                          'Bloque le $dateStr',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.greyWarm),
                        ),
                        trailing: TextButton(
                          onPressed: () => _unblockUser(
                            user['userId'] as String,
                            name,
                          ),
                          child: const Text(
                            'Debloquer',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
