import 'package:flutter/material.dart';
import '../../../core/theme/provider_app_colors.dart';

/// Tappable card with icon, title, subtitle — provider portal style (no random gradients).
class ProviderActionCard extends StatelessWidget {
  const ProviderActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.leadingAccent = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool leadingAccent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ProviderAppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ProviderAppColors.outline.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: leadingAccent
                      ? ProviderAppColors.primary.withValues(alpha: 0.18)
                      : ProviderAppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: leadingAccent
                      ? ProviderAppColors.primary
                      : ProviderAppColors.textSecondary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: ProviderAppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ProviderAppColors.textTertiary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: ProviderAppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
