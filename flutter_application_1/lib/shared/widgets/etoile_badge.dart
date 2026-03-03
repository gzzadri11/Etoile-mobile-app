import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Reusable badge component for the Etoile app.
///
/// Used for verified badges, recruiter badges, and other status indicators.
/// Supports an optional icon, configurable colors, and compact mode.
class EtoileBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final bool compact;

  const EtoileBadge({
    super.key,
    required this.label,
    this.icon,
    required this.backgroundColor,
    required this.textColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 24 : 28,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: textColor,
            ),
            const SizedBox(width: 2),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  height: 1.2,
                ),
          ),
        ],
      ),
    );
  }
}
