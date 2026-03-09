import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/mock_data_service.dart';
import 'provider_booking_details_screen.dart';

class ProviderBookingsScreen extends StatefulWidget {
  final String providerId;
  
  const ProviderBookingsScreen({
    super.key,
    required this.providerId,
  });

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _mockData = MockDataService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _mockData.getProviderEvents(widget.providerId);
    final pending = bookings.where((b) => b.status == 'pending').toList();
    final confirmed = bookings.where((b) => b.status == 'confirmed').toList();
    final ongoing = bookings.where((b) => b.status == 'ongoing').toList();
    final completed = bookings.where((b) => b.status == 'completed').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Bookings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          tabs: [
            Tab(text: 'Pending (${pending.length})'),
            Tab(text: 'Confirmed (${confirmed.length})'),
            Tab(text: 'Ongoing (${ongoing.length})'),
            Tab(text: 'Completed (${completed.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsList(pending, 'pending'),
          _buildBookingsList(confirmed, 'confirmed'),
          _buildBookingsList(ongoing, 'ongoing'),
          _buildBookingsList(completed, 'completed'),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List bookings, String status) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No $status bookings', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking, status);
      },
    );
  }

  Widget _buildBookingCard(booking, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.eventType.toUpperCase(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${booking.eventId}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today, '${booking.eventDate.day}/${booking.eventDate.month}/${booking.eventDate.year}'),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.access_time, booking.eventTime),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.location_on, booking.venue.address),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.currency_rupee, '₹${booking.totalAmount.toStringAsFixed(0)}'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => ProviderBookingDetailsScreen(
                        bookingId: booking.eventId,
                        providerId: widget.providerId,
                      ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              if (status == 'pending') ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _declineBooking(booking.eventId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptBooking(booking.eventId),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.green;
      case 'ongoing': return Colors.blue;
      case 'completed': return Colors.purple;
      default: return Colors.grey;
    }
  }

  void _acceptBooking(String bookingId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking $bookingId accepted')),
    );
  }

  void _declineBooking(String bookingId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking $bookingId declined')),
    );
  }
}

