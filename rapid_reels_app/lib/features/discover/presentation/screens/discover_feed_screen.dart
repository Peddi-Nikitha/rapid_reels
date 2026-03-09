import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../core/theme/text_styles.dart';

class DiscoverFeedScreen extends StatefulWidget {
  const DiscoverFeedScreen({super.key});

  @override
  State<DiscoverFeedScreen> createState() => _DiscoverFeedScreenState();
}

class _DiscoverFeedScreenState extends State<DiscoverFeedScreen> {
  final _mockData = MockDataService();
  late PageController _pageController;
  String _selectedFilter = 'all';
  final Map<String, bool> _followedCreators = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var reels = _mockData.getPublicReels();
    if (_selectedFilter != 'all') {
      reels = reels.where((r) => r.eventType == _selectedFilter).toList();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vertical Scrolling Reels (TikTok Style)
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: reels.length,
            itemBuilder: (context, index) {
              final reel = reels[index];
              final provider = _mockData.getProviderById(reel.providerId);
              
              return Stack(
                children: [
                  // Reel Background - Image Thumbnail
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: reel.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surface,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.surface,
                        child: const Icon(Icons.error_outline, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  
                  // Refined Gradient Overlay
                  Positioned.fill(
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
                  
                  // Action Buttons (Right Side) - Compact and Professional
                  Positioned(
                    right: 12,
                    bottom: 120,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(
                          Icons.favorite_border_rounded,
                          _formatNumber(reel.likes),
                          () {},
                        ),
                        const SizedBox(height: 20),
                        _buildActionButton(
                          Icons.comment_rounded,
                          '0',
                          () {},
                        ),
                        const SizedBox(height: 20),
                        _buildActionButton(
                          Icons.share_rounded,
                          _formatNumber(reel.shares),
                          () {},
                        ),
                        const SizedBox(height: 20),
                        _buildActionButton(
                          Icons.bookmark_border_rounded,
                          'Save',
                          () {},
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
                              context.push(
                                AppRoutes.providerPortfolio,
                                extra: {
                                  'provider': provider,
                                  'bookingData': {},
                                },
                              );
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
                          reel.description,
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
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _showSearchSheet,
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
                        child: const Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
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
        onTap: () => setState(() => _selectedFilter = value),
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

  void _showSearchSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search reels...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

