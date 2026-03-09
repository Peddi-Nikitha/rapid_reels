import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';

/// Transaction History Screen - Shows all wallet and payment transactions
class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'txn_001',
      'type': 'debit',
      'category': 'booking',
      'title': 'Wedding Event Booking',
      'description': 'Advance payment for wedding event on Dec 25',
      'amount': 15000,
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'status': 'completed',
      'paymentMethod': 'UPI',
      'bookingId': 'BK001',
    },
    {
      'id': 'txn_002',
      'type': 'credit',
      'category': 'referral',
      'title': 'Referral Bonus',
      'description': 'Earned from Rajesh Kumar\'s signup',
      'amount': 100,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'completed',
      'paymentMethod': 'Wallet',
    },
    {
      'id': 'txn_003',
      'type': 'debit',
      'category': 'booking',
      'title': 'Birthday Party Booking',
      'description': 'Full payment for birthday event',
      'amount': 8500,
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'status': 'completed',
      'paymentMethod': 'Credit Card',
      'bookingId': 'BK002',
    },
    {
      'id': 'txn_004',
      'type': 'credit',
      'category': 'refund',
      'title': 'Booking Cancellation Refund',
      'description': 'Refund for cancelled engagement event',
      'amount': 4500,
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'status': 'completed',
      'paymentMethod': 'Wallet',
      'bookingId': 'BK003',
    },
    {
      'id': 'txn_005',
      'type': 'credit',
      'category': 'offer',
      'title': 'Offer Discount',
      'description': 'FIRST25 coupon applied',
      'amount': 1250,
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'status': 'completed',
      'paymentMethod': 'Wallet',
    },
    {
      'id': 'txn_006',
      'type': 'debit',
      'category': 'booking',
      'title': 'Corporate Event Booking',
      'description': 'Advance payment (50%)',
      'amount': 12000,
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'status': 'completed',
      'paymentMethod': 'Net Banking',
      'bookingId': 'BK004',
    },
    {
      'id': 'txn_007',
      'type': 'credit',
      'category': 'referral',
      'title': 'Referral Bonus',
      'description': 'Earned from Priya Sharma\'s signup',
      'amount': 100,
      'date': DateTime.now().subtract(const Duration(days: 12)),
      'status': 'completed',
      'paymentMethod': 'Wallet',
    },
    {
      'id': 'txn_008',
      'type': 'debit',
      'category': 'booking',
      'title': 'Engagement Ceremony',
      'description': 'Remaining payment (50%)',
      'amount': 9000,
      'date': DateTime.now().subtract(const Duration(days: 15)),
      'status': 'completed',
      'paymentMethod': 'UPI',
      'bookingId': 'BK005',
    },
    {
      'id': 'txn_009',
      'type': 'pending',
      'category': 'booking',
      'title': 'Anniversary Event',
      'description': 'Payment processing...',
      'amount': 6500,
      'date': DateTime.now().subtract(const Duration(minutes: 30)),
      'status': 'pending',
      'paymentMethod': 'Credit Card',
      'bookingId': 'BK006',
    },
  ];

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
    final allTransactions = _transactions;
    final creditTransactions =
        _transactions.where((t) => t['type'] == 'credit').toList();
    final debitTransactions =
        _transactions.where((t) => t['type'] == 'debit').toList();

    // Calculate totals
    final totalCredit = creditTransactions.fold<double>(
        0, (sum, t) => sum + (t['amount'] as int));
    final totalDebit = debitTransactions.fold<double>(
        0, (sum, t) => sum + (t['amount'] as int));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Transaction History',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Money In'),
            Tab(text: 'Money Out'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary Cards
          Container(
            margin: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Money In',
                    '₹${totalCredit.toInt()}',
                    Icons.arrow_downward,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Money Out',
                    '₹${totalDebit.toInt()}',
                    Icons.arrow_upward,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionsList(allTransactions),
                _buildTransactionsList(creditTransactions),
                _buildTransactionsList(debitTransactions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String label, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<Map<String, dynamic>> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No transactions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your transaction history will appear here',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Group by date
    final groupedTransactions = <String, List<Map<String, dynamic>>>{};
    for (var transaction in transactions) {
      final date = transaction['date'] as DateTime;
      final dateKey = _getDateKey(date);
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(transaction);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final dateKey = groupedTransactions.keys.elementAt(index);
        final dayTransactions = groupedTransactions[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                dateKey,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ...dayTransactions.map((transaction) {
              return _buildTransactionCard(transaction);
            }),
          ],
        );
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final type = transaction['type'] as String;
    final isCredit = type == 'credit';
    final isPending = type == 'pending';

    Color statusColor;
    IconData statusIcon;

    if (isPending) {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
    } else if (isCredit) {
      statusColor = Colors.green;
      statusIcon = Icons.arrow_downward;
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.arrow_upward;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showTransactionDetails(transaction);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(transaction['category'] as String),
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction['title'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction['description'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(transaction['date'] as DateTime),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              transaction['paymentMethod'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isCredit ? '+' : '-'}₹${transaction['amount']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isPending)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Pending',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'booking':
        return Icons.event;
      case 'referral':
        return Icons.card_giftcard;
      case 'refund':
        return Icons.replay;
      case 'offer':
        return Icons.local_offer;
      default:
        return Icons.receipt;
    }
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Transaction Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow('Transaction ID', transaction['id']),
                  _buildDetailRow('Title', transaction['title']),
                  _buildDetailRow('Description', transaction['description']),
                  _buildDetailRow('Amount', '₹${transaction['amount']}'),
                  _buildDetailRow('Payment Method', transaction['paymentMethod']),
                  _buildDetailRow('Status', transaction['status']),
                  _buildDetailRow(
                    'Date & Time',
                    '${(transaction['date'] as DateTime).day}/${(transaction['date'] as DateTime).month}/${(transaction['date'] as DateTime).year} ${(transaction['date'] as DateTime).hour}:${(transaction['date'] as DateTime).minute}',
                  ),
                  if (transaction['bookingId'] != null)
                    _buildDetailRow('Booking ID', transaction['bookingId']),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Receipt downloaded'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Download Receipt'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Transactions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Last 7 Days'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('Last 30 Days'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Custom Range'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('By Category'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}

