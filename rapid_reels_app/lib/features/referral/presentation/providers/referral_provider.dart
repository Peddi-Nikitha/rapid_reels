import 'package:flutter_riverpod/flutter_riverpod.dart';

// Wallet Balance Provider
final walletBalanceProvider = StateProvider<double>((ref) => 500.0);

// Referral Stats Provider
final referralStatsProvider = FutureProvider.family<ReferralStats, String>((ref, userId) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return ReferralStats(
    totalReferrals: 5,
    successfulReferrals: 3,
    pendingReferrals: 2,
    totalEarnings: 600.0,
    availableBalance: ref.watch(walletBalanceProvider),
  );
});

// Referral History Provider
final referralHistoryProvider = FutureProvider.family<List<ReferralRecord>, String>((ref, userId) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    ReferralRecord(
      id: 'ref_1',
      referredUserName: 'Amit Kumar',
      referredDate: DateTime.now().subtract(const Duration(days: 5)),
      status: ReferralStatus.completed,
      rewardAmount: 200.0,
    ),
    ReferralRecord(
      id: 'ref_2',
      referredUserName: 'Priya Sharma',
      referredDate: DateTime.now().subtract(const Duration(days: 12)),
      status: ReferralStatus.completed,
      rewardAmount: 200.0,
    ),
    ReferralRecord(
      id: 'ref_3',
      referredUserName: 'Rahul Singh',
      referredDate: DateTime.now().subtract(const Duration(days: 3)),
      status: ReferralStatus.pending,
      rewardAmount: 200.0,
    ),
  ];
});

// Wallet Transactions Provider
final walletTransactionsProvider = FutureProvider.family<List<WalletTransaction>, String>((ref, userId) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    WalletTransaction(
      id: 'txn_1',
      type: TransactionType.credit,
      amount: 200.0,
      description: 'Referral bonus for inviting Amit',
      date: DateTime.now().subtract(const Duration(days: 5)),
      balanceAfter: 500.0,
    ),
    WalletTransaction(
      id: 'txn_2',
      type: TransactionType.credit,
      amount: 200.0,
      description: 'Referral bonus for inviting Priya',
      date: DateTime.now().subtract(const Duration(days: 12)),
      balanceAfter: 300.0,
    ),
    WalletTransaction(
      id: 'txn_3',
      type: TransactionType.debit,
      amount: 100.0,
      description: 'Applied to booking #BK123',
      date: DateTime.now().subtract(const Duration(days: 20)),
      balanceAfter: 100.0,
    ),
  ];
});

// Referral Notifier
class ReferralNotifier extends StateNotifier<AsyncValue<void>> {
  ReferralNotifier() : super(const AsyncValue.data(null));

  Future<void> redeemWalletBalance(double amount, String method) async {
    state = const AsyncValue.loading();
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> applyWalletToBooking(String bookingId, double amount) async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(seconds: 1));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final referralNotifierProvider = StateNotifierProvider<ReferralNotifier, AsyncValue<void>>((ref) {
  return ReferralNotifier();
});

// Models
class ReferralStats {
  final int totalReferrals;
  final int successfulReferrals;
  final int pendingReferrals;
  final double totalEarnings;
  final double availableBalance;

  ReferralStats({
    required this.totalReferrals,
    required this.successfulReferrals,
    required this.pendingReferrals,
    required this.totalEarnings,
    required this.availableBalance,
  });
}

enum ReferralStatus {
  pending,
  completed,
  expired,
}

class ReferralRecord {
  final String id;
  final String referredUserName;
  final DateTime referredDate;
  final ReferralStatus status;
  final double rewardAmount;

  ReferralRecord({
    required this.id,
    required this.referredUserName,
    required this.referredDate,
    required this.status,
    required this.rewardAmount,
  });
}

enum TransactionType {
  credit,
  debit,
}

class WalletTransaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime date;
  final double balanceAfter;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.balanceAfter,
  });
}

