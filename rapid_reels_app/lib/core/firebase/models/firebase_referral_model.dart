import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Referral Model
/// Collection: referrals
/// Document ID: referralId
class FirebaseReferralModel {
  final String referralId;
  final String referrerId; // User who referred (Reference to users collection)
  final String referredId; // User who was referred (Reference to users collection)
  final String referralCode; // Unique referral code
  final String status; // pending, completed, expired, cancelled
  final ReferralReward reward;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? expiredAt;
  final String? completedBookingId; // Booking that triggered reward
  final Map<String, dynamic>? metadata;

  FirebaseReferralModel({
    required this.referralId,
    required this.referrerId,
    required this.referredId,
    required this.referralCode,
    required this.status,
    required this.reward,
    required this.createdAt,
    this.completedAt,
    this.expiredAt,
    this.completedBookingId,
    this.metadata,
  });

  factory FirebaseReferralModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseReferralModel(
      referralId: doc.id,
      referrerId: data['referrerId'] ?? '',
      referredId: data['referredId'] ?? '',
      referralCode: data['referralCode'] ?? '',
      status: data['status'] ?? 'pending',
      reward: ReferralReward.fromMap(data['reward'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      expiredAt: (data['expiredAt'] as Timestamp?)?.toDate(),
      completedBookingId: data['completedBookingId'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'referrerId': referrerId,
      'referredId': referredId,
      'referralCode': referralCode,
      'status': status,
      'reward': reward.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'expiredAt': expiredAt != null ? Timestamp.fromDate(expiredAt!) : null,
      'completedBookingId': completedBookingId,
      'metadata': metadata,
    };
  }
}

class ReferralReward {
  final double referrerReward; // Amount credited to referrer
  final double referredReward; // Amount credited to referred user
  final String currency; // INR
  final String rewardType; // wallet_credit, discount_coupon
  final String? couponCode; // If rewardType is discount_coupon
  final bool isCredited;

  ReferralReward({
    required this.referrerReward,
    required this.referredReward,
    this.currency = 'INR',
    this.rewardType = 'wallet_credit',
    this.couponCode,
    this.isCredited = false,
  });

  factory ReferralReward.fromMap(Map<String, dynamic> map) {
    return ReferralReward(
      referrerReward: (map['referrerReward'] ?? 0.0).toDouble(),
      referredReward: (map['referredReward'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'INR',
      rewardType: map['rewardType'] ?? 'wallet_credit',
      couponCode: map['couponCode'],
      isCredited: map['isCredited'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'referrerReward': referrerReward,
      'referredReward': referredReward,
      'currency': currency,
      'rewardType': rewardType,
      'couponCode': couponCode,
      'isCredited': isCredited,
    };
  }
}

