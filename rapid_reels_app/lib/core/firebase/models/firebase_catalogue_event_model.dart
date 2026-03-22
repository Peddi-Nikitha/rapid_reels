import 'package:cloud_firestore/cloud_firestore.dart';

/// Catalogue entry: `providers/{providerId}/catalogue_events/{catalogueEventId}`
class FirebaseCatalogueEventModel {
  final String catalogueEventId;
  final String providerId;
  final String title;
  final String shortDescription;
  final String? slug;
  final String eventType; // wedding, birthday, engagement, corporate, brand
  final String heroImageUrl;
  final List<String> galleryImageUrls;
  final String longDescription;
  final List<String> highlights;
  final List<String> tags;
  /// References [PackageOffering.packageId] on the provider document.
  final List<String> packageIds;
  final bool isPublished;
  final int sortOrder;
  final double? startingPrice;
  final String? durationLabel;
  final DateTime createdAt;
  final DateTime updatedAt;

  FirebaseCatalogueEventModel({
    required this.catalogueEventId,
    required this.providerId,
    required this.title,
    required this.shortDescription,
    this.slug,
    required this.eventType,
    required this.heroImageUrl,
    required this.galleryImageUrls,
    required this.longDescription,
    required this.highlights,
    required this.tags,
    required this.packageIds,
    required this.isPublished,
    required this.sortOrder,
    this.startingPrice,
    this.durationLabel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FirebaseCatalogueEventModel.fromFirestore(
    DocumentSnapshot doc,
    String providerId,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebaseCatalogueEventModel(
      catalogueEventId: doc.id,
      providerId: providerId,
      title: data['title'] ?? '',
      shortDescription: data['shortDescription'] ?? '',
      slug: data['slug'],
      eventType: data['eventType'] ?? 'wedding',
      heroImageUrl: data['heroImageUrl'] ?? '',
      galleryImageUrls: List<String>.from(data['galleryImageUrls'] ?? []),
      longDescription: data['longDescription'] ?? '',
      highlights: List<String>.from(data['highlights'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      packageIds: List<String>.from(data['packageIds'] ?? []),
      isPublished: data['isPublished'] == true,
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      startingPrice: (data['startingPrice'] as num?)?.toDouble(),
      durationLabel: data['durationLabel'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'shortDescription': shortDescription,
      'slug': slug,
      'eventType': eventType,
      'heroImageUrl': heroImageUrl,
      'galleryImageUrls': galleryImageUrls,
      'longDescription': longDescription,
      'highlights': highlights,
      'tags': tags,
      'packageIds': packageIds,
      'isPublished': isPublished,
      'sortOrder': sortOrder,
      'startingPrice': startingPrice,
      'durationLabel': durationLabel,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  FirebaseCatalogueEventModel copyWith({
    String? title,
    String? shortDescription,
    String? slug,
    String? eventType,
    String? heroImageUrl,
    List<String>? galleryImageUrls,
    String? longDescription,
    List<String>? highlights,
    List<String>? tags,
    List<String>? packageIds,
    bool? isPublished,
    int? sortOrder,
    double? startingPrice,
    String? durationLabel,
    DateTime? updatedAt,
  }) {
    return FirebaseCatalogueEventModel(
      catalogueEventId: catalogueEventId,
      providerId: providerId,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      slug: slug ?? this.slug,
      eventType: eventType ?? this.eventType,
      heroImageUrl: heroImageUrl ?? this.heroImageUrl,
      galleryImageUrls: galleryImageUrls ?? this.galleryImageUrls,
      longDescription: longDescription ?? this.longDescription,
      highlights: highlights ?? this.highlights,
      tags: tags ?? this.tags,
      packageIds: packageIds ?? this.packageIds,
      isPublished: isPublished ?? this.isPublished,
      sortOrder: sortOrder ?? this.sortOrder,
      startingPrice: startingPrice ?? this.startingPrice,
      durationLabel: durationLabel ?? this.durationLabel,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
