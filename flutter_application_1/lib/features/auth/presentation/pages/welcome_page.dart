library;

/// Page d'accueil pour les utilisateurs non authentifies.
///
/// Affiche le branding de l'application avec le slogan,
/// la mascotte et les boutons de connexion / inscription.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';

/// Page d'accueil affichee aux utilisateurs non authentifies.
///
/// Presente le branding avec le slogan,
/// and CTA buttons for seekers, recruiters, and existing users.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: AppColors.black,
                  size: 36,
                ),
              ),

              const SizedBox(height: AppTheme.spaceLg),

              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradient.createShader(bounds),
                child: const Text(
                  'ETOILE',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    letterSpacing: 6,
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.spaceSm),

              Text(
                '40 secondes pour briller',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.greyWarm,
                    ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push(AppRoutes.register),
                  child: const Text('Je cherche une alternance'),
                ),
              ),

              const SizedBox(height: AppTheme.spaceLg),

              TextButton(
                onPressed: () => context.push(AppRoutes.login),
                child: const Text('Deja un compte ? Se connecter'),
              ),

              const SizedBox(height: AppTheme.space2Xl),
            ],
          ),
        ),
      ),
    );
  }
}
