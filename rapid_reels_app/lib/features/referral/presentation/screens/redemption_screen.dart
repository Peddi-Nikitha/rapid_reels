import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../shared/widgets/custom_button.dart';

class RedemptionScreen extends StatefulWidget {
  const RedemptionScreen({super.key});

  @override
  State<RedemptionScreen> createState() => _RedemptionScreenState();
}

class _RedemptionScreenState extends State<RedemptionScreen> {
  final _mockData = MockDataService();
  String _selectedOption = 'booking';

  @override
  Widget build(BuildContext context) {
    final user = _mockData.currentUser;
    final balance = user.walletBalance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Redeem Balance',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Display
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Available Balance',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Redemption Options
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Redeem As',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRedemptionOption(
                    value: 'booking',
                    title: 'Apply to Booking',
                    description: 'Use wallet balance on your next event booking',
                    icon: Icons.event_available,
                  ),
                  const SizedBox(height: 12),
                  _buildRedemptionOption(
                    value: 'bank',
                    title: 'Transfer to Bank',
                    description: 'Transfer to your bank account (₹500 minimum)',
                    icon: Icons.account_balance,
                    isDisabled: balance < 500,
                  ),
                  const SizedBox(height: 12),
                  _buildRedemptionOption(
                    value: 'upi',
                    title: 'UPI Transfer',
                    description: 'Instant transfer to UPI ID (₹100 minimum)',
                    icon: Icons.qr_code_scanner,
                    isDisabled: balance < 100,
                  ),
                ],
              ),
            ),
            
            // Terms and Conditions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTerm('Wallet balance can be used for event bookings'),
                    _buildTerm('Minimum ₹500 required for bank transfer'),
                    _buildTerm('Minimum ₹100 required for UPI transfer'),
                    _buildTerm('Bank transfer takes 2-3 business days'),
                    _buildTerm('UPI transfer is instant'),
                    _buildTerm('Balance expires after 1 year of inactivity'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            text: 'Continue',
            onPressed: _selectedOption == 'booking'
                ? _redeemForBooking
                : (_selectedOption == 'bank' && balance >= 500) ||
                        (_selectedOption == 'upi' && balance >= 100)
                    ? _redeemToBank
                    : null,
          ),
        ),
      ),
    );
  }

  Widget _buildRedemptionOption({
    required String value,
    required String title,
    required String description,
    required IconData icon,
    bool isDisabled = false,
  }) {
    final isSelected = _selectedOption == value;
    
    return GestureDetector(
      onTap: isDisabled ? null : () => setState(() => _selectedOption = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.surface.withValues(alpha: 0.5)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDisabled
                    ? Colors.grey.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: isDisabled ? Colors.grey : AppColors.primary,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDisabled ? Colors.grey : null,
                        ),
                      ),
                      if (isDisabled) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Not Available',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDisabled ? Colors.grey : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedOption,
              onChanged: isDisabled ? null : (val) => setState(() => _selectedOption = val!),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerm(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _redeemForBooking() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Apply to Booking'),
        content: const Text(
          'Your wallet balance will be automatically applied to your next booking. You can choose the amount to use during checkout.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wallet balance ready to use on bookings!'),
                ),
              );
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  void _redeemToBank() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(_selectedOption == 'bank' ? 'Bank Transfer' : 'UPI Transfer'),
        content: Text(
          _selectedOption == 'bank'
              ? 'Transfer will be initiated to your registered bank account. It may take 2-3 business days.'
              : 'Transfer will be initiated to your registered UPI ID instantly.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _selectedOption == 'bank'
                        ? 'Bank transfer initiated successfully!'
                        : 'UPI transfer completed!',
                  ),
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

