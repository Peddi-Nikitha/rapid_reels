import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/firebase/models/firebase_reel_model.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

// My Reels Provider - Future provider for user reels
final myReelsProvider = FutureProvider.family<List<FirebaseReelModel>, String>(
  (ref, userId) {
    final service = ref.watch(firestoreServiceProvider);
    return service.getUserReels(userId);
  },
);

// Filtered Reels Provider
final filteredReelsProvider = Provider.family<List<FirebaseReelModel>, ({String userId, String? status, String? eventType})>(
  (ref, params) {
    final reelsAsync = ref.watch(myReelsProvider(params.userId));
    return reelsAsync.when(
      data: (reels) {
        var filtered = reels;
        if (params.status != null && params.status != 'all') {
          filtered = filtered.where((r) => r.status == params.status).toList();
        }
        if (params.eventType != null && params.eventType != 'all') {
          filtered = filtered.where((r) => r.eventType == params.eventType).toList();
        }
        return filtered;
      },
      loading: () => [],
      error: (_, __) => [],
    );
  },
);

// Reel Statistics Provider
final reelStatsProvider = Provider.family<Map<String, dynamic>, String>(
  (ref, userId) {
    final reelsAsync = ref.watch(myReelsProvider(userId));
    return reelsAsync.when(
      data: (reels) {
        final totalViews = reels.fold<int>(0, (sum, r) => sum + r.analytics.views);
        final totalLikes = reels.fold<int>(0, (sum, r) => sum + r.analytics.likes);
        final totalShares = reels.fold<int>(0, (sum, r) => sum + r.analytics.shares);
        
        return {
          'total': reels.length,
          'processing': reels.where((r) => r.status == 'processing' || r.status == 'ready').length,
          'delivered': reels.where((r) => r.status == 'delivered').length,
          'published': reels.where((r) => r.status == 'published').length,
          'totalViews': totalViews,
          'totalLikes': totalLikes,
          'totalShares': totalShares,
        };
      },
      loading: () => {
        'total': 0,
        'processing': 0,
        'delivered': 0,
        'published': 0,
        'totalViews': 0,
        'totalLikes': 0,
        'totalShares': 0,
      },
      error: (_, __) => {
        'total': 0,
        'processing': 0,
        'delivered': 0,
        'published': 0,
        'totalViews': 0,
        'totalLikes': 0,
        'totalShares': 0,
      },
    );
  },
);

