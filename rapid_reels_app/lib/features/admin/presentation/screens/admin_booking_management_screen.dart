import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/firebase/models/firebase_booking_model.dart';
import '../../../../core/firebase/models/firebase_payment_transaction_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';

class AdminBookingManagementScreen extends StatefulWidget {
  const AdminBookingManagementScreen({super.key});

  @override
  State<AdminBookingManagementScreen> createState() => _AdminBookingManagementScreenState();
}

class _AdminBookingManagementScreenState extends State<AdminBookingManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FirebaseBookingModel>>(
      future: _firestoreService.getAllBookings(),
      builder: (context, snapshot) {
        final allBookings = snapshot.data ?? [];
        final pending = allBookings.where((b) => b.status == 'pending').toList();
        final confirmed = allBookings.where((b) => b.status == 'confirmed').toList();
        final ongoing = allBookings.where((b) => b.status == 'ongoing').toList();
        final completed = allBookings.where((b) => b.status == 'completed').toList();

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Booking Management')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Booking Management',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (_) {},
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Bookings')),
              const PopupMenuItem(value: 'Today', child: Text('Today')),
              const PopupMenuItem(value: 'This Week', child: Text('This Week')),
              const PopupMenuItem(value: 'This Month', child: Text('This Month')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          isScrollable: true,
          tabs: [
            Tab(text: 'All (${allBookings.length})'),
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
          _buildBookingsList(allBookings),
          _buildBookingsList(pending),
          _buildBookingsList(confirmed),
          _buildBookingsList(ongoing),
          _buildBookingsList(completed),
        ],
      ),
    );
      },
    );
  }

  Widget _buildBookingsList(List<FirebaseBookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No bookings found', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(FirebaseBookingModel booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(booking.status).withValues(alpha: 0.3),
          width: 1,
        ),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${booking.bookingId}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(booking.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(booking.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.calendar_today, '${booking.eventDate.day}/${booking.eventDate.month}/${booking.eventDate.year}'),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.access_time, booking.eventTime),
          _buildInfoRow(Icons.person, 'Customer: ${booking.customerId}'),
          _buildInfoRow(Icons.business, 'Provider: ${booking.providerId}'),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.location_on, booking.venue.address),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.currency_pound, '£${booking.payment.totalAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showBookingPaymentDetails(booking);
                  },
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 12),
              if (booking.status == 'pending')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Take action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Manage'),
                  ),
                ),
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
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
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

  void _showBookingPaymentDetails(FirebaseBookingModel booking) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking ${booking.bookingId}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Customer: ${booking.customerId}'),
                Text('Provider: ${booking.providerId}'),
                const SizedBox(height: 12),
                const Text(
                  'Payment Transactions',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<List<FirebasePaymentTransactionModel>>(
                    stream: _firestoreService.streamPaymentTransactionsByBooking(booking.bookingId),
                    builder: (context, snapshot) {
                      final txs = snapshot.data ?? const <FirebasePaymentTransactionModel>[];
                      if (txs.isEmpty) return const Center(child: Text('No transactions found'));
                      return ListView.builder(
                        itemCount: txs.length,
                        itemBuilder: (context, index) {
                          final tx = txs[index];
                          return ListTile(
                            leading: const Icon(Icons.payment),
                            title: Text(tx.transactionId, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text('£${tx.amount.toStringAsFixed(2)} • ${tx.status}'),
                            trailing: Text(tx.currency.toUpperCase()),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

