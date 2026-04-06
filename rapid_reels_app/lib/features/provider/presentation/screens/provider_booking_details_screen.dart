import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/provider_app_colors.dart';
import '../../../../shared/widgets/provider/provider_gradient_button.dart';
import '../../../../core/firebase/models/firebase_booking_model.dart';
import '../../../../core/firebase/models/firebase_payment_transaction_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';

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
    final firestoreService = FirestoreService();

    return FutureBuilder<FirebaseBookingModel?>(
      future: firestoreService.getBooking(bookingId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Booking Details')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Booking Details')),
            body: Center(
              child: Text(snapshot.hasError ? 'Error: ${snapshot.error}' : 'Booking not found'),
            ),
          );
        }

        final booking = snapshot.data!;

        return Scaffold(
      backgroundColor: ProviderAppColors.background,
      appBar: AppBar(
        backgroundColor: ProviderAppColors.background,
        elevation: 0,
        title: Text(
          'Booking Details',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
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
                          'Booking ID: ${booking.bookingId}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: ProviderAppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Event Information
            Text(
              'Event Information',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ProviderAppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (booking.catalogueTitle != null && booking.catalogueTitle!.isNotEmpty)
              _buildInfoCard(
                icon: Icons.auto_awesome,
                title: 'Catalogue offering',
                value: booking.catalogueTitle!,
              ),
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
            
            // Customer Contact
            Text(
              'Customer Contact',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ProviderAppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ProviderAppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ProviderAppColors.outline.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ProviderAppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: ProviderAppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.contactPerson,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.contactNumber,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: ProviderAppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone, color: ProviderAppColors.primary),
                    onPressed: () {
                      // Make call
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.message, color: ProviderAppColors.primary),
                    onPressed: () {
                      // Send message
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Navigation to Venue
            ProviderGradientButton(
              onPressed: () {
                // Open maps navigation
              },
              icon: const Icon(Icons.directions),
              label: 'Navigate to Venue',
            ),
            const SizedBox(height: 24),

            Text(
              'Payment Transactions',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ProviderAppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<FirebasePaymentTransactionModel>>(
              stream: firestoreService.streamPaymentTransactionsByBooking(booking.bookingId),
              builder: (context, txSnapshot) {
                final transactions = txSnapshot.data ?? const <FirebasePaymentTransactionModel>[];
                if (transactions.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ProviderAppColors.card,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'No payment transactions yet.',
                      style: GoogleFonts.poppins(color: ProviderAppColors.textSecondary),
                    ),
                  );
                }
                return Column(
                  children: transactions.map(_buildTransactionCard).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Action Buttons
            if (booking.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _declineBooking(context, booking, firestoreService),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ProviderAppColors.error,
                        side: const BorderSide(color: ProviderAppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                      onPressed: () => _acceptBooking(context, booking, firestoreService),
                      label: 'Accept',
                      minHeight: 52,
                    ),
                  ),
                ],
              )
            else if (booking.status == 'confirmed' || booking.status == 'ongoing')
              Column(
                children: [
                  ProviderGradientButton(
                    onPressed: () => _markAsDone(context, booking, firestoreService),
                    label: 'Mark as Done',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
      },
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
        color: ProviderAppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ProviderAppColors.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: ProviderAppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: ProviderAppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ProviderAppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildTransactionCard(FirebasePaymentTransactionModel tx) {
    final isSuccess = tx.status == 'succeeded';
    final isFailure = tx.status == 'failed' || tx.status == 'canceled';
    final color = isSuccess ? Colors.green : (isFailure ? Colors.red : Colors.orange);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ProviderAppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tx.transactionId,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                tx.status.toUpperCase(),
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Amount: £${tx.amount.toStringAsFixed(2)}'),
          Text('Method: ${tx.paymentMethodType}'),
          if (tx.failureMessage != null && tx.failureMessage!.isNotEmpty)
            Text('Reason: ${tx.failureMessage}', style: const TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  static Future<void> _acceptBooking(
    BuildContext context,
    FirebaseBookingModel booking,
    FirestoreService firestoreService,
  ) async {
    try {
      await firestoreService.updateBooking(booking.bookingId, {
        'status': 'confirmed',
        'eventStatus.providerAccepted': Timestamp.now(),
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking accepted'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept: $e'), backgroundColor: Colors.red),
      );
    }
  }

  static Future<void> _declineBooking(
    BuildContext context,
    FirebaseBookingModel booking,
    FirestoreService firestoreService,
  ) async {
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
    if (reason == null) return;

    try {
      await firestoreService.updateBooking(booking.bookingId, {
        'status': 'cancelled',
        'cancellationReason': reason,
        'cancelledAt': Timestamp.now(),
      });
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking declined'), backgroundColor: Colors.orange),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to decline: $e'), backgroundColor: Colors.red),
      );
    }
  }

  static Future<void> _markAsDone(
    BuildContext context,
    FirebaseBookingModel booking,
    FirestoreService firestoreService,
  ) async {
    try {
      await firestoreService.completeBookingAndCreatePayout(booking);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking marked as done'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark done: $e'), backgroundColor: Colors.red),
      );
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

}

