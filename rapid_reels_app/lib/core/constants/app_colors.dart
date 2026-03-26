import 'package:flutter/material.dart';

class AppColors {
  // Blue minimal palette (clean and professional)
  static const Color background = Color(0xFF0A0A0A);
  static const Color primary = Color(0xFF1DA1F2);
  static const Color secondary = Color(0xFF0D6EFD);
  static const Color accent = Color(0xFF66B2FF);
  static const Color primaryDark = Color(0xFF0A57C8);
  
  // Dark surfaces tuned for blue-accent contrast
  static const Color surface = Color(0xFF111827);
  static const Color cardBackground = Color(0xFF1A2233);
  static const Color surfaceElevated = Color(0xFF243147);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCBD5E1);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  
  // Status colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);
  
  // Event type colors
  static const Color wedding = Color(0xFF60A5FA);
  static const Color birthday = Color(0xFFF59E0B);
  static const Color engagement = Color(0xFF3B82F6);
  static const Color corporate = Color(0xFF2563EB);
  static const Color brand = Color(0xFF818CF8);
  static const Color other = Color(0xFF0EA5E9);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [surface, surfaceElevated],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Home premium layer tokens
  static const Color homeGlowCyan = primary;
  static const Color homeGlowMagenta = secondary;
  static const Color homeGlowLime = accent;
  static const Color homePatternLine = Color(0x22FFFFFF);
  static const Color homeVignette = Color(0xCC000000);

  static const Color homeGlassBorder = Color(0x66A5C8FF);
  static const Color homeGlassFillTop = Color(0xCC141C2B);
  static const Color homeGlassFillBottom = Color(0xB3212D43);
  static const Color homeGlassShadow = Color(0x40000000);

  static const LinearGradient homeGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [homeGlassFillTop, homeGlassFillBottom],
  );
}

