import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Shows a success overlay animation when a seeker applies to an offer.
///
/// Uses [OverlayEntry] to display above the feed PageView.
/// Animation sequence:
/// 1. Fade in semi-transparent background (200ms)
/// 2. Scale up white circle + animated check icon (400ms)
/// 3. Fade in "Candidature envoyee !" text (200ms)
/// 4. Hold 500ms then fade out (300ms)
void showApplySuccessOverlay(BuildContext context) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _ApplySuccessAnimation(
      onDone: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

class _ApplySuccessAnimation extends StatefulWidget {
  final VoidCallback onDone;

  const _ApplySuccessAnimation({required this.onDone});

  @override
  State<_ApplySuccessAnimation> createState() => _ApplySuccessAnimationState();
}

class _ApplySuccessAnimationState extends State<_ApplySuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _backgroundOpacity;
  late Animation<double> _circleScale;
  late Animation<double> _checkOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _fadeOut;

  // Total duration: 200 + 400 + 200 + 500 + 300 = 1600ms
  static const _totalDuration = Duration(milliseconds: 1600);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration);

    // 0.0 - 0.125 (0-200ms): background fade in
    _backgroundOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.125, curve: Curves.easeIn),
      ),
    );

    // 0.125 - 0.375 (200-600ms): circle scale up
    _circleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.125, 0.375, curve: Curves.elasticOut),
      ),
    );

    // 0.125 - 0.375 (200-600ms): check icon fade in with circle
    _checkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.375, curve: Curves.easeIn),
      ),
    );

    // 0.375 - 0.5 (600-800ms): text fade in
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.375, 0.5, curve: Curves.easeIn),
      ),
    );

    // 0.8125 - 1.0 (1300-1600ms): everything fades out
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8125, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final globalFade = _fadeOut.value;

        return IgnorePointer(
          child: Opacity(
            opacity: globalFade,
            child: Container(
              color: AppColors.black.withValues(alpha: 0.4 * _backgroundOpacity.value),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Circle + check
                    Transform.scale(
                      scale: _circleScale.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Opacity(
                          opacity: _checkOpacity.value,
                          child: const Icon(
                            Icons.check,
                            color: AppColors.success,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Text
                    Opacity(
                      opacity: _textOpacity.value,
                      child: const Text(
                        'Candidature envoyée !',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
