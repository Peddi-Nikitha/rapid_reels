import 'package:cloud_firestore/cloud_firestore.dart';

/// One-off helper to insert some sample providers with packages
/// into the `providers` collection for local/dev usage.
///
/// Call this from a debug-only screen or a temporary button.
Future<void> seedSampleProviders() async {
  final db = FirebaseFirestore.instance;
  final now = DateTime.now();

  // Basic day availability (all days open with a single 8h slot).
  Map<String, dynamic> _defaultAvailability() {
    final slot = {
      'startTime': '10:00',
      'endTime': '18:00',
      'slotDuration': 60,
    };
    return {
      'monday': {'isOpen': true, 'slots': [slot]},
      'tuesday': {'isOpen': true, 'slots': [slot]},
      'wednesday': {'isOpen': true, 'slots': [slot]},
      'thursday': {'isOpen': true, 'slots': [slot]},
      'friday': {'isOpen': true, 'slots': [slot]},
      'saturday': {'isOpen': true, 'slots': [slot]},
      'sunday': {'isOpen': true, 'slots': [slot]},
    };
  }

  final providers = <Map<String, dynamic>>[
    {
      'providerId': 'demo_provider_1',
      'businessName': 'Golden Frames Studio',
      'ownerName': 'Arjun Mehta',
      'email': 'goldenframes@example.com',
      'phoneNumber': '+91 90000 00001',
      'profileImage':
          'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800',
      'coverImages': [
        'https://images.unsplash.com/photo-1518895949257-7621c3c786d4?w=800',
        'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800',
      ],
      'bio':
          'Premium wedding and event reel specialists with a cinematic style and same‑day delivery.',
      'eventTypes': ['wedding', 'engagement', 'birthday'],
      'packages': [
        {
          'packageId': 'pkg_gold',
          'name': 'Gold Wedding Package',
          'price': 34999.0,
          'duration': 240, // minutes
          'reelsCount': 6,
          'editingStyle': 'cinematic',
          'deliveryTime': 60, // minutes
          'highlightVideo': true,
          'liveReelStation': true,
          'features': [
            '4 hours on‑site coverage',
            'Up to 6 vertical reels',
            'Cinematic color grading',
            'One highlight montage',
            'Same‑day delivery for 3 reels',
          ],
        },
        {
          'packageId': 'pkg_silver',
          'name': 'Silver Wedding Package',
          'price': 24999.0,
          'duration': 180,
          'reelsCount': 4,
          'editingStyle': 'modern',
          'deliveryTime': 90,
          'highlightVideo': false,
          'liveReelStation': false,
          'features': [
            '3 hours on‑site coverage',
            'Up to 4 vertical reels',
            'Basic color correction',
            'Delivery within 24 hours',
          ],
        },
      ],
      'portfolio': [],
      'location': {
        'address': 'Banjara Hills',
        'city': 'Hyderabad',
        'state': 'Telangana',
        'pincode': '500034',
        'coordinates': {
          'latitude': 17.4156,
          'longitude': 78.4483,
        },
      },
      'serviceAreas': ['Hyderabad', 'Secunderabad'],
      'serviceRadius': 50,
      'teamSize': 3,
      'equipment': ['Sony A7S III', 'Gimbal', 'LED lights', 'Lavalier mics'],
      'rating': 4.8,
      'totalReviews': 42,
      'totalEventsCompleted': 120,
      'totalReelsDelivered': 650,
      'averageDeliveryTime': 90,
      'availability': _defaultAvailability(),
      'blockedDates': [],
      'bankDetails': null,
      'commissionRate': 10.0,
      'isVerified': true,
      'isActive': true,
      'isFeatured': true,
      'verificationStatus': 'approved',
      'rejectionReason': null,
      'createdAt': now,
      'updatedAt': now,
      'metadata': {
        'seed': true,
      },
    },
    {
      'providerId': 'demo_provider_2',
      'businessName': 'Urban Reels Co.',
      'ownerName': 'Sara Khan',
      'email': 'urbanreels@example.com',
      'phoneNumber': '+91 90000 00002',
      'profileImage':
          'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800',
      'coverImages': [
        'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800',
      ],
      'bio':
          'Fast‑turnaround reels for birthdays, brands, and corporate events with a modern style.',
      'eventTypes': ['birthday', 'corporate', 'brand'],
      'packages': [
        {
          'packageId': 'pkg_birthday_modern',
          'name': 'Birthday Highlights',
          'price': 9999.0,
          'duration': 120,
          'reelsCount': 3,
          'editingStyle': 'modern',
          'deliveryTime': 60,
          'highlightVideo': false,
          'liveReelStation': true,
          'features': [
            '2 hours coverage',
            '3 reels optimised for Instagram',
            'Trendy transitions & music sync',
          ],
        },
        {
          'packageId': 'pkg_corporate_premium',
          'name': 'Corporate Launch',
          'price': 44999.0,
          'duration': 300,
          'reelsCount': 8,
          'editingStyle': 'cinematic',
          'deliveryTime': 120,
          'highlightVideo': true,
          'liveReelStation': true,
          'features': [
            '5 hours coverage',
            'Up to 8 reels',
            'Event highlight film',
            'On‑site review monitor',
          ],
        },
      ],
      'portfolio': [],
      'location': {
        'address': 'Madhapur',
        'city': 'Hyderabad',
        'state': 'Telangana',
        'pincode': '500081',
        'coordinates': {
          'latitude': 17.4483,
          'longitude': 78.3915,
        },
      },
      'serviceAreas': ['Hyderabad'],
      'serviceRadius': 30,
      'teamSize': 4,
      'equipment': ['Canon R5', 'Drone', 'Gimbal', 'Audio recorder'],
      'rating': 4.6,
      'totalReviews': 25,
      'totalEventsCompleted': 60,
      'totalReelsDelivered': 300,
      'averageDeliveryTime': 120,
      'availability': _defaultAvailability(),
      'blockedDates': [],
      'bankDetails': null,
      'commissionRate': 12.0,
      'isVerified': true,
      'isActive': true,
      'isFeatured': false,
      'verificationStatus': 'approved',
      'rejectionReason': null,
      'createdAt': now,
      'updatedAt': now,
      'metadata': {
        'seed': true,
      },
    },
  ];

  final batch = db.batch();

  for (final provider in providers) {
    final id = provider['providerId'] as String;
    final ref = db.collection('providers').doc(id);
    batch.set(ref, provider, SetOptions(merge: true));
  }

  await batch.commit();
}

