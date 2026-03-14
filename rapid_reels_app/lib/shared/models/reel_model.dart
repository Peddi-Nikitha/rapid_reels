/// Shared Reel Model
/// Domain model for reel/video data
class ReelModel {
  final String reelId;
  final String bookingId;
  final String customerId;
  final String providerId;
  final String eventType;
  final String eventName;
  final String title;
  final String? description;
  final String videoUrl;
  final String thumbnailUrl;
  final int duration; // in seconds
  final String status; // processing, ready, delivered, published, archived
  final ReelMetadata metadata;
  final ReelAnalytics analytics;
  final List<String>? tags;
  final List<String>? hashtags;
  final bool isPublic;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final DateTime? publishedAt;

  ReelModel({
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
  });

  factory ReelModel.fromMap(Map<String, dynamic> data, String id) {
    return ReelModel(
      reelId: id,
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
      isPublic: data['isPublic'] ?? false,
      isFeatured: data['isFeatured'] ?? false,
      createdAt: data['createdAt'] is String
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      deliveredAt: data['deliveredAt'] != null && data['deliveredAt'] is String
          ? DateTime.parse(data['deliveredAt'])
          : null,
      publishedAt: data['publishedAt'] != null && data['publishedAt'] is String
          ? DateTime.parse(data['publishedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
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
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
    };
  }

  ReelModel copyWith({
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
  }) {
    return ReelModel(
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
    );
  }

  // Helper getters
  bool get isDelivered => status == 'delivered' || status == 'published';
  bool get isProcessing => status == 'processing' || status == 'ready';
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes}m ${seconds}s';
  }
}

class ReelMetadata {
  final String editingStyle;
  final String? musicTrack;
  final String? colorGrading;
  final String quality;
  final int fileSize;
  final String? format;

  ReelMetadata({
    required this.editingStyle,
    this.musicTrack,
    this.colorGrading,
    required this.quality,
    required this.fileSize,
    this.format,
  });

  factory ReelMetadata.fromMap(Map<String, dynamic> map) {
    return ReelMetadata(
      editingStyle: map['editingStyle'] ?? 'standard',
      musicTrack: map['musicTrack'],
      colorGrading: map['colorGrading'],
      quality: map['quality'] ?? '1080p',
      fileSize: map['fileSize'] ?? 0,
      format: map['format'],
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
    };
  }
}

class ReelAnalytics {
  final int views;
  final int likes;
  final int shares;
  final int comments;
  final int downloads;
  final double averageWatchTime;
  final DateTime? lastViewedAt;

  ReelAnalytics({
    this.views = 0,
    this.likes = 0,
    this.shares = 0,
    this.comments = 0,
    this.downloads = 0,
    this.averageWatchTime = 0.0,
    this.lastViewedAt,
  });

  factory ReelAnalytics.fromMap(Map<String, dynamic> map) {
    return ReelAnalytics(
      views: map['views'] ?? 0,
      likes: map['likes'] ?? 0,
      shares: map['shares'] ?? 0,
      comments: map['comments'] ?? 0,
      downloads: map['downloads'] ?? 0,
      averageWatchTime: (map['averageWatchTime'] ?? 0.0).toDouble(),
      lastViewedAt: map['lastViewedAt'] != null && map['lastViewedAt'] is String
          ? DateTime.parse(map['lastViewedAt'])
          : null,
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
      'lastViewedAt': lastViewedAt?.toIso8601String(),
    };
  }
}

