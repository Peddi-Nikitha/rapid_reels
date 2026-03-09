import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../features/booking/data/models/service_provider_model.dart';

class PackageCard extends StatelessWidget {
  final PackageOffering package;
  final bool isSelected;
  final bool isPopular;
  final VoidCallback? onTap;

  const PackageCard({
    super.key,
    required this.package,
    this.isSelected = false,
    this.isPopular = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 500, // Fixed height to match carousel
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surface,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Gradient Background - Fixed height
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: _getPackageGradient(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  // Dark Overlay for better text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                package.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (isPopular)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '⭐ POPULAR',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                '£',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              package.price.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1,
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${package.duration ~/ 60} hours coverage',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Section - Scrollable
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Stats Row
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildQuickStat(
                              Icons.video_library_rounded,
                              package.reelsCount == -1
                                  ? '∞'
                                  : '${package.reelsCount}',
                              'Reels',
                            ),
                            Container(
                              width: 1,
                              height: 35,
                              color: AppColors.textTertiary,
                            ),
                            _buildQuickStat(
                              Icons.timer_rounded,
                              package.deliveryTime < 60
                                  ? '${package.deliveryTime}m'
                                  : '${package.deliveryTime ~/ 60}h',
                              'Delivery',
                            ),
                            Container(
                              width: 1,
                              height: 35,
                              color: AppColors.textTertiary,
                            ),
                            _buildQuickStat(
                              Icons.people_rounded,
                              _getTeamSize(),
                              'Team',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'What\'s Included:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Features List - Show all but with compact spacing
                      ...package.features.map((feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: _getPackageColor().withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: _getPackageColor(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: _getPackageColor()),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _getPackageColor(),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  LinearGradient _getPackageGradient() {
    switch (package.packageId) {
      case 'pkg_bronze':
        return const LinearGradient(
          colors: [Color(0xFFCD7F32), Color(0xFFB87333)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'pkg_silver':
        return const LinearGradient(
          colors: [Color(0xFFC0C0C0), Color(0xFFA8A8A8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'pkg_gold':
        return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'pkg_platinum':
        return const LinearGradient(
          colors: [Color(0xFFE5E4E2), Color(0xFFBCC6CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppColors.primaryGradient;
    }
  }

  Color _getPackageColor() {
    switch (package.packageId) {
      case 'pkg_bronze':
        return const Color(0xFFCD7F32);
      case 'pkg_silver':
        return const Color(0xFFC0C0C0);
      case 'pkg_gold':
        return const Color(0xFFFFD700);
      case 'pkg_platinum':
        return const Color(0xFFE5E4E2);
      default:
        return AppColors.primary;
    }
  }

  String _getTeamSize() {
    switch (package.packageId) {
      case 'pkg_bronze':
        return '1';
      case 'pkg_silver':
        return '1';
      case 'pkg_gold':
        return '2';
      case 'pkg_platinum':
        return '3+';
      default:
        return '1';
    }
  }
}
