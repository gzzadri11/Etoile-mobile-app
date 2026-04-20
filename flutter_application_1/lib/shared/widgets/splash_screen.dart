library;

/// Ecran de demarrage anime minimaliste (fond blanc, texte gradient).

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Splash screen minimaliste avec animation fade du texte Etoile.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App name
                FadeTransition(
                  opacity: _fadeIn,
                  child: Semantics(
                    label: 'Etoile - Application de recrutement',
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradient.createShader(bounds),
                      child: const Text(
                        'Etoile',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Loading indicator
                FadeTransition(
                  opacity: _fadeIn,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
