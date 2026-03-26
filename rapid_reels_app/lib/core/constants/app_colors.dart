import 'package:flutter/material.dart';

class AppColors {
  // Viral reels palette (Instagram/TikTok inspired)
  static const Color background = Color(0xFF000000);
  static const Color primary = Color(0xFFFF0050);
  static const Color secondary = Color(0xFFFFA500);
  static const Color accent = Color(0xFF833AB4);
  static const Color primaryDark = Color(0xFFCC0040);
  
  // Dark surfaces tuned for neon pink/orange contrast
  static const Color surface = Color(0xFF141016);
  static const Color cardBackground = Color(0xFF1B1520);
  static const Color surfaceElevated = Color(0xFF2B2133);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFE2D8E9);
  static const Color textTertiary = Color(0xFFB6A6C3);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF140A00);
  
  // Status colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFFFF7A00);
  
  // Event type colors
  static const Color wedding = Color(0xFF833AB4);
  static const Color birthday = Color(0xFFFFA500);
  static const Color engagement = Color(0xFFFF4D8D);
  static const Color corporate = Color(0xFFB066FF);
  static const Color brand = Color(0xFFFF6A00);
  static const Color other = Color(0xFFD24CFF);

  // Reels/discover interaction colors
  static const Color verifiedBadge = primary;
  static const Color reelLike = Color(0xFFFF3040);
  
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

