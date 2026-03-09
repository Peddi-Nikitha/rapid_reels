import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/mock_data_service.dart';
import '../../../../shared/widgets/shimmer_loading.dart';

class TrendingReelsScreen extends StatefulWidget {
  const TrendingReelsScreen({super.key});

  @override
  State<TrendingReelsScreen> createState() => _TrendingReelsScreenState();
}

class _TrendingReelsScreenState extends State<TrendingReelsScreen>
    with SingleTickerProviderStateMixin {
  final _mockData = MockDataService();
  late TabController _tabController;
  String _selectedPeriod = 'today';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reels = _mockData.getPublicReels()
      ..sort((a, b) => b.views.compareTo(a.views));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Trending Reels',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'This Week'),
            Tab(text: 'This Month'),
            Tab(text: 'All Time'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Pills
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPeriodChip('Today', 'today'),
                  const SizedBox(width: 8),
                  _buildPeriodChip('This Week', 'week'),
                  const SizedBox(width: 8),
                  _buildPeriodChip('This Month', 'month'),
                  const SizedBox(width: 8),
                  _buildPeriodChip('All Time', 'all'),
                ],
              ),
            ),
          ),
          
          // Trending Reels Grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReelsGrid(reels),
                _buildReelsGrid(reels),
                _buildReelsGrid(reels),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReelsGrid(List reels) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 9 / 16,
      ),
      itemCount: reels.length,
      itemBuilder: (context, index) {
        final reel = reels[index];
        final provider = _mockData.getProviderById(reel.providerId);
        final rank = index + 1;

        return GestureDetector(
          onTap: () {
            context.push(
              AppRoutes.reelPlayer,
              extra: {'reel': reel},
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.surface,
            ),
            child: Stack(
              children: [
                // Thumbnail
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: reel.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerLoading(
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
                
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                ),
                
                // Rank Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: rank <= 3
                          ? AppColors.primary
                          : Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (rank <= 3)
                          Icon(
                            rank == 1
                                ? Icons.emoji_events
                                : rank == 2
                                    ? Icons.military_tech
                                    : Icons.star,
                            size: 14,
                            color: Colors.white,
                          ),
                        if (rank <= 3) const SizedBox(width: 4),
                        Text(
                          '#$rank',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Info
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        reel.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      
                      // Provider
                      if (provider != null)
                        Text(
                          provider.businessName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 6),
                      
                      // Stats
                      Row(
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 12,
                            color: Colors.white60,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatNumber(reel.views),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.favorite,
                            size: 12,
                            color: Colors.white60,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatNumber(reel.likes),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Play Icon
                Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey,
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
}

