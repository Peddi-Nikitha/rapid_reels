import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/mock_data_service.dart';

class ProviderBookingDetailsScreen extends StatelessWidget {
  final String bookingId;
  final String providerId;
  
  const ProviderBookingDetailsScreen({
    super.key,
    required this.bookingId,
    required this.providerId,
  });

  @override
  Widget build(BuildContext context) {
    final mockData = MockDataService();
    final bookings = mockData.getProviderEvents(providerId);
    final booking = bookings.firstWhere(
      (b) => b.eventId == bookingId,
      orElse: () => bookings.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Booking Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getStatusColor(booking.status).withValues(alpha: 0.2),
                    _getStatusColor(booking.status).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getStatusColor(booking.status),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(booking.status),
                    color: _getStatusColor(booking.status),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(booking.status),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Booking ID: ${booking.eventId}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Event Information
            const Text(
              'Event Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.event,
              title: 'Event Type',
              value: booking.eventType.toUpperCase(),
            ),
            _buildInfoCard(
              icon: Icons.calendar_today,
              title: 'Date',
              value: '${booking.eventDate.day}/${booking.eventDate.month}/${booking.eventDate.year}',
            ),
            _buildInfoCard(
              icon: Icons.access_time,
              title: 'Time',
              value: booking.eventTime,
            ),
            _buildInfoCard(
              icon: Icons.location_on,
              title: 'Venue',
              value: booking.venue.address,
            ),
            _buildInfoCard(
              icon: Icons.people,
              title: 'Guest Count',
              value: '${booking.guestCount} guests',
            ),
            const SizedBox(height: 24),
            
            // Booking Timeline
            const Text(
              'Booking Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTimeline(),
            const SizedBox(height: 24),
            
            // Customer Contact
            const Text(
              'Customer Contact',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+91 98765 43210',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone, color: AppColors.primary),
                    onPressed: () {
                      // Make call
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.message, color: AppColors.primary),
                    onPressed: () {
                      // Send message
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Navigation to Venue
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Open maps navigation
                },
                icon: const Icon(Icons.directions),
                label: const Text('Navigate to Venue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickActionButton(
                  context: context,
                  icon: Icons.timeline,
                  label: 'Timeline',
                  onTap: () {
                    context.push(
                      '${AppRoutes.providerBookingTimeline}/$providerId/$bookingId',
                    );
                  },
                ),
                _buildQuickActionButton(
                  context: context,
                  icon: Icons.calendar_today,
                  label: 'Calendar',
                  onTap: () {
                    context.push(
                      '${AppRoutes.providerBookingCalendar}/$providerId',
                    );
                  },
                ),
                _buildQuickActionButton(
                  context: context,
                  icon: Icons.contact_phone,
                  label: 'Contact',
                  onTap: () {
                    context.push(
                      '${AppRoutes.providerCustomerContact}/$providerId/$bookingId',
                    );
                  },
                ),
                _buildQuickActionButton(
                  context: context,
                  icon: Icons.navigation,
                  label: 'Navigate',
                  onTap: () {
                    context.push(
                      '${AppRoutes.providerVenueNavigation}/$providerId/$bookingId',
                    );
                  },
                ),
                _buildQuickActionButton(
                  context: context,
                  icon: Icons.checklist,
                  label: 'Checklist',
                  onTap: () {
                    context.push(
                      '${AppRoutes.providerPreEventChecklist}/$providerId/$bookingId',
                    );
                  },
                ),
                _buildQuickActionButton(
                  context: context,
                  icon: Icons.update,
                  label: 'Status',
                  onTap: () {
                    context.push(
                      '${AppRoutes.providerBookingStatus}/$providerId/$bookingId',
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            if (booking.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Decline booking
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Accept booking
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              )
            else if (booking.status == 'confirmed')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/live-event-mode');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Start Event Coverage'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final timelineSteps = [
      {'step': 'Booking Created', 'completed': true, 'time': '2 days ago'},
      {'step': 'Payment Received', 'completed': true, 'time': '1 day ago'},
      {'step': 'Booking Confirmed', 'completed': true, 'time': '12 hours ago'},
      {'step': 'Event Coverage', 'completed': false, 'time': 'Pending'},
      {'step': 'Reel Delivery', 'completed': false, 'time': 'Pending'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: timelineSteps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isLast = index == timelineSteps.length - 1;
          
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: step['completed'] as bool
                          ? AppColors.success
                          : Colors.grey[700],
                    ),
                    child: step['completed'] as bool
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: step['completed'] as bool
                          ? AppColors.success
                          : Colors.grey[700],
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['step'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: step['completed'] as bool
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['time'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'ongoing':
        return Icons.play_circle;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'ongoing':
        return Colors.blue;
      case 'completed':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 48) / 3,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

