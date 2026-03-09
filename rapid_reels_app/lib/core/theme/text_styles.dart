import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Comprehensive Typography System
/// Using Inter font family for modern, clean, professional appearance
class AppTypography {
  // Font Family
  static String get fontFamily => 'Inter';

  // Base Text Style with Inter
  static TextStyle _baseStyle({
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // ========== DISPLAY TEXT (Large Headings) ==========
  
  /// Display Large - Hero titles, main screen titles
  /// 36px, Bold, -1.2 letter spacing
  static TextStyle get displayLarge => _baseStyle(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
        height: 1.1,
      ).copyWith(color: AppColors.textPrimary);

  /// Display Medium - Section headers, prominent titles
  /// 32px, Bold, -1.0 letter spacing
  static TextStyle get displayMedium => _baseStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        height: 1.15,
      ).copyWith(color: AppColors.textPrimary);

  /// Display Small - Sub-hero titles
  /// 28px, Bold, -0.8 letter spacing
  static TextStyle get displaySmall => _baseStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.2,
      ).copyWith(color: AppColors.textPrimary);

  // ========== HEADLINES (Section Headers) ==========
  
  /// Headline Large - Major section titles
  /// 24px, SemiBold, -0.5 letter spacing
  static TextStyle get headlineLarge => _baseStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.25,
      ).copyWith(color: AppColors.textPrimary);

  /// Headline Medium - Section subtitles
  /// 22px, SemiBold, -0.4 letter spacing
  static TextStyle get headlineMedium => _baseStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.3,
      ).copyWith(color: AppColors.textPrimary);

  /// Headline Small - Card titles, list headers
  /// 20px, SemiBold, -0.3 letter spacing
  static TextStyle get headlineSmall => _baseStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.3,
      ).copyWith(color: AppColors.textPrimary);

  // ========== TITLE (Card Titles, Labels) ==========
  
  /// Title Large - Card titles, prominent labels
  /// 18px, SemiBold, -0.2 letter spacing
  static TextStyle get titleLarge => _baseStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.35,
      ).copyWith(color: AppColors.textPrimary);

  /// Title Medium - Standard card titles
  /// 16px, SemiBold, -0.2 letter spacing
  static TextStyle get titleMedium => _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.4,
      ).copyWith(color: AppColors.textPrimary);

  /// Title Small - Small labels, badges
  /// 14px, SemiBold, -0.1 letter spacing
  static TextStyle get titleSmall => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.4,
      ).copyWith(color: AppColors.textPrimary);

  // ========== BODY TEXT (Content) ==========
  
  /// Body Large - Primary content text
  /// 16px, Regular, -0.1 letter spacing
  static TextStyle get bodyLarge => _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        height: 1.5,
      ).copyWith(color: AppColors.textPrimary);

  /// Body Medium - Secondary content, descriptions
  /// 14px, Regular, -0.1 letter spacing
  static TextStyle get bodyMedium => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        height: 1.5,
      ).copyWith(color: AppColors.textSecondary);

  /// Body Small - Tertiary content, metadata
  /// 13px, Regular, -0.1 letter spacing
  static TextStyle get bodySmall => _baseStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        height: 1.45,
      ).copyWith(color: AppColors.textSecondary);

  // ========== LABEL (Form Labels, Buttons) ==========
  
  /// Label Large - Large button text, prominent labels
  /// 15px, SemiBold, 0.1 letter spacing
  static TextStyle get labelLarge => _baseStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      ).copyWith(color: AppColors.textPrimary);

  /// Label Medium - Standard button text, form labels
  /// 14px, SemiBold, 0.1 letter spacing
  static TextStyle get labelMedium => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      ).copyWith(color: AppColors.textPrimary);

  /// Label Small - Small buttons, compact labels
  /// 12px, SemiBold, 0.2 letter spacing
  static TextStyle get labelSmall => _baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.4,
      ).copyWith(color: AppColors.textPrimary);

  // ========== CAPTION (Small Text, Metadata) ==========
  
  /// Caption Large - Small descriptions, timestamps
  /// 12px, Regular, -0.1 letter spacing
  static TextStyle get captionLarge => _baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        height: 1.4,
      ).copyWith(color: AppColors.textSecondary);

  /// Caption Medium - Standard captions
  /// 11px, Regular, -0.1 letter spacing
  static TextStyle get captionMedium => _baseStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        height: 1.4,
      ).copyWith(color: AppColors.textSecondary);

  /// Caption Small - Tiny text, badges
  /// 10px, Regular, 0.1 letter spacing
  static TextStyle get captionSmall => _baseStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.4,
      ).copyWith(color: AppColors.textTertiary);

  // ========== SPECIAL STYLES ==========
  
  /// Button Large - Primary action buttons
  /// 16px, SemiBold, 0.2 letter spacing
  static TextStyle get buttonLarge => _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.2,
      ).copyWith(color: Colors.white);

  /// Button Medium - Secondary buttons
  /// 14px, SemiBold, 0.2 letter spacing
  static TextStyle get buttonMedium => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.2,
      ).copyWith(color: Colors.white);

  /// Button Small - Compact buttons
  /// 12px, SemiBold, 0.3 letter spacing
  static TextStyle get buttonSmall => _baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        height: 1.2,
      ).copyWith(color: Colors.white);

  /// Overline - Uppercase labels, tags
  /// 10px, SemiBold, 1.2 letter spacing
  static TextStyle get overline => _baseStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        height: 1.4,
      ).copyWith(color: AppColors.textTertiary);

  // ========== PRICE & CURRENCY ==========
  
  /// Price Large - Large price displays
  /// 28px, Bold, -0.5 letter spacing
  static TextStyle get priceLarge => _baseStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
      ).copyWith(color: AppColors.primary);

  /// Price Medium - Standard prices
  /// 20px, Bold, -0.3 letter spacing
  static TextStyle get priceMedium => _baseStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.3,
      ).copyWith(color: AppColors.primary);

  /// Price Small - Small prices, discounts
  /// 16px, SemiBold, -0.2 letter spacing
  static TextStyle get priceSmall => _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
      ).copyWith(color: AppColors.primary);

  // ========== INTERACTIVE ELEMENTS ==========
  
  /// Link - Clickable links
  /// 14px, SemiBold, 0.1 letter spacing
  static TextStyle get link => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      ).copyWith(
        color: AppColors.primary,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.primary,
      );

  /// Error - Error messages
  /// 12px, Regular, -0.1 letter spacing
  static TextStyle get error => _baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        height: 1.4,
      ).copyWith(color: AppColors.error);

  /// Success - Success messages
  /// 12px, Regular, -0.1 letter spacing
  static TextStyle get success => _baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        height: 1.4,
      ).copyWith(color: AppColors.success);

  // ========== STATS & NUMBERS ==========
  
  /// Stat Large - Large statistics
  /// 24px, Bold, -0.5 letter spacing
  static TextStyle get statLarge => _baseStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
      ).copyWith(color: AppColors.textPrimary);

  /// Stat Medium - Medium statistics
  /// 20px, Bold, -0.3 letter spacing
  static TextStyle get statMedium => _baseStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.3,
      ).copyWith(color: AppColors.textPrimary);

  /// Stat Small - Small statistics
  /// 16px, SemiBold, -0.2 letter spacing
  static TextStyle get statSmall => _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
      ).copyWith(color: AppColors.textPrimary);

  // ========== BADGE & TAG ==========
  
  /// Badge - Badge text
  /// 11px, SemiBold, 0.2 letter spacing
  static TextStyle get badge => _baseStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.2,
      ).copyWith(color: Colors.white);

  /// Tag - Tag text
  /// 10px, SemiBold, 0.3 letter spacing
  static TextStyle get tag => _baseStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        height: 1.2,
      ).copyWith(color: AppColors.textPrimary);
}

/// Legacy TextStyles class for backward compatibility
/// Use AppTypography for new code
class TextStyles {
  // Headlines
  static TextStyle get h1 => AppTypography.displayLarge;
  static TextStyle get h2 => AppTypography.displayMedium;
  static TextStyle get h3 => AppTypography.displaySmall;
  static TextStyle get h4 => AppTypography.headlineLarge;
  static TextStyle get h5 => AppTypography.headlineMedium;
  
  // Body Text
  static TextStyle get bodyLarge => AppTypography.bodyLarge;
  static TextStyle get bodyMedium => AppTypography.bodyMedium;
  static TextStyle get bodySmall => AppTypography.bodySmall;
  
  // Special Styles
  static TextStyle get buttonLarge => AppTypography.buttonLarge;
  static TextStyle get buttonMedium => AppTypography.buttonMedium;
  static TextStyle get caption => AppTypography.captionMedium;
  static TextStyle get captionBold => AppTypography.labelSmall;
  static TextStyle get overline => AppTypography.overline;
  
  // Price Styles
  static TextStyle get priceSmall => AppTypography.priceSmall;
  static TextStyle get priceMedium => AppTypography.priceMedium;
  static TextStyle get priceLarge => AppTypography.priceLarge;
  
  // Link & Error
  static TextStyle get link => AppTypography.link;
  static TextStyle get error => AppTypography.error;
}

