import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/models/firebase_provider_model.dart';
import '../../../../core/firebase/models/firebase_reel_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/reel_video_layer.dart';
import '../reel_engagement.dart';

class ReelPlayerScreen extends StatefulWidget {
  final String reelId;
  final List<FirebaseReelModel> reels;
  final int initialIndex;

  const ReelPlayerScreen({
    super.key,
    required this.reelId,
    required this.reels,
    required this.initialIndex,
  });

  @override
  State<ReelPlayerScreen> createState() => _ReelPlayerScreenState();
}

class _ReelPlayerScreenState extends State<ReelPlayerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  late List<FirebaseReelModel> _reels;
  final Map<String, bool> _likedReels = {};
  final Map<String, bool> _followedCreators = {};
  final _firestoreService = FirestoreService();
  final Map<String, FirebaseProviderModel?> _providerCache = {};
  final Set<String> _countedViewReelIds = {};

  @override
  void initState() {
    super.initState();
    _reels = List<FirebaseReelModel>.from(widget.reels);
    _currentIndex = widget.initialIndex.clamp(0, (_reels.length - 1).clamp(0, 999));
    _pageController = PageController(initialPage: _currentIndex);
    _seedLikesFromReels();
    _loadProviders();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_reels.isNotEmpty) _recordViewForReel(_reels[_currentIndex].reelId);
    });
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

  void _recordViewForReel(String reelId) {
    if (_countedViewReelIds.contains(reelId)) return;
    _countedViewReelIds.add(reelId);
    unawaited(
      _firestoreService.incrementReelViews(reelId).catchError((_) {}),
    );
  }

  Future<void> _loadProviders() async {
    if (_reels.isEmpty) return;
    final providerIds = _reels.map((r) => r.providerId).toSet().toList();
    for (final id in providerIds) {
      final p = await _firestoreService.getProvider(id);
      if (mounted) _providerCache[id] = p;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reels.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: Text('No reels', style: TextStyle(color: Colors.white)),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index >= 0 && index < _reels.length) {
            _recordViewForReel(_reels[index].reelId);
          }
        },
        itemCount: _reels.length,
        itemBuilder: (context, index) {
          return _buildReelPage(_reels[index], index == _currentIndex);
        },
      ),
    );
  }

  Widget _buildReelPage(FirebaseReelModel reel, bool isActive) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final reelId = reel.reelId;
    final isLiked = _likedReels.containsKey(reelId)
        ? _likedReels[reelId]!
        : (uid != null && reel.isLikedByUser(uid));
    final provider = _providerCache[reel.providerId];
    final isFollowing = _followedCreators[reel.providerId] ?? false;

    return Stack(
      children: [
        // Video player (plays when active) + thumbnail fallback
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
        
        // Top Bar - Compact and Refined
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: () => Navigator.pop(context),
                  size: 20,
                ),
                const Spacer(),
                _buildIconButton(
                  icon: Icons.more_vert_rounded,
                  onPressed: () => _showOptionsSheet(reel),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        
        // Right Action Buttons - Compact and Professional
        Positioned(
          right: 12,
          bottom: 120,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                label: _formatNumber(reel.likes),
                onTap: () {
                  ReelEngagement.toggleLike(
                    context: context,
                    userId: uid,
                    reel: reel,
                    firestore: _firestoreService,
                    previousLiked: isLiked,
                    setLikedDisplay: (liked) {
                      setState(() => _likedReels[reel.reelId] = liked);
                    },
                    onSynced: _mergeReel,
                  );
                },
                color: isLiked ? AppColors.reelLike : Colors.white,
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.comment_rounded,
                label: _formatNumber(reel.analytics.comments),
                onTap: () {
                  ReelEngagement.showCommentsSheet(
                    context: context,
                    reelId: reel.reelId,
                    userId: uid,
                    firestore: _firestoreService,
                    onSynced: _mergeReel,
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                icon: Icons.share_rounded,
                label: _formatNumber(reel.shares),
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
        
        // Bottom Info - Creator-Focused Design
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
                                  color: AppColors.verifiedBadge,
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
                                    color: AppColors.verifiedBadge,
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
                                      color: AppColors.warning,
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
                                  '${_formatNumber(provider.totalReelsDelivered)} reels',
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
                ),
                const SizedBox(height: 16),
              ],
              
              // Event Type Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
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
              const SizedBox(height: 14),
              
              // Title
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
              
              // Description
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
                  _buildStatItem(
                    icon: Icons.visibility_outlined,
                    text: '${_formatNumber(reel.views)}',
                    size: 13,
                  ),
                  const SizedBox(width: 12),
                  _buildStatItem(
                    icon: Icons.favorite_outline_rounded,
                    text: '${_formatNumber(reel.likes)}',
                    size: 13,
                  ),
                  if (reel.metadata.musicTrack != null && reel.metadata.musicTrack!.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    _buildStatItem(
                      icon: Icons.music_note_rounded,
                      text: reel.metadata.musicTrack!,
                      size: 13,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 20,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: size,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
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
                color: color ?? Colors.white,
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
    required double size,
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
        Flexible(
          child:           Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              fontSize: size,
              color: Colors.white.withValues(alpha: 0.85),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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

  void _showOptionsSheet(FirebaseReelModel reel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionItem(Icons.info_outline, 'Reel Info', () {}),
            _buildOptionItem(Icons.flag_outlined, 'Report', () {}),
            _buildOptionItem(Icons.edit, 'Request Re-edit', () {}),
            _buildOptionItem(Icons.delete_outline, 'Delete from Gallery', () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}


