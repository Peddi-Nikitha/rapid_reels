import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/firebase/models/firebase_provider_model.dart';
import '../../../../core/firebase/models/firebase_booking_model.dart';

bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class ProviderDashboardScreen extends StatefulWidget {
  final String providerId;
  
  const ProviderDashboardScreen({
    super.key,
    required this.providerId,
  });

  @override
  State<ProviderDashboardScreen> createState() => _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseProviderModel?>(
      future: _firestoreService.getProvider(widget.providerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Text(
                'Error loading provider: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final provider = snapshot.data;
        if (provider == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text('Provider not found')),
          );
        }

        // Stream provider bookings to drive dashboard stats and today's schedule
        return StreamBuilder<List<FirebaseBookingModel>>(
          stream: _firestoreService.streamProviderBookings(widget.providerId),
          builder: (context, bookingSnapshot) {
            final bookings = bookingSnapshot.data ?? <FirebaseBookingModel>[];

            final today = DateTime.now();
            final todayBookings = bookings
                .where((b) => isSameDay(b.eventDate, today))
                .toList();
            final pendingCount =
                bookings.where((b) => b.status == 'pending').length;
            final totalBookings = bookings.length;

            final stats = <String, dynamic>{
              'pendingBookings': pendingCount,
              'totalBookings': totalBookings,
            };

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.surface,
                elevation: 0,
                title: Text(
                  provider.businessName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Dashboard'),
                    Tab(text: 'Reels'),
                    Tab(text: 'My Profile'),
                  ],
                ),
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(provider, stats, todayBookings),
                    _buildReelsTab(),
                    _buildMyProfileTab(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOverviewTab(provider, stats, todayBookings) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Today',
                    value: '${todayBookings.length}',
                    subtitle: 'Bookings',
                    icon: Icons.today,
                    color: Colors.blue,
                    onTap: () => context.push(
                      '${AppRoutes.providerBookings}/${widget.providerId}',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Pending',
                    value: '${stats['pendingBookings']}',
                    subtitle: 'To Confirm',
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                    onTap: () => context.push(
                      '${AppRoutes.providerBookings}/${widget.providerId}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total',
                    value: '${stats['totalBookings']}',
                    subtitle: 'Bookings',
                    icon: Icons.event,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            // Today's Bookings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today\'s Bookings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(
                    '${AppRoutes.providerBookings}/${widget.providerId}',
                  ),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (todayBookings.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'No bookings for today',
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...todayBookings.map(
                (booking) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event, color: AppColors.primary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.eventType.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${booking.eventDate.day}/${booking.eventDate.month}/${booking.eventDate.year} at ${booking.eventTime}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
    );
  }

  Widget _buildReelsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildActionCard(
          context: context,
          icon: Icons.video_library,
          title: 'My Reels',
          subtitle: 'View and manage your reels',
          gradient: const LinearGradient(
            colors: [Color(0xFF8E44AD), Color(0xFF9B59B6)],
          ),
          onTap: () => context.push('${AppRoutes.providerMyReels}/${widget.providerId}'),
        ),
      ],
    );
  }

  Widget _buildMyProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildActionCard(
          context: context,
          icon: Icons.person,
          title: 'Business Profile',
          subtitle: 'Update your provider profile',
          gradient: const LinearGradient(
            colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
          ),
          onTap: () => context.push(AppRoutes.providerBusinessProfile),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          context: context,
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Sign out from your account',
          gradient: const LinearGradient(
            colors: [Color(0xFFFF3B30), Color(0xFFFF6B6B)],
          ),
          onTap: () => _showLogoutDialog(context),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: card,
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to provider login page
              if (context.mounted) {
                context.go(AppRoutes.providerLogin);
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

