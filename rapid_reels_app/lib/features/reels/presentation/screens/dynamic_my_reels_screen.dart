import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/my_reels_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Dynamic My Reels Screen - Fully integrated with Firebase
/// Grid/list view of user reels with filtering and analytics
class DynamicMyReelsScreen extends ConsumerStatefulWidget {
  const DynamicMyReelsScreen({super.key});

  @override
  ConsumerState<DynamicMyReelsScreen> createState() => _DynamicMyReelsScreenState();
}

class _DynamicMyReelsScreenState extends ConsumerState<DynamicMyReelsScreen> {
  bool _isGridView = true;
  String _selectedStatus = 'all';
  String? _selectedEventType;
  
  final List<String> _statusFilters = ['all', 'processing', 'delivered', 'published'];
  final List<String> _eventTypes = ['all', 'wedding', 'birthday', 'engagement', 'corporate', 'brand'];

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final userId = currentUser?.uid ?? '';

    if (userId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: Text('Please login to view reels'),
        ),
      );
    }

    final filteredReels = ref.watch(
      filteredReelsProvider((
        userId: userId,
        status: _selectedStatus == 'all' ? null : _selectedStatus,
        eventType: _selectedEventType == 'all' ? null : _selectedEventType,
      )),
    );

    final stats = ref.watch(reelStatsProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'My Reels',
          style: AppTypography.headlineSmall,
        ),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myReelsProvider(userId));
        },
        child: CustomScrollView(
          slivers: [
            // Statistics Bar
            _buildStatsBar(stats),
            
            // Filter Chips
            _buildFilterChips(),
            
            // Reels List/Grid
            if (filteredReels.isEmpty)
              _buildEmptyState()
            else if (_isGridView)
              _buildReelsGrid(filteredReels)
            else
              _buildReelsList(filteredReels),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBar(Map<String, dynamic> stats) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', stats['total'] ?? 0),
                _buildStatItem('Views', stats['totalViews'] ?? 0),
                _buildStatItem('Likes', stats['totalLikes'] ?? 0),
                _buildStatItem('Shares', stats['totalShares'] ?? 0),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatChip('Processing', stats['processing'] ?? 0),
                _buildStatChip('Delivered', stats['delivered'] ?? 0),
                _buildStatChip('Published', stats['published'] ?? 0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textPrimary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toString(),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Status',
              style: AppTypography.titleSmall,
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _statusFilters.length,
              itemBuilder: (context, index) {
                final filter = _statusFilters[index];
                final isSelected = _selectedStatus == filter;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      filter.toUpperCase(),
                      style: AppTypography.bodySmall.copyWith(
                        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = filter;
                      });
                    },
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary,
                    checkmarkColor: AppColors.textPrimary,
                  ),
                );
              },
            ),
          ),
          
          // Event Type Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Event Type',
              style: AppTypography.titleSmall,
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _eventTypes.length,
              itemBuilder: (context, index) {
                final type = _eventTypes[index];
                final isSelected = _selectedEventType == type || (_selectedEventType == null && type == 'all');
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      type.toUpperCase(),
                      style: AppTypography.bodySmall.copyWith(
                        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedEventType = type == 'all' ? null : type;
                      });
                    },
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.secondary,
                    checkmarkColor: AppColors.textPrimary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReelsGrid(List reels) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final reel = reels[index];
            return _buildReelGridCard(reel);
          },
          childCount: reels.length,
        ),
      ),
    );
  }

  Widget _buildReelsList(List reels) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final reel = reels[index];
            return _buildReelListCard(reel);
          },
          childCount: reels.length,
        ),
      ),
    );
  }

  Widget _buildReelGridCard(reel) {
    return InkWell(
      onTap: () {
        context.push('${AppRoutes.reelPlayer}/${reel.reelId}');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: reel.thumbnailUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.cardBackground,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    // Status Badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildStatusBadge(reel.status),
                    ),
                    // Duration Badge
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_circle_outline,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDuration(reel.duration),
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reel.title,
                    style: AppTypography.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reel.eventType.toUpperCase(),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildAnalyticsIcon(Icons.visibility, reel.analytics.views),
                      const SizedBox(width: 12),
                      _buildAnalyticsIcon(Icons.favorite, reel.analytics.likes),
                      const SizedBox(width: 12),
                      _buildAnalyticsIcon(Icons.share, reel.analytics.shares),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReelListCard(reel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          context.push('${AppRoutes.reelPlayer}/${reel.reelId}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: reel.thumbnailUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 120,
                        color: AppColors.cardBackground,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: _buildStatusBadge(reel.status),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reel.title,
                      style: AppTypography.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reel.eventType.toUpperCase(),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildAnalyticsIcon(Icons.visibility, reel.analytics.views),
                        const SizedBox(width: 16),
                        _buildAnalyticsIcon(Icons.favorite, reel.analytics.likes),
                        const SizedBox(width: 16),
                        _buildAnalyticsIcon(Icons.share, reel.analytics.shares),
                        const SizedBox(width: 16),
                        _buildAnalyticsIcon(Icons.download, reel.analytics.downloads),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Duration: ${_formatDuration(reel.duration)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_circle_outline),
                    onPressed: () {
                      context.push('${AppRoutes.reelPlayer}/${reel.reelId}');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      context.push('${AppRoutes.reelShare}/${reel.reelId}');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    
    switch (status) {
      case 'processing':
        color = AppColors.warning;
        icon = Icons.hourglass_empty;
        break;
      case 'ready':
        color = AppColors.info;
        icon = Icons.check_circle_outline;
        break;
      case 'delivered':
        color = AppColors.success;
        icon = Icons.done;
        break;
      case 'published':
        color = AppColors.primary;
        icon = Icons.publish;
        break;
      default:
        color = AppColors.textSecondary;
        icon = Icons.help;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsIcon(IconData icon, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          _formatNumber(value),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 24),
            Text(
              'No Reels Found',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedStatus == 'all'
                  ? 'Your reels will appear here once delivered'
                  : 'No ${_selectedStatus} reels',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}:${secs.toString().padLeft(2, '0')}';
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

