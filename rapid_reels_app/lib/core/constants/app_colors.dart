import 'package:flutter/material.dart';

class AppColors {
  // Provider-parity warm dark palette for user role.
  static const Color background = Color(0xFF121212);
  static const Color primary = Color(0xFFFF7E5F);
  static const Color secondary = Color(0xFFE85D4C);
  static const Color accent = Color(0xFFFF9B6B);
  static const Color primaryDark = Color(0xFFE85D4C);

  // Surfaces
  static const Color surface = Color(0xFF1A1A1A);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color surfaceElevated = Color(0xFF252525);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFE0E0E0);
  static const Color textTertiary = Color(0xFFBDBDBD);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  
  // Status colors
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF64B5F6);
  
  // Event type colors
  static const Color wedding = Color(0xFFFF8A65);
  static const Color birthday = Color(0xFFFFB74D);
  static const Color engagement = Color(0xFFFF7043);
  static const Color corporate = Color(0xFF64B5F6);
  static const Color brand = Color(0xFFBA68C8);
  static const Color other = Color(0xFF90A4AE);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF7E5F), Color(0xFFFF6B45), Color(0xFFE85D4C)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF252525)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF9B6B), Color(0xFFFF7E5F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Home premium layer tokens
  static const Color homeGlowCyan = Color(0xFFFF7E5F);
  static const Color homeGlowMagenta = Color(0xFFE85D4C);
  static const Color homeGlowLime = Color(0xFFFFB74D);
  static const Color homePatternLine = Color(0x22FFFFFF);
  static const Color homeVignette = Color(0xCC000000);

  static const Color homeGlassBorder = Color(0x3DFFFFFF);
  static const Color homeGlassFillTop = Color(0xB31E1E1E);
  static const Color homeGlassFillBottom = Color(0x8C252525);
  static const Color homeGlassShadow = Color(0x33000000);

  static const LinearGradient homeGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [homeGlassFillTop, homeGlassFillBottom],
  );
}

