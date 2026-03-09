import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/mock_data_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockData = MockDataService();
    
    // Mock admin statistics
    final stats = {
      'totalUsers': 1250,
      'totalProviders': 45,
      'totalBookings': 320,
      'pendingVerifications': 8,
      'pendingTickets': 12,
      'totalRevenue': 2500000.0,
      'todayBookings': 15,
      'activeProviders': 38,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Users',
                    value: '${stats['totalUsers']}',
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: () => context.push(AppRoutes.adminUserManagement),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Providers',
                    value: '${stats['totalProviders']}',
                    icon: Icons.business,
                    color: Colors.green,
                    onTap: () => context.push(AppRoutes.adminUserManagement),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Bookings',
                    value: '${stats['totalBookings']}',
                    icon: Icons.event,
                    color: Colors.purple,
                    onTap: () => context.push(AppRoutes.adminBookingManagement),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Revenue',
                    value: '₹${((stats['totalRevenue'] as double) / 100000).toStringAsFixed(1)}L',
                    icon: Icons.currency_rupee,
                    color: Colors.amber,
                    onTap: () => context.push(AppRoutes.adminPaymentManagement),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  context: context,
                  icon: Icons.verified_user,
                  title: 'Provider Verification',
                  subtitle: '${stats['pendingVerifications']} pending',
                  color: Colors.orange,
                  onTap: () => context.push(AppRoutes.adminProviderVerification),
                ),
                _buildActionCard(
                  context: context,
                  icon: Icons.video_library,
                  title: 'Content Moderation',
                  subtitle: 'Moderate reels',
                  color: Colors.red,
                  onTap: () => context.push(AppRoutes.adminContentModeration),
                ),
                _buildActionCard(
                  context: context,
                  icon: Icons.support_agent,
                  title: 'Support Tickets',
                  subtitle: '${stats['pendingTickets']} open',
                  color: Colors.blue,
                  onTap: () => context.push(AppRoutes.adminSupportTickets),
                ),
                _buildActionCard(
                  context: context,
                  icon: Icons.analytics,
                  title: 'Analytics',
                  subtitle: 'View insights',
                  color: Colors.purple,
                  onTap: () => context.push(AppRoutes.adminAnalytics),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Recent Activity
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildActivityItem('New provider registration', '2 hours ago', Icons.person_add, Colors.green),
            _buildActivityItem('Booking completed', '3 hours ago', Icons.check_circle, Colors.blue),
            _buildActivityItem('Payment processed', '4 hours ago', Icons.payment, Colors.amber),
            _buildActivityItem('Support ticket opened', '5 hours ago', Icons.support, Colors.red),
            _buildActivityItem('Provider verified', '6 hours ago', Icons.verified, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
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
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
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
    );
  }
}

