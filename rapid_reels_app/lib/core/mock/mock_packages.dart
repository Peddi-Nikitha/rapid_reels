import '../../features/booking/data/models/service_provider_model.dart';

class MockPackages {
  static final List<PackageOffering> allPackages = [
    bronze,
    silver,
    gold,
    platinum,
  ];

  static final PackageOffering bronze = PackageOffering(
    packageId: 'pkg_bronze',
    name: 'Bronze',
    price: 100,
    duration: 120, // 2 hours
    reelsCount: 1,
    editingStyle: 'basic',
    deliveryTime: 120, // 2 hours
    highlightVideo: false,
    liveReelStation: false,
    features: [
      '2-hour coverage',
      '1 instant reel (30-60 sec)',
      'Basic editing',
      'Delivered in 2 hours',
      'HD quality (1080p)',
      '1 professional videographer',
    ],
  );

  static final PackageOffering silver = PackageOffering(
    packageId: 'pkg_silver',
    name: 'Silver',
    price: 300,
    duration: 240, // 4 hours
    reelsCount: 3,
    editingStyle: 'standard',
    deliveryTime: 60, // 1 hour
    highlightVideo: false,
    liveReelStation: false,
    features: [
      '4-hour coverage',
      '3 instant reels',
      'Standard editing with transitions',
      'Delivered in 1 hour',
      'HD quality (1080p)',
      '1 professional videographer',
      'Background music included',
    ],
  );

  static final PackageOffering gold = PackageOffering(
    packageId: 'pkg_gold',
    name: 'Gold',
    price: 500,
    duration: 360, // 6 hours
    reelsCount: 5,
    editingStyle: 'premium',
    deliveryTime: 30, // 30 minutes
    highlightVideo: true,
    liveReelStation: false,
    features: [
      '6-hour coverage',
      '5 instant reels + 1 highlight video (2-3 min)',
      'Premium editing with effects',
      'Instant delivery',
      'Full edited video next day',
      '4K quality',
      '2 professional videographers',
      'Cinematic effects',
      'Custom music selection',
    ],
  );

  static final PackageOffering platinum = PackageOffering(
    packageId: 'pkg_platinum',
    name: 'Platinum',
    price: 1500,
    duration: 600, // 10 hours (full day)
    reelsCount: -1, // unlimited
    editingStyle: 'cinematic',
    deliveryTime: 15, // 15 minutes
    highlightVideo: true,
    liveReelStation: false,
    features: [
      'Full-day coverage (10 hours)',
      'Unlimited instant reels',
      'Cinematic editing',
      'Instant delivery',
      'Full edited video same day',
      '4K quality',
      '3 professional videographers',
      'Professional lighting setup',
      'Same-day full video delivery',
    ],
  );

  static PackageOffering? getPackageById(String packageId) {
    try {
      return allPackages.firstWhere((pkg) => pkg.packageId == packageId);
    } catch (e) {
      return null;
    }
  }

  static String getPackageDescription(String packageId) {
    switch (packageId) {
      case 'pkg_bronze':
        return 'Perfect for small gatherings and intimate moments';
      case 'pkg_silver':
        return 'Ideal for birthday parties and small celebrations';
      case 'pkg_gold':
        return 'Most popular! Perfect for weddings and large events';
      case 'pkg_platinum':
        return 'Premium coverage with live reel station and unlimited reels';
      default:
        return '';
    }
  }
}

