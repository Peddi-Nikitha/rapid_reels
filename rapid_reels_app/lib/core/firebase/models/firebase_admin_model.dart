import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Admin Analytics Model
/// Collection: admin_analytics
/// Document ID: date (YYYY-MM-DD format)
class FirebaseAdminAnalyticsModel {
  final String date; // YYYY-MM-DD
  final AdminMetrics metrics;
  final AdminRevenue revenue;
  final AdminUserStats userStats;
  final AdminProviderStats providerStats;
  final AdminBookingStats bookingStats;
  final DateTime updatedAt;

  FirebaseAdminAnalyticsModel({
    required this.date,
    required this.metrics,
    required this.revenue,
    required this.userStats,
    required this.providerStats,
    required this.bookingStats,
    required this.updatedAt,
  });

  factory FirebaseAdminAnalyticsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseAdminAnalyticsModel(
      date: doc.id,
      metrics: AdminMetrics.fromMap(data['metrics'] ?? {}),
      revenue: AdminRevenue.fromMap(data['revenue'] ?? {}),
      userStats: AdminUserStats.fromMap(data['userStats'] ?? {}),
      providerStats: AdminProviderStats.fromMap(data['providerStats'] ?? {}),
      bookingStats: AdminBookingStats.fromMap(data['bookingStats'] ?? {}),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'metrics': metrics.toMap(),
      'revenue': revenue.toMap(),
      'userStats': userStats.toMap(),
      'providerStats': providerStats.toMap(),
      'bookingStats': bookingStats.toMap(),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class AdminMetrics {
  final int totalUsers;
  final int activeUsers; // Users active in last 30 days
  final int totalProviders;
  final int activeProviders;
  final int totalBookings;
  final int completedBookings;
  final int totalReels;
  final double averageRating;
  final double averageDeliveryTime; // in minutes

  AdminMetrics({
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.totalProviders = 0,
    this.activeProviders = 0,
    this.totalBookings = 0,
    this.completedBookings = 0,
    this.totalReels = 0,
    this.averageRating = 0.0,
    this.averageDeliveryTime = 0.0,
  });

  factory AdminMetrics.fromMap(Map<String, dynamic> map) {
    return AdminMetrics(
      totalUsers: map['totalUsers'] ?? 0,
      activeUsers: map['activeUsers'] ?? 0,
      totalProviders: map['totalProviders'] ?? 0,
      activeProviders: map['activeProviders'] ?? 0,
      totalBookings: map['totalBookings'] ?? 0,
      completedBookings: map['completedBookings'] ?? 0,
      totalReels: map['totalReels'] ?? 0,
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      averageDeliveryTime: (map['averageDeliveryTime'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'totalProviders': totalProviders,
      'activeProviders': activeProviders,
      'totalBookings': totalBookings,
      'completedBookings': completedBookings,
      'totalReels': totalReels,
      'averageRating': averageRating,
      'averageDeliveryTime': averageDeliveryTime,
    };
  }
}

class AdminRevenue {
  final double totalRevenue; // Total GMV
  final double platformCommission; // Platform's commission
  final double providerEarnings; // Total paid to providers
  final double pendingPayouts; // Pending provider payouts
  final double refunds; // Total refunds issued

  AdminRevenue({
    this.totalRevenue = 0.0,
    this.platformCommission = 0.0,
    this.providerEarnings = 0.0,
    this.pendingPayouts = 0.0,
    this.refunds = 0.0,
  });

  factory AdminRevenue.fromMap(Map<String, dynamic> map) {
    return AdminRevenue(
      totalRevenue: (map['totalRevenue'] ?? 0.0).toDouble(),
      platformCommission: (map['platformCommission'] ?? 0.0).toDouble(),
      providerEarnings: (map['providerEarnings'] ?? 0.0).toDouble(),
      pendingPayouts: (map['pendingPayouts'] ?? 0.0).toDouble(),
      refunds: (map['refunds'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalRevenue': totalRevenue,
      'platformCommission': platformCommission,
      'providerEarnings': providerEarnings,
      'pendingPayouts': pendingPayouts,
      'refunds': refunds,
    };
  }
}

class AdminUserStats {
  final int newUsers; // New users today
  final int totalUsers;
  final int verifiedUsers;
  final double averageBookingsPerUser;
  final double averageWalletBalance;

  AdminUserStats({
    this.newUsers = 0,
    this.totalUsers = 0,
    this.verifiedUsers = 0,
    this.averageBookingsPerUser = 0.0,
    this.averageWalletBalance = 0.0,
  });

  factory AdminUserStats.fromMap(Map<String, dynamic> map) {
    return AdminUserStats(
      newUsers: map['newUsers'] ?? 0,
      totalUsers: map['totalUsers'] ?? 0,
      verifiedUsers: map['verifiedUsers'] ?? 0,
      averageBookingsPerUser: (map['averageBookingsPerUser'] ?? 0.0).toDouble(),
      averageWalletBalance: (map['averageWalletBalance'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'newUsers': newUsers,
      'totalUsers': totalUsers,
      'verifiedUsers': verifiedUsers,
      'averageBookingsPerUser': averageBookingsPerUser,
      'averageWalletBalance': averageWalletBalance,
    };
  }
}

class AdminProviderStats {
  final int newProviders; // New providers today
  final int totalProviders;
  final int verifiedProviders;
  final int activeProviders;
  final double averageRating;
  final double averageEarningsPerProvider;

  AdminProviderStats({
    this.newProviders = 0,
    this.totalProviders = 0,
    this.verifiedProviders = 0,
    this.activeProviders = 0,
    this.averageRating = 0.0,
    this.averageEarningsPerProvider = 0.0,
  });

  factory AdminProviderStats.fromMap(Map<String, dynamic> map) {
    return AdminProviderStats(
      newProviders: map['newProviders'] ?? 0,
      totalProviders: map['totalProviders'] ?? 0,
      verifiedProviders: map['verifiedProviders'] ?? 0,
      activeProviders: map['activeProviders'] ?? 0,
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      averageEarningsPerProvider: (map['averageEarningsPerProvider'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'newProviders': newProviders,
      'totalProviders': totalProviders,
      'verifiedProviders': verifiedProviders,
      'activeProviders': activeProviders,
      'averageRating': averageRating,
      'averageEarningsPerProvider': averageEarningsPerProvider,
    };
  }
}

class AdminBookingStats {
  final int newBookings; // New bookings today
  final int totalBookings;
  final int confirmedBookings;
  final int ongoingBookings;
  final int completedBookings;
  final int cancelledBookings;
  final double averageBookingValue;
  final double completionRate; // Percentage

  AdminBookingStats({
    this.newBookings = 0,
    this.totalBookings = 0,
    this.confirmedBookings = 0,
    this.ongoingBookings = 0,
    this.completedBookings = 0,
    this.cancelledBookings = 0,
    this.averageBookingValue = 0.0,
    this.completionRate = 0.0,
  });

  factory AdminBookingStats.fromMap(Map<String, dynamic> map) {
    return AdminBookingStats(
      newBookings: map['newBookings'] ?? 0,
      totalBookings: map['totalBookings'] ?? 0,
      confirmedBookings: map['confirmedBookings'] ?? 0,
      ongoingBookings: map['ongoingBookings'] ?? 0,
      completedBookings: map['completedBookings'] ?? 0,
      cancelledBookings: map['cancelledBookings'] ?? 0,
      averageBookingValue: (map['averageBookingValue'] ?? 0.0).toDouble(),
      completionRate: (map['completionRate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'newBookings': newBookings,
      'totalBookings': totalBookings,
      'confirmedBookings': confirmedBookings,
      'ongoingBookings': ongoingBookings,
      'completedBookings': completedBookings,
      'cancelledBookings': cancelledBookings,
      'averageBookingValue': averageBookingValue,
      'completionRate': completionRate,
    };
  }
}

/// Firebase Support Ticket Model
/// Collection: support_tickets
/// Document ID: ticketId
class FirebaseSupportTicketModel {
  final String ticketId;
  final String userId; // Reference to users collection
  final String? providerId; // Reference to providers collection (if provider ticket)
  final String type; // booking_issue, payment_issue, technical, general, complaint
  final String priority; // low, medium, high, urgent
  final String status; // open, in_progress, resolved, closed
  final String subject;
  final String description;
  final List<String>? attachments; // URLs
  final String? bookingId; // Related booking
  final List<SupportMessage> messages;
  final String? assignedTo; // Admin user ID
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final Map<String, dynamic>? metadata;

  FirebaseSupportTicketModel({
    required this.ticketId,
    required this.userId,
    this.providerId,
    required this.type,
    required this.priority,
    required this.status,
    required this.subject,
    required this.description,
    this.attachments,
    this.bookingId,
    required this.messages,
    this.assignedTo,
    required this.createdAt,
    this.resolvedAt,
    this.closedAt,
    this.metadata,
  });

  factory FirebaseSupportTicketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseSupportTicketModel(
      ticketId: doc.id,
      userId: data['userId'] ?? '',
      providerId: data['providerId'],
      type: data['type'] ?? '',
      priority: data['priority'] ?? 'medium',
      status: data['status'] ?? 'open',
      subject: data['subject'] ?? '',
      description: data['description'] ?? '',
      attachments: data['attachments'] != null ? List<String>.from(data['attachments']) : null,
      bookingId: data['bookingId'],
      messages: (data['messages'] as List?)
              ?.map((m) => SupportMessage.fromMap(m))
              .toList() ??
          [],
      assignedTo: data['assignedTo'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
      closedAt: (data['closedAt'] as Timestamp?)?.toDate(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'providerId': providerId,
      'type': type,
      'priority': priority,
      'status': status,
      'subject': subject,
      'description': description,
      'attachments': attachments,
      'bookingId': bookingId,
      'messages': messages.map((m) => m.toMap()).toList(),
      'assignedTo': assignedTo,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'closedAt': closedAt != null ? Timestamp.fromDate(closedAt!) : null,
      'metadata': metadata,
    };
  }
}

class SupportMessage {
  final String messageId;
  final String senderId; // User ID or Admin ID
  final String senderType; // user, provider, admin
  final String message;
  final List<String>? attachments;
  final DateTime sentAt;
  final bool isRead;

  SupportMessage({
    required this.messageId,
    required this.senderId,
    required this.senderType,
    required this.message,
    this.attachments,
    required this.sentAt,
    this.isRead = false,
  });

  factory SupportMessage.fromMap(Map<String, dynamic> map) {
    return SupportMessage(
      messageId: map['messageId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderType: map['senderType'] ?? 'user',
      message: map['message'] ?? '',
      attachments: map['attachments'] != null ? List<String>.from(map['attachments']) : null,
      sentAt: (map['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderType': senderType,
      'message': message,
      'attachments': attachments,
      'sentAt': Timestamp.fromDate(sentAt),
      'isRead': isRead,
    };
  }
}

