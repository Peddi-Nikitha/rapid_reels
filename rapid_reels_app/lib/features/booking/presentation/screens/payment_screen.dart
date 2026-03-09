import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../data/models/event_booking_model.dart';

/// Mock Payment Screen
/// No Razorpay - Simulated payment flow
class PaymentScreen extends ConsumerStatefulWidget {
  final EventBooking booking;
  final bool isAdvancePayment;

  const PaymentScreen({
    super.key,
    required this.booking,
    this.isAdvancePayment = true,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'upi';

  void _processPayment() async {
    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isProcessing = false);

    if (mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment Successful! (Mock)'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to success screen
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        context.go(AppRoutes.home);
      }
    }
  }

  double get _paymentAmount {
    if (widget.isAdvancePayment) {
      return widget.booking.advanceAmount ?? widget.booking.totalAmount * 0.5;
    }
    return widget.booking.totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Booking Summary Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryRow('Event', widget.booking.eventName),
                        _buildSummaryRow('Type', widget.booking.eventType.toUpperCase()),
                        _buildSummaryRow('Package', widget.booking.packageName),
                        _buildSummaryRow(
                          'Date',
                          '${widget.booking.eventDate.day}/${widget.booking.eventDate.month}/${widget.booking.eventDate.year}',
                        ),
                        _buildSummaryRow('Time', widget.booking.eventTime),
                        const Divider(height: 32),
                        _buildSummaryRow(
                          'Total Amount',
                          '₹${widget.booking.totalAmount.toStringAsFixed(0)}',
                        ),
                        if (widget.isAdvancePayment) ...[
                          _buildSummaryRow(
                            'Advance (50%)',
                            '₹${_paymentAmount.toStringAsFixed(0)}',
                            isHighlight: true,
                          ),
                          _buildSummaryRow(
                            'Remaining',
                            '₹${(widget.booking.totalAmount - _paymentAmount).toStringAsFixed(0)}',
                            isSubtle: true,
                          ),
                        ] else
                          _buildSummaryRow(
                            'Pay Now',
                            '₹${_paymentAmount.toStringAsFixed(0)}',
                            isHighlight: true,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Payment Methods
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildPaymentMethodTile(
                    'UPI',
                    'Google Pay, PhonePe, Paytm',
                    Icons.qr_code_2,
                    'upi',
                  ),
                  _buildPaymentMethodTile(
                    'Credit/Debit Card',
                    'Visa, Mastercard, RuPay',
                    Icons.credit_card,
                    'card',
                  ),
                  _buildPaymentMethodTile(
                    'Net Banking',
                    'All major banks',
                    Icons.account_balance,
                    'netbanking',
                  ),
                  _buildPaymentMethodTile(
                    'Wallet',
                    'Paytm, PhonePe, Amazon Pay',
                    Icons.account_balance_wallet,
                    'wallet',
                  ),

                  const SizedBox(height: 24),

                  // Mock Payment Note
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withAlpha(51),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'This is a mock payment. No real transaction will be processed.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pay Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(51),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Pay ₹${_paymentAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isHighlight = false,
    bool isSubtle = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHighlight ? 16 : 15,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
              color: isSubtle ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 18 : 15,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
  ) {
    final isSelected = _selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedPaymentMethod = value);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(26) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(51)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.textTertiary,
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
