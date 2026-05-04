library;

/// Page d'authentification administrateur (second facteur).
///
/// Apres la connexion classique, l'admin doit saisir un code secret
/// verifie cote serveur via une RPC bcrypt Supabase.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';

/// Page d'authentification admin — second facteur apres login.
/// Requiert un code secret verifie cote serveur via RPC bcrypt.
class AdminAuthPage extends StatefulWidget {
  const AdminAuthPage({super.key});

  @override
  State<AdminAuthPage> createState() => _AdminAuthPageState();
}

class _AdminAuthPageState extends State<AdminAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await Supabase.instance.client.rpc(
        'verify_admin_secrets',
        params: {'code': _codeController.text.trim()},
      );

      if (!mounted) return;

      if (result == true) {
        AppRouter.verifyAdminSession();
        context.go(AppRoutes.admin);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code incorrect'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur de verification'),
          backgroundColor: AppColors.danger,
        ),
      );
      debugPrint('[AdminAuth] Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acces administration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.search),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shield,
                  size: 64,
                  color: AppColors.accent,
                ),
                const SizedBox(height: AppTheme.spaceLg),
                Text(
                  'Vérification de sécurité',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Text(
                  'Entrez votre code d\'accès pour continuer',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spaceLg * 2),
                TextFormField(
                  controller: _codeController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Code d\'acces',
                    prefixIcon: Icon(Icons.key_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer le code';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _verify(),
                ),
                const SizedBox(height: AppTheme.spaceLg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verify,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Verifier'),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                TextButton(
                  onPressed: () => context.go(AppRoutes.search),
                  child: const Text('Retour'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
