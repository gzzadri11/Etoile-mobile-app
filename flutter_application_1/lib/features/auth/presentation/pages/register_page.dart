library;

/// Page d'inscription chercheur (prenom, email, mot de passe).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/validators.dart';
import '../../../../shared/widgets/etoile_button.dart';
import '../../../../shared/widgets/etoile_text_field.dart';
import '../bloc/auth_bloc.dart';

/// Page d'inscription seeker-only.
///
/// Parcours : prenom + email + mot de passe.
/// Apres inscription, redirige vers l'onboarding seeker.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthBloc>().add(AuthRegisterRequested(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      role: 'seeker',
    ));
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
          if (state is AuthAuthenticated) {
            context.go(AppRoutes.onboardingSeeker);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.createAccount,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: AppTheme.spaceSm),
                    Text(
                      AppStrings.createAccountSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceLg),

                    EtoileTextField(
                      controller: _firstNameController,
                      label: AppStrings.firstName,
                      hintText: 'Votre prenom',
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.person_outlined,
                      enabled: !isLoading,
                      validator: validateRequired,
                    ),

                    const SizedBox(height: AppTheme.spaceMd),
                    EtoileTextField(
                      controller: _emailController,
                      label: AppStrings.email,
                      hintText: 'votre@email.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.email_outlined,
                      enabled: !isLoading,
                      validator: validateEmail,
                    ),

                    const SizedBox(height: AppTheme.spaceMd),
                    EtoileTextField(
                      controller: _passwordController,
                      label: AppStrings.password,
                      hintText: 'Au moins 8 caracteres',
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.lock_outlined,
                      enabled: !isLoading,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: validatePassword,
                    ),

                    const SizedBox(height: AppTheme.spaceMd),
                    EtoileTextField(
                      controller: _confirmPasswordController,
                      label: AppStrings.confirmPassword,
                      hintText: 'Confirmez votre mot de passe',
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_outlined,
                      enabled: !isLoading,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                            () => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      onSubmitted: (_) => _onRegisterPressed(),
                      validator: validatePasswordConfirmation(
                        _passwordController.text,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spaceLg),
                    EtoileButton(
                      onPressed: isLoading ? null : _onRegisterPressed,
                      isLoading: isLoading,
                      label: AppStrings.continueAction,
                    ),

                    const SizedBox(height: AppTheme.spaceLg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.push(AppRoutes.login),
                          child: Text(
                            AppStrings.login,
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spaceLg),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
