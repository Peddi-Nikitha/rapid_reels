import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/firebase/models/firebase_booking_model.dart';
import '../../../../core/firebase/models/firebase_payment_transaction_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class MyTransactionsScreen extends StatelessWidget {
  const MyTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view transactions')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'My Transactions'),
      body: StreamBuilder<List<FirebasePaymentTransactionModel>>(
        stream: FirestoreService().streamPaymentTransactionsForCustomer(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load transactions: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final transactions = snapshot.data ?? const <FirebasePaymentTransactionModel>[];
          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                'No transactions yet',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return _TransactionCard(transaction: tx);
            },
          );
        },
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final FirebasePaymentTransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseBookingModel?>(
      future: FirestoreService().getBooking(transaction.bookingId),
      builder: (context, bookingSnapshot) {
        final booking = bookingSnapshot.data;
        final eventName = booking?.eventName ?? booking?.eventType ?? 'Booking';
        final eventDateTime = booking == null
            ? '-'
            : '${DateFormat('dd MMM yyyy').format(booking.eventDate)} • ${booking.eventTime}';
        final statusColor = _statusColor(transaction.status);
        final statusLabel = _statusLabel(transaction.status);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      eventName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${transaction.currency.toUpperCase()} ${transaction.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Booking: ${transaction.bookingId}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                'Event: $eventDateTime',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                'Txn: ${transaction.transactionId}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                'Method: ${transaction.paymentMethodType}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(transaction.createdAt),
                style: const TextStyle(color: AppColors.textTertiary),
              ),
              if ((transaction.failureMessage ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Reason: ${transaction.failureMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'succeeded':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'failed':
      case 'canceled':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'succeeded':
        return 'SUCCESS';
      case 'processing':
        return 'PROCESSING';
      case 'failed':
        return 'FAILED';
      case 'canceled':
        return 'CANCELED';
      default:
        return status.toUpperCase();
    }
  }
}
