import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFFFF0033); // Vibrant red
  static const Color primaryDark = Color(0xFFCC0029);
  static const Color secondary = Color(0xFF6B0DFF); // Deep purple
  
  // Backgrounds
  static const Color background = Color(0xFF0A0A0A); // Almost black
  static const Color surface = Color(0xFF1A1A1A); // Dark gray
  static const Color cardBackground = Color(0xFF252525);
  
  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF707070);
  
  // Status colors
  static const Color success = Color(0xFF00D66B);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF007AFF);
  
  // Event type colors
  static const Color wedding = Color(0xFFFF6B9D);
  static const Color birthday = Color(0xFFFFD700);
  static const Color engagement = Color(0xFFFF1493);
  static const Color corporate = Color(0xFF4169E1);
  static const Color brand = Color(0xFF9370DB);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF0033), Color(0xFF6B0DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF252525)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

