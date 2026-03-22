import '../../../../core/firebase/models/firebase_catalogue_event_model.dart';
import '../../data/models/service_provider_model.dart';

Map<String, dynamic> packageOfferingToMap(PackageOffering p) {
  return {
    'packageId': p.packageId,
    'name': p.name,
    'price': p.price,
    'duration': p.duration,
    'reelsCount': p.reelsCount,
    'editingStyle': p.editingStyle,
    'deliveryTime': p.deliveryTime,
    'highlightVideo': p.highlightVideo,
    'liveReelStation': p.liveReelStation,
    'features': p.features,
  };
}

/// Resolves which packages apply for a catalogue entry; falls back to all provider packages.
List<PackageOffering> packagesForCatalogue(
  ServiceProvider provider,
  FirebaseCatalogueEventModel catalogue,
) {
  if (catalogue.packageIds.isEmpty) return provider.packages;
  final filtered =
      provider.packages.where((x) => catalogue.packageIds.contains(x.packageId)).toList();
  return filtered.isNotEmpty ? filtered : provider.packages;
}
