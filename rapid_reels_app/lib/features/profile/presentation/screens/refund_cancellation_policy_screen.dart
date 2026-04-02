import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

class RefundCancellationPolicyScreen extends StatelessWidget {
  const RefundCancellationPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Refund & Cancellation Policy',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 12),
          _policySection(
            '1) Scope and Definitions',
            const [
              'This policy applies to bookings made via Rapid Reels and paid through platform-supported payment methods.',
              'A cancellation request means a written request submitted through app support with booking reference.',
              'Refund outcomes are evaluated case-by-case based on the details of the booking and delivery stage.',
            ],
          ),
          _policySection(
            '2) How to Request Cancellation',
            const [
              'Raise a support request from the app and include booking ID, event date, and reason for cancellation.',
              'Requests should be submitted as early as possible after the decision to cancel.',
              'We may request supporting details before final review.',
            ],
          ),
          _policySection(
            '3) Case-by-Case Refund Review',
            const [
              'We review each cancellation individually.',
              'Factors include time remaining to the event, provider preparation already completed, and any delivered service.',
              'Outcomes may be full refund, partial refund, or no refund depending on the specific facts.',
            ],
          ),
          _policySection(
            '4) Non-Refundable Elements',
            const [
              'Processing/platform fees may be non-refundable where already incurred.',
              'Any portion of service that has already been delivered is generally not refundable.',
              'No-shows or last-minute cancellations may result in reduced refund eligibility.',
            ],
          ),
          _policySection(
            '5) Provider Cancellation or No-Show',
            const [
              'If a provider cancels or fails to deliver without valid reason, customer-friendly remediation is prioritized.',
              'Depending on availability and context, we may arrange replacement service or issue refund per review outcome.',
            ],
          ),
          _policySection(
            '6) Duplicate or Erroneous Charges',
            const [
              'Duplicate/incorrect charges should be reported promptly with payment reference.',
              'Verified duplicate charges are refunded to the original payment source where possible.',
            ],
          ),
          _policySection(
            '7) Refund Method and Timelines',
            const [
              'Approved refunds are generally returned to the original payment method.',
              'Payment processor and bank timelines apply; typical completion can take several business days.',
              'Where original method cannot be credited, an alternative compliant method may be used.',
            ],
          ),
          _policySection(
            '8) Disputes and Updates',
            const [
              'For unresolved concerns, raise a support ticket with full booking and transaction details.',
              'Policy clauses may be updated over time; the latest in-app version applies to new decisions.',
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Disclaimer: This policy provides operational guidance and does not guarantee any automatic refund. Final outcomes depend on case review and payment processor constraints.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.support),
              icon: const Icon(Icons.support_agent),
              label: const Text('Contact Support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Effective Date: 02 Apr 2026',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Region Focus: United Kingdom',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          SizedBox(height: 4),
          Text(
            'Version: 1.0',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _policySection(String title, List<String> points) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        children: points
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
