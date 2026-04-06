import 'package:flutter/material.dart';
import '../../../core/theme/provider_app_colors.dart';

class ProviderEmptyState extends StatelessWidget {
  const ProviderEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: ProviderAppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: ProviderAppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ProviderAppColors.textTertiary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
