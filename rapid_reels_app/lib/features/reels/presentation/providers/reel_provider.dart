import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/mock/mock_reels.dart';

// User Reels Provider
final userReelsProvider = FutureProvider.family<List<ReelModel>, String>((ref, userId) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return MockReels.getUserReels(userId);
});

// Public Reels Provider (for Discover)
final publicReelsProvider = FutureProvider<List<ReelModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return MockReels.getPublicReels();
});

// Trending Reels Provider
final trendingReelsProvider2 = FutureProvider<List<ReelModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return MockReels.getTrendingReels();
});

// Reel by ID Provider
final reelByIdProvider = FutureProvider.family<ReelModel?, String>((ref, reelId) async {
  await Future.delayed(const Duration(milliseconds: 200));
  return MockReels.getReelById(reelId);
});

// Reel Filter State
enum ReelFilter {
  all,
  wedding,
  birthday,
  engagement,
  corporate,
  brand,
}

// Reel Sort Option
enum ReelSortOption {
  recent,
  popular,
  views,
}

// Reel Gallery State Notifier
class ReelGalleryNotifier extends StateNotifier<ReelGalleryState> {
  ReelGalleryNotifier() : super(const ReelGalleryState());

  void setFilter(ReelFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void setSortOption(ReelSortOption sortOption) {
    state = state.copyWith(sortOption: sortOption);
  }

  void toggleViewMode() {
    state = state.copyWith(
      isGridView: !state.isGridView,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

// Reel Gallery State
class ReelGalleryState {
  final ReelFilter filter;
  final ReelSortOption sortOption;
  final bool isGridView;
  final String searchQuery;

  const ReelGalleryState({
    this.filter = ReelFilter.all,
    this.sortOption = ReelSortOption.recent,
    this.isGridView = true,
    this.searchQuery = '',
  });

  ReelGalleryState copyWith({
    ReelFilter? filter,
    ReelSortOption? sortOption,
    bool? isGridView,
    String? searchQuery,
  }) {
    return ReelGalleryState(
      filter: filter ?? this.filter,
      sortOption: sortOption ?? this.sortOption,
      isGridView: isGridView ?? this.isGridView,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final reelGalleryNotifierProvider = StateNotifierProvider<ReelGalleryNotifier, ReelGalleryState>((ref) {
  return ReelGalleryNotifier();
});

// Reel Player State Notifier
class ReelPlayerNotifier extends StateNotifier<ReelPlayerState> {
  ReelPlayerNotifier() : super(const ReelPlayerState());

  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void toggleMute() {
    state = state.copyWith(isMuted: !state.isMuted);
  }

  void toggleLike() {
    state = state.copyWith(isLiked: !state.isLiked);
  }

  void setPlaying(bool isPlaying) {
    state = state.copyWith(isPlaying: isPlaying);
  }
}

// Reel Player State
class ReelPlayerState {
  final int currentIndex;
  final bool isMuted;
  final bool isLiked;
  final bool isPlaying;

  const ReelPlayerState({
    this.currentIndex = 0,
    this.isMuted = false,
    this.isLiked = false,
    this.isPlaying = true,
  });

  ReelPlayerState copyWith({
    int? currentIndex,
    bool? isMuted,
    bool? isLiked,
    bool? isPlaying,
  }) {
    return ReelPlayerState(
      currentIndex: currentIndex ?? this.currentIndex,
      isMuted: isMuted ?? this.isMuted,
      isLiked: isLiked ?? this.isLiked,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

final reelPlayerNotifierProvider = StateNotifierProvider<ReelPlayerNotifier, ReelPlayerState>((ref) {
  return ReelPlayerNotifier();
});

