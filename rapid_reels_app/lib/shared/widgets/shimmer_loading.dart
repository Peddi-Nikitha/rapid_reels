import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.cardBackground,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerEventCard extends StatelessWidget {
  const ShimmerEventCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ShimmerLoading(width: 80, height: 28, borderRadius: 8),
              const Spacer(),
              const ShimmerLoading(width: 60, height: 24, borderRadius: 6),
            ],
          ),
          const SizedBox(height: 16),
          const ShimmerLoading(width: 200, height: 20),
          const SizedBox(height: 12),
          const ShimmerLoading(width: 150, height: 16),
          const SizedBox(height: 8),
          const ShimmerLoading(width: 180, height: 16),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ShimmerLoading(width: 100, height: 16),
              const ShimmerLoading(width: 80, height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class ShimmerProviderCard extends StatelessWidget {
  const ShimmerProviderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoading(
            width: double.infinity,
            height: 150,
            borderRadius: 16,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading(width: 180, height: 20),
                const SizedBox(height: 8),
                const ShimmerLoading(width: 100, height: 14),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const ShimmerLoading(width: 60, height: 16),
                    const SizedBox(width: 16),
                    const ShimmerLoading(width: 60, height: 16),
                    const SizedBox(width: 16),
                    const ShimmerLoading(width: 60, height: 16),
                  ],
                ),
                const SizedBox(height: 12),
                const ShimmerLoading(width: double.infinity, height: 14),
                const SizedBox(height: 6),
                const ShimmerLoading(width: 200, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerReelCard extends StatelessWidget {
  const ShimmerReelCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerLoading(
          width: double.infinity,
          height: 200,
          borderRadius: 12,
        ),
        const SizedBox(height: 8),
        const ShimmerLoading(width: 120, height: 14),
        const SizedBox(height: 6),
        Row(
          children: [
            const ShimmerLoading(width: 50, height: 12),
            const SizedBox(width: 12),
            const ShimmerLoading(width: 50, height: 12),
          ],
        ),
      ],
    );
  }
}

