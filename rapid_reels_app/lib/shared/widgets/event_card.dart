import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../features/booking/data/models/event_booking_model.dart';

class EventCard extends StatelessWidget {
  final EventBooking event;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getStatusColor().withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Event Type Row
            Row(
              children: [
                _buildStatusBadge(),
                const Spacer(),
                _buildEventTypeChip(),
              ],
            ),
            const SizedBox(height: 12),
            
            // Event Name
            Text(
              event.eventName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            
            // Date and Time
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd MMM yyyy').format(event.eventDate),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  event.eventTime,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Venue
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.venue.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            if (event.status == 'confirmed' && event.eventDate.isAfter(DateTime.now())) ...[
              const SizedBox(height: 12),
              _buildCountdown(),
            ],
            
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            
            // Bottom Row - Package and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      size: 16,
                      color: _getPackageColor(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${event.packageName} Package',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getPackageColor(),
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${event.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (event.status == 'ongoing')
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(),
                shape: BoxShape.circle,
              ),
            ),
          Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _getEventTypeColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _formatEventType(event.eventType),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _getEventTypeColor(),
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    final difference = event.eventDate.difference(DateTime.now());
    final days = difference.inDays;
    final hours = difference.inHours % 24;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timer,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            days > 0
                ? 'In $days ${days == 1 ? "day" : "days"}'
                : 'In $hours ${hours == 1 ? "hour" : "hours"}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (event.status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'ongoing':
        return 'Live';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return event.status;
    }
  }

  Color _getStatusColor() {
    switch (event.status) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.info;
      case 'ongoing':
        return AppColors.success;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getEventTypeColor() {
    switch (event.eventType) {
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
        return AppColors.textSecondary;
    }
  }

  Color _getPackageColor() {
    switch (event.packageId) {
      case 'pkg_bronze':
        return const Color(0xFFCD7F32);
      case 'pkg_silver':
        return const Color(0xFFC0C0C0);
      case 'pkg_gold':
        return const Color(0xFFFFD700);
      case 'pkg_platinum':
        return const Color(0xFFE5E4E2);
      default:
        return AppColors.primary;
    }
  }

  String _formatEventType(String type) {
    return type[0].toUpperCase() + type.substring(1);
  }
}

