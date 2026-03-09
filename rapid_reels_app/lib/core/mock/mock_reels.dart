class ReelModel {
  final String reelId;
  final String eventId;
  final String customerId;
  final String providerId;
  final String title;
  final String description;
  final String eventType;
  final String eventMoment;
  final String videoUrl;
  final String thumbnailUrl;
  final int duration; // in seconds
  final String resolution;
  final String aspectRatio;
  final double fileSize; // in MB
  final String editingStyle;
  final List<String> filters;
  final List<String> transitions;
  final MusicTrack? musicTrack;
  final String colorGrading;
  final String status;
  final DateTime uploadedAt;
  final DateTime processedAt;
  final DateTime deliveredAt;
  final int processingTime; // in minutes
  final int qualityScore;
  final int views;
  final int likes;
  final int shares;
  final int downloads;
  final double? customerRating;
  final String? customerFeedback;
  final bool isPublic;
  final bool isHighlight;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReelModel({
    required this.reelId,
    required this.eventId,
    required this.customerId,
    required this.providerId,
    required this.title,
    required this.description,
    required this.eventType,
    required this.eventMoment,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.duration,
    required this.resolution,
    required this.aspectRatio,
    required this.fileSize,
    required this.editingStyle,
    required this.filters,
    required this.transitions,
    this.musicTrack,
    required this.colorGrading,
    required this.status,
    required this.uploadedAt,
    required this.processedAt,
    required this.deliveredAt,
    required this.processingTime,
    required this.qualityScore,
    required this.views,
    required this.likes,
    required this.shares,
    required this.downloads,
    this.customerRating,
    this.customerFeedback,
    required this.isPublic,
    required this.isHighlight,
    required this.createdAt,
    required this.updatedAt,
  });
}

class MusicTrack {
  final String name;
  final String artist;
  final int duration;
  final String license;

  MusicTrack({
    required this.name,
    required this.artist,
    required this.duration,
    required this.license,
  });
}

class MockReels {
  static final List<ReelModel> allReels = [
    // Event 004 Reels (Past Wedding)
    ReelModel(
      reelId: 'reel_001',
      eventId: 'event_004',
      customerId: 'user_001',
      providerId: 'provider_001',
      title: 'Wedding Entry - Amit & Sneha',
      description: 'Cinematic entry of the beautiful couple',
      eventType: 'wedding',
      eventMoment: 'Bride Entry',
      videoUrl: 'https://example.com/reel_001.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=400',
      duration: 45,
      resolution: '4K',
      aspectRatio: '9:16',
      fileSize: 32.5,
      editingStyle: 'cinematic',
      filters: ['warm_tone', 'soft_glow'],
      transitions: ['cross_dissolve', 'zoom'],
      musicTrack: MusicTrack(
        name: 'Tum Hi Ho',
        artist: 'Arijit Singh',
        duration: 45,
        license: 'royalty_free',
      ),
      colorGrading: 'warm',
      status: 'delivered',
      uploadedAt: DateTime.now().subtract(const Duration(days: 30, hours: 5)),
      processedAt: DateTime.now().subtract(const Duration(days: 30, hours: 4, minutes: 45)),
      deliveredAt: DateTime.now().subtract(const Duration(days: 30, hours: 4, minutes: 30)),
      processingTime: 15,
      qualityScore: 95,
      views: 1234,
      likes: 89,
      shares: 23,
      downloads: 5,
      customerRating: 5.0,
      customerFeedback: 'Absolutely loved it! Perfect capture!',
      isPublic: true,
      isHighlight: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30, hours: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    
    ReelModel(
      reelId: 'reel_002',
      eventId: 'event_004',
      customerId: 'user_001',
      providerId: 'provider_001',
      title: 'Varmala Ceremony',
      description: 'Beautiful exchange of garlands',
      eventType: 'wedding',
      eventMoment: 'Varmala',
      videoUrl: 'https://example.com/reel_002.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400',
      duration: 60,
      resolution: '4K',
      aspectRatio: '9:16',
      fileSize: 45.8,
      editingStyle: 'cinematic',
      filters: ['vintage', 'warm_tone'],
      transitions: ['fade', 'slide'],
      musicTrack: MusicTrack(
        name: 'Gerua',
        artist: 'Arijit Singh',
        duration: 60,
        license: 'royalty_free',
      ),
      colorGrading: 'warm',
      status: 'delivered',
      uploadedAt: DateTime.now().subtract(const Duration(days: 30, hours: 4)),
      processedAt: DateTime.now().subtract(const Duration(days: 30, hours: 3, minutes: 48)),
      deliveredAt: DateTime.now().subtract(const Duration(days: 30, hours: 3, minutes: 40)),
      processingTime: 12,
      qualityScore: 98,
      views: 987,
      likes: 76,
      shares: 18,
      downloads: 4,
      customerRating: 5.0,
      isPublic: true,
      isHighlight: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30, hours: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),

    ReelModel(
      reelId: 'reel_003',
      eventId: 'event_004',
      customerId: 'user_001',
      providerId: 'provider_001',
      title: 'Pheras - Seven Rounds',
      description: 'Sacred seven circles around the fire',
      eventType: 'wedding',
      eventMoment: 'Phere',
      videoUrl: 'https://example.com/reel_003.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=400',
      duration: 90,
      resolution: '4K',
      aspectRatio: '9:16',
      fileSize: 68.2,
      editingStyle: 'cinematic',
      filters: ['soft_glow', 'golden_hour'],
      transitions: ['zoom', 'pan'],
      musicTrack: MusicTrack(
        name: 'Kesariya',
        artist: 'Arijit Singh',
        duration: 90,
        license: 'royalty_free',
      ),
      colorGrading: 'warm',
      status: 'delivered',
      uploadedAt: DateTime.now().subtract(const Duration(days: 30, hours: 3)),
      processedAt: DateTime.now().subtract(const Duration(days: 30, hours: 2, minutes: 42)),
      deliveredAt: DateTime.now().subtract(const Duration(days: 30, hours: 2, minutes: 30)),
      processingTime: 18,
      qualityScore: 97,
      views: 1456,
      likes: 112,
      shares: 34,
      downloads: 8,
      customerRating: 5.0,
      isPublic: false,
      isHighlight: false,
      createdAt: DateTime.now().subtract(const Duration(days: 30, hours: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),

    // Event 005 Reels (Past Corporate Event)
    ReelModel(
      reelId: 'reel_004',
      eventId: 'event_005',
      customerId: 'user_001',
      providerId: 'provider_004',
      title: 'CEO\'s Inspiring Speech',
      description: 'Motivational address to the team',
      eventType: 'corporate',
      eventMoment: 'CEO Speech',
      videoUrl: 'https://example.com/reel_004.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400',
      duration: 75,
      resolution: '1080p',
      aspectRatio: '9:16',
      fileSize: 48.3,
      editingStyle: 'modern',
      filters: ['clean', 'professional'],
      transitions: ['cut', 'fade'],
      musicTrack: MusicTrack(
        name: 'Inspiring Corporate',
        artist: 'Audio Library',
        duration: 75,
        license: 'royalty_free',
      ),
      colorGrading: 'neutral',
      status: 'delivered',
      uploadedAt: DateTime.now().subtract(const Duration(days: 45, hours: 2)),
      processedAt: DateTime.now().subtract(const Duration(days: 45, hours: 1, minutes: 25)),
      deliveredAt: DateTime.now().subtract(const Duration(days: 45, hours: 1, minutes: 15)),
      processingTime: 35,
      qualityScore: 92,
      views: 543,
      likes: 45,
      shares: 12,
      downloads: 3,
      customerRating: 4.5,
      isPublic: false,
      isHighlight: false,
      createdAt: DateTime.now().subtract(const Duration(days: 45, hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 45)),
    ),

    ReelModel(
      reelId: 'reel_005',
      eventId: 'event_005',
      customerId: 'user_001',
      providerId: 'provider_004',
      title: 'Award Ceremony Highlights',
      description: 'Best moments from the awards',
      eventType: 'corporate',
      eventMoment: 'Award Ceremony',
      videoUrl: 'https://example.com/reel_005.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=400',
      duration: 60,
      resolution: '1080p',
      aspectRatio: '9:16',
      fileSize: 38.7,
      editingStyle: 'modern',
      filters: ['bright', 'vibrant'],
      transitions: ['zoom', 'slide'],
      musicTrack: MusicTrack(
        name: 'Celebration',
        artist: 'Audio Library',
        duration: 60,
        license: 'royalty_free',
      ),
      colorGrading: 'vibrant',
      status: 'delivered',
      uploadedAt: DateTime.now().subtract(const Duration(days: 45, hours: 1)),
      processedAt: DateTime.now().subtract(const Duration(days: 45, minutes: 28)),
      deliveredAt: DateTime.now().subtract(const Duration(days: 45, minutes: 20)),
      processingTime: 32,
      qualityScore: 94,
      views: 678,
      likes: 56,
      shares: 15,
      downloads: 4,
      customerRating: 5.0,
      isPublic: false,
      isHighlight: true,
      createdAt: DateTime.now().subtract(const Duration(days: 45, hours: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 45)),
    ),

    // Event 003 Reels (Live Engagement)
    ReelModel(
      reelId: 'reel_006',
      eventId: 'event_003',
      customerId: 'user_002',
      providerId: 'provider_002',
      title: 'Ring Exchange - Priya & Rohit',
      description: 'Beautiful ring exchange moment',
      eventType: 'engagement',
      eventMoment: 'Ring Exchange',
      videoUrl: 'https://example.com/reel_006.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=400',
      duration: 50,
      resolution: '1080p',
      aspectRatio: '9:16',
      fileSize: 35.2,
      editingStyle: 'romantic',
      filters: ['soft_focus', 'warm_tone'],
      transitions: ['fade', 'zoom'],
      musicTrack: MusicTrack(
        name: 'Perfect',
        artist: 'Ed Sheeran',
        duration: 50,
        license: 'royalty_free',
      ),
      colorGrading: 'warm',
      status: 'delivered',
      uploadedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      processedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 18)),
      deliveredAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      processingTime: 12,
      qualityScore: 96,
      views: 234,
      likes: 28,
      shares: 7,
      downloads: 2,
      isPublic: false,
      isHighlight: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),

    // Trending/Public Reels
    ReelModel(
      reelId: 'reel_007',
      eventId: 'event_999',
      customerId: 'user_003',
      providerId: 'provider_001',
      title: 'Baraat Entry - Most Energetic!',
      description: 'Epic groom entry with dhol and dancing',
      eventType: 'wedding',
      eventMoment: 'Baraat Entry',
      videoUrl: 'https://example.com/reel_007.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=400',
      duration: 70,
      resolution: '4K',
      aspectRatio: '9:16',
      fileSize: 52.8,
      editingStyle: 'cinematic',
      filters: ['vibrant', 'high_contrast'],
      transitions: ['zoom', 'spin'],
      musicTrack: MusicTrack(
        name: 'Balam Pichkari',
        artist: 'Bollywood Hits',
        duration: 70,
        license: 'royalty_free',
      ),
      colorGrading: 'vibrant',
      status: 'delivered',
      uploadedAt: DateTime.now().subtract(const Duration(days: 15)),
      processedAt: DateTime.now().subtract(const Duration(days: 15)),
      deliveredAt: DateTime.now().subtract(const Duration(days: 15)),
      processingTime: 20,
      qualityScore: 98,
      views: 25000,
      likes: 2100,
      shares: 350,
      downloads: 45,
      customerRating: 5.0,
      isPublic: true,
      isHighlight: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 14)),
    ),

    ReelModel(
      reelId: 'reel_008',
      eventId: 'event_998',
      customerId: 'user_004',
      providerId: 'provider_002',
      title: 'First Birthday Smash Cake',
      description: 'Adorable baby\'s first cake smashing',
      eventType: 'birthday',
      eventMoment: 'Cake Smash',
      videoUrl: 'https://example.com/reel_008.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1558636508-e0db3814bd1d?w=400',
      duration: 40,
      resolution: '4K',
      aspectRatio: '9:16',
      fileSize: 28.5,
      editingStyle: 'playful',
      filters: ['bright', 'colorful'],
      transitions: ['bounce', 'fade'],
      musicTrack: MusicTrack(
        name: 'Happy Birthday Tune',
        artist: 'Kids Music',
        duration: 40,
        license: 'royalty_free',
      ),
      colorGrading: 'vibrant',
      status: 'delivered',
      uploadedAt: DateTime.now().subtract(const Duration(days: 10)),
      processedAt: DateTime.now().subtract(const Duration(days: 10)),
      deliveredAt: DateTime.now().subtract(const Duration(days: 10)),
      processingTime: 15,
      qualityScore: 95,
      views: 18500,
      likes: 1650,
      shares: 280,
      downloads: 32,
      customerRating: 5.0,
      isPublic: true,
      isHighlight: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
  ];

  static ReelModel? getReelById(String reelId) {
    try {
      return allReels.firstWhere((reel) => reel.reelId == reelId);
    } catch (e) {
      return null;
    }
  }

  static List<ReelModel> getEventReels(String eventId) {
    return allReels.where((reel) => reel.eventId == eventId).toList();
  }

  static List<ReelModel> getUserReels(String userId) {
    return allReels.where((reel) => reel.customerId == userId).toList();
  }

  static List<ReelModel> getPublicReels() {
    return allReels.where((reel) => reel.isPublic).toList();
  }

  static List<ReelModel> getTrendingReels() {
    return allReels
        .where((reel) => reel.isPublic)
        .toList()
      ..sort((a, b) => b.views.compareTo(a.views));
  }
}

