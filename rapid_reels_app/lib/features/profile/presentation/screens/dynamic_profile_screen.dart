import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Dynamic Profile Screen - Fully integrated with Firebase
/// Real-time user data, statistics, and quick actions
class DynamicProfileScreen extends ConsumerStatefulWidget {
  const DynamicProfileScreen({super.key});

  @override
  ConsumerState<DynamicProfileScreen> createState() => _DynamicProfileScreenState();
}

class _DynamicProfileScreenState extends ConsumerState<DynamicProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final userId = currentUser?.uid ?? '';

    if (userId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: Text('Please login to view profile'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userProfileProvider(userId));
            ref.invalidate(recentBookingsProvider(userId));
            ref.invalidate(recentReelsProvider(userId));
          },
          child: CustomScrollView(
            slivers: [
              // Profile Header
              _buildProfileHeader(userId),
              
              // Statistics Section
              _buildStatisticsSection(userId),
              
              // Quick Actions
              _buildQuickActions(),
              
              // Recent Activity
              _buildRecentActivity(userId),
              
              // Referral Section
              _buildReferralSection(userId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String userId) {
    final userAsync = ref.watch(userProfileProvider(userId));
    
    return SliverToBoxAdapter(
      child: userAsync.when(
        data: (user) {
          if (user == null) {
            return const SizedBox.shrink();
          }
          
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Picture
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        border: Border.all(color: AppColors.primary, width: 3),
                      ),
                      child: user.profileImage != null
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: user.profileImage!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.textPrimary,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                          border: Border.all(color: AppColors.background, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Name and Verification
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.fullName,
                      style: AppTypography.headlineMedium,
                    ),
                    if (user.isVerified) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                
                // Location
                if (user.currentLocation != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user.currentLocation!.city}, ${user.currentLocation!.state}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
        loading: () => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 150,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading profile',
                style: AppTypography.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(String userId) {
    final userAsync = ref.watch(userProfileProvider(userId));
    final walletBalance = ref.watch(walletBalanceProvider(userId));
    
    return SliverToBoxAdapter(
      child: userAsync.when(
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.event,
                  label: 'Events',
                  value: user.totalEventsBooked.toString(),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.textTertiary,
                ),
                _buildStatItem(
                  icon: Icons.video_library,
                  label: 'Reels',
                  value: user.totalReelsReceived.toString(),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.textTertiary,
                ),
                _buildStatItem(
                  icon: Icons.account_balance_wallet,
                  label: 'Wallet',
                  value: '₹${walletBalance.toStringAsFixed(0)}',
                ),
              ],
            ),
          );
        },
        loading: () => Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildActionCard(
                  icon: Icons.edit,
                  label: 'Edit Profile',
                  onTap: () => context.push(AppRoutes.editProfile),
                ),
                _buildActionCard(
                  icon: Icons.account_balance_wallet,
                  label: 'Wallet',
                  onTap: () => context.push(AppRoutes.wallet),
                ),
                _buildActionCard(
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () => context.push(AppRoutes.settings),
                ),
                _buildActionCard(
                  icon: Icons.help_outline,
                  label: 'Support',
                  onTap: () => context.push(AppRoutes.support),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.textTertiary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyMedium,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(String userId) {
    final bookingsAsync = ref.watch(recentBookingsProvider(userId));
    final reelsAsync = ref.watch(recentReelsProvider(userId));
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Recent Bookings
            bookingsAsync.when(
              data: (bookings) {
                if (bookings.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.event_busy,
                    message: 'No recent bookings',
                    action: 'Book Now',
                    onAction: () => context.push(AppRoutes.eventTypeSelection),
                  );
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Bookings',
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...bookings.take(3).map((booking) => _buildBookingCard(booking)),
                    if (bookings.length > 3)
                      TextButton(
                        onPressed: () => context.push(AppRoutes.myEvents),
                        child: const Text('View All'),
                      ),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            const SizedBox(height: 24),
            
            // Recent Reels
            reelsAsync.when(
              data: (reels) {
                if (reels.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.video_library_outlined,
                    message: 'No reels yet',
                  );
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Reels',
                      style: AppTypography.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: reels.length,
                        itemBuilder: (context, index) {
                          return _buildReelCard(reels[index]);
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.event,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.eventName,
                  style: AppTypography.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  booking.eventType.toUpperCase(),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(booking.status),
        ],
      ),
    );
  }

  Widget _buildReelCard(reel) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: reel.thumbnailUrl,
              width: 100,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.surface,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            reel.title,
            style: AppTypography.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'confirmed':
        color = AppColors.success;
        break;
      case 'ongoing':
        color = AppColors.info;
        break;
      case 'completed':
        color = AppColors.success;
        break;
      case 'cancelled':
        color = AppColors.error;
        break;
      default:
        color = AppColors.warning;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildReferralSection(String userId) {
    final userAsync = ref.watch(userProfileProvider(userId));
    
    return SliverToBoxAdapter(
      child: userAsync.when(
        data: (user) {
          if (user == null || user.referralCode == null) {
            return const SizedBox.shrink();
          }
          
          return Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.card_giftcard,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Referral Code',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.referralCode!,
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.textPrimary,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.copy,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () {
                          // Copy to clipboard
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Referral code copied!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Share your code and earn rewards!',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? action,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (action != null && onAction != null) ...[
            const SizedBox(height: 16),
            CustomButton(
              text: action,
              onPressed: onAction,
              type: ButtonType.outline,
            ),
          ],
        ],
      ),
    );
  }
}

