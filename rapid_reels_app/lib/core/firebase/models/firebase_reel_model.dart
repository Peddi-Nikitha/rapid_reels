import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_utils.dart';

/// Firebase Reel Model
/// Collection: reels
/// Document ID: reelId
class FirebaseReelModel {
  final String reelId;
  final String bookingId; // Reference to bookings collection
  final String customerId; // Reference to users collection
  final String providerId; // Reference to providers collection
  final String eventType; // wedding, birthday, engagement, corporate, brand
  final String eventName;
  final String title; // Reel title/caption
  final String? description;
  final String videoUrl; // Firebase Storage URL
  final String thumbnailUrl; // Firebase Storage URL
  final int duration; // in seconds
  final String status; // processing, ready, delivered, published, archived
  final ReelMetadata metadata;
  final ReelAnalytics analytics;
  final List<String>? tags;
  final List<String>? hashtags;
  final bool isPublic; // Can be shown in discover feed
  final bool isFeatured; // Featured in trending
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final DateTime? publishedAt;
  final Map<String, dynamic>? editingDetails;
  /// User IDs who liked this reel (Firestore `likedBy`). Used for heart state after reload.
  final List<String> likedBy;

  FirebaseReelModel({
    required this.reelId,
    required this.bookingId,
    required this.customerId,
    required this.providerId,
    required this.eventType,
    required this.eventName,
    required this.title,
    this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.duration,
    required this.status,
    required this.metadata,
    required this.analytics,
    this.tags,
    this.hashtags,
    this.isPublic = false,
    this.isFeatured = false,
    required this.createdAt,
    this.deliveredAt,
    this.publishedAt,
    this.editingDetails,
    this.likedBy = const [],
  });

  bool isLikedByUser(String? userId) =>
      userId != null && userId.isNotEmpty && likedBy.contains(userId);

  // Display helpers for UI compatibility
  int get views => analytics.views;
  int get likes => analytics.likes;
  int get shares => analytics.shares;
  double get fileSize => metadata.fileSize / 1024 / 1024; // bytes to MB
  String get resolution => metadata.quality;

  factory FirebaseReelModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseReelModel(
      reelId: doc.id,
      bookingId: data['bookingId'] ?? '',
      customerId: data['customerId'] ?? '',
      providerId: data['providerId'] ?? '',
      eventType: data['eventType'] ?? '',
      eventName: data['eventName'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      videoUrl: data['videoUrl'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      duration: data['duration'] ?? 0,
      status: data['status'] ?? 'processing',
      metadata: ReelMetadata.fromMap(data['metadata'] ?? {}),
      analytics: ReelAnalytics.fromMap(data['analytics'] ?? {}),
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      hashtags: data['hashtags'] != null ? List<String>.from(data['hashtags']) : null,
      isPublic: firebaseToBool(data['isPublic'], false),
      isFeatured: firebaseToBool(data['isFeatured'], false),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveredAt: (data['deliveredAt'] as Timestamp?)?.toDate(),
      publishedAt: (data['publishedAt'] as Timestamp?)?.toDate(),
      editingDetails: data['editingDetails'],
      likedBy: data['likedBy'] != null
          ? List<String>.from(data['likedBy'] as List<dynamic>)
          : const [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'bookingId': bookingId,
      'customerId': customerId,
      'providerId': providerId,
      'eventType': eventType,
      'eventName': eventName,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'status': status,
      'metadata': metadata.toMap(),
      'analytics': analytics.toMap(),
      'tags': tags,
      'hashtags': hashtags,
      'isPublic': isPublic,
      'isFeatured': isFeatured,
      'createdAt': Timestamp.fromDate(createdAt),
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'publishedAt': publishedAt != null ? Timestamp.fromDate(publishedAt!) : null,
      'editingDetails': editingDetails,
      'likedBy': likedBy,
    };
  }

  FirebaseReelModel copyWith({
    String? reelId,
    String? bookingId,
    String? customerId,
    String? providerId,
    String? eventType,
    String? eventName,
    String? title,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
    int? duration,
    String? status,
    ReelMetadata? metadata,
    ReelAnalytics? analytics,
    List<String>? tags,
    List<String>? hashtags,
    bool? isPublic,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? deliveredAt,
    DateTime? publishedAt,
    Map<String, dynamic>? editingDetails,
    List<String>? likedBy,
  }) {
    return FirebaseReelModel(
      reelId: reelId ?? this.reelId,
      bookingId: bookingId ?? this.bookingId,
      customerId: customerId ?? this.customerId,
      providerId: providerId ?? this.providerId,
      eventType: eventType ?? this.eventType,
      eventName: eventName ?? this.eventName,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      analytics: analytics ?? this.analytics,
      tags: tags ?? this.tags,
      hashtags: hashtags ?? this.hashtags,
      isPublic: isPublic ?? this.isPublic,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      publishedAt: publishedAt ?? this.publishedAt,
      editingDetails: editingDetails ?? this.editingDetails,
      likedBy: likedBy ?? this.likedBy,
    );
  }

  /// Discover / trending: highest engagement (likes) first, then tie-breakers.
  static int compareForTrending(FirebaseReelModel a, FirebaseReelModel b) {
    final likeCmp = b.likes.compareTo(a.likes);
    if (likeCmp != 0) return likeCmp;
    final likedByCmp = b.likedBy.length.compareTo(a.likedBy.length);
    if (likedByCmp != 0) return likedByCmp;
    final viewCmp = b.views.compareTo(a.views);
    if (viewCmp != 0) return viewCmp;
    final ta = a.publishedAt ?? a.createdAt;
    final tb = b.publishedAt ?? b.createdAt;
    return tb.compareTo(ta);
  }
}

/// Comment document under `reels/{reelId}/comments/{commentId}`.
class ReelCommentDocument {
  final String commentId;
  final String reelId;
  final String userId;
  final String text;
  final DateTime createdAt;

  ReelCommentDocument({
    required this.commentId,
    required this.reelId,
    required this.userId,
    required this.text,
    required this.createdAt,
  });

  factory ReelCommentDocument.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReelCommentDocument(
      commentId: data['commentId'] as String? ?? doc.id,
      reelId: data['reelId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class ReelMetadata {
  final String editingStyle; // basic, standard, premium, cinematic
  final String? musicTrack;
  final String? colorGrading;
  final String quality; // 1080p, 4K
  final int fileSize; // in bytes
  final String? format; // mp4, mov
  final Map<String, dynamic>? filters;
  final List<String>? transitions;

  ReelMetadata({
    required this.editingStyle,
    this.musicTrack,
    this.colorGrading,
    required this.quality,
    required this.fileSize,
    this.format,
    this.filters,
    this.transitions,
  });

  factory ReelMetadata.fromMap(Map<String, dynamic> map) {
    return ReelMetadata(
      editingStyle: map['editingStyle'] ?? 'standard',
      musicTrack: map['musicTrack'],
      colorGrading: map['colorGrading'],
      quality: map['quality'] ?? '1080p',
      fileSize: map['fileSize'] ?? 0,
      format: map['format'],
      filters: map['filters'],
      transitions: map['transitions'] != null ? List<String>.from(map['transitions']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'editingStyle': editingStyle,
      'musicTrack': musicTrack,
      'colorGrading': colorGrading,
      'quality': quality,
      'fileSize': fileSize,
      'format': format,
      'filters': filters,
      'transitions': transitions,
    };
  }
}

class ReelAnalytics {
  final int views;
  final int likes;
  final int shares;
  final int comments;
  final int downloads;
  final double averageWatchTime; // in seconds
  final DateTime? lastViewedAt;
  final List<String>? viewedBy; // userIds who viewed

  ReelAnalytics({
    this.views = 0,
    this.likes = 0,
    this.shares = 0,
    this.comments = 0,
    this.downloads = 0,
    this.averageWatchTime = 0.0,
    this.lastViewedAt,
    this.viewedBy,
  });

  factory ReelAnalytics.fromMap(Map<String, dynamic> map) {
    return ReelAnalytics(
      views: map['views'] ?? 0,
      likes: map['likes'] ?? 0,
      shares: map['shares'] ?? 0,
      comments: map['comments'] ?? 0,
      downloads: map['downloads'] ?? 0,
      averageWatchTime: (map['averageWatchTime'] ?? 0.0).toDouble(),
      lastViewedAt: (map['lastViewedAt'] as Timestamp?)?.toDate(),
      viewedBy: map['viewedBy'] != null ? List<String>.from(map['viewedBy']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'views': views,
      'likes': likes,
      'shares': shares,
      'comments': comments,
      'downloads': downloads,
      'averageWatchTime': averageWatchTime,
      'lastViewedAt': lastViewedAt != null ? Timestamp.fromDate(lastViewedAt!) : null,
      'viewedBy': viewedBy,
    };
  }
}

