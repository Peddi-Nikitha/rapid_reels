import 'package:flutter/material.dart';

/// Cool blue/grey palette for the provider portal (aligned with customer app).
class ProviderAppColors {
  ProviderAppColors._();

  static const Color background = Color(0xFF141A1D);
  static const Color surface = Color(0xFF1D2529);
  static const Color card = Color(0xFF232D31);
  static const Color surfaceElevated = Color(0xFF2A353A);
  /// Search / pill inputs (e.g. dark grey search bar).
  static const Color searchBarFill = Color(0xFF2A353A);

  static const Color primary = Color(0xFF2A84A0);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryDeep = Color(0xFF236D84);
  static const Color primaryMid = Color(0xFF3C97B3);

  static const Color textPrimary = Color(0xFFFFFFFF);
  /// Body / descriptions (off-white).
  static const Color textSecondary = Color(0xFFD2D2D1);
  static const Color textTertiary = Color(0xFF989694);
  static const Color textMuted = Color(0xFF8D8B89);

  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFF2B544);
  static const Color error = Color(0xFFE57373);
  /// Accent for info chips / stats (aligned with former provider [AppColors.info] usage).
  static const Color info = Color(0xFF6EAFC2);
  static const Color outline = Color(0xFF3D484C);
  /// Slightly darker than [card] for image placeholders / borders.
  static const Color cardBackground = Color(0xFF1A2327);

  /// Primary CTA: horizontal blue range.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2A84A0), primaryMid, primaryDeep],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient primarySoftGradient = LinearGradient(
    colors: [Color(0xFF2A84A0), Color(0xFF49A4C0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Glass nav / overlay tint (use with [BackdropFilter]).
  static Color glassSurface = const Color(0xFF1D2529).withValues(alpha: 0.72);
}
