import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Offer/Coupon Model
/// Collection: offers
/// Document ID: offerId
class FirebaseOfferModel {
  final String offerId;
  final String code; // Coupon code
  final String title;
  final String? description;
  final String type; // discount_percentage, discount_amount, cashback, referral_bonus
  final OfferDiscount discount;
  final OfferValidity validity;
  final OfferEligibility eligibility;
  final int maxUses; // Maximum number of times this offer can be used
  final int usedCount; // Number of times already used
  final bool isActive;
  final bool isPublic; // Visible in offers screen
  final String? imageUrl;
  final List<String>? applicableEventTypes; // wedding, birthday, etc.
  final List<String>? applicablePackages; // package IDs
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;

  FirebaseOfferModel({
    required this.offerId,
    required this.code,
    required this.title,
    this.description,
    required this.type,
    required this.discount,
    required this.validity,
    required this.eligibility,
    required this.maxUses,
    this.usedCount = 0,
    this.isActive = true,
    this.isPublic = true,
    this.imageUrl,
    this.applicableEventTypes,
    this.applicablePackages,
    required this.createdAt,
    this.expiresAt,
    this.metadata,
  });

  factory FirebaseOfferModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseOfferModel(
      offerId: doc.id,
      code: data['code'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      type: data['type'] ?? '',
      discount: OfferDiscount.fromMap(data['discount'] ?? {}),
      validity: OfferValidity.fromMap(data['validity'] ?? {}),
      eligibility: OfferEligibility.fromMap(data['eligibility'] ?? {}),
      maxUses: data['maxUses'] ?? 0,
      usedCount: data['usedCount'] ?? 0,
      isActive: data['isActive'] ?? true,
      isPublic: data['isPublic'] ?? true,
      imageUrl: data['imageUrl'],
      applicableEventTypes: data['applicableEventTypes'] != null
          ? List<String>.from(data['applicableEventTypes'])
          : null,
      applicablePackages: data['applicablePackages'] != null
          ? List<String>.from(data['applicablePackages'])
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'title': title,
      'description': description,
      'type': type,
      'discount': discount.toMap(),
      'validity': validity.toMap(),
      'eligibility': eligibility.toMap(),
      'maxUses': maxUses,
      'usedCount': usedCount,
      'isActive': isActive,
      'isPublic': isPublic,
      'imageUrl': imageUrl,
      'applicableEventTypes': applicableEventTypes,
      'applicablePackages': applicablePackages,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'metadata': metadata,
    };
  }
}

class OfferDiscount {
  final double? percentage; // 10 for 10%
  final double? amount; // Fixed discount amount
  final double? maxDiscount; // Maximum discount cap
  final double? minPurchaseAmount; // Minimum purchase to apply

  OfferDiscount({
    this.percentage,
    this.amount,
    this.maxDiscount,
    this.minPurchaseAmount,
  });

  factory OfferDiscount.fromMap(Map<String, dynamic> map) {
    return OfferDiscount(
      percentage: map['percentage'] != null ? (map['percentage'] as num).toDouble() : null,
      amount: map['amount'] != null ? (map['amount'] as num).toDouble() : null,
      maxDiscount: map['maxDiscount'] != null ? (map['maxDiscount'] as num).toDouble() : null,
      minPurchaseAmount: map['minPurchaseAmount'] != null
          ? (map['minPurchaseAmount'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'percentage': percentage,
      'amount': amount,
      'maxDiscount': maxDiscount,
      'minPurchaseAmount': minPurchaseAmount,
    };
  }
}

class OfferValidity {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? validDays; // ['monday', 'tuesday', etc.]
  final List<String>? validTimeSlots; // ['morning', 'afternoon', 'evening']

  OfferValidity({
    this.startDate,
    this.endDate,
    this.validDays,
    this.validTimeSlots,
  });

  factory OfferValidity.fromMap(Map<String, dynamic> map) {
    return OfferValidity(
      startDate: (map['startDate'] as Timestamp?)?.toDate(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      validDays: map['validDays'] != null ? List<String>.from(map['validDays']) : null,
      validTimeSlots: map['validTimeSlots'] != null ? List<String>.from(map['validTimeSlots']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'validDays': validDays,
      'validTimeSlots': validTimeSlots,
    };
  }
}

class OfferEligibility {
  final bool isNewUserOnly;
  final bool isFirstBookingOnly;
  final int? minBookingAmount;
  final List<String>? eligibleUserIds; // Specific users
  final List<String>? excludedUserIds; // Excluded users
  final int? maxUsesPerUser;

  OfferEligibility({
    this.isNewUserOnly = false,
    this.isFirstBookingOnly = false,
    this.minBookingAmount,
    this.eligibleUserIds,
    this.excludedUserIds,
    this.maxUsesPerUser,
  });

  factory OfferEligibility.fromMap(Map<String, dynamic> map) {
    return OfferEligibility(
      isNewUserOnly: map['isNewUserOnly'] ?? false,
      isFirstBookingOnly: map['isFirstBookingOnly'] ?? false,
      minBookingAmount: map['minBookingAmount'],
      eligibleUserIds: map['eligibleUserIds'] != null ? List<String>.from(map['eligibleUserIds']) : null,
      excludedUserIds: map['excludedUserIds'] != null ? List<String>.from(map['excludedUserIds']) : null,
      maxUsesPerUser: map['maxUsesPerUser'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isNewUserOnly': isNewUserOnly,
      'isFirstBookingOnly': isFirstBookingOnly,
      'minBookingAmount': minBookingAmount,
      'eligibleUserIds': eligibleUserIds,
      'excludedUserIds': excludedUserIds,
      'maxUsesPerUser': maxUsesPerUser,
    };
  }
}

/// User Offer Usage Tracking
/// Subcollection: users/{userId}/offer_usage
/// Document ID: offerId
class FirebaseUserOfferUsageModel {
  final String userId;
  final String offerId;
  final int usageCount;
  final DateTime firstUsedAt;
  final DateTime lastUsedAt;
  final List<String>? bookingIds; // Bookings where this offer was used

  FirebaseUserOfferUsageModel({
    required this.userId,
    required this.offerId,
    this.usageCount = 0,
    required this.firstUsedAt,
    required this.lastUsedAt,
    this.bookingIds,
  });

  factory FirebaseUserOfferUsageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseUserOfferUsageModel(
      userId: doc.id.split('/')[1], // Extract from path
      offerId: doc.id,
      usageCount: data['usageCount'] ?? 0,
      firstUsedAt: (data['firstUsedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUsedAt: (data['lastUsedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bookingIds: data['bookingIds'] != null ? List<String>.from(data['bookingIds']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'usageCount': usageCount,
      'firstUsedAt': Timestamp.fromDate(firstUsedAt),
      'lastUsedAt': Timestamp.fromDate(lastUsedAt),
      'bookingIds': bookingIds,
    };
  }
}

