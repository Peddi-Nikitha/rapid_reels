import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/firebase/models/firebase_provider_model.dart';
import '../../../../core/firebase/models/firebase_booking_model.dart';
import '../../../../core/theme/provider_app_theme.dart';
import '../../../../shared/widgets/provider/provider_action_card.dart';
import '../../../../shared/widgets/provider/provider_stat_card.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

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

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseProviderModel?>(
      future: _firestoreService.getProvider(widget.providerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
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
              appBar: AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: 64,
                titleSpacing: 16,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rapid Reels',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      provider.businessName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    tooltip: 'Notifications',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ProviderAppTheme.wrap(
                            const NotificationsScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ..._buildOverviewContent(
                      context,
                      provider,
                      stats,
                      todayBookings,
                    ),
                    const SizedBox(height: 20),
                    _buildReelsSection(context, provider),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildOverviewContent(
    BuildContext context,
    FirebaseProviderModel provider,
    Map<String, dynamic> stats,
    List<FirebaseBookingModel> todayBookings,
  ) {
    final cs = Theme.of(context).colorScheme;
    return [
      if (provider.verificationStatus != 'approved')
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: cs.primaryContainer.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.verified_user_outlined, color: cs.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      provider.verificationStatus == 'pending'
                          ? AppStrings.providerPendingApprovalProvider
                          : 'This profile is not approved for public listings. Contact support if you need help.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      Row(
        children: [
          Expanded(
            child: ProviderStatCard(
              title: 'Today',
              value: '${todayBookings.length}',
              subtitle: 'Bookings',
              icon: Icons.today,
              accentColor: cs.primary,
              onTap: () => context.go(
                '${AppRoutes.providerPortal}/${widget.providerId}/bookings',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ProviderStatCard(
              title: 'Pending',
              value: '${stats['pendingBookings']}',
              subtitle: 'To confirm',
              icon: Icons.pending_actions,
              accentColor: const Color(0xFFFFB020),
              onTap: () => context.go(
                '${AppRoutes.providerPortal}/${widget.providerId}/bookings',
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: ProviderStatCard(
              title: 'Total',
              value: '${stats['totalBookings']}',
              subtitle: 'Bookings',
              icon: Icons.event,
              accentColor: const Color(0xFF4ADE80),
              onTap: () => context.go(
                '${AppRoutes.providerPortal}/${widget.providerId}/bookings',
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      ProviderActionCard(
        icon: Icons.calendar_month_outlined,
        title: 'Schedule',
        subtitle: 'Events calendar and availability',
        onTap: () => context.go(
          '${AppRoutes.providerPortal}/${widget.providerId}/schedule',
        ),
      ),
      const SizedBox(height: 12),
      ProviderActionCard(
        icon: Icons.event_busy,
        title: 'Availability only',
        subtitle: 'Weekly hours and blocked dates',
        leadingAccent: false,
        onTap: () => context.push(AppRoutes.providerAvailabilityCalendar),
      ),
      const SizedBox(height: 24),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Today's bookings",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          TextButton(
            onPressed: () => context.go(
              '${AppRoutes.providerPortal}/${widget.providerId}/bookings',
            ),
            child: const Text('View all'),
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (todayBookings.isEmpty)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              'No bookings for today',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        )
      else
        ...todayBookings.map(
          (booking) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.event, color: cs.primary, size: 18),
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
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    ];
  }

  Widget _buildReelsSection(BuildContext context, FirebaseProviderModel provider) {
    if (provider.verificationStatus != 'approved') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(Icons.hourglass_top_rounded, size: 48, color: Theme.of(context).hintColor),
            const SizedBox(height: 12),
            Text(
              'Reels unlock after admin approval',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.providerPendingApprovalProvider,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor),
            ),
          ],
        ),
      );
    }
    return ProviderActionCard(
      icon: Icons.video_library_outlined,
      title: 'My reels',
      subtitle: 'Delivered and in-progress reels',
      onTap: () => context.push('${AppRoutes.providerMyReels}/${widget.providerId}'),
    );
  }
}

