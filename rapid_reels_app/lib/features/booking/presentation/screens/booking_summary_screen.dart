import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/firebase/models/firebase_provider_model.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../data/adapters/booking_firebase_adapter.dart';
import '../../data/services/stripe_payment_service.dart';

class BookingSummaryScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const BookingSummaryScreen({super.key, required this.bookingData});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  bool _acceptedTerms = false;
  bool _isProcessing = false;
  final _firestoreService = FirestoreService();
  final _stripePaymentService = StripePaymentService();

  @override
  Widget build(BuildContext context) {
    final pkg = widget.bookingData['package'] as Map<String, dynamic>?;
    final packageName = pkg?['name']?.toString() ?? '';
    final packagePrice = (pkg?['price'] as num?)?.toDouble() ?? 0.0;
    final packageDurationMinutes = (pkg?['duration'] as num?)?.toInt() ?? 0;
    final packageReelsCount = (pkg?['reelsCount'] as num?)?.toInt() ?? 0;
    final providerId = widget.bookingData['providerId']?.toString() ?? '';
    final totalAmount = widget.bookingData['totalAmount'];
    final advanceAmount = totalAmount * 0.5;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Review Booking'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Success Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Center(
                    child: Text(
                      'Review Your Booking',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Please review all details before confirming',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Event Details
                  _buildSection('Event Details', [
                    if (widget.bookingData['catalogueTitle'] != null &&
                        widget.bookingData['catalogueTitle']
                            .toString()
                            .isNotEmpty)
                      _buildDetailRow(
                        'Offering',
                        widget.bookingData['catalogueTitle'].toString(),
                      ),
                    _buildDetailRow(
                      'Event Name',
                      widget.bookingData['eventName'],
                    ),
                    _buildDetailRow(
                      'Event Type',
                      _formatEventType(widget.bookingData['eventType']),
                    ),
                    _buildDetailRow(
                      'Date',
                      DateFormat(
                        'dd MMM yyyy',
                      ).format(widget.bookingData['eventDate']),
                    ),
                    _buildDetailRow(
                      'Time',
                      widget.bookingData['eventTime'].format(context),
                    ),
                    _buildDetailRow(
                      'Duration',
                      '${widget.bookingData['duration']} hours',
                    ),
                    _buildDetailRow(
                      'Guest Count',
                      '${widget.bookingData['guestCount']} guests',
                    ),
                  ]),

                  // Venue Details
                  _buildSection('Venue', [
                    _buildDetailRow('Name', widget.bookingData['venueName']),
                    _buildDetailRow(
                      'Address',
                      widget.bookingData['venueAddress'],
                    ),
                    _buildDetailRow('City', widget.bookingData['venueCity']),
                  ]),

                  // Provider Details
                  if (providerId.isNotEmpty)
                    FutureBuilder<FirebaseProviderModel?>(
                      future: _firestoreService.getProvider(providerId),
                      builder: (context, snapshot) {
                        final provider = snapshot.data;
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildSection('Service Provider', const [
                            Text('Loading provider...'),
                          ]);
                        }
                        if (provider == null) return const SizedBox.shrink();
                        return _buildSection('Service Provider', [
                          _buildDetailRow('Provider', provider.businessName),
                          _buildDetailRow('Rating', '${provider.rating} ⭐'),
                          _buildDetailRow('Contact', provider.phoneNumber),
                        ]);
                      },
                    ),

                  // Package Details
                  _buildSection('Package', [
                    _buildDetailRow('Package', packageName),
                    _buildDetailRow(
                      'Coverage',
                      '${packageDurationMinutes ~/ 60} hours',
                    ),
                    _buildDetailRow(
                      'Reels',
                      packageReelsCount == -1
                          ? 'Unlimited'
                          : '$packageReelsCount',
                    ),
                    _buildDetailRow(
                      'Editing',
                      widget.bookingData['editingStyle'],
                    ),
                    if (widget.bookingData['additionalReels'] > 0)
                      _buildDetailRow(
                        'Additional Reels',
                        '+${widget.bookingData['additionalReels']} (₹${widget.bookingData['additionalReels'] * 1500})',
                      ),
                    if (widget.bookingData['includeDrone'])
                      _buildDetailRow('Drone Footage', 'Included (₹3000)'),
                  ]),

                  // Payment Breakdown
                  _buildSection('Payment', [
                    _buildDetailRow(
                      'Base Price',
                      '₹${packagePrice.toStringAsFixed(0)}',
                    ),
                    if (widget.bookingData['additionalCost'] > 0)
                      _buildDetailRow(
                        'Add-ons',
                        '+₹${widget.bookingData['additionalCost'].toStringAsFixed(0)}',
                      ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      'Total Amount',
                      '₹${totalAmount.toStringAsFixed(0)}',
                      isTotal: true,
                    ),
                    _buildDetailRow(
                      'Advance (50%)',
                      '₹${advanceAmount.toStringAsFixed(0)}',
                      subtitle: 'To be paid now',
                    ),
                    _buildDetailRow(
                      'Remaining',
                      '₹${(totalAmount - advanceAmount).toStringAsFixed(0)}',
                      subtitle: 'After event completion',
                    ),
                  ]),

                  // Terms & Conditions
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          onChanged: (value) =>
                              setState(() => _acceptedTerms = value ?? false),
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                              () => _acceptedTerms = !_acceptedTerms,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Text(
                                'I agree to the Terms & Conditions and Cancellation Policy',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
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

          // Bottom Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: CustomButton(
                text: 'Pay ₹${advanceAmount.toStringAsFixed(0)} & Confirm',
                onPressed: _acceptedTerms && !_isProcessing
                    ? _handleConfirmBooking
                    : null,
                isLoading: _isProcessing,
                icon: Icons.payment,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isTotal = false,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isTotal ? 16 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: AppColors.textSecondary,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  String _formatEventType(String type) {
    return type[0].toUpperCase() + type.substring(1);
  }

  Future<void> _handleConfirmBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to confirm your booking.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final supportsStripeMobile =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (!supportsStripeMobile) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stripe payment is available on Android/iOS app only.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (Stripe.publishableKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Stripe publishable key missing. Set it in lib/core/config/stripe_config.dart.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final booking = BookingFirebaseAdapter.fromBookingData(
        widget.bookingData,
        user.uid,
      );
      final bookingId = await _firestoreService.createBooking(booking);
      final paymentIntent = await _stripePaymentService.createPaymentIntent(
        bookingId: bookingId,
        userId: user.uid,
        amount: booking.payment.advanceAmount,
      );
      await _stripePaymentService.presentPaymentSheet(
        clientSecret: paymentIntent.clientSecret,
        merchantDisplayName: 'Rapid Reels',
      );

      await _firestoreService.updateBooking(bookingId, {
        'status': 'confirmed',
        'payment.paymentStatus': 'advance_paid',
        'eventStatus.bookingConfirmed': Timestamp.now(),
        'payment.transactions': FieldValue.arrayUnion([
          {
            'paymentId': paymentIntent.paymentIntentId,
            'amount': booking.payment.advanceAmount,
            'method': 'stripe',
            'transactionId': paymentIntent.paymentIntentId,
            'status': 'success',
            'paidAt': Timestamp.now(),
          },
        ]),
      });

      if (!mounted) return;

      setState(() => _isProcessing = false);
      context.go(
        AppRoutes.paymentSuccess,
        extra: {
          'bookingId': bookingId,
          'paymentId': paymentIntent.paymentIntentId,
          'amount': booking.payment.advanceAmount,
        },
      );
    } on StripeException catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      context.go(
        AppRoutes.paymentFailure,
        extra: {
          'message': e.error.localizedMessage ?? 'Payment was cancelled',
          'bookingData': widget.bookingData,
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isProcessing = false);
      context.go(
        AppRoutes.paymentFailure,
        extra: {
          'message': 'Failed to confirm payment: ${e.toString()}',
          'bookingData': widget.bookingData,
        },
      );
    }
  }
}
