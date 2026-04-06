import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/provider_app_colors.dart';
import '../../../../core/theme/provider_app_theme.dart';
import '../../../../shared/widgets/provider/provider_gradient_button.dart';
import '../../../../core/firebase/models/firebase_booking_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';
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
  final _firestoreService = FirestoreService();

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
    return StreamBuilder<List<FirebaseBookingModel>>(
      stream: _firestoreService.streamProviderBookings(widget.providerId),
      builder: (context, snapshot) {
        final bookings = snapshot.data ?? [];
        final pending = bookings.where((b) => b.status == 'pending').toList();
        final confirmed = bookings
            .where((b) => b.status == 'confirmed' || b.status == 'ongoing')
            .toList();
        final completed = bookings.where((b) => b.status == 'completed').toList();

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Bookings')),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        return Scaffold(
      backgroundColor: ProviderAppColors.background,
      appBar: AppBar(
        backgroundColor: ProviderAppColors.background,
        elevation: 0,
        title: Text(
          'Bookings',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ProviderAppColors.primary,
          labelColor: ProviderAppColors.primary,
          unselectedLabelColor: ProviderAppColors.textMuted,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
          isScrollable: true,
          tabs: [
            Tab(text: 'Pending (${pending.length})'),
            Tab(text: 'Confirmed (${confirmed.length})'),
            Tab(text: 'Completed (${completed.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingsList(pending, 'pending'),
          _buildBookingsList(confirmed, 'confirmed'),
          _buildBookingsList(completed, 'completed'),
        ],
      ),
    );
      },
    );
  }

  Widget _buildBookingsList(List<FirebaseBookingModel> bookings, String status) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: ProviderAppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'No $status bookings',
              style: GoogleFonts.poppins(color: ProviderAppColors.textSecondary),
            ),
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

  Widget _buildBookingCard(FirebaseBookingModel booking, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProviderAppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ProviderAppColors.outline.withValues(alpha: 0.6)),
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
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ProviderAppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${booking.bookingId}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: ProviderAppColors.textTertiary,
                      ),
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
          const SizedBox(height: 6),
          _buildInfoRow(Icons.location_on, booking.venue.address),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.currency_pound, '£${booking.payment.totalAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => ProviderAppTheme.wrap(
                          ProviderBookingDetailsScreen(
                            bookingId: booking.bookingId,
                            providerId: widget.providerId,
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ProviderAppColors.primary,
                    side: const BorderSide(color: ProviderAppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              if (booking.status == 'pending') ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _declineBooking(booking),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ProviderAppColors.error,
                      side: const BorderSide(color: ProviderAppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ProviderSuccessButton(
                    fullWidth: true,
                    minHeight: 44,
                    onPressed: () => _acceptBooking(booking),
                    label: 'Accept',
                  ),
                ),
              ],
              if (booking.status == 'confirmed' || booking.status == 'ongoing') ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ProviderGradientButton(
                    fullWidth: true,
                    minHeight: 44,
                    onPressed: () => _markAsDone(booking),
                    label: 'Mark Done',
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
        Icon(icon, size: 14, color: ProviderAppColors.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: ProviderAppColors.textSecondary,
            ),
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

  Future<void> _acceptBooking(FirebaseBookingModel booking) async {
    try {
      await _firestoreService.updateBooking(booking.bookingId, {
        'status': 'confirmed',
        'eventStatus.providerAccepted': Timestamp.now(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking accepted'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _declineBooking(FirebaseBookingModel booking) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Decline Booking'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Reason for declining (optional)',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: const Text('Decline'),
            ),
          ],
        );
      },
    );
    if (reason == null) return; // User cancelled

    try {
      await _firestoreService.updateBooking(booking.bookingId, {
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancelledAt': Timestamp.now(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking declined'), backgroundColor: Colors.orange),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to decline: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _markAsDone(FirebaseBookingModel booking) async {
    try {
      await _firestoreService.completeBookingAndCreatePayout(booking);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking marked as done'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark done: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

