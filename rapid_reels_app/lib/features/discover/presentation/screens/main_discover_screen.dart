import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/mock_data_service.dart';

/// Main Discover Screen - TikTok-style vertical feed
class MainDiscoverScreen extends ConsumerStatefulWidget {
  const MainDiscoverScreen({super.key});

  @override
  ConsumerState<MainDiscoverScreen> createState() => _MainDiscoverScreenState();
}

class _MainDiscoverScreenState extends ConsumerState<MainDiscoverScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, bool> _followedCreators = {};
  final _mockData = MockDataService();

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reels = MockDataService().getTrendingReels();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _buildPremiumTabBar(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showSearchBottomSheet(),
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
          ),
        ],
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: reels.length,
        itemBuilder: (context, index) {
          final reel = reels[index];
          return _buildReelPage(reel, index);
        },
      ),
    );
  }

  Widget _buildReelPage(dynamic reel, int index) {
    final provider = _mockData.getProviderById(reel.providerId);
    final isFollowing = _followedCreators[reel.providerId] ?? false;
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background gradient (simulating video)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getEventColor(reel.eventType).withOpacity(0.3),
                AppColors.background,
                _getEventColor(reel.eventType).withOpacity(0.4),
              ],
            ),
          ),
        ),

        // Thumbnail - Using image from reel
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: reel.thumbnailUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColors.surface,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.surface,
              child: Icon(
                _getEventIcon(reel.eventType),
                size: 60,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),

        // Gradient Overlay
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
                    reel.description,
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
                      _buildStatChip(Icons.visibility_outlined, '${_formatCount(reel.views)}'),
                      const SizedBox(width: 10),
                      _buildStatChip(Icons.favorite_border_rounded, '${_formatCount((reel.views * 0.12).toInt())}'),
                      const SizedBox(width: 10),
                      _buildStatChip(Icons.share_rounded, '${_formatCount((reel.views * 0.05).toInt())}'),
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
                Icons.favorite_border_rounded,
                '${(reel.views * 0.12).toInt()}',
                AppColors.primary,
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                Icons.comment_rounded,
                '${(reel.views * 0.08).toInt()}',
                Colors.white,
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                Icons.share_rounded,
                'Share',
                Colors.white,
              ),
              const SizedBox(height: 20),
              _buildActionButton(
                Icons.bookmark_border_rounded,
                'Save',
                Colors.white,
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

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
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
                color: color,
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

  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search reels, providers, events...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Trending Searches',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildTrendingSearchItem('Wedding Reels', Icons.favorite, '1.2K'),
                        _buildTrendingSearchItem('Birthday Celebrations', Icons.cake, '890'),
                        _buildTrendingSearchItem('Corporate Events', Icons.business, '654'),
                        _buildTrendingSearchItem('Engagement Ceremony', Icons.diamond, '543'),
                        _buildTrendingSearchItem('Brand Collaborations', Icons.handshake, '432'),
                        const SizedBox(height: 20),
                        const Text(
                          'Popular Providers',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildProviderSearchItem('Creative Reels Studio', '4.8', '250+ events'),
                        _buildProviderSearchItem('Moment Makers', '4.9', '180+ events'),
                        _buildProviderSearchItem('RapidCut Productions', '4.7', '320+ events'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTrendingSearchItem(String title, IconData icon, String count) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: Text(
        '$count reels',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _buildProviderSearchItem(String name, String rating, String events) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary,
        child: Text(
          name.substring(0, 1),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Row(
        children: [
          Icon(Icons.star, size: 14, color: Colors.amber),
          const SizedBox(width: 4),
          Text(rating),
          const SizedBox(width: 12),
          Text(events),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}

