import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/provider_app_colors.dart';

/// Glass-style bottom navigation for the provider portal (blur + frosted tint).
class ProviderBottomNavBar extends StatelessWidget {
  const ProviderBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <_NavItem>[
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _NavItem(Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Schedule'),
    _NavItem(Icons.event_note_outlined, Icons.event_note_rounded, 'Bookings'),
    _NavItem(Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Earnings'),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 4),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: ProviderAppColors.glassSurface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.14),
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 24,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
                    children: List.generate(_items.length, (i) {
                      final item = _items[i];
                      final selected = i == currentIndex;
                      return Expanded(
                        child: _NavCell(
                          selected: selected,
                          icon: selected ? item.filled : item.outlined,
                          label: item.label,
                          onTap: () => onTap(i),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.outlined, this.filled, this.label);
  final IconData outlined;
  final IconData filled;
  final String label;
}

class _NavCell extends StatelessWidget {
  const _NavCell({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = selected ? ProviderAppColors.primary : ProviderAppColors.textMuted;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? ProviderAppColors.primary.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 24, color: accent),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: accent,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
