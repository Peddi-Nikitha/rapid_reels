import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final bool showRatingNumber;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
    this.showRatingNumber = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            return Icon(
              Icons.star,
              size: size,
              color: color ?? AppColors.warning,
            );
          } else if (index < rating) {
            return Icon(
              Icons.star_half,
              size: size,
              color: color ?? AppColors.warning,
            );
          } else {
            return Icon(
              Icons.star_border,
              size: size,
              color: color ?? AppColors.warning,
            );
          }
        }),
        if (showRatingNumber) ...[
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.875,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}

