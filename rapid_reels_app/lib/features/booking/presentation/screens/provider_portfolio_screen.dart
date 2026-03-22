import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/models/firebase_reel_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../features/booking/data/models/service_provider_model.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/rating_stars.dart';
import '../../../../shared/widgets/reel_card.dart';

class ProviderPortfolioScreen extends StatelessWidget {
  final ServiceProvider provider;
  final Map<String, dynamic> bookingData;

  const ProviderPortfolioScreen({
    super.key,
    required this.provider,
    required this.bookingData,
  });

  @override
  Widget build(BuildContext context) {
    final useProviderPortfolio = provider.portfolio.isNotEmpty;
    return useProviderPortfolio
        ? _PortfolioContent(
            provider: provider,
            bookingData: bookingData,
            reelsFromProvider: true,
            portfolioCount: provider.portfolio.length,
          )
        : FutureBuilder<List<FirebaseReelModel>>(
            future: FirestoreService().getProviderReels(provider.providerId),
            builder: (context, snapshot) {
              final reels = snapshot.data ?? [];
              return _PortfolioContent(
                provider: provider,
                bookingData: bookingData,
                reelsFromProvider: false,
                portfolioCount: reels.length,
                firebaseReels: reels,
              );
            },
          );
  }
}

class _PortfolioContent extends StatelessWidget {
  final ServiceProvider provider;
  final Map<String, dynamic> bookingData;
  final bool reelsFromProvider;
  final int portfolioCount;
  final List<FirebaseReelModel>? firebaseReels;

  const _PortfolioContent({
    required this.provider,
    required this.bookingData,
    required this.reelsFromProvider,
    required this.portfolioCount,
    this.firebaseReels,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Cover Images or profile image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: provider.coverImages.isNotEmpty
                  ? CarouselSlider(
                      items: provider.coverImages.map((url) {
                        return CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: AppColors.surface,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.surface,
                            child: const Icon(Icons.image, size: 48),
                          ),
                        );
                      }).toList(),
                      options: CarouselOptions(
                        height: 300,
                        viewportFraction: 1.0,
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 3),
                      ),
                    )
                  : provider.profileImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: provider.profileImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: AppColors.surface,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.surface,
                            child: const Icon(Icons.person, size: 48),
                          ),
                        )
                      : Container(color: AppColors.surface),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Provider Info
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              provider.businessName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (provider.isVerified)
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.info,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          RatingStars(rating: provider.rating, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '(${provider.totalReviews} reviews)',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        provider.bio,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Stats Row
                      Row(
                        children: [
                          _buildStatItem(
                            Icons.event,
                            '${provider.totalEventsCompleted}+',
                            'Events',
                          ),
                          const SizedBox(width: 24),
                          _buildStatItem(
                            Icons.video_library,
                            '${provider.totalReelsDelivered}+',
                            'Reels',
                          ),
                          const SizedBox(width: 24),
                          _buildStatItem(
                            Icons.timer,
                            '${provider.averageDeliveryTime}m',
                            'Avg. Time',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Equipment
                      if (provider.equipment.isNotEmpty) ...[
                        const Text(
                          'Equipment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: provider.equipment.map((item) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.camera_alt,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Service Areas
                      const Text(
                        'Service Areas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: provider.serviceAreas.map((area) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              area,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      
                      // Portfolio - dynamic from provider.portfolio or mock
                      if (portfolioCount > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Portfolio',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: reelsFromProvider
                              ? ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: provider.portfolio.length,
                                  itemBuilder: (context, index) {
                                    final item = provider.portfolio[index];
                                    final thumbUrl = item.thumbnailUrl.isNotEmpty
                                        ? item.thumbnailUrl
                                        : item.videoUrl;
                                    return Container(
                                      width: 150,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: _PortfolioThumbCard(
                                        imageUrl: thumbUrl,
                                        eventType: item.eventType,
                                        views: item.views,
                                      ),
                                    );
                                  },
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: firebaseReels?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final reel = firebaseReels![index];
                                    return Container(
                                      width: 150,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: ReelCard(
                                        reel: reel,
                                        showStats: true,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: CustomButton(
            text: 'Book ${provider.businessName}',
            onPressed: () {
              context.push(
                AppRoutes.catalogueSelection,
                extra: {
                  'provider': provider,
                  'bookingData': bookingData,
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PortfolioThumbCard extends StatelessWidget {
  final String imageUrl;
  final String eventType;
  final int views;

  const _PortfolioThumbCard({
    required this.imageUrl,
    required this.eventType,
    required this.views,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.cardBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.surface,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.surface,
                            child: const Icon(Icons.video_library, size: 40),
                          ),
                        )
                      : Container(
                          color: AppColors.surface,
                          child: const Icon(Icons.video_library, size: 40),
                        ),
                ),
                const Center(
                  child: Icon(
                    Icons.play_circle_filled,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventType,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${views >= 1000 ? '${(views / 1000).toStringAsFixed(1)}K' : views} views',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

