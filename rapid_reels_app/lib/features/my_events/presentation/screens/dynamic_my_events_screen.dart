import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/my_events_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

/// Dynamic My Events Screen - Fully integrated with Firebase
/// Real-time bookings list with filtering and search
class DynamicMyEventsScreen extends ConsumerStatefulWidget {
  const DynamicMyEventsScreen({super.key});

  @override
  ConsumerState<DynamicMyEventsScreen> createState() => _DynamicMyEventsScreenState();
}

class _DynamicMyEventsScreenState extends ConsumerState<DynamicMyEventsScreen> {
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _filters = ['all', 'upcoming', 'ongoing', 'completed', 'cancelled'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final userId = currentUser?.uid ?? '';

    if (userId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: Text('Please login to view events'),
        ),
      );
    }

    final filteredEvents = ref.watch(
      filteredEventsProvider((userId: userId, status: _selectedFilter == 'all' ? null : _selectedFilter)),
    );

    final searchResults = _searchQuery.isEmpty
        ? filteredEvents
        : ref.watch(searchEventsProvider((userId: userId, query: _searchQuery)));

    final stats = ref.watch(eventStatsProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'My Events',
          style: AppTypography.headlineSmall,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _buildSearchDialog(),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myEventsProvider(userId));
        },
        child: CustomScrollView(
          slivers: [
            // Statistics Bar
            _buildStatsBar(stats),
            
            // Filter Tabs
            _buildFilterTabs(),
            
            // Events List
            if (searchResults.isEmpty)
              _buildEmptyState()
            else
              _buildEventsList(searchResults),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBar(Map<String, int> stats) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatChip('Total', stats['total'] ?? 0),
            _buildStatChip('Upcoming', stats['upcoming'] ?? 0, AppColors.info),
            _buildStatChip('Ongoing', stats['ongoing'] ?? 0, AppColors.warning),
            _buildStatChip('Completed', stats['completed'] ?? 0, AppColors.success),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int value, [Color? color]) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: AppTypography.headlineSmall.copyWith(
            color: color ?? AppColors.primary,
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

  Widget _buildFilterTabs() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _filters.length,
          itemBuilder: (context, index) {
            final filter = _filters[index];
            final isSelected = _selectedFilter == filter;
            
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilterChip(
                label: Text(
                  filter.toUpperCase(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary,
                checkmarkColor: AppColors.textPrimary,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventsList(List events) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final booking = events[index];
            return _buildEventCard(booking);
          },
          childCount: events.length,
        ),
      ),
    );
  }

  Widget _buildEventCard(booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          context.push('${AppRoutes.eventDetails2}/${booking.bookingId}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Event Type Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getEventTypeColor(booking.eventType).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getEventTypeIcon(booking.eventType),
                      color: _getEventTypeColor(booking.eventType),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Event Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.eventName,
                          style: AppTypography.titleMedium,
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
                  
                  // Status Badge
                  _buildStatusBadge(booking.status),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Event Details
              _buildDetailRow(
                Icons.calendar_today,
                _formatDate(booking.eventDate),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.access_time,
                booking.eventTime,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.location_on,
                '${booking.venue.name}, ${booking.venue.city}',
              ),
              
              const SizedBox(height: 16),
              
              // Package Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Package',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.package.name,
                            style: AppTypography.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${booking.payment.totalAmount.toStringAsFixed(0)}',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          booking.payment.paymentStatus.toUpperCase(),
                          style: AppTypography.bodySmall.copyWith(
                            color: _getPaymentStatusColor(booking.payment.paymentStatus),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Action Buttons
              if (booking.status == 'confirmed' || booking.status == 'ongoing')
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Track Live',
                          onPressed: () {
                            context.push('${AppRoutes.liveEventTracking}/${booking.bookingId}');
                          },
                          type: ButtonType.outline,
                          height: 40,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'View Details',
                          onPressed: () {
                            context.push('${AppRoutes.eventDetails2}/${booking.bookingId}');
                          },
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    
    switch (status) {
      case 'pending':
        color = AppColors.warning;
        icon = Icons.pending;
        break;
      case 'confirmed':
        color = AppColors.success;
        icon = Icons.check_circle;
        break;
      case 'ongoing':
        color = AppColors.info;
        icon = Icons.play_circle;
        break;
      case 'completed':
        color = AppColors.success;
        icon = Icons.done_all;
        break;
      case 'cancelled':
        color = AppColors.error;
        icon = Icons.cancel;
        break;
      default:
        color = AppColors.textSecondary;
        icon = Icons.help;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: AppTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 24),
            Text(
              'No Events Found',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'all'
                  ? 'Start booking your first event!'
                  : 'No ${_selectedFilter} events',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Book Event',
              onPressed: () {
                context.push(AppRoutes.eventTypeSelection);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchDialog() {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        'Search Events',
        style: AppTypography.titleLarge,
      ),
      content: TextField(
        controller: _searchController,
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search by event name, type, or venue...',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _searchController.clear();
            setState(() {
              _searchQuery = '';
            });
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Search'),
        ),
      ],
    );
  }

  Color _getEventTypeColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'wedding':
        return AppColors.wedding;
      case 'birthday':
        return AppColors.birthday;
      case 'engagement':
        return AppColors.engagement;
      case 'corporate':
        return AppColors.corporate;
      case 'brand':
        return AppColors.brand;
      default:
        return AppColors.primary;
    }
  }

  IconData _getEventTypeIcon(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'wedding':
        return Icons.favorite;
      case 'birthday':
        return Icons.cake;
      case 'engagement':
        return Icons.diamond;
      case 'corporate':
        return Icons.business;
      case 'brand':
        return Icons.store;
      default:
        return Icons.event;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'fully_paid':
        return AppColors.success;
      case 'advance_paid':
        return AppColors.warning;
      case 'pending':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

