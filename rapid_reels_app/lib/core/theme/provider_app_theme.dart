import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'provider_app_colors.dart';

class ProviderAppTheme {
  ProviderAppTheme._();

  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ProviderAppColors.background,
    );

    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: ProviderAppColors.textSecondary,
      displayColor: ProviderAppColors.textPrimary,
    );

    return base.copyWith(
      primaryColor: ProviderAppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: ProviderAppColors.primary,
        onPrimary: ProviderAppColors.onPrimary,
        secondary: ProviderAppColors.surfaceElevated,
        onSecondary: ProviderAppColors.textPrimary,
        surface: ProviderAppColors.surface,
        onSurface: ProviderAppColors.textPrimary,
        error: ProviderAppColors.error,
        onError: ProviderAppColors.onPrimary,
        outline: ProviderAppColors.outline,
      ),
      textTheme: textTheme.copyWith(
        headlineSmall: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: ProviderAppColors.textPrimary,
          height: 1.2,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ProviderAppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: ProviderAppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: ProviderAppColors.textSecondary,
          height: 1.45,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: ProviderAppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: ProviderAppColors.textTertiary,
        ),
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ProviderAppColors.textPrimary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ProviderAppColors.background,
        foregroundColor: ProviderAppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ProviderAppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: ProviderAppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: ProviderAppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: ProviderAppColors.surfaceElevated,
        disabledColor: ProviderAppColors.surface,
        selectedColor: ProviderAppColors.primary.withValues(alpha: 0.28),
        secondarySelectedColor: ProviderAppColors.primary.withValues(alpha: 0.28),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: ProviderAppColors.textPrimary,
        ),
        secondaryLabelStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: ProviderAppColors.textSecondary,
        ),
        brightness: Brightness.dark,
        side: const BorderSide(color: ProviderAppColors.outline, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ProviderAppColors.primary,
          foregroundColor: ProviderAppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ProviderAppColors.primary,
          foregroundColor: ProviderAppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ProviderAppColors.primary,
          side: const BorderSide(color: ProviderAppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ProviderAppColors.primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ProviderAppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ProviderAppColors.primary, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(
          color: ProviderAppColors.textSecondary,
          fontSize: 14,
        ),
        hintStyle: GoogleFonts.poppins(
          color: ProviderAppColors.textTertiary,
          fontSize: 15,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dividerTheme: const DividerThemeData(
        color: ProviderAppColors.outline,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ProviderAppColors.surfaceElevated,
        contentTextStyle: GoogleFonts.poppins(color: ProviderAppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ProviderAppColors.primary,
        foregroundColor: ProviderAppColors.onPrimary,
      ),
    );
  }

  /// Wraps portal routes; use at router pageBuilder boundary.
  static Widget wrap(Widget child) {
    return Theme(
      data: theme,
      child: child,
    );
  }
}
