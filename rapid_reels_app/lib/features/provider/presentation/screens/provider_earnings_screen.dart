import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/models/firebase_booking_model.dart';
import '../../../../core/firebase/models/firebase_payment_transaction_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/theme/provider_app_colors.dart';

class ProviderEarningsScreen extends StatefulWidget {
  const ProviderEarningsScreen({super.key, required this.providerId});

  final String providerId;

  @override
  State<ProviderEarningsScreen> createState() => _ProviderEarningsScreenState();
}

class _ProviderEarningsScreenState extends State<ProviderEarningsScreen>
    with SingleTickerProviderStateMixin {
  String _selectedPeriod = 'This Month';
  late TabController _tabController;
  final _firestoreService = FirestoreService();

  static const _periods = ['This Week', 'This Month', 'This Year', 'All Time'];

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

  DateTime _periodStart() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'This Week':
        return DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - DateTime.monday));
      case 'This Month':
        return DateTime(now.year, now.month, 1);
      case 'This Year':
        return DateTime(now.year, 1, 1);
      default:
        return DateTime(2000);
    }
  }

  bool _inSelectedPeriod(DateTime t) {
    if (_selectedPeriod == 'All Time') return true;
    final start = _periodStart();
    final end = DateTime.now().add(const Duration(days: 1));
    return !t.isBefore(start) && t.isBefore(end);
  }

  List<FirebasePaymentTransactionModel> _filterForPeriod(
    List<FirebasePaymentTransactionModel> all,
  ) {
    return all.where((t) => _inSelectedPeriod(t.createdAt)).toList();
  }

  double _sumGrossSucceeded(List<FirebasePaymentTransactionModel> list) {
    return list
        .where((t) => t.status == 'succeeded')
        .fold<double>(0, (a, t) => a + t.amount);
  }

  double _estimateNet(double gross, double commissionPercent) {
    return gross * (1 - commissionPercent / 100);
  }

  String _formatMoney(double amount, String currency) {
    final c = currency.toLowerCase();
    final sym = c == 'gbp'
        ? '£'
        : c == 'inr'
            ? '₹'
            : c.toUpperCase();
    return '$sym${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: cs.primary,
          labelColor: cs.primary,
          unselectedLabelColor: Theme.of(context).hintColor,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Payments'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: StreamBuilder<List<FirebasePaymentTransactionModel>>(
        stream: _firestoreService.streamPaymentTransactionsForProvider(
          widget.providerId,
        ),
        builder: (context, txSnap) {
          return StreamBuilder(
            stream: _firestoreService.streamProviderDoc(widget.providerId),
            builder: (context, provSnap) {
              final commission = provSnap.data?.commissionRate ?? 15.0;
              final allTx = txSnap.data ?? const <FirebasePaymentTransactionModel>[];
              final periodTx = _filterForPeriod(allTx);
              final gross = _sumGrossSucceeded(periodTx);
              final netEst = _estimateNet(gross, commission);

              return TabBarView(
                controller: _tabController,
                children: [
                  _buildOverview(context, gross, netEst, commission, periodTx),
                  _buildPaymentsTab(allTx),
                  _buildAnalyticsTab(allTx, commission),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOverview(
    BuildContext context,
    double grossSucceeded,
    double netEstimate,
    double commissionRate,
    List<FirebasePaymentTransactionModel> periodTx,
  ) {
    final recent =
        periodTx.where((t) => t.status == 'succeeded').take(8).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: ProviderAppColors.primarySoftGradient,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer payments (gross)',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatMoney(grossSucceeded, 'gbp'),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Est. your share (${(100 - commissionRate).toStringAsFixed(0)}% after ${commissionRate.toStringAsFixed(0)}% platform): ${_formatMoney(netEstimate, 'gbp')}',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _periods
                .map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: _selectedPeriod == p,
                      label: Text(p),
                      onSelected: (_) => setState(() => _selectedPeriod = p),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Payout bank details'),
          subtitle: const Text('Manage where you receive funds'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push(
              '${AppRoutes.providerPortal}/${widget.providerId}/account',
            );
          },
        ),
        const Divider(),
        Text(
          'Recent in period',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          Text(
            'No successful payments in this period.',
            style: TextStyle(color: Theme.of(context).hintColor),
          )
        else
          ...recent.map((t) => _paymentRow(context, t, commissionRate)),
      ],
    );
  }

  Future<String> _bookingTitle(String bookingId) async {
    final b = await _firestoreService.getBooking(bookingId);
    if (b == null) return 'Booking $bookingId';
    return b.eventName.isNotEmpty ? b.eventName : '${b.eventType} · $bookingId';
  }

  Widget _paymentRow(
    BuildContext context,
    FirebasePaymentTransactionModel t,
    double commissionRate,
  ) {
    final net = _estimateNet(
      t.status == 'succeeded' ? t.amount : 0,
      commissionRate,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          title: FutureBuilder<String>(
            future: _bookingTitle(t.bookingId),
            builder: (context, snap) => Text(
              snap.data ?? '…',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          subtitle: Text(
            DateFormat.yMMMd().add_jm().format(t.createdAt),
            style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatMoney(t.amount, t.currency),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (t.status == 'succeeded')
                Text(
                  'est. ${_formatMoney(net, t.currency)}',
                  style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentsTab(List<FirebasePaymentTransactionModel> transactions) {
    final pending =
        transactions.where((t) => t.status == 'processing').toList();
    final history = transactions
        .where((t) => t.status != 'processing')
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Pending',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (pending.isEmpty)
          _buildEmptyMessage('No pending payments')
        else
          ...pending.map((t) => _buildPaymentTxCard(t)),
        const SizedBox(height: 24),
        const Text(
          'History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (history.isEmpty)
          _buildEmptyMessage('No payment history yet')
        else
          ...history.map((t) => _buildPaymentTxCard(t)),
      ],
    );
  }

  Widget _buildEmptyMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message),
    );
  }

  Widget _buildPaymentTxCard(FirebasePaymentTransactionModel tx) {
    final isPending = tx.status == 'processing';
    return FutureBuilder<FirebaseBookingModel?>(
      future: _firestoreService.getBooking(tx.bookingId),
      builder: (context, snap) {
        final title = snap.data?.eventName.isNotEmpty == true
            ? snap.data!.eventName
            : 'Booking ${tx.bookingId}';
        return _buildPaymentCard(
          {
            'event': title,
            'amount': tx.amount,
            'currency': tx.currency,
            'date':
                '${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year}',
            'status': tx.status,
          },
          isPending: isPending,
        );
      },
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment,
      {required bool isPending}) {
    final cs = Theme.of(context).colorScheme;
    final amount = payment['amount'] as double;
    final currency = payment['currency'] as String? ?? 'gbp';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: isPending
            ? Border.all(color: ProviderAppColors.warning, width: 1)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPending
                  ? ProviderAppColors.warning.withValues(alpha: 0.12)
                  : cs.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPending ? Icons.pending : Icons.check_circle,
              color: isPending ? ProviderAppColors.warning : cs.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment['event'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${payment['date']} · ${payment['status']}',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
          Text(
            _formatMoney(amount, currency),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(
    List<FirebasePaymentTransactionModel> all,
    double commissionRate,
  ) {
    final succeeded = all.where((t) => t.status == 'succeeded').toList();
    final byMonth = <String, double>{};
    for (final t in succeeded) {
      final k = '${t.createdAt.year}-${t.createdAt.month.toString().padLeft(2, '0')}';
      byMonth[k] = (byMonth[k] ?? 0) + t.amount;
    }
    final keys = byMonth.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Gross by month (successful charges)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        if (keys.isEmpty)
          Text(
            'No data yet.',
            style: TextStyle(color: Theme.of(context).hintColor),
          )
        else
          ...keys.map((k) {
            final gross = byMonth[k]!;
            final net = _estimateNet(gross, commissionRate);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                tileColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(k),
                subtitle: Text(
                  'Est. net ${_formatMoney(net, 'gbp')}',
                  style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                ),
                trailing: Text(
                  _formatMoney(gross, 'gbp'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            );
          }),
      ],
    );
  }
}
