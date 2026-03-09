import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/mock/mock_users.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../wallet/presentation/screens/transaction_history_screen.dart';
import '../../../support/presentation/screens/help_support_screen.dart';
import '../../../my_events/presentation/screens/enhanced_my_events_screen.dart';
import '../../../wallet/presentation/screens/wallet_transaction_screen.dart';
import '../../../offers/presentation/screens/offers_coupons_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

/// Main Profile Screen - User profile with settings and options
class MainProfileScreen extends ConsumerStatefulWidget {
  const MainProfileScreen({super.key});

  @override
  ConsumerState<MainProfileScreen> createState() => _MainProfileScreenState();
}

class _MainProfileScreenState extends ConsumerState<MainProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // Get mock user data
    final user = MockUsers.getUserById('user_001');

    if (user == null) {
      return const Center(child: Text('User not found'));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section - Refined
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  // Cover Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=1200&q=80',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                              Colors.black.withValues(alpha: 0.7),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      children: [
                        // Top Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile',
                              style: AppTypography.displaySmall.copyWith(
                                color: Colors.white,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SettingsScreen(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.settings_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Profile Picture - Refined
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.white,
                            child: Text(
                              user.fullName.substring(0, 2).toUpperCase(),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Name - Using Typography System
                        Text(
                          user.fullName,
                          style: AppTypography.headlineLarge.copyWith(
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Contact Info
                        Text(
                          user.phoneNumber ?? user.email ?? '',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Stats Row - Refined
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildProfileStat(
                                'Events',
                                '${user.totalEventsBooked}',
                              ),
                              Container(
                                width: 1,
                                height: 36,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              _buildProfileStat(
                                'Reels',
                                '${user.totalReelsReceived}',
                              ),
                              Container(
                                width: 1,
                                height: 36,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              _buildProfileStat(
                                'Wallet',
                                '₹${user.walletBalance.toInt()}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Quick Actions - Refined
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        'Edit Profile',
                        Icons.edit_rounded,
                        AppColors.primary,
                        () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        'Share Profile',
                        Icons.share_rounded,
                        const Color(0xFF007AFF),
                        () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Menu Sections - Refined
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Activity',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMenuCard([
                      _buildMenuItem(
                        'My Events',
                        Icons.event_rounded,
                        AppColors.primary,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EnhancedMyEventsScreen(),
                            ),
                          );
                        },
                        badge: '${user.totalEventsBooked}',
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        'My Reels',
                        Icons.video_library_rounded,
                        const Color(0xFF9C27B0),
                        () {},
                        badge: '${user.totalReelsReceived}',
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        'Favorites',
                        Icons.favorite_rounded,
                        const Color(0xFFFF3040),
                        () {},
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        'Download History',
                        Icons.download_rounded,
                        const Color(0xFF00D66B),
                        () {},
                      ),
                    ]),

                    const SizedBox(height: 24),

                    Text(
                      'Wallet & Rewards',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMenuCard([
                      _buildMenuItem(
                        'My Wallet',
                        Icons.account_balance_wallet_rounded,
                        const Color(0xFFFFB800),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WalletTransactionScreen(),
                            ),
                          );
                        },
                        trailing: '₹${user.walletBalance.toInt()}',
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        'Refer & Earn',
                        Icons.card_giftcard_rounded,
                        AppColors.primary,
                        () {},
                        subtitle: 'Get ₹100 per referral',
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        'Transaction History',
                        Icons.receipt_long_rounded,
                        const Color(0xFF007AFF),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TransactionHistoryScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        'Offers & Coupons',
                        Icons.local_offer_rounded,
                        const Color(0xFFFF9500),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OffersCouponsScreen(),
                            ),
                          );
                        },
                        badge: '3',
                      ),
                    ]),

                    const SizedBox(height: 24),

                    Text(
                      'Settings & Support',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMenuCard([
                      _buildMenuItem(
                        'Saved Addresses',
                        Icons.location_on_rounded,
                        const Color(0xFFFF3040),
                        () {},
                        badge: '${user.savedAddresses?.length ?? 0}',
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        'Payment Methods',
                        Icons.credit_card_rounded,
                        const Color(0xFF007AFF),
                        () {},
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        'Notifications',
                        Icons.notifications_rounded,
                        const Color(0xFF9C27B0),
                        () {},
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        'Language',
                        Icons.language_rounded,
                        const Color(0xFF00D66B),
                        () {},
                        trailing: 'English',
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        'Help & Support',
                        Icons.help_rounded,
                        const Color(0xFFFF9500),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpSupportScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        'About',
                        Icons.info_rounded,
                        AppColors.textTertiary,
                        () {},
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // Referral Card - Refined
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667eea).withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 0.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.card_giftcard_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Invite Friends',
                                      style: AppTypography.headlineSmall.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Get ₹100 for each referral',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Your Referral Code',
                                        style: AppTypography.captionLarge.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        user.referralCode ?? 'RAPID123',
                                        style: AppTypography.headlineMedium.copyWith(
                                          letterSpacing: 2,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Material(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: () {},
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        'Share',
                                        style: AppTypography.buttonMedium.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Logout Button - Refined
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showLogoutDialog(),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.logout_rounded,
                                color: Color(0xFFFF3B30),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Logout',
                                style: AppTypography.buttonLarge.copyWith(
                                  color: const Color(0xFFFF3B30),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // App Version - Refined
                    Center(
                      child: Text(
                        'Version 1.0.0',
                        style: AppTypography.captionLarge.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.statMedium.copyWith(
            color: Colors.white,
            shadows: const [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.captionLarge.copyWith(
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.cardBackground.withValues(alpha: 0.5),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: AppColors.cardBackground.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    Color iconColor,
    VoidCallback onTap, {
    String? subtitle,
    String? trailing,
    String? badge,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon Container - Refined
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: -0.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Trailing
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                              child: Text(
                                badge,
                                style: AppTypography.badge,
                              ),
                    ),
                  if (badge != null && trailing != null) const SizedBox(width: 8),
                  if (trailing != null)
                            Text(
                              trailing,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to login page
                context.go(AppRoutes.login);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

