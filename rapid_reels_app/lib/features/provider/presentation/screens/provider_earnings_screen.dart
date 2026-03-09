import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/mock_data_service.dart';

class ProviderEarningsScreen extends StatefulWidget {
  final String providerId;
  
  const ProviderEarningsScreen({super.key, required this.providerId});

  @override
  State<ProviderEarningsScreen> createState() => _ProviderEarningsScreenState();
}

class _ProviderEarningsScreenState extends State<ProviderEarningsScreen> with SingleTickerProviderStateMixin {
  String _selectedPeriod = 'This Month';
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final mockData = MockDataService();
    final stats = mockData.getProviderStats(widget.providerId);
    final totalEarnings = stats['totalEarnings'] as double;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Earnings & Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Payments'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(stats, totalEarnings),
          _buildPaymentsTab(),
          _buildAnalyticsTab(stats),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(stats, totalEarnings) {
    return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Total Earnings Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF11998E).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Earnings', style: TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 8),
                Text(
                  '₹${totalEarnings.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '+15% from last month',
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Period Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['This Week', 'This Month', 'This Year', 'All Time']
                  .map((period) => _buildPeriodChip(period))
                  .toList(),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats Grid
          Row(
            children: [
              Expanded(child: _buildStatCard('Bookings', '${stats['totalBookings']}', Icons.event, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Completed', '${stats['completedBookings']}', Icons.check_circle, Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('Pending', '${stats['pendingBookings']}', Icons.hourglass_empty, Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Rating', '${stats['averageRating']}⭐', Icons.star, Colors.amber)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent Transactions
          const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          ..._buildTransactions(),
          
          const SizedBox(height: 24),
          
          // Withdraw Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _showWithdrawDialog,
              icon: const Icon(Icons.account_balance),
              label: const Text('Withdraw Funds'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
    );
  }

  Widget _buildPeriodChip(String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          period,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  List<Widget> _buildTransactions() {
    final transactions = [
      {'date': 'Dec 15, 2025', 'event': 'Wedding - Amit & Sneha', 'amount': 25000.0},
      {'date': 'Dec 10, 2025', 'event': 'Birthday Party', 'amount': 8000.0},
      {'date': 'Dec 5, 2025', 'event': 'Engagement - Priya & Rohit', 'amount': 15000.0},
    ];
    
    return transactions.map((t) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_downward, color: Colors.green, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t['event'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(t['date'] as String, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Text(
              '₹${(t['amount'] as double).toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Withdraw Funds'),
        content: const Text('Enter amount to withdraw to your bank account.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Withdrawal request submitted!')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsTab() {
    final pendingPayments = [
      {'event': 'Wedding - Amit & Sneha', 'amount': 25000.0, 'date': 'Dec 20, 2025'},
      {'event': 'Birthday Party', 'amount': 8000.0, 'date': 'Dec 22, 2025'},
    ];

    final paymentHistory = [
      {'event': 'Engagement', 'amount': 15000.0, 'date': 'Dec 15, 2025', 'status': 'paid'},
      {'event': 'Corporate Event', 'amount': 20000.0, 'date': 'Dec 10, 2025', 'status': 'paid'},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Pending Payments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...pendingPayments.map((payment) => _buildPaymentCard(payment, isPending: true)),
        const SizedBox(height: 24),
        const Text('Commission Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              _buildCommissionRow('Platform Commission', '15%', '₹7,500'),
              const Divider(),
              _buildCommissionRow('Your Earnings', '85%', '₹42,500'),
              const Divider(),
              _buildCommissionRow('Total Amount', '100%', '₹50,000', isTotal: true),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Payment History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...paymentHistory.map((payment) => _buildPaymentCard(payment, isPending: false)),
      ],
    );
  }

  Widget _buildAnalyticsTab(stats) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Earnings Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.show_chart, size: 48, color: Colors.grey[600]),
                      const SizedBox(height: 8),
                      Text('Chart visualization', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Performance Metrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard('Avg per Event', '₹25,000', Icons.trending_up, Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('Total Events', '${stats['totalBookings']}', Icons.event, Colors.blue)),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment, {required bool isPending}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: isPending ? Border.all(color: AppColors.warning, width: 1) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPending ? AppColors.warning.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(isPending ? Icons.pending : Icons.check_circle, color: isPending ? AppColors.warning : AppColors.success, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment['event'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(payment['date'] as String, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Text('₹${(payment['amount'] as double).toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCommissionRow(String label, String percentage, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Row(
            children: [
              Text(percentage, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: Colors.grey[600])),
              const SizedBox(width: 16),
              Text(amount, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: FontWeight.bold, color: isTotal ? AppColors.primary : null)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

