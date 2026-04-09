import 'package:flutter/material.dart';

class AppColors {
  // Unified cool blue/grey palette.
  static const Color background = Color(0xFF141A1D);
  static const Color primary = Color(0xFF2A84A0);
  static const Color secondary = Color(0xFF989694);
  static const Color accent = Color(0xFF49A4C0);
  static const Color primaryDark = Color(0xFF236D84);

  // Surfaces
  static const Color surface = Color(0xFF1D2529);
  static const Color cardBackground = Color(0xFF232D31);
  static const Color surfaceElevated = Color(0xFF2A353A);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFD2D2D1);
  static const Color textTertiary = Color(0xFF989694);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  
  // Status colors
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFF2B544);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF6EAFC2);
  
  // Event type colors
  static const Color wedding = Color(0xFF4E9FB7);
  static const Color birthday = Color(0xFF7DAEBE);
  static const Color engagement = Color(0xFF3D93AE);
  static const Color corporate = Color(0xFF6EAFC2);
  static const Color brand = Color(0xFF7A9CAA);
  static const Color other = Color(0xFF8D8B89);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2A84A0), Color(0xFF3C97B3), Color(0xFF236D84)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1D2529), Color(0xFF2A353A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF49A4C0), Color(0xFF2A84A0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Home premium layer tokens
  static const Color homeGlowCyan = Color(0xFF2A84A0);
  static const Color homeGlowMagenta = Color(0xFF3C97B3);
  static const Color homeGlowLime = Color(0xFF989694);
  static const Color homePatternLine = Color(0x22FFFFFF);
  static const Color homeVignette = Color(0xCC000000);

  static const Color homeGlassBorder = Color(0x3DFFFFFF);
  static const Color homeGlassFillTop = Color(0xB3232D31);
  static const Color homeGlassFillBottom = Color(0x8C2A353A);
  static const Color homeGlassShadow = Color(0x33000000);

  static const LinearGradient homeGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [homeGlassFillTop, homeGlassFillBottom],
  );
}

