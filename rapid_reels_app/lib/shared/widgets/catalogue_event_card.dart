import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/firebase/models/firebase_catalogue_event_model.dart';

class CatalogueEventCard extends StatelessWidget {
  final FirebaseCatalogueEventModel event;
  final VoidCallback? onTap;

  const CatalogueEventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hero = event.heroImageUrl.isNotEmpty
        ? event.heroImageUrl
        : (event.galleryImageUrls.isNotEmpty ? event.galleryImageUrls.first : null);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 140,
                child: hero != null
                    ? CachedNetworkImage(
                        imageUrl: hero,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: AppColors.surface),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          child: const Icon(Icons.event, size: 48, color: AppColors.primary),
                        ),
                      )
                    : Container(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        child: const Icon(Icons.event, size: 48, color: AppColors.primary),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event.shortDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            event.eventType,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (event.startingPrice != null)
                          Text(
                            'from £${event.startingPrice!.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
