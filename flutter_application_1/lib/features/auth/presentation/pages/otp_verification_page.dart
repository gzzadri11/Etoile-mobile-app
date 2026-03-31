library;

/// Page de verification OTP par email (6 chiffres).
///
/// Affichee apres l'inscription pour valider l'adresse email
/// de l'utilisateur via Supabase Auth verifyOTP.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/etoile_button.dart';
import '../bloc/auth_bloc.dart';

/// OTP verification page shown after registration when email confirmation is required.
class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String role;

  const OtpVerificationPage({
    super.key,
    required this.email,
    required this.role,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  Timer? _resendTimer;
  int _resendSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds <= 0) {
        timer.cancel();
        if (mounted) setState(() => _canResend = true);
      } else {
        if (mounted) setState(() => _resendSeconds--);
      }
    });
  }

  void _onVerify() {
    final code = _otpController.text.trim();
    if (code.length != 6) return;

    context.read<AuthBloc>().add(AuthVerifyOtpRequested(
          email: widget.email,
          otpCode: code,
        ));
  }

  void _onResend() {
    if (!_canResend) return;
    context.read<AuthBloc>().add(AuthResendOtpRequested(
          email: widget.email,
          role: widget.role,
        ));
    _startResendTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code renvoye'),
        backgroundColor: AppColors.success,
      ),
    );
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
            final route = widget.role == 'recruiter'
                ? AppRoutes.onboardingRecruiter
                : AppRoutes.onboardingSeeker;
            context.go(route);
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
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Email icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      size: 40,
                      color: AppColors.primaryOrange,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  Text(
                    'Verifiez votre email',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppTheme.spaceSm),

                  Text(
                    'Un code a 6 chiffres a ete envoye a',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.greyWarm,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    widget.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppTheme.spaceLg * 2),

                  // OTP input field
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      enabled: !isLoading,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 12,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '------',
                        hintStyle: TextStyle(
                          fontSize: 28,
                          letterSpacing: 12,
                          color: AppColors.greyMedium,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: const BorderSide(
                            color: AppColors.primaryYellow,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 6) _onVerify();
                      },
                    ),
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // Verify button
                  EtoileButton(
                    label: 'Verifier',
                    onPressed: isLoading ? null : _onVerify,
                    isLoading: isLoading,
                  ),

                  const SizedBox(height: AppTheme.spaceLg),

                  // Resend button
                  if (_canResend)
                    TextButton(
                      onPressed: _onResend,
                      child: const Text('Renvoyer le code'),
                    )
                  else
                    Text(
                      'Renvoyer dans ${_resendSeconds}s',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.greyWarm,
                          ),
                    ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
