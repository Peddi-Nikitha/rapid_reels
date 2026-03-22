import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/models/firebase_catalogue_event_model.dart';
import '../../data/models/service_provider_model.dart';
import '../utils/booking_flow_maps.dart';

class CatalogueEventDetailScreen extends StatelessWidget {
  final ServiceProvider provider;
  final Map<String, dynamic> bookingData;
  final FirebaseCatalogueEventModel catalogueEvent;

  const CatalogueEventDetailScreen({
    super.key,
    required this.provider,
    required this.bookingData,
    required this.catalogueEvent,
  });

  @override
  Widget build(BuildContext context) {
    final packages = packagesForCatalogue(provider, catalogueEvent);
    final images = <String>[
      if (catalogueEvent.heroImageUrl.isNotEmpty) catalogueEvent.heroImageUrl,
      ...catalogueEvent.galleryImageUrls,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          catalogueEvent.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (images.isNotEmpty)
              SizedBox(
                height: 220,
                child: images.length == 1
                    ? CachedNetworkImage(imageUrl: images.first, fit: BoxFit.cover)
                    : CarouselSlider(
                        options: CarouselOptions(
                          height: 220,
                          viewportFraction: 1,
                          enableInfiniteScroll: images.length > 1,
                          autoPlay: images.length > 1,
                        ),
                        items: images
                            .map(
                              (url) => CachedNetworkImage(
                                imageUrl: url,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                            .toList(),
                      ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    catalogueEvent.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    catalogueEvent.shortDescription,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  if (catalogueEvent.highlights.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Highlights',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...catalogueEvent.highlights.map(
                      (h) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                h,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (catalogueEvent.longDescription.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      catalogueEvent.longDescription,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Choose a package',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (packages.isEmpty)
                    const Text(
                      'No packages linked yet. Ask the provider to attach packages in their catalogue.',
                      style: TextStyle(color: AppColors.textSecondary),
                    )
                  else
                    ...packages.map((p) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => _selectPackage(context, p),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${p.duration ~/ 60}h • ${p.reelsCount} reels',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${p.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectPackage(BuildContext context, PackageOffering p) {
    final m = Map<String, dynamic>.from(bookingData);
    m['package'] = packageOfferingToMap(p);
    m['packageId'] = p.packageId;
    m['catalogueEventId'] = catalogueEvent.catalogueEventId;
    m['catalogueTitle'] = catalogueEvent.title;
    m['catalogueHeroUrl'] = catalogueEvent.heroImageUrl;
    context.push(AppRoutes.packageCustomization, extra: m);
  }
}
