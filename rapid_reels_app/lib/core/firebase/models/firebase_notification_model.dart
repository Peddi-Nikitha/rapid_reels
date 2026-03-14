import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Notification Model
/// Collection: notifications
/// Document ID: notificationId
class FirebaseNotificationModel {
  final String notificationId;
  final String userId; // Reference to users collection (recipient)
  final String type; // booking_update, reel_delivered, payment, referral, system, promotion
  final String title;
  final String body;
  final String? imageUrl;
  final NotificationData? data; // Additional data payload
  final bool isRead;
  final bool isDelivered;
  final String priority; // high, normal, low
  final String? actionUrl; // Deep link or route
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? deliveredAt;
  final Map<String, dynamic>? metadata;

  FirebaseNotificationModel({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    this.data,
    this.isRead = false,
    this.isDelivered = false,
    this.priority = 'normal',
    this.actionUrl,
    required this.createdAt,
    this.readAt,
    this.deliveredAt,
    this.metadata,
  });

  factory FirebaseNotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseNotificationModel(
      notificationId: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      imageUrl: data['imageUrl'],
      data: data['data'] != null ? NotificationData.fromMap(data['data']) : null,
      isRead: data['isRead'] ?? false,
      isDelivered: data['isDelivered'] ?? false,
      priority: data['priority'] ?? 'normal',
      actionUrl: data['actionUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      deliveredAt: (data['deliveredAt'] as Timestamp?)?.toDate(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data?.toMap(),
      'isRead': isRead,
      'isDelivered': isDelivered,
      'priority': priority,
      'actionUrl': actionUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'metadata': metadata,
    };
  }
}

class NotificationData {
  final String? bookingId;
  final String? reelId;
  final String? providerId;
  final String? paymentId;
  final String? referralId;
  final Map<String, dynamic>? customData;

  NotificationData({
    this.bookingId,
    this.reelId,
    this.providerId,
    this.paymentId,
    this.referralId,
    this.customData,
  });

  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      bookingId: map['bookingId'],
      reelId: map['reelId'],
      providerId: map['providerId'],
      paymentId: map['paymentId'],
      referralId: map['referralId'],
      customData: map['customData'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'reelId': reelId,
      'providerId': providerId,
      'paymentId': paymentId,
      'referralId': referralId,
      'customData': customData,
    };
  }
}

