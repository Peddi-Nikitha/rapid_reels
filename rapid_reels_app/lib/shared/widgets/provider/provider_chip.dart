import 'package:flutter/material.dart';
import '../../../core/theme/provider_app_colors.dart';

class ProviderChip extends StatelessWidget {
  const ProviderChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? ProviderAppColors.primary.withValues(alpha: 0.2)
                : ProviderAppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? ProviderAppColors.primary : ProviderAppColors.outline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected
                      ? ProviderAppColors.primary
                      : ProviderAppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}
