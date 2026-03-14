import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/mock/mock_packages.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';

class BookingSummaryScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const BookingSummaryScreen({
    super.key,
    required this.bookingData,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  bool _acceptedTerms = false;
  bool _isProcessing = false;
  final _mockData = MockDataService();

  @override
  Widget build(BuildContext context) {
    final packageId = widget.bookingData['packageId'];
    final package = MockPackages.getPackageById(packageId);
    final provider = _mockData.getProviderById(widget.bookingData['providerId']);
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
                  _buildSection(
                    'Event Details',
                    [
                      _buildDetailRow('Event Name', widget.bookingData['eventName']),
                      _buildDetailRow('Event Type', _formatEventType(widget.bookingData['eventType'])),
                      _buildDetailRow(
                        'Date',
                        DateFormat('dd MMM yyyy').format(widget.bookingData['eventDate']),
                      ),
                      _buildDetailRow('Time', widget.bookingData['eventTime'].format(context)),
                      _buildDetailRow('Duration', '${widget.bookingData['duration']} hours'),
                      _buildDetailRow('Guest Count', '${widget.bookingData['guestCount']} guests'),
                    ],
                  ),
                  
                  // Venue Details
                  _buildSection(
                    'Venue',
                    [
                      _buildDetailRow('Name', widget.bookingData['venueName']),
                      _buildDetailRow('Address', widget.bookingData['venueAddress']),
                      _buildDetailRow('City', widget.bookingData['venueCity']),
                    ],
                  ),
                  
                  // Provider Details
                  if (provider != null)
                    _buildSection(
                      'Service Provider',
                      [
                        _buildDetailRow('Provider', provider.businessName),
                        _buildDetailRow('Rating', '${provider.rating} ⭐'),
                        _buildDetailRow('Contact', provider.phoneNumber),
                      ],
                    ),
                  
                  // Package Details
                  _buildSection(
                    'Package',
                    [
                      _buildDetailRow('Package', package?.name ?? ''),
                      _buildDetailRow('Coverage', '${(package?.duration ?? 0) ~/ 60} hours'),
                      _buildDetailRow(
                        'Reels',
                        package?.reelsCount == -1
                            ? 'Unlimited'
                            : '${package?.reelsCount}',
                      ),
                      _buildDetailRow('Editing', widget.bookingData['editingStyle']),
                      if (widget.bookingData['additionalReels'] > 0)
                        _buildDetailRow(
                          'Additional Reels',
                          '+${widget.bookingData['additionalReels']} (₹${widget.bookingData['additionalReels'] * 1500})',
                        ),
                      if (widget.bookingData['includeDrone'])
                        _buildDetailRow('Drone Footage', 'Included (₹3000)'),
                    ],
                  ),
                  
                  // Payment Breakdown
                  _buildSection(
                    'Payment',
                    [
                      _buildDetailRow('Base Price', '₹${package?.price.toStringAsFixed(0)}'),
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
                    ],
                  ),
                  
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
                          onChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
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
                onPressed: _acceptedTerms && !_isProcessing ? _handleConfirmBooking : null,
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
    setState(() => _isProcessing = true);

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isProcessing = false);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking confirmed! Check your email for details.'),
        backgroundColor: AppColors.primary,
      ),
    );

    // Navigate to home page
    context.go(AppRoutes.home);
  }
}

