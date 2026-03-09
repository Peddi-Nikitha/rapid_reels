import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;
  final Color? color;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.isPrimary = false,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isPrimary ? 140 : 64,
        decoration: BoxDecoration(
          gradient: isPrimary ? AppColors.primaryGradient : null,
          color: isPrimary ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary
              ? null
              : Border.all(color: Colors.grey.shade800, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isPrimary ? 32 : 24,
              color: color ?? AppColors.textPrimary,
            ),
            if (isPrimary) const SizedBox(height: 8),
            if (isPrimary || label.length < 15)
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isPrimary ? 16 : 12,
                  fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
                  color: color ?? AppColors.textPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

