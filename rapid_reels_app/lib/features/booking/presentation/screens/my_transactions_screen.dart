import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/firebase/models/firebase_booking_model.dart';
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
      body: StreamBuilder<List<FirebaseBookingModel>>(
        stream: FirestoreService().streamUserBookings(userId),
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

          final rows = _extractRows(snapshot.data ?? []);
          if (rows.isEmpty) {
            return const Center(
              child: Text(
                'No transactions yet',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final row = rows[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            row.eventName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '₹${row.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Status: ${row.status.toUpperCase()}',
                      style: TextStyle(
                        color: row.status == 'success'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Booking: ${row.bookingId}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      'Txn: ${row.transactionId}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy, hh:mm a').format(row.paidAt),
                      style: const TextStyle(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<_BookingTransactionRow> _extractRows(
    List<FirebaseBookingModel> bookings,
  ) {
    final rows = <_BookingTransactionRow>[];
    for (final booking in bookings) {
      final transactions =
          booking.payment.transactions ?? const <PaymentTransaction>[];
      for (final transaction in transactions) {
        rows.add(
          _BookingTransactionRow(
            bookingId: booking.bookingId,
            eventName: booking.eventName,
            amount: transaction.amount,
            transactionId: transaction.transactionId,
            status: transaction.status,
            paidAt: transaction.paidAt,
          ),
        );
      }
    }
    rows.sort((a, b) => b.paidAt.compareTo(a.paidAt));
    return rows;
  }
}

class _BookingTransactionRow {
  _BookingTransactionRow({
    required this.bookingId,
    required this.eventName,
    required this.amount,
    required this.transactionId,
    required this.status,
    required this.paidAt,
  });

  final String bookingId;
  final String eventName;
  final double amount;
  final String transactionId;
  final String status;
  final DateTime paidAt;
}
