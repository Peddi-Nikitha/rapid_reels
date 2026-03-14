import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Live Event Tracking Model
/// Collection: live_events
/// Document ID: bookingId (same as booking ID)
class FirebaseLiveEventModel {
  final String bookingId; // Reference to bookings collection
  final String providerId; // Reference to providers collection
  final String customerId; // Reference to users collection
  final String status; // not_started, active, paused, completed
  final DateTime? startedAt;
  final DateTime? pausedAt;
  final DateTime? completedAt;
  final int totalDuration; // Total event duration in minutes
  final int elapsedTime; // Elapsed time in minutes
  final LiveEventProgress progress;
  final List<EventMilestone> milestones;
  final List<FootageUpload> footageUploads;
  final List<ReelDelivery> reelDeliveries;
  final LiveEventLocation? currentLocation; // Provider's current location
  final Map<String, dynamic>? metadata;

  FirebaseLiveEventModel({
    required this.bookingId,
    required this.providerId,
    required this.customerId,
    required this.status,
    this.startedAt,
    this.pausedAt,
    this.completedAt,
    required this.totalDuration,
    this.elapsedTime = 0,
    required this.progress,
    required this.milestones,
    required this.footageUploads,
    required this.reelDeliveries,
    this.currentLocation,
    this.metadata,
  });

  factory FirebaseLiveEventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseLiveEventModel(
      bookingId: doc.id,
      providerId: data['providerId'] ?? '',
      customerId: data['customerId'] ?? '',
      status: data['status'] ?? 'not_started',
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      pausedAt: (data['pausedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      totalDuration: data['totalDuration'] ?? 0,
      elapsedTime: data['elapsedTime'] ?? 0,
      progress: LiveEventProgress.fromMap(data['progress'] ?? {}),
      milestones: (data['milestones'] as List?)
              ?.map((m) => EventMilestone.fromMap(m))
              .toList() ??
          [],
      footageUploads: (data['footageUploads'] as List?)
              ?.map((f) => FootageUpload.fromMap(f))
              .toList() ??
          [],
      reelDeliveries: (data['reelDeliveries'] as List?)
              ?.map((r) => ReelDelivery.fromMap(r))
              .toList() ??
          [],
      currentLocation: data['currentLocation'] != null
          ? LiveEventLocation.fromMap(data['currentLocation'])
          : null,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'providerId': providerId,
      'customerId': customerId,
      'status': status,
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'pausedAt': pausedAt != null ? Timestamp.fromDate(pausedAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'totalDuration': totalDuration,
      'elapsedTime': elapsedTime,
      'progress': progress.toMap(),
      'milestones': milestones.map((m) => m.toMap()).toList(),
      'footageUploads': footageUploads.map((f) => f.toMap()).toList(),
      'reelDeliveries': reelDeliveries.map((r) => r.toMap()).toList(),
      'currentLocation': currentLocation?.toMap(),
      'metadata': metadata,
    };
  }
}

class LiveEventProgress {
  final double coveragePercentage; // 0.0 to 100.0
  final int keyMomentsCaptured;
  final int totalKeyMoments;
  final int reelsDelivered;
  final int expectedReels;
  final String? currentPhase; // setup, ceremony, reception, etc.

  LiveEventProgress({
    this.coveragePercentage = 0.0,
    this.keyMomentsCaptured = 0,
    this.totalKeyMoments = 0,
    this.reelsDelivered = 0,
    this.expectedReels = 0,
    this.currentPhase,
  });

  factory LiveEventProgress.fromMap(Map<String, dynamic> map) {
    return LiveEventProgress(
      coveragePercentage: (map['coveragePercentage'] ?? 0.0).toDouble(),
      keyMomentsCaptured: map['keyMomentsCaptured'] ?? 0,
      totalKeyMoments: map['totalKeyMoments'] ?? 0,
      reelsDelivered: map['reelsDelivered'] ?? 0,
      expectedReels: map['expectedReels'] ?? 0,
      currentPhase: map['currentPhase'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'coveragePercentage': coveragePercentage,
      'keyMomentsCaptured': keyMomentsCaptured,
      'totalKeyMoments': totalKeyMoments,
      'reelsDelivered': reelsDelivered,
      'expectedReels': expectedReels,
      'currentPhase': currentPhase,
    };
  }
}

class EventMilestone {
  final String milestoneId;
  final String name; // 'Bride Entry', 'Cake Cutting', etc.
  final String? description;
  final DateTime? capturedAt;
  final bool isCaptured;
  final String? footageId; // Reference to footage upload
  final String? reelId; // Reference to delivered reel

  EventMilestone({
    required this.milestoneId,
    required this.name,
    this.description,
    this.capturedAt,
    this.isCaptured = false,
    this.footageId,
    this.reelId,
  });

  factory EventMilestone.fromMap(Map<String, dynamic> map) {
    return EventMilestone(
      milestoneId: map['milestoneId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      capturedAt: (map['capturedAt'] as Timestamp?)?.toDate(),
      isCaptured: map['isCaptured'] ?? false,
      footageId: map['footageId'],
      reelId: map['reelId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'milestoneId': milestoneId,
      'name': name,
      'description': description,
      'capturedAt': capturedAt != null ? Timestamp.fromDate(capturedAt!) : null,
      'isCaptured': isCaptured,
      'footageId': footageId,
      'reelId': reelId,
    };
  }
}

class FootageUpload {
  final String uploadId;
  final String fileName;
  final String fileUrl; // Firebase Storage URL
  final int fileSize; // in bytes
  final String fileType; // video, image
  final DateTime uploadedAt;
  final String? milestoneId; // Associated milestone
  final Map<String, dynamic>? metadata;

  FootageUpload({
    required this.uploadId,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.fileType,
    required this.uploadedAt,
    this.milestoneId,
    this.metadata,
  });

  factory FootageUpload.fromMap(Map<String, dynamic> map) {
    return FootageUpload(
      uploadId: map['uploadId'] ?? '',
      fileName: map['fileName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      fileType: map['fileType'] ?? 'video',
      uploadedAt: (map['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      milestoneId: map['milestoneId'],
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uploadId': uploadId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'fileType': fileType,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'milestoneId': milestoneId,
      'metadata': metadata,
    };
  }
}

class ReelDelivery {
  final String reelId; // Reference to reels collection
  final String title;
  final DateTime deliveredAt;
  final String status; // processing, ready, delivered
  final int deliveryTime; // Time taken to deliver in minutes

  ReelDelivery({
    required this.reelId,
    required this.title,
    required this.deliveredAt,
    required this.status,
    required this.deliveryTime,
  });

  factory ReelDelivery.fromMap(Map<String, dynamic> map) {
    return ReelDelivery(
      reelId: map['reelId'] ?? '',
      title: map['title'] ?? '',
      deliveredAt: (map['deliveredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: map['status'] ?? 'delivered',
      deliveryTime: map['deliveryTime'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reelId': reelId,
      'title': title,
      'deliveredAt': Timestamp.fromDate(deliveredAt),
      'status': status,
      'deliveryTime': deliveryTime,
    };
  }
}

class LiveEventLocation {
  final double latitude;
  final double longitude;
  final DateTime updatedAt;
  final String? address;

  LiveEventLocation({
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
    this.address,
  });

  factory LiveEventLocation.fromMap(Map<String, dynamic> map) {
    return LiveEventLocation(
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      address: map['address'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'address': address,
    };
  }
}

