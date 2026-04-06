import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/provider_app_colors.dart';
import '../../../../shared/widgets/provider/provider_gradient_button.dart';
import '../../../../core/constants/app_routes.dart';

class ProviderVerificationScreen extends StatelessWidget {
  const ProviderVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulate verification status
    final verificationStatus = 'pending'; // pending, approved, rejected
    
    return Scaffold(
      backgroundColor: ProviderAppColors.background,
      appBar: AppBar(
        backgroundColor: ProviderAppColors.surface,
        elevation: 0,
        title: const Text(
          'Verification Status',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _getStatusColor(verificationStatus).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(verificationStatus),
                  size: 64,
                  color: _getStatusColor(verificationStatus),
                ),
              ),
              const SizedBox(height: 32),
              
              // Status Title
              Text(
                _getStatusTitle(verificationStatus),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Status Message
              Text(
                _getStatusMessage(verificationStatus),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Verification Checklist
              if (verificationStatus == 'pending')
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ProviderAppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Verification Checklist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildChecklistItem('Business Profile', true),
                      _buildChecklistItem('Portfolio Upload', true),
                      _buildChecklistItem('Service Areas', true),
                      _buildChecklistItem('Documents Upload', true),
                      _buildChecklistItem('Availability Calendar', true),
                      _buildChecklistItem('Admin Review', false),
                    ],
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Action Button
              if (verificationStatus == 'pending')
                ProviderGradientButton(
                  onPressed: () {
                    context.go('${AppRoutes.providerDashboard}/provider_001');
                  },
                  label: 'Check Status',
                )
              else if (verificationStatus == 'approved')
                ProviderSuccessButton(
                  onPressed: () {
                    context.go('${AppRoutes.providerDashboard}/provider_001');
                  },
                  label: 'Go to Dashboard',
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String item, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? ProviderAppColors.success : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            item,
            style: TextStyle(
              fontSize: 14,
              color: isCompleted ? Colors.white : Colors.grey[600],
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.verified;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.hourglass_empty;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return ProviderAppColors.success;
      case 'rejected':
        return ProviderAppColors.error;
      default:
        return ProviderAppColors.warning;
    }
  }

  String _getStatusTitle(String status) {
    switch (status) {
      case 'approved':
        return 'Account Verified!';
      case 'rejected':
        return 'Verification Rejected';
      default:
        return 'Verification Pending';
    }
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'approved':
        return 'Your provider account has been verified. You can now start accepting bookings!';
      case 'rejected':
        return 'Your verification was rejected. Please check your documents and try again.';
      default:
        return 'Your account is under review. We will notify you once the verification is complete. This usually takes 24-48 hours.';
    }
  }
}

