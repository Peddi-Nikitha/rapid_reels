import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Wallet Transaction Model
/// Collection: wallet_transactions
/// Document ID: transactionId
class FirebaseWalletTransactionModel {
  final String transactionId;
  final String userId; // Reference to users collection
  final String type; // credit, debit, refund, referral_reward, booking_payment, withdrawal
  final double amount;
  final String currency; // INR
  final String status; // pending, completed, failed, cancelled
  final String? description;
  final WalletTransactionReference? reference; // Links to booking, referral, etc.
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;
  final Map<String, dynamic>? metadata;

  FirebaseWalletTransactionModel({
    required this.transactionId,
    required this.userId,
    required this.type,
    required this.amount,
    this.currency = 'INR',
    required this.status,
    this.description,
    this.reference,
    required this.createdAt,
    this.completedAt,
    this.failureReason,
    this.metadata,
  });

  factory FirebaseWalletTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseWalletTransactionModel(
      transactionId: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'INR',
      status: data['status'] ?? 'pending',
      description: data['description'],
      reference: data['reference'] != null
          ? WalletTransactionReference.fromMap(data['reference'])
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      failureReason: data['failureReason'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'amount': amount,
      'currency': currency,
      'status': status,
      'description': description,
      'reference': reference?.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'failureReason': failureReason,
      'metadata': metadata,
    };
  }
}

class WalletTransactionReference {
  final String referenceType; // booking, referral, withdrawal, refund
  final String referenceId; // bookingId, referralId, withdrawalId, etc.
  final String? paymentMethod; // razorpay, wallet, bank_transfer, upi
  final String? transactionId; // External transaction ID (Razorpay, etc.)

  WalletTransactionReference({
    required this.referenceType,
    required this.referenceId,
    this.paymentMethod,
    this.transactionId,
  });

  factory WalletTransactionReference.fromMap(Map<String, dynamic> map) {
    return WalletTransactionReference(
      referenceType: map['referenceType'] ?? '',
      referenceId: map['referenceId'] ?? '',
      paymentMethod: map['paymentMethod'],
      transactionId: map['transactionId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'referenceType': referenceType,
      'referenceId': referenceId,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
    };
  }
}

/// Firebase Wallet Balance Model (stored in users collection as subcollection)
/// Subcollection: users/{userId}/wallet
/// Document ID: balance (single document)
class FirebaseWalletBalanceModel {
  final String userId;
  final double balance;
  final double pendingBalance; // Pending withdrawals
  final double lifetimeEarnings; // Total credits ever received
  final double lifetimeSpent; // Total debits ever made
  final DateTime lastUpdatedAt;
  final List<String>? recentTransactionIds;

  FirebaseWalletBalanceModel({
    required this.userId,
    required this.balance,
    this.pendingBalance = 0.0,
    this.lifetimeEarnings = 0.0,
    this.lifetimeSpent = 0.0,
    required this.lastUpdatedAt,
    this.recentTransactionIds,
  });

  factory FirebaseWalletBalanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseWalletBalanceModel(
      userId: doc.id,
      balance: (data['balance'] ?? 0.0).toDouble(),
      pendingBalance: (data['pendingBalance'] ?? 0.0).toDouble(),
      lifetimeEarnings: (data['lifetimeEarnings'] ?? 0.0).toDouble(),
      lifetimeSpent: (data['lifetimeSpent'] ?? 0.0).toDouble(),
      lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      recentTransactionIds: data['recentTransactionIds'] != null
          ? List<String>.from(data['recentTransactionIds'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'balance': balance,
      'pendingBalance': pendingBalance,
      'lifetimeEarnings': lifetimeEarnings,
      'lifetimeSpent': lifetimeSpent,
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
      'recentTransactionIds': recentTransactionIds,
    };
  }
}

