library;

/// Page d'onboarding affichee une seule fois apres la premiere connexion.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _ctrl = PageController();
  int _current = 0;
  static const int _total = 3;

  void _next() {
    if (_current < _total - 1) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    AppRouter.setOnboardingDone();
    if (mounted) context.go(AppRoutes.editProfile);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _current = i),
                children: const [
                  _Screen1(),
                  _Screen2(),
                  _Screen3(),
                ],
              ),
            ),

            // Pagination + bouton
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 12, 32, 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(_total, (i) {
                      final isActive = i == _current;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(right: 6),
                        width: isActive ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.accent
                              : const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  GestureDetector(
                    onTap: _next,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _current == _total - 1
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ÉCRAN 1 ──────────────────────────────────────────────────────────────────

class _Screen1 extends StatelessWidget {
  const _Screen1();

  @override
  Widget build(BuildContext context) {
    return const _OnboardingShell(
      imagePath: 'images/etoile/perso_1.png',
      titleBlack1: 'Enregistrez',
      titleBlack2: 'votre vidéo en',
      titleAccent: '40 secondes',
      description: 'Présentez-vous en moins\nde 40 secondes.',
    );
  }
}

// ── ÉCRAN 2 ──────────────────────────────────────────────────────────────────

class _Screen2 extends StatelessWidget {
  const _Screen2();

  @override
  Widget build(BuildContext context) {
    return const _OnboardingShell(
      imagePath: 'images/etoile/perso_2.png',
      titleBlack1: 'Découvrez les offres',
      titleBlack2: 'dans',
      titleAccent: 'votre secteur',
      description: 'Trouvez et contactez\nfacilement les recruteurs.',
    );
  }
}

// ── ÉCRAN 3 ──────────────────────────────────────────────────────────────────

class _Screen3 extends StatelessWidget {
  const _Screen3();

  @override
  Widget build(BuildContext context) {
    return const _OnboardingShell(
      imagePath: 'images/etoile/perso_3.png',
      titleBlack1: 'Soyez contacté',
      titleBlack2: 'directement par',
      titleAccent: 'messageries',
      description: 'Créez votre profil en\nquelques clics.',
    );
  }
}

// ── SHELL COMMUN ─────────────────────────────────────────────────────────────

class _OnboardingShell extends StatelessWidget {
  final String imagePath;
  final String titleBlack1;
  final String titleBlack2;
  final String titleAccent;
  final String description;

  const _OnboardingShell({
    required this.imagePath,
    required this.titleBlack1,
    required this.titleBlack2,
    required this.titleAccent,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Zone illustration
          Expanded(
            flex: 7,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Cercle flou violet
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: AppColors.accentBg,
                    shape: BoxShape.circle,
                  ),
                ),
                // Personnage
                Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => const Icon(
                    Icons.star_rounded,
                    size: 120,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),

          // Zone texte
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 30,
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(
                        text: '$titleBlack1\n$titleBlack2 ',
                        style: const TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: titleAccent,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 17,
                    color: Color(0xFF6B7280),
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

