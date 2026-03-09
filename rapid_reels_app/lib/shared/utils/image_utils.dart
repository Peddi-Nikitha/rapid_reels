import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Utility class for generating realistic placeholder images
class ImageUtils {
  // Realistic placeholder image URLs using placeholder services
  static const String placeholderBase = 'https://picsum.photos';
  static const String placeholderEvent = 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3';
  static const String placeholderWedding = 'https://images.unsplash.com/photo-1519741497674-611481863552';
  static const String placeholderBirthday = 'https://images.unsplash.com/photo-1530103862676-de8c9debad1d';
  static const String placeholderEngagement = 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc';
  static const String placeholderCorporate = 'https://images.unsplash.com/photo-1540575467063-178a50c2e87c';
  static const String placeholderReel = 'https://images.unsplash.com/photo-1611162617474-5b21e879e113';
  static const String placeholderProvider = 'https://images.unsplash.com/photo-1551836022-d5d88e9218df';
  static const String placeholderVenue = 'https://images.unsplash.com/photo-1511578314322-379afb476865';

  /// Get a placeholder image URL with specific dimensions
  static String getPlaceholder({int width = 400, int height = 300, int? seed}) {
    if (seed != null) {
      return '$placeholderBase/seed/$seed/$width/$height';
    }
    return '$placeholderBase/$width/$height';
  }

  /// Get event-specific placeholder
  static String getEventPlaceholder(String eventType, {int width = 400, int height = 300}) {
    switch (eventType.toLowerCase()) {
      case 'wedding':
        return '$placeholderWedding?w=$width&h=$height&fit=crop';
      case 'birthday':
        return '$placeholderBirthday?w=$width&h=$height&fit=crop';
      case 'engagement':
        return '$placeholderEngagement?w=$width&h=$height&fit=crop';
      case 'corporate':
        return '$placeholderCorporate?w=$width&h=$height&fit=crop';
      default:
        return getPlaceholder(width: width, height: height);
    }
  }

  /// Build a gradient placeholder widget
  static Widget buildGradientPlaceholder({
    required double width,
    required double height,
    List<Color>? colors,
    String? label,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? [
            AppColors.primary.withOpacity(0.6),
            AppColors.primary.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: label != null
          ? Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  /// Build a shimmer placeholder
  static Widget buildShimmerPlaceholder({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
    );
  }
}

