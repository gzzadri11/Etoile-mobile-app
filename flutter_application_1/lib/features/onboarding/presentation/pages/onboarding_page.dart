import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';

/// Onboarding page shown once after registration.
///
/// Displays 3 slides explaining the app, with mascotte illustrations.
/// Content is adapted based on user role (seeker vs recruiter).
class OnboardingPage extends StatefulWidget {
  final String role;

  const OnboardingPage({super.key, required this.role});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _currentPage = 0;

  bool get _isSeeker => widget.role == 'seeker';

  List<_OnboardingSlide> get _slides => [
        _OnboardingSlide(
          title: _isSeeker
              ? 'Enregistrez votre video en 40 secondes'
              : 'Trouvez les meilleurs talents',
          subtitle: _isSeeker
              ? 'Presentez-vous aux recruteurs avec une video courte et percutante.'
              : 'Decouvrez des candidats motives grace a leurs videos de presentation.',
        ),
        _OnboardingSlide(
          title: _isSeeker
              ? 'Decouvrez des offres dans votre secteur'
              : 'Publiez vos offres en video ou en affiche',
          subtitle: _isSeeker
              ? 'Parcourez les offres des recruteurs et trouvez le poste ideal.'
              : 'Attirez les meilleurs profils avec des offres visuelles et engageantes.',
        ),
        _OnboardingSlide(
          title: 'Contactez directement par messagerie',
          subtitle: _isSeeker
              ? 'Echangez avec les recruteurs en temps reel, sans intermediaire.'
              : 'Discutez avec les candidats qui vous interessent, simplement.',
        ),
      ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      // Redirect to profile edit so the user completes their profile
      if (widget.role == 'recruiter') {
        context.go(AppRoutes.editRecruiterProfile);
      } else {
        context.go(AppRoutes.editProfile);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = _slides;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Passer'),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceLg,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Mascotte
                        Image.asset(
                          'assets/images/mascotte.png',
                          height: 160,
                        ),

                        const SizedBox(height: AppTheme.space2Xl),

                        // Title
                        Text(
                          slide.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppTheme.spaceMd),

                        // Subtitle
                        Text(
                          slide.subtitle,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.greyWarm,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceMd),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primaryYellow
                          : AppColors.greyLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Action button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceLg,
                0,
                AppTheme.spaceLg,
                AppTheme.space2Xl,
              ),
              child: SizedBox(
                width: double.infinity,
                child: _currentPage == slides.length - 1
                    ? ElevatedButton(
                        onPressed: _completeOnboarding,
                        child: const Text('Commencer'),
                      )
                    : OutlinedButton(
                        onPressed: () {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: const Text('Suivant'),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String subtitle;

  const _OnboardingSlide({
    required this.title,
    required this.subtitle,
  });
}
