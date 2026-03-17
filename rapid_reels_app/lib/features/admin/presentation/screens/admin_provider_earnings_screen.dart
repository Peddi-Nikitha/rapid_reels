import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/firebase/services/firestore_service.dart';

/// Admin view of provider earnings: completed bookings, revenue, commission, payouts.
class AdminProviderEarningsScreen extends StatelessWidget {
  const AdminProviderEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return FutureBuilder<ProviderEarningsData>(
      future: _loadEarningsData(firestoreService),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Provider Earnings')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Provider Earnings')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final data = snapshot.data ?? ProviderEarningsData(providerSummaries: [], totalRevenue: 0, totalPayouts: 0, totalCommission: 0);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: const Text(
              'Provider Earnings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(data),
                const SizedBox(height: 24),
                const Text(
                  'By Provider',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (data.providerSummaries.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('No provider earnings yet', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ),
                  )
                else
                  ...data.providerSummaries.map((s) => _buildProviderCard(s)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<ProviderEarningsData> _loadEarningsData(FirestoreService firestoreService) async {
    final allBookings = await firestoreService.getAllBookings();
    final completedBookings = allBookings.where((b) => b.status == 'completed').toList();
    final payouts = await firestoreService.getAllProviderPayouts(limit: 1000);

    final providerIds = <String>{};
    for (final b in completedBookings) {
      providerIds.add(b.providerId);
    }
    for (final p in payouts) {
      providerIds.add(p.userId);
    }

    final summaries = <ProviderEarningsSummary>[];
    for (final providerId in providerIds) {
      final provider = await firestoreService.getProvider(providerId);
      final bookings = completedBookings.where((b) => b.providerId == providerId).toList();
      final providerPayouts = payouts.where((p) => p.userId == providerId).toList();
      final totalRevenue = bookings.fold<double>(0, (sum, b) => sum + b.payment.totalAmount);
      final totalPayout = providerPayouts.fold<double>(0, (sum, p) => sum + p.amount);
      final commission = totalRevenue - totalPayout;

      summaries.add(ProviderEarningsSummary(
        providerId: providerId,
        providerName: provider?.businessName ?? providerId,
        completedBookings: bookings.length,
        totalRevenue: totalRevenue,
        commissionRetained: commission,
        payouts: totalPayout,
      ));
    }

    summaries.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    final totalRevenue = completedBookings.fold<double>(0, (sum, b) => sum + b.payment.totalAmount);
    final totalPayouts = payouts.fold<double>(0, (sum, p) => sum + p.amount);
    final totalCommission = totalRevenue - totalPayouts;

    return ProviderEarningsData(
      providerSummaries: summaries,
      totalRevenue: totalRevenue,
      totalPayouts: totalPayouts,
      totalCommission: totalCommission,
    );
  }

  Widget _buildSummaryCards(ProviderEarningsData data) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Revenue',
            '₹${data.totalRevenue.toStringAsFixed(0)}',
            Icons.currency_rupee,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Commission',
            '₹${data.totalCommission.toStringAsFixed(0)}',
            Icons.account_balance,
            Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildProviderCard(ProviderEarningsSummary summary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.business, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.providerName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${summary.completedBookings} completed bookings',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Revenue', '₹${summary.totalRevenue.toStringAsFixed(0)}'),
          _buildInfoRow('Payouts', '₹${summary.payouts.toStringAsFixed(0)}'),
          _buildInfoRow('Commission', '₹${summary.commissionRetained.toStringAsFixed(0)}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class ProviderEarningsSummary {
  final String providerId;
  final String providerName;
  final int completedBookings;
  final double totalRevenue;
  final double commissionRetained;
  final double payouts;

  ProviderEarningsSummary({
    required this.providerId,
    required this.providerName,
    required this.completedBookings,
    required this.totalRevenue,
    required this.commissionRetained,
    required this.payouts,
  });
}

class ProviderEarningsData {
  final List<ProviderEarningsSummary> providerSummaries;
  final double totalRevenue;
  final double totalPayouts;
  final double totalCommission;

  ProviderEarningsData({
    required this.providerSummaries,
    required this.totalRevenue,
    required this.totalPayouts,
    required this.totalCommission,
  });
}
