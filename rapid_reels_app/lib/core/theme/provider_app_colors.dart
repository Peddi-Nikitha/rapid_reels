import 'package:flutter/material.dart';

/// Warm dark palette for the provider portal only (customer app uses [AppColors]).
/// Reference: high-contrast dark UI with orange–coral gradient CTAs.
class ProviderAppColors {
  ProviderAppColors._();

  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color card = Color(0xFF1E1E1E);
  static const Color surfaceElevated = Color(0xFF252525);
  /// Search / pill inputs (e.g. dark grey search bar).
  static const Color searchBarFill = Color(0xFF2A2A2A);

  static const Color primary = Color(0xFFFF7E5F);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryDeep = Color(0xFFE85D4C);
  static const Color primaryMid = Color(0xFFFF6B45);

  static const Color textPrimary = Color(0xFFFFFFFF);
  /// Body / descriptions (off-white).
  static const Color textSecondary = Color(0xFFE0E0E0);
  static const Color textTertiary = Color(0xFFBDBDBD);
  static const Color textMuted = Color(0xFF8A8A8A);

  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFFF6B6B);
  /// Accent for info chips / stats (aligned with former provider [AppColors.info] usage).
  static const Color info = Color(0xFF64B5F6);
  static const Color outline = Color(0xFF3A3A3A);
  /// Slightly darker than [card] for image placeholders / borders.
  static const Color cardBackground = Color(0xFF181818);

  /// Primary CTA: horizontal orange → coral (Trail Wind–style).
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF7E5F), primaryMid, primaryDeep],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient primarySoftGradient = LinearGradient(
    colors: [Color(0xFFFF7E5F), Color(0xFFFF9B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Glass nav / overlay tint (use with [BackdropFilter]).
  static Color glassSurface = const Color(0xFF1A1A1A).withValues(alpha: 0.72);
}
