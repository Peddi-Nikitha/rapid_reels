import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../features/booking/data/models/event_booking_model.dart';

class ProviderBookingTimelineScreen extends StatelessWidget {
  final String bookingId;
  final String providerId;
  
  const ProviderBookingTimelineScreen({
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

    final timelineStages = _getTimelineStages(booking);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Booking Timeline',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.eventName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Booking ID: ${booking.eventId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      booking.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(booking.status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Timeline
            const Text(
              'Booking Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ...timelineStages.asMap().entries.map((entry) {
              final index = entry.key;
              final stage = entry.value;
              final isLast = index == timelineStages.length - 1;
              
              return _buildTimelineItem(
                stage: stage,
                isCompleted: stage['isCompleted'] as bool,
                isLast: isLast,
              );
            }),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getTimelineStages(EventBooking booking) {
    final stages = <Map<String, dynamic>>[];
    
    // Booking Requested
    stages.add({
      'title': 'Booking Requested',
      'description': 'Customer submitted booking request',
      'icon': Icons.event_available,
      'timestamp': booking.createdAt,
      'isCompleted': true,
    });
    
    // Booking Confirmed
    stages.add({
      'title': 'Booking Confirmed',
      'description': booking.status == 'pending' 
          ? 'Waiting for confirmation'
          : 'Booking has been confirmed',
      'icon': Icons.check_circle_outline,
      'timestamp': booking.eventStatus.bookingConfirmed,
      'isCompleted': booking.status != 'pending',
    });
    
    // Event Started
    if (booking.status == 'ongoing' || booking.status == 'completed') {
      stages.add({
        'title': 'Event Started',
        'description': 'Event coverage has begun',
        'icon': Icons.play_circle_outline,
        'timestamp': booking.eventStatus.eventStarted,
        'isCompleted': true,
      });
    } else {
      stages.add({
        'title': 'Event Started',
        'description': 'Event will start on ${_formatDate(booking.eventDate)}',
        'icon': Icons.play_circle_outline,
        'timestamp': booking.eventDate,
        'isCompleted': false,
      });
    }
    
    // Coverage In Progress
    if (booking.status == 'ongoing' || booking.status == 'completed') {
      stages.add({
        'title': 'Coverage In Progress',
        'description': 'Recording and capturing event moments',
        'icon': Icons.videocam,
        'timestamp': booking.eventStatus.eventStarted,
        'isCompleted': true,
      });
    } else {
      stages.add({
        'title': 'Coverage In Progress',
        'description': 'Coverage will begin during event',
        'icon': Icons.videocam,
        'timestamp': null,
        'isCompleted': false,
      });
    }
    
    // Footage Uploaded
    if (booking.status == 'completed') {
      stages.add({
        'title': 'Footage Uploaded',
        'description': 'Event footage has been uploaded',
        'icon': Icons.cloud_upload,
        'timestamp': booking.eventStatus.eventCompleted,
        'isCompleted': true,
      });
    } else {
      stages.add({
        'title': 'Footage Uploaded',
        'description': 'Footage will be uploaded after event',
        'icon': Icons.cloud_upload,
        'timestamp': null,
        'isCompleted': false,
      });
    }
    
    // Reel Delivered
    if (booking.status == 'completed') {
      stages.add({
        'title': 'Reel Delivered',
        'description': 'Reel has been delivered to customer',
        'icon': Icons.check_circle,
        'timestamp': booking.completedAt,
        'isCompleted': true,
      });
    } else {
      stages.add({
        'title': 'Reel Delivered',
        'description': 'Reel will be delivered after editing',
        'icon': Icons.check_circle,
        'timestamp': null,
        'isCompleted': false,
      });
    }
    
    // Event Completed
    stages.add({
      'title': 'Event Completed',
      'description': booking.status == 'completed'
          ? 'Event and delivery completed successfully'
          : 'Event completion pending',
      'icon': Icons.flag,
      'timestamp': booking.completedAt,
      'isCompleted': booking.status == 'completed',
    });
    
    return stages;
  }

  Widget _buildTimelineItem({
    required Map<String, dynamic> stage,
    required bool isCompleted,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line
          Column(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primary
                      : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  stage['icon'] as IconData,
                  color: isCompleted ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
              ),
              // Vertical Line
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted
                        ? AppColors.primary
                        : Colors.grey[300],
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage['title'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.black : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stage['description'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (stage['timestamp'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _formatDateTime(stage['timestamp'] as DateTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'ongoing':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

