import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/etoile_button.dart';
import '../../../../shared/widgets/etoile_text_field.dart';
import '../bloc/auth_bloc.dart';

/// Forgot password page
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmitPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthPasswordResetRequested(
              email: _emailController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthPasswordResetSent) {
            setState(() {
              _emailSent = true;
            });
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          if (_emailSent) {
            return _buildSuccessContent();
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppTheme.spaceXl),

                    // Title
                    Text(
                      'Mot de passe oublie ?',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: AppTheme.spaceSm),
                    Text(
                      'Entrez votre email et nous vous enverrons un lien pour reinitialiser votre mot de passe.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.greyWarm,
                          ),
                    ),

                    const SizedBox(height: AppTheme.space2Xl),

                    // Email field
                    EtoileTextField(
                      controller: _emailController,
                      label: AppStrings.email,
                      hintText: 'votre@email.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.email_outlined,
                      enabled: !isLoading,
                      onSubmitted: (_) => _onSubmitPressed(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.errorFieldRequired;
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return AppStrings.errorInvalidEmail;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppTheme.spaceLg),

                    // Submit button
                    EtoileButton(
                      onPressed: isLoading ? null : _onSubmitPressed,
                      isLoading: isLoading,
                      label: 'Envoyer le lien',
                    ),

                    const SizedBox(height: AppTheme.spaceLg),

                    // Back to login
                    Center(
                      child: TextButton(
                        onPressed: isLoading ? null : () => context.pop(),
                        child: const Text('Retour a la connexion'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSuccessContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mark_email_read_outlined,
              size: 80,
              color: AppColors.success,
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Text(
              'Email envoye !',
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              'Verifiez votre boite de reception et suivez le lien pour reinitialiser votre mot de passe.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.greyWarm,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.space2Xl),
            EtoileButton(
              onPressed: () => context.pop(),
              label: 'Retour a la connexion',
            ),
            const SizedBox(height: AppTheme.spaceMd),
            TextButton(
              onPressed: () {
                setState(() {
                  _emailSent = false;
                });
              },
              child: const Text('Renvoyer l\'email'),
            ),
          ],
        ),
      ),
    );
  }
}
