import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

/// Notifications Screen - Shows all user notifications
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  final List<Map<String, dynamic>> _allNotifications = [
    {
      'id': 'notif_001',
      'type': 'booking_confirmed',
      'title': 'Booking Confirmed! 🎉',
      'message': 'Your wedding event booking has been confirmed for Dec 25, 2026',
      'time': DateTime.now().subtract(const Duration(minutes: 5)),
      'isRead': false,
      'icon': Icons.check_circle,
      'color': Colors.green,
      'actionText': 'View Details',
    },
    {
      'id': 'notif_002',
      'type': 'reel_ready',
      'title': 'Your Reel is Ready! 🎬',
      'message': 'Your birthday party reel has been delivered. Check it out now!',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
      'icon': Icons.video_library,
      'color': AppColors.primary,
      'actionText': 'Watch Now',
    },
    {
      'id': 'notif_003',
      'type': 'payment_success',
      'title': 'Payment Successful ✅',
      'message': 'Your payment of ₹15,000 has been processed successfully',
      'time': DateTime.now().subtract(const Duration(hours: 5)),
      'isRead': true,
      'icon': Icons.payment,
      'color': Colors.blue,
      'actionText': 'View Receipt',
    },
    {
      'id': 'notif_004',
      'type': 'referral_earned',
      'title': 'You Earned ₹100! 💰',
      'message': 'Your friend Rajesh signed up using your referral code',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
      'icon': Icons.card_giftcard,
      'color': Colors.amber,
      'actionText': 'View Wallet',
    },
    {
      'id': 'notif_005',
      'type': 'event_reminder',
      'title': 'Event Tomorrow! ⏰',
      'message': 'Your engagement ceremony is scheduled for tomorrow at 6:00 PM',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
      'icon': Icons.event,
      'color': Colors.orange,
      'actionText': 'View Event',
    },
    {
      'id': 'notif_006',
      'type': 'provider_message',
      'title': 'Message from Provider 💬',
      'message': 'Creative Reels Studio: "We\'ll arrive 30 minutes early to set up"',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'isRead': true,
      'icon': Icons.message,
      'color': Colors.purple,
      'actionText': 'Reply',
    },
    {
      'id': 'notif_007',
      'type': 'offer',
      'title': 'Special Offer! 🎁',
      'message': 'Get 20% off on your next booking. Use code: RAPID20',
      'time': DateTime.now().subtract(const Duration(days: 3)),
      'isRead': true,
      'icon': Icons.local_offer,
      'color': Colors.pink,
      'actionText': 'Use Offer',
    },
    {
      'id': 'notif_008',
      'type': 'review_request',
      'title': 'Rate Your Experience ⭐',
      'message': 'How was your recent event with Moment Makers?',
      'time': DateTime.now().subtract(const Duration(days: 5)),
      'isRead': true,
      'icon': Icons.star,
      'color': Colors.amber,
      'actionText': 'Rate Now',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final unreadNotifications = _allNotifications.where((n) => !n['isRead']).toList();
    final bookingNotifications = _allNotifications
        .where((n) => ['booking_confirmed', 'event_reminder', 'payment_success'].contains(n['type']))
        .toList();
    final otherNotifications = _allNotifications
        .where((n) => !['booking_confirmed', 'event_reminder', 'payment_success'].contains(n['type']))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (unreadNotifications.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  for (var notif in _allNotifications) {
                    notif['isRead'] = true;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications marked as read')),
                );
              },
              child: const Text('Mark all read'),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(
              text: 'All',
              icon: unreadNotifications.isNotEmpty
                  ? Badge(
                      label: Text('${unreadNotifications.length}'),
                      child: const Icon(Icons.notifications),
                    )
                  : const Icon(Icons.notifications),
            ),
            const Tab(text: 'Bookings', icon: Icon(Icons.event)),
            const Tab(text: 'Updates', icon: Icon(Icons.campaign)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsList(_allNotifications),
          _buildNotificationsList(bookingNotifications),
          _buildNotificationsList(otherNotifications),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<Map<String, dynamic>> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? AppColors.surface : AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? Colors.transparent : AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              notification['isRead'] = true;
            });
            _handleNotificationAction(notification);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (notification['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notification['icon'] as IconData,
                    color: notification['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification['message'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTime(notification['time'] as DateTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _handleNotificationAction(notification);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              notification['actionText'] as String,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _handleNotificationAction(Map<String, dynamic> notification) {
    final type = notification['type'] as String;
    String message = '';

    switch (type) {
      case 'booking_confirmed':
        message = 'Opening booking details...';
        break;
      case 'reel_ready':
        message = 'Opening your reel...';
        break;
      case 'payment_success':
        message = 'Opening payment receipt...';
        break;
      case 'referral_earned':
        message = 'Opening wallet...';
        break;
      case 'event_reminder':
        message = 'Opening event details...';
        break;
      case 'provider_message':
        message = 'Opening chat...';
        break;
      case 'offer':
        message = 'Applying offer code...';
        break;
      case 'review_request':
        message = 'Opening review form...';
        break;
      default:
        message = 'Opening notification...';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
