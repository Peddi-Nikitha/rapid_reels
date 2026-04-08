import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart';

/// Branded bottom navigation for the main customer shell (safe area + top edge).
class RapidBottomNavBar extends StatelessWidget {
  const RapidBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 4),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.92),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              children: [
                _item(
                  0,
                  Icons.home_outlined,
                  Icons.home_rounded,
                  AppStrings.navHome,
                ),
                _item(
                  1,
                  Icons.movie_filter_outlined,
                  Icons.movie_filter_rounded,
                  AppStrings.navReels,
                ),
                _item(
                  2,
                  Icons.event_outlined,
                  Icons.event_rounded,
                  AppStrings.navMyEvents,
                ),
                _item(
                  3,
                  Icons.person_outline,
                  Icons.person_rounded,
                  AppStrings.navProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final selected = currentIndex == index;
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? activeIcon : icon,
                  color: color,
                  size: 26,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 11,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
