import 'package:flutter/material.dart';
import '../../../core/theme/provider_app_colors.dart';

class ProviderPrimaryButton extends StatelessWidget {
  const ProviderPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final child = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: ProviderAppColors.primary,
        foregroundColor: ProviderAppColors.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(label),
        ],
      ),
    );
    if (expanded) {
      return SizedBox(width: double.infinity, child: child);
    }
    return child;
  }
}
