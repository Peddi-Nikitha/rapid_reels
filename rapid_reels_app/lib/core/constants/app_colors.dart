import 'package:flutter/material.dart';

class AppColors {
  // Neon GenZ palette
  static const Color background = Color(0xFF050505);
  static const Color primary = Color(0xFF00ACB3); // Updated brand teal
  static const Color secondary = Color(0xFFFF00FF); // Neon magenta
  static const Color accent = Color(0xFF39FF14); // Neon lime
  static const Color primaryDark = Color(0xFF008289);
  
  // Surfaces tuned for dark neon contrast
  static const Color surface = Color(0xFF111111);
  static const Color cardBackground = Color(0xFF181818);
  static const Color surfaceElevated = Color(0xFF202020);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFD0D0D0);
  static const Color textTertiary = Color(0xFF9A9A9A);
  static const Color onPrimary = Color(0xFF050505);
  static const Color onSecondary = Color(0xFF050505);
  
  // Status colors
  static const Color success = Color(0xFF39FF14);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF5A7A);
  static const Color info = Color(0xFF00F5FF);
  
  // Event type colors
  static const Color wedding = Color(0xFFFF6B9D);
  static const Color birthday = Color(0xFFFFD700);
  static const Color engagement = Color(0xFFFF1493);
  static const Color corporate = Color(0xFF4169E1);
  static const Color brand = Color(0xFF9370DB);
  static const Color other = Color(0xFF26A69A);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00F5FF), Color(0xFFFF00FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF111111), Color(0xFF202020)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF39FF14), Color(0xFF00F5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Home premium layer tokens
  static const Color homeGlowCyan = Color(0xFF00F5FF);
  static const Color homeGlowMagenta = Color(0xFFFF00FF);
  static const Color homeGlowLime = Color(0xFF39FF14);
  static const Color homePatternLine = Color(0x22FFFFFF);
  static const Color homeVignette = Color(0xCC000000);

  static const Color homeGlassBorder = Color(0x52FFFFFF);
  static const Color homeGlassFillTop = Color(0xB3111111);
  static const Color homeGlassFillBottom = Color(0x8C1A1A1A);
  static const Color homeGlassShadow = Color(0x33000000);

  static const LinearGradient homeGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [homeGlassFillTop, homeGlassFillBottom],
  );
}

