import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/models/firebase_provider_model.dart';
import '../../../../core/firebase/models/firebase_reel_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../shared/widgets/reel_video_layer.dart';
import '../../../reels/presentation/reel_engagement.dart';

/// Main Discover Screen - TikTok-style vertical feed
class MainDiscoverScreen extends ConsumerStatefulWidget {
  const MainDiscoverScreen({super.key});

  @override
  ConsumerState<MainDiscoverScreen> createState() => _MainDiscoverScreenState();
}

class _MainDiscoverScreenState extends ConsumerState<MainDiscoverScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  int _currentIndex = 0;
  final Map<String, bool> _followedCreators = {};
  final Map<String, bool> _likedReels = {};
  final _firestoreService = FirestoreService();
  List<FirebaseReelModel> _reels = [];
  final Map<String, FirebaseProviderModel?> _providerCache = {};
  bool _isLoading = true;

  final List<String> _categories = [
    'For You',
    'Weddings',
    'Birthdays',
    'Corporate',
    'Engagements',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _pageController = PageController();
    _loadReels();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadReels() async {
    setState(() => _isLoading = true);
    try {
      final reels = await _firestoreService.getDiscoverReels();
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
      if (mounted) setState(() => _isLoading = false);
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _buildPremiumTabBar(),
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemCount: _reels.isEmpty ? 1 : _reels.length,
        itemBuilder: (context, index) {
          if (_reels.isEmpty) {
            return const Center(
              child: Text('No reels yet', style: TextStyle(color: Colors.white70)),
            );
          }
          return _buildReelPage(_reels[index], index);
        },
      ),
    );
  }

  Widget _buildReelPage(FirebaseReelModel reel, int index) {
    final provider = _providerCache[reel.providerId];
    final isFollowing = _followedCreators[reel.providerId] ?? false;
    final isActive = index == _currentIndex;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final reelId = reel.reelId;
    final isLiked = _likedReels.containsKey(reelId)
        ? _likedReels[reelId]!
        : (uid != null && reel.isLikedByUser(uid));

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video layer - plays when active (visible), autoplay by default
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

        // Gradient Overlay (pass taps through to video for play/pause & double-tap like)
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

        // Bottom information overlay - Refined Design
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Creator Profile Section - Prominent
                  if (provider != null)
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
                                          errorWidget: (context, url, error) => Container(
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
                                      child: Text(
                                        provider.businessName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.3,
                                          color: Colors.white,
                                          shadows: [
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
                                      '${_formatCount(provider.totalReelsDelivered)} reels',
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
                            isFollowing: isFollowing,
                            onTap: () {
                              setState(() {
                                _followedCreators[reel.providerId] = !isFollowing;
                              });
                            },
                          ),
                        ],
                      ),
                    )
                  else
                    // Fallback if provider not found
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              reel.providerId.substring(9, 11),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Provider ${reel.providerId.substring(9)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (provider != null) const SizedBox(height: 16),
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
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Caption - Refined Typography
                  Text(
                    reel.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [
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
                  Text(
                    reel.description ?? '',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.2,
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Engagement Stats
                  Row(
                    children: [
                      _buildStatChip(Icons.visibility_outlined, _formatCount(reel.views)),
                      const SizedBox(width: 10),
                      _buildStatChip(
                        isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        _formatCount(reel.likes),
                      ),
                      const SizedBox(width: 10),
                      _buildStatChip(Icons.share_rounded, _formatCount(reel.shares)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Right side actions - Compact and Professional
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                label: _formatCount(reel.likes),
                iconColor: isLiked ? const Color(0xFFFF3040) : Colors.white,
                onTap: () {
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
                icon: Icons.comment_rounded,
                label: _formatCount(reel.analytics.comments),
                iconColor: Colors.white,
                onTap: () {
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
                icon: Icons.share_rounded,
                label: 'Share',
                iconColor: Colors.white,
                onTap: () {
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
      ],
    );
  }

  Widget _buildPremiumTabBar() {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(left: 8),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.2),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        tabs: _categories.map((cat) {
          return Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Text(cat),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
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
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
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

  Widget _buildStatChip(IconData icon, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.5, color: Colors.white.withValues(alpha: 0.9)),
          const SizedBox(width: 5),
          Text(
            count,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
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
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Color _getEventColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'wedding':
        return AppColors.wedding;
      case 'birthday':
        return AppColors.birthday;
      case 'engagement':
        return AppColors.engagement;
      case 'corporate':
        return AppColors.corporate;
      default:
        return AppColors.primary;
    }
  }

  IconData _getEventIcon(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'wedding':
        return Icons.favorite;
      case 'birthday':
        return Icons.cake;
      case 'engagement':
        return Icons.diamond;
      case 'corporate':
        return Icons.business;
      default:
        return Icons.celebration;
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

}

