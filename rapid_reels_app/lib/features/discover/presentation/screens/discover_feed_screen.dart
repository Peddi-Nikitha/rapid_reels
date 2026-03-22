import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/models/firebase_provider_model.dart';
import '../../../../core/firebase/models/firebase_reel_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/reel_video_layer.dart';
import '../../../reels/presentation/reel_engagement.dart';

class DiscoverFeedScreen extends StatefulWidget {
  const DiscoverFeedScreen({super.key});

  @override
  State<DiscoverFeedScreen> createState() => _DiscoverFeedScreenState();
}

class _DiscoverFeedScreenState extends State<DiscoverFeedScreen> {
  final _firestoreService = FirestoreService();
  late PageController _pageController;
  String _selectedFilter = 'all';
  final Map<String, bool> _followedCreators = {};
  final Map<String, bool> _likedReels = {};
  List<FirebaseReelModel> _reels = [];
  final Map<String, FirebaseProviderModel?> _providerCache = {};
  bool _isLoading = true;
  String? _error;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadReels();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadReels() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final reels = await _firestoreService.getDiscoverReels(
        eventType: _selectedFilter == 'all' ? null : _selectedFilter,
      );

      final providerIds = reels.map((r) => r.providerId).toSet().toList();
      final providers = await Future.wait(
        providerIds.map((id) => _firestoreService.getProvider(id)),
      );
      final cache = <String, FirebaseProviderModel?>{};
      for (var i = 0; i < providerIds.length; i++) {
        cache[providerIds[i]] = providers[i];
      }
      if (mounted) {
        setState(() {
          _reels = reels;
          _providerCache.addAll(cache);
          _isLoading = false;
          _seedLikesFromReels();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _seedLikesFromReels() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    for (final r in _reels) {
      _likedReels[r.reelId] = uid != null && r.isLikedByUser(uid);
    }
  }

  void _mergeReel(FirebaseReelModel? fresh) {
    if (fresh == null || !mounted) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    setState(() {
      final i = _reels.indexWhere((r) => r.reelId == fresh.reelId);
      if (i >= 0) _reels[i] = fresh;
      if (uid != null) _likedReels[fresh.reelId] = fresh.isLikedByUser(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _reels.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (_error != null && _reels.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _loadReels,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vertical Scrolling Reels (TikTok Style)
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: _reels.isEmpty ? 1 : _reels.length,
            itemBuilder: (context, index) {
              if (_reels.isEmpty) {
                return const Center(
                  child: Text(
                    'No reels yet',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }
              final reel = _reels[index];
              final provider = _providerCache[reel.providerId];
              final reelId = reel.reelId;
              final uid = FirebaseAuth.instance.currentUser?.uid;
              final isLiked = _likedReels.containsKey(reelId)
                  ? _likedReels[reelId]!
                  : (uid != null && reel.isLikedByUser(uid));
              
              final isActive = index == _currentIndex;
              return Stack(
                  children: [
                    Positioned.fill(
                      child: ReelVideoLayer(
                        reel: reel,
                        isActive: isActive,
                        onDoubleTap: () {
                          ReelEngagement.toggleLike(
                            context: context,
                            userId: uid,
                            reel: reel,
                            firestore: _firestoreService,
                            previousLiked: isLiked,
                            setLikedDisplay: (liked) {
                              setState(() => _likedReels[reelId] = liked);
                            },
                            onSynced: _mergeReel,
                          );
                        },
                      ),
                    ),
                  
                  // Refined Gradient Overlay (taps pass through to video)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.0),
                              Colors.black.withValues(alpha: 0.3),
                              Colors.black.withValues(alpha: 0.75),
                            ],
                            stops: const [0.0, 0.4, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Action Buttons (Right Side) - Compact and Professional
                  Positioned(
                    right: 12,
                    bottom: 120,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(
                          isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          _formatNumber(reel.likes),
                          () {
                            ReelEngagement.toggleLike(
                              context: context,
                              userId: uid,
                              reel: reel,
                              firestore: _firestoreService,
                              previousLiked: isLiked,
                              setLikedDisplay: (liked) {
                                setState(() => _likedReels[reelId] = liked);
                              },
                              onSynced: _mergeReel,
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildActionButton(
                          Icons.comment_rounded,
                          _formatNumber(reel.analytics.comments),
                          () {
                            ReelEngagement.showCommentsSheet(
                              context: context,
                              reelId: reelId,
                              userId: uid,
                              firestore: _firestoreService,
                              onSynced: _mergeReel,
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildActionButton(
                          Icons.share_rounded,
                          _formatNumber(reel.shares),
                          () {
                            ReelEngagement.shareReel(
                              context: context,
                              reel: reel,
                              firestore: _firestoreService,
                              onSynced: _mergeReel,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Reel Info (Bottom) - Creator-Focused Design
                  Positioned(
                    left: 16,
                    right: 88,
                    bottom: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Creator Profile Section - Prominent
                        if (provider != null) ...[
                          GestureDetector(
                            onTap: () {
                              if (reel.providerId.isEmpty) return;
                              context.push('${AppRoutes.providerDetails}/${reel.providerId}');
                            },
                            child: Row(
                              children: [
                                // Creator Avatar with Verification
                                Stack(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.3),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: provider.profileImage.isNotEmpty
                                            ? CachedNetworkImage(
                                                imageUrl: provider.profileImage,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => Container(
                                                  color: AppColors.primary,
                                                  child: const Icon(
                                                    Icons.person_rounded,
                                                    color: Colors.white,
                                                    size: 22,
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                color: AppColors.primary,
                                                child: const Icon(
                                                  Icons.person_rounded,
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                              ),
                                      ),
                                    ),
                                    // Verification Badge
                                    if (provider.isVerified)
                                      Positioned(
                                        bottom: -1,
                                        right: -1,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1DA1F2),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.verified_rounded,
                                            color: Colors.white,
                                            size: 10,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                // Creator Name & Stats
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child:                                       Text(
                                        provider.businessName,
                                        style: AppTypography.titleMedium.copyWith(
                                          color: Colors.white,
                                          shadows: const [
                                            Shadow(
                                              color: Colors.black45,
                                              offset: Offset(0, 1),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                          ),
                                          if (provider.isVerified) ...[
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.verified_rounded,
                                              color: Color(0xFF1DA1F2),
                                              size: 16,
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          // Rating
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.star_rounded,
                                                size: 12,
                                                color: Color(0xFFFFB800),
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                provider.rating.toStringAsFixed(1),
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white.withValues(alpha: 0.95),
                                                  letterSpacing: -0.1,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 12),
                                          // Creator Stats
                                          Text(
                                            '${_formatNumber(provider.totalReelsDelivered)} reels • ${_formatNumber(provider.totalEventsCompleted)} events',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white.withValues(alpha: 0.85),
                                              letterSpacing: -0.1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Follow Button
                                _buildFollowButton(
                                  isFollowing: _followedCreators[reel.providerId] ?? false,
                                  onTap: () {
                                    setState(() {
                                      _followedCreators[reel.providerId] =
                                          !(_followedCreators[reel.providerId] ?? false);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Event Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            _formatEventType(reel.eventType),
                            style: AppTypography.tag.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Reel Title - Using Typography System
                        Text(
                          reel.title,
                          style: AppTypography.titleLarge.copyWith(
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 1),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        
                        // Description
                        Text(
                          reel.description ?? '',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        
                        // Engagement Stats
                        Row(
                          children: [
                            _buildStatItem(
                              icon: Icons.visibility_outlined,
                              text: '${_formatNumber(reel.views)}',
                            ),
                            const SizedBox(width: 12),
                            _buildStatItem(
                              icon: Icons.favorite_outline_rounded,
                              text: '${_formatNumber(reel.likes)}',
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                _formatEventType(reel.eventType),
                                style: AppTypography.tag.copyWith(
                                  color: Colors.white.withValues(alpha: 0.95),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                ],
              );
            },
          ),
          
          // Top Bar - Compact and Refined
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Discover',
                    style: AppTypography.headlineMedium.copyWith(
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Filter Chips - Premium Design
          Positioned(
            top: 72,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Wedding', 'wedding'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Birthday', 'birthday'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Engagement', 'engagement'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13.5,
          color: Colors.white.withValues(alpha: 0.85),
        ),
        const SizedBox(width: 5),
          Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _selectedFilter = value);
          _loadReels();
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.15),
              width: 0.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatEventType(String type) {
    return type[0].toUpperCase() + type.substring(1);
  }

  Widget _buildFollowButton({
    required bool isFollowing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: isFollowing
                ? Colors.white.withValues(alpha: 0.2)
                : AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isFollowing
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isFollowing ? Colors.white : AppColors.primary)
                    .withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            isFollowing ? 'Following' : 'Follow',
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

}

