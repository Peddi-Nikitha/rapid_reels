import 'package:cloud_firestore/cloud_firestore.dart';

class FirebasePaymentTransactionModel {
  final String docId;
  final String transactionId;
  final String bookingId;
  final String customerUserId;
  final String providerUserId;
  final String stripeEventId;
  final double amount;
  final String currency;
  final String status;
  final String? failureCode;
  final String? failureMessage;
  final String paymentMethodType;
  final bool isLiveMode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? processedAt;
  final Map<String, dynamic>? metadata;

  FirebasePaymentTransactionModel({
    required this.docId,
    required this.transactionId,
    required this.bookingId,
    required this.customerUserId,
    required this.providerUserId,
    required this.stripeEventId,
    required this.amount,
    required this.currency,
    required this.status,
    this.failureCode,
    this.failureMessage,
    required this.paymentMethodType,
    required this.isLiveMode,
    required this.createdAt,
    required this.updatedAt,
    this.processedAt,
    this.metadata,
  });

  factory FirebasePaymentTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return FirebasePaymentTransactionModel(
      docId: doc.id,
      transactionId: (data['transactionId'] ?? '').toString(),
      bookingId: (data['bookingId'] ?? '').toString(),
      customerUserId: (data['customerUserId'] ?? '').toString(),
      providerUserId: (data['providerUserId'] ?? '').toString(),
      stripeEventId: (data['stripeEventId'] ?? '').toString(),
      amount: ((data['amount'] ?? 0) as num).toDouble(),
      currency: (data['currency'] ?? 'gbp').toString().toLowerCase(),
      status: (data['status'] ?? 'processing').toString(),
      failureCode: data['failureCode'] as String?,
      failureMessage: data['failureMessage'] as String?,
      paymentMethodType: (data['paymentMethodType'] ?? 'stripe').toString(),
      isLiveMode: (data['isLiveMode'] ?? false) == true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      processedAt: (data['processedAt'] as Timestamp?)?.toDate(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'transactionId': transactionId,
      'bookingId': bookingId,
      'customerUserId': customerUserId,
      'providerUserId': providerUserId,
      'stripeEventId': stripeEventId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'failureCode': failureCode,
      'failureMessage': failureMessage,
      'paymentMethodType': paymentMethodType,
      'isLiveMode': isLiveMode,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'processedAt': processedAt != null ? Timestamp.fromDate(processedAt!) : null,
      'metadata': metadata,
    };
  }
}
