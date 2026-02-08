import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/etoile_button.dart';
import '../../../../shared/widgets/etoile_text_field.dart';
import '../bloc/auth_bloc.dart';

/// Registration page for new users
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
  String _selectedRole = 'seeker';

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              firstName: _firstNameController.text.trim(),
              role: _selectedRole,
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
          if (state is AuthAuthenticated) {
            context.go(AppRoutes.feed);
          } else if (state is AuthEmailVerificationRequired) {
            // Show dialog for email verification
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('Verifiez votre email'),
                content: const Text(
                  'Un email de confirmation a ete envoye. '
                  'Cliquez sur le lien dans l\'email puis connectez-vous.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.go(AppRoutes.login);
                    },
                    child: const Text('Aller a la connexion'),
                  ),
                ],
              ),
            );
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

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      AppStrings.createAccount,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: AppTheme.spaceSm),
                    Text(
                      AppStrings.createAccountSubtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.greyWarm,
                          ),
                    ),

                    const SizedBox(height: AppTheme.spaceLg),

                    // Role selection
                    _buildRoleSelector(),

                    const SizedBox(height: AppTheme.spaceLg),

                    // First name field
                    EtoileTextField(
                      controller: _firstNameController,
                      label: AppStrings.firstName,
                      hintText: 'Votre prenom',
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.person_outlined,
                      enabled: !isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.errorFieldRequired;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppTheme.spaceMd),

                    // Email field
                    EtoileTextField(
                      controller: _emailController,
                      label: AppStrings.email,
                      hintText: 'votre@email.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.email_outlined,
                      enabled: !isLoading,
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

                    const SizedBox(height: AppTheme.spaceMd),

                    // Password field
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
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.errorFieldRequired;
                        }
                        if (value.length < 8) {
                          return AppStrings.errorInvalidPassword;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppTheme.spaceMd),

                    // Confirm password field
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
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      onSubmitted: (_) => _onRegisterPressed(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.errorFieldRequired;
                        }
                        if (value != _passwordController.text) {
                          return AppStrings.errorPasswordMismatch;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppTheme.spaceLg),

                    // Register button
                    EtoileButton(
                      onPressed: isLoading ? null : _onRegisterPressed,
                      isLoading: isLoading,
                      label: AppStrings.continueAction,
                    ),

                    const SizedBox(height: AppTheme.spaceLg),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.greyWarm,
                              ),
                        ),
                        TextButton(
                          onPressed:
                              isLoading ? null : () => context.push(AppRoutes.login),
                          child: Text(
                            AppStrings.login,
                            style: TextStyle(
                              color: AppColors.primaryYellow,
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

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Je suis...',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.greyWarm,
              ),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Row(
          children: [
            Expanded(
              child: _RoleCard(
                title: 'Chercheur',
                subtitle: "d'emploi",
                icon: Icons.person_search_outlined,
                isSelected: _selectedRole == 'seeker',
                onTap: () => setState(() => _selectedRole = 'seeker'),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: _RoleCard(
                title: 'Recruteur',
                subtitle: "d'entreprise",
                icon: Icons.business_outlined,
                isSelected: _selectedRole == 'recruiter',
                onTap: () => setState(() => _selectedRole = 'recruiter'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tagBackground : AppColors.greyLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.primaryYellow : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primaryOrange : AppColors.greyWarm,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected ? AppColors.black : AppColors.greyWarm,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.greyWarm,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
