import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Review/Rating Model
/// Collection: reviews
/// Document ID: reviewId
class FirebaseReviewModel {
  final String reviewId;
  final String bookingId; // Reference to bookings collection
  final String customerId; // Reference to users collection
  final String providerId; // Reference to providers collection
  final double rating; // 1.0 to 5.0
  final String? title;
  final String? comment;
  final List<String>? photos; // URLs of review photos
  final ReviewCategories categories; // Ratings for different aspects
  final bool isVerified; // Verified purchase/booking
  final bool isPublic;
  final bool isHelpful; // For helpful count
  final int helpfulCount;
  final String status; // pending, approved, rejected, hidden
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? response; // Provider's response
  final DateTime? respondedAt;

  FirebaseReviewModel({
    required this.reviewId,
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.rating,
    this.title,
    this.comment,
    this.photos,
    required this.categories,
    this.isVerified = true,
    this.isPublic = true,
    this.isHelpful = false,
    this.helpfulCount = 0,
    this.status = 'approved',
    required this.createdAt,
    this.updatedAt,
    this.response,
    this.respondedAt,
  });

  factory FirebaseReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseReviewModel(
      reviewId: doc.id,
      bookingId: data['bookingId'] ?? '',
      customerId: data['customerId'] ?? '',
      providerId: data['providerId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      title: data['title'],
      comment: data['comment'],
      photos: data['photos'] != null ? List<String>.from(data['photos']) : null,
      categories: ReviewCategories.fromMap(data['categories'] ?? {}),
      isVerified: data['isVerified'] ?? true,
      isPublic: data['isPublic'] ?? true,
      isHelpful: data['isHelpful'] ?? false,
      helpfulCount: data['helpfulCount'] ?? 0,
      status: data['status'] ?? 'approved',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      response: data['response'],
      respondedAt: (data['respondedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bookingId': bookingId,
      'customerId': customerId,
      'providerId': providerId,
      'rating': rating,
      'title': title,
      'comment': comment,
      'photos': photos,
      'categories': categories.toMap(),
      'isVerified': isVerified,
      'isPublic': isPublic,
      'isHelpful': isHelpful,
      'helpfulCount': helpfulCount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'response': response,
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }

  FirebaseReviewModel copyWith({
    String? reviewId,
    String? bookingId,
    String? customerId,
    String? providerId,
    double? rating,
    String? title,
    String? comment,
    List<String>? photos,
    ReviewCategories? categories,
    bool? isVerified,
    bool? isPublic,
    bool? isHelpful,
    int? helpfulCount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? response,
    DateTime? respondedAt,
  }) {
    return FirebaseReviewModel(
      reviewId: reviewId ?? this.reviewId,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      photos: photos ?? this.photos,
      categories: categories ?? this.categories,
      isVerified: isVerified ?? this.isVerified,
      isPublic: isPublic ?? this.isPublic,
      isHelpful: isHelpful ?? this.isHelpful,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      response: response ?? this.response,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}

class ReviewCategories {
  final double videoQuality; // 1.0 to 5.0
  final double editingQuality; // 1.0 to 5.0
  final double deliveryTime; // 1.0 to 5.0
  final double professionalism; // 1.0 to 5.0
  final double valueForMoney; // 1.0 to 5.0

  ReviewCategories({
    required this.videoQuality,
    required this.editingQuality,
    required this.deliveryTime,
    required this.professionalism,
    required this.valueForMoney,
  });

  factory ReviewCategories.fromMap(Map<String, dynamic> map) {
    return ReviewCategories(
      videoQuality: (map['videoQuality'] ?? 0.0).toDouble(),
      editingQuality: (map['editingQuality'] ?? 0.0).toDouble(),
      deliveryTime: (map['deliveryTime'] ?? 0.0).toDouble(),
      professionalism: (map['professionalism'] ?? 0.0).toDouble(),
      valueForMoney: (map['valueForMoney'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'videoQuality': videoQuality,
      'editingQuality': editingQuality,
      'deliveryTime': deliveryTime,
      'professionalism': professionalism,
      'valueForMoney': valueForMoney,
    };
  }

  double get averageRating {
    return (videoQuality + editingQuality + deliveryTime + professionalism + valueForMoney) / 5.0;
  }
}

