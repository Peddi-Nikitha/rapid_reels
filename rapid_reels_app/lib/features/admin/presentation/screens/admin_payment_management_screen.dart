import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/firebase/models/firebase_payment_transaction_model.dart';
import '../../../../core/firebase/models/firebase_wallet_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';

class AdminPaymentManagementScreen extends StatefulWidget {
  const AdminPaymentManagementScreen({super.key});

  @override
  State<AdminPaymentManagementScreen> createState() => _AdminPaymentManagementScreenState();
}

class _AdminPaymentManagementScreenState extends State<AdminPaymentManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _firestoreService = FirestoreService();
  String _selectedFilter = 'all';

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Payment Management',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _selectedFilter = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Statuses')),
              const PopupMenuItem(value: 'succeeded', child: Text('Succeeded')),
              const PopupMenuItem(value: 'processing', child: Text('Processing')),
              const PopupMenuItem(value: 'failed', child: Text('Failed')),
              const PopupMenuItem(value: 'canceled', child: Text('Canceled')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'All Payments'),
            Tab(text: 'Payouts'),
            Tab(text: 'Refunds'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary Cards
          _buildSummarySection(),
          
          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllPaymentsTab(),
                _buildPayoutsTab(),
                _buildRefundsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return StreamBuilder<List<FirebasePaymentTransactionModel>>(
      stream: _firestoreService.streamPaymentTransactionsForAdmin(),
      builder: (context, snapshot) {
        final txs = snapshot.data ?? const <FirebasePaymentTransactionModel>[];
        final totalRevenue = txs
            .where((t) => t.status == 'succeeded')
            .fold<double>(0, (sum, t) => sum + t.amount);
        final failedCount =
            txs.where((t) => t.status == 'failed' || t.status == 'canceled').length;
        final pendingCount = txs.where((t) => t.status == 'processing').length;

        return Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surface,
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard('Revenue', '£${totalRevenue.toStringAsFixed(2)}', Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard('Processing', '$pendingCount', Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard('Failed', '$failedCount', Colors.red),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllPaymentsTab() {
    return StreamBuilder<List<FirebasePaymentTransactionModel>>(
      stream: _firestoreService.streamPaymentTransactionsForAdmin(
        status: _selectedFilter == 'all' ? null : _selectedFilter,
      ),
      builder: (context, snapshot) {
        final payments = snapshot.data ?? const <FirebasePaymentTransactionModel>[];
        if (payments.isEmpty) {
          return const Center(child: Text('No payment transactions found'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: payments.length,
          itemBuilder: (context, index) => _buildPaymentCard(payments[index]),
        );
      },
    );
  }

  Widget _buildPayoutsTab() {
    return FutureBuilder<List<FirebaseWalletTransactionModel>>(
      future: _firestoreService.getAllProviderPayouts(),
      builder: (context, snapshot) {
        final payouts = snapshot.data ?? const <FirebaseWalletTransactionModel>[];
        if (payouts.isEmpty) {
          return const Center(child: Text('No payouts found'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: payouts.length,
          itemBuilder: (context, index) => _buildPayoutCard(payouts[index]),
        );
      },
    );
  }

  Widget _buildRefundsTab() {
    return StreamBuilder<List<FirebasePaymentTransactionModel>>(
      stream: _firestoreService.streamPaymentTransactionsForAdmin(status: 'failed'),
      builder: (context, snapshot) {
        final refunds = snapshot.data ?? const <FirebasePaymentTransactionModel>[];
        if (refunds.isEmpty) {
          return const Center(child: Text('No failed/refund records'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: refunds.length,
          itemBuilder: (context, index) => _buildRefundCard(refunds[index]),
        );
      },
    );
  }

  Widget _buildPaymentCard(FirebasePaymentTransactionModel payment) {
    final isCompleted = payment.status == 'succeeded';
    
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : Icons.pending,
              color: isCompleted ? Colors.green : Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Payment',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customer: ${payment.customerUserId}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  '${payment.createdAt.day}/${payment.createdAt.month}/${payment.createdAt.year}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '£${payment.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  payment.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutCard(FirebaseWalletTransactionModel payout) {
    final status = payout.status;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getPayoutStatusColor(status).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                payout.userId,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPayoutStatusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getPayoutStatusColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount: £${payout.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${payout.createdAt.day}/${payout.createdAt.month}/${payout.createdAt.year}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          if (status == 'pending')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Reject payout
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Approve payout
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRefundCard(FirebasePaymentTransactionModel refund) {
    final status = refund.status;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Booking ${refund.bookingId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRefundStatusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getRefundStatusColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount: £${refund.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              Text(
                '${refund.createdAt.day}/${refund.createdAt.month}/${refund.createdAt.year}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          if (status == 'pending')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Reject refund
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Process refund
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Process'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getPayoutStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  Color _getRefundStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}

