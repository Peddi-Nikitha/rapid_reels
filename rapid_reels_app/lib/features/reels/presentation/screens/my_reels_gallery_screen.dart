import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/models/firebase_reel_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/reel_card.dart';
import '../../../../shared/widgets/empty_state.dart';

class MyReelsGalleryScreen extends StatefulWidget {
  const MyReelsGalleryScreen({super.key});

  @override
  State<MyReelsGalleryScreen> createState() => _MyReelsGalleryScreenState();
}

class _MyReelsGalleryScreenState extends State<MyReelsGalleryScreen> {
  final _firestoreService = FirestoreService();
  String _selectedFilter = 'all';
  String _sortBy = 'newest';

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'My Reels', showBackButton: false),
        body: const Center(child: Text('Please log in to view your reels')),
      );
    }

    return FutureBuilder<List<FirebaseReelModel>>(
      future: _firestoreService.getUserReels(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: const CustomAppBar(title: 'My Reels', showBackButton: false),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        var reels = snapshot.data ?? [];

        // Apply filter
        if (_selectedFilter != 'all') {
          reels = reels.where((r) => r.eventType == _selectedFilter).toList();
        }

        // Apply sorting
        final reelsList = reels.toList();
        if (_sortBy == 'newest') {
          reelsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } else if (_sortBy == 'oldest') {
          reelsList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        } else if (_sortBy == 'mostViewed') {
          reelsList.sort((a, b) => b.views.compareTo(a.views));
        }
        reels = reelsList;

        // Group by eventType
        final groupedReels = <String, List<FirebaseReelModel>>{};
        for (var reel in reels) {
          groupedReels.putIfAbsent(reel.eventType, () => []).add(reel);
        }

        return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'My Reels',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Wedding', 'wedding'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Birthday', 'birthday'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Engagement', 'engagement'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Corporate', 'corporate'),
                ],
              ),
            ),
          ),
          
          // Stats Summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _buildStatBox(
                  '${reels.length}',
                  'Total Reels',
                  Icons.video_library,
                ),
                const SizedBox(width: 12),
                _buildStatBox(
                  '${reels.fold<int>(0, (sum, r) => sum + r.views)}',
                  'Total Views',
                  Icons.visibility,
                ),
                const SizedBox(width: 12),
                _buildStatBox(
                  '${reels.fold<int>(0, (sum, r) => sum + r.likes)}',
                  'Total Likes',
                  Icons.favorite,
                ),
              ],
            ),
          ),
          
          Expanded(
            child: reels.isEmpty
                ? EmptyState(
                    icon: Icons.video_library,
                    title: 'No Reels Yet',
                    message: 'Book an event to start receiving instant reels',
                    buttonText: 'Book Event',
                    onButtonPressed: () {
                      context.push(AppRoutes.eventTypeSelection);
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: groupedReels.length,
                    itemBuilder: (context, index) {
                      final eventType = groupedReels.keys.elementAt(index);
                      final eventReels = groupedReels[eventType]!;
                      final eventName = eventType.isEmpty
                          ? 'Other'
                          : '${eventType[0].toUpperCase()}${eventType.substring(1)}';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Event Header
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$eventName Reels',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${eventReels.length} reels',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text('View Event'),
                                ),
                              ],
                            ),
                          ),
                          
                          // Reels Grid
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: eventReels.length,
                            itemBuilder: (context, reelIndex) {
                              final reel = eventReels[reelIndex];
                              return ReelCard(
                                reel: reel,
                                onTap: () {
                                  context.push(
                                    AppRoutes.reelPlayer,
                                    extra: {
                                      'reelId': reel.reelId,
                                      'reels': eventReels,
                                      'initialIndex': reelIndex,
                                    },
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildSortOption('Newest First', 'newest', setModalState),
              _buildSortOption('Oldest First', 'oldest', setModalState),
              _buildSortOption('Most Viewed', 'mostViewed', setModalState),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value, StateSetter setModalState) {
    final isSelected = _sortBy == value;
    return RadioListTile<String>(
      value: value,
      groupValue: _sortBy,
      onChanged: (val) {
        setModalState(() {
          _sortBy = val!;
        });
      },
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }
}

