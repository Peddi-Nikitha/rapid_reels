import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/provider_app_colors.dart';

/// Primary gradient CTA for the provider portal (rounded, bold Poppins label).
class ProviderGradientButton extends StatelessWidget {
  const ProviderGradientButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
    this.minHeight = 52,
    this.borderRadius = 14,
  });

  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final bool loading;
  final bool fullWidth;
  final double minHeight;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final showGradient = onPressed != null || loading;
    final canTap = !loading && onPressed != null;
    final child = loading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: ProviderAppColors.onPrimary,
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                IconTheme.merge(
                  data: const IconThemeData(
                    color: ProviderAppColors.onPrimary,
                    size: 20,
                  ),
                  child: icon!,
                ),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ProviderAppColors.onPrimary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canTap ? onPressed : null,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: showGradient ? ProviderAppColors.primaryGradient : null,
            color: showGradient ? null : ProviderAppColors.surfaceElevated,
            boxShadow: showGradient
                ? [
                    BoxShadow(
                      color: ProviderAppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: fullWidth ? double.infinity : 0,
              minHeight: minHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Green “accept / success” CTA (same shape as [ProviderGradientButton], semantic success color).
class ProviderSuccessButton extends StatelessWidget {
  const ProviderSuccessButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.fullWidth = true,
    this.minHeight = 48,
    this.borderRadius = 14,
  });

  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final bool fullWidth;
  final double minHeight;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: onPressed != null
                ? ProviderAppColors.success
                : ProviderAppColors.surfaceElevated,
            boxShadow: onPressed != null
                ? [
                    BoxShadow(
                      color: ProviderAppColors.success.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: fullWidth ? double.infinity : 0,
              minHeight: minHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Center(
                child: Row(
                  mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      IconTheme.merge(
                        data: const IconThemeData(
                          color: ProviderAppColors.onPrimary,
                          size: 20,
                        ),
                        child: icon!,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ProviderAppColors.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
