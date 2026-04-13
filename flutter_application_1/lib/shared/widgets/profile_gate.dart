library;

/// Gate de completude profil (bloque les actions si profil < 100%).

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../features/profile/data/repositories/profile_repository.dart';

/// Checks profile completion and shows a blocking dialog if incomplete.
///
/// Returns `true` if the user is allowed to proceed (profile 100% complete).
/// Returns `false` if the profile is incomplete (dialog was shown).
Future<bool> checkProfileGate(BuildContext context) async {
  final profileRepo = GetIt.I<ProfileRepository>();
  final percentage = await profileRepo.getProfileCompletionPercentage();

  if (percentage >= 100) return true;

  if (!context.mounted) return false;

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Profil incomplet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: AppColors.greyLight,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryYellow),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            '$percentage% complete',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryOrange,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          const Text(
            'Completez votre profil a 100% pour debloquer cette fonctionnalite.',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Plus tard'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            context.push(AppRoutes.editProfile);
          },
          child: const Text('Completer mon profil'),
        ),
      ],
    ),
  );

  return false;
}
