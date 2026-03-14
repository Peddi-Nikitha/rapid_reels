import 'dart:math';

class Venue {
  final String venueId;
  final String name;
  final String address;
  final String city;
  final String pincode;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final double? rating;
  final int? reviewCount;
  final String? venueType; // wedding, corporate, outdoor, etc.
  final int? capacity;

  Venue({
    required this.venueId,
    required this.name,
    required this.address,
    required this.city,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.rating,
    this.reviewCount,
    this.venueType,
    this.capacity,
  });
}

class MockVenues {
  // Popular venues in Hyderabad & Siddipet area (India) + sample UK venues
  static final List<Venue> allVenues = [
    Venue(
      venueId: 'venue_001',
      name: 'Green Gardens Convention Hall',
      address: '123, Main Road, Film Nagar',
      city: 'Hyderabad',
      pincode: '500096',
      latitude: 17.3850,
      longitude: 78.4867,
      imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
      rating: 4.5,
      reviewCount: 120,
      venueType: 'wedding',
      capacity: 500,
    ),
    Venue(
      venueId: 'venue_002',
      name: 'Royal Palace Banquet',
      address: '456, Jubilee Hills',
      city: 'Hyderabad',
      pincode: '500033',
      latitude: 17.4225,
      longitude: 78.4075,
      imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
      rating: 4.8,
      reviewCount: 89,
      venueType: 'wedding',
      capacity: 800,
    ),
    Venue(
      venueId: 'venue_003',
      name: 'Grand Ballroom Events',
      address: '789, Banjara Hills',
      city: 'Hyderabad',
      pincode: '500034',
      latitude: 17.4486,
      longitude: 78.3908,
      imageUrl: 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800',
      rating: 4.6,
      reviewCount: 156,
      venueType: 'corporate',
      capacity: 300,
    ),
    Venue(
      venueId: 'venue_004',
      name: 'Sunset Terrace',
      address: '321, Hitech City',
      city: 'Hyderabad',
      pincode: '500081',
      latitude: 17.4486,
      longitude: 78.3908,
      imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
      rating: 4.7,
      reviewCount: 203,
      venueType: 'outdoor',
      capacity: 400,
    ),
    Venue(
      venueId: 'venue_005',
      name: 'Elegant Events Center',
      address: '654, Gachibowli',
      city: 'Hyderabad',
      pincode: '500032',
      latitude: 17.4225,
      longitude: 78.4075,
      imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
      rating: 4.4,
      reviewCount: 98,
      venueType: 'wedding',
      capacity: 600,
    ),
    Venue(
      venueId: 'venue_006',
      name: 'Crystal Hall',
      address: '987, Secunderabad',
      city: 'Hyderabad',
      pincode: '500003',
      latitude: 17.4399,
      longitude: 78.4983,
      imageUrl: 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800',
      rating: 4.9,
      reviewCount: 234,
      venueType: 'corporate',
      capacity: 250,
    ),
    // Venues in Siddipet area
    Venue(
      venueId: 'venue_007',
      name: 'Siddipet Grand Hall',
      address: 'Main Road, Siddipet',
      city: 'Siddipet',
      pincode: '502103',
      latitude: 18.1023,
      longitude: 78.8514,
      imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
      rating: 4.3,
      reviewCount: 67,
      venueType: 'wedding',
      capacity: 400,
    ),
    Venue(
      venueId: 'venue_008',
      name: 'Community Center',
      address: 'Near Bus Stand, Siddipet',
      city: 'Siddipet',
      pincode: '502103',
      latitude: 18.1050,
      longitude: 78.8550,
      imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
      rating: 4.2,
      reviewCount: 45,
      venueType: 'corporate',
      capacity: 200,
    ),
    Venue(
      venueId: 'venue_009',
      name: 'Garden Party Venue',
      address: 'Outskirts, Siddipet',
      city: 'Siddipet',
      pincode: '502103',
      latitude: 18.1000,
      longitude: 78.8500,
      imageUrl: 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800',
      rating: 4.6,
      reviewCount: 89,
      venueType: 'outdoor',
      capacity: 500,
    ),
    // More venues in Siddipet area
    Venue(
      venueId: 'venue_010',
      name: 'Siddipet Function Hall',
      address: 'Near Railway Station, Siddipet',
      city: 'Siddipet',
      pincode: '502103',
      latitude: 18.1030,
      longitude: 78.8520,
      imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
      rating: 4.4,
      reviewCount: 56,
      venueType: 'wedding',
      capacity: 350,
    ),
    Venue(
      venueId: 'venue_011',
      name: 'Grand Banquet Hall',
      address: 'Market Road, Siddipet',
      city: 'Siddipet',
      pincode: '502103',
      latitude: 18.1040,
      longitude: 78.8530,
      imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
      rating: 4.5,
      reviewCount: 78,
      venueType: 'wedding',
      capacity: 450,
    ),
    Venue(
      venueId: 'venue_012',
      name: 'Royal Function Hall',
      address: 'City Center, Siddipet',
      city: 'Siddipet',
      pincode: '502103',
      latitude: 18.1015,
      longitude: 78.8510,
      imageUrl: 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800',
      rating: 4.7,
      reviewCount: 92,
      venueType: 'wedding',
      capacity: 500,
    ),
    Venue(
      venueId: 'venue_013',
      name: 'Celebration Banquet',
      address: 'New Colony, Siddipet',
      city: 'Siddipet',
      pincode: '502103',
      latitude: 18.1060,
      longitude: 78.8540,
      imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
      rating: 4.3,
      reviewCount: 64,
      venueType: 'wedding',
      capacity: 300,
    ),
    Venue(
      venueId: 'venue_014',
      name: 'Elite Convention Center',
      address: 'Highway Road, Siddipet',
      city: 'Siddipet',
      pincode: '502103',
      latitude: 18.0990,
      longitude: 78.8490,
      imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
      rating: 4.6,
      reviewCount: 85,
      venueType: 'corporate',
      capacity: 400,
    ),
    // ========== UK Venues (London & nearby) ==========
    Venue(
      venueId: 'venue_101',
      name: 'London Grand Ballroom',
      address: '1 Westminster Bridge Road, London',
      city: 'London',
      pincode: 'SE1 7PB',
      latitude: 51.5007,
      longitude: -0.1246,
      imageUrl: 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800',
      rating: 4.7,
      reviewCount: 210,
      venueType: 'wedding',
      capacity: 400,
    ),
    Venue(
      venueId: 'venue_102',
      name: 'Riverbank Banquet Hall',
      address: '10 Southbank, London',
      city: 'London',
      pincode: 'SE1 9PU',
      latitude: 51.5079,
      longitude: -0.0994,
      imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
      rating: 4.5,
      reviewCount: 160,
      venueType: 'corporate',
      capacity: 300,
    ),
    Venue(
      venueId: 'venue_103',
      name: 'Hyde Park Pavilion',
      address: 'Hyde Park Corner, London',
      city: 'London',
      pincode: 'W2 2UH',
      latitude: 51.5074,
      longitude: -0.1657,
      imageUrl: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
      rating: 4.6,
      reviewCount: 185,
      venueType: 'outdoor',
      capacity: 500,
    ),
    Venue(
      venueId: 'venue_104',
      name: 'Canary Wharf Conference Center',
      address: '25 Bank Street, Canary Wharf, London',
      city: 'London',
      pincode: 'E14 5JP',
      latitude: 51.5054,
      longitude: -0.0235,
      imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
      rating: 4.8,
      reviewCount: 240,
      venueType: 'corporate',
      capacity: 600,
    ),
    Venue(
      venueId: 'venue_105',
      name: 'Royal Garden Banquet',
      address: 'Kensington High Street, London',
      city: 'London',
      pincode: 'W8 4PT',
      latitude: 51.5010,
      longitude: -0.1924,
      imageUrl: 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800',
      rating: 4.4,
      reviewCount: 140,
      venueType: 'wedding',
      capacity: 350,
    ),
    // ========== London Photography Studios ==========
    Venue(
      venueId: 'venue_photo_ldn_001',
      name: 'Arch Photo Studio – Camberwell',
      address: 'Arch 267 Urlwin Street, Camberwell, London SE5 0NG',
      city: 'London',
      pincode: 'SE5 0NG',
      latitude: 51.4820554,
      longitude: -0.0957964,
      imageUrl: 'https://images.unsplash.com/photo-1516031190-1ef4d3cb1d43?w=800&q=80',
      rating: 4.6,
      reviewCount: 95,
      venueType: 'photography',
      capacity: null,
    ),
    Venue(
      venueId: 'venue_photo_ldn_002',
      name: 'Flash Studios – East London',
      address: '12 Cody Road, London E16 4SR',
      city: 'London',
      pincode: 'E16 4SR',
      latitude: 51.5147,
      longitude: 0.0192,
      imageUrl: 'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=800&q=80',
      rating: 4.5,
      reviewCount: 82,
      venueType: 'photography',
      capacity: null,
    ),
    Venue(
      venueId: 'venue_photo_ldn_003',
      name: 'Shoot Studio – North Kensington',
      address: 'Unit 1, 3 Latimer Place, London W10 6QT',
      city: 'London',
      pincode: 'W10 6QT',
      latitude: 51.5217,
      longitude: -0.2295,
      imageUrl: 'https://images.unsplash.com/photo-1516031190-1ef4d3cb1d43?w=800&q=80',
      rating: 4.7,
      reviewCount: 110,
      venueType: 'photography',
      capacity: null,
    ),
    Venue(
      venueId: 'venue_photo_ldn_004',
      name: '69 Drops Studios – Whitechapel',
      address: '77 Greenfield Road, Whitechapel, London E1 1EJ',
      city: 'London',
      pincode: 'E1 1EJ',
      latitude: 51.5155,
      longitude: -0.0616,
      imageUrl: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=800&q=80',
      rating: 4.8,
      reviewCount: 134,
      venueType: 'photography',
      capacity: null,
    ),
    Venue(
      venueId: 'venue_photo_ldn_005',
      name: 'Inspire Studios – Walthamstow',
      address: '255 Hoe Street, London E17 9PT',
      city: 'London',
      pincode: 'E17 9PT',
      latitude: 51.5884,
      longitude: -0.0197,
      imageUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800&q=80',
      rating: 4.4,
      reviewCount: 73,
      venueType: 'photography',
      capacity: null,
    ),
    // ========== Siddipet Photography Studios ==========
    Venue(
      venueId: 'venue_photo_001',
      name: 'Smiley Baby Studio – Siddipet',
      address: 'Housing Board Colony, Siddipet',
      city: 'Siddipet',
      pincode: '502103',
      latitude: 18.1017,
      longitude: 78.8486,
      imageUrl: 'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=800&q=80',
      rating: 4.6,
      reviewCount: 89,
      venueType: 'photography',
      capacity: null,
    ),
    Venue(
      venueId: 'venue_photo_002',
      name: 'RajaRani Studio – Siddipet',
      address: 'Kalakunta Colony, Siddipet',
      city: 'Siddipet',
      pincode: '502103',
      latitude: 18.1029,
      longitude: 78.8523,
      imageUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=800&q=80',
      rating: 4.5,
      reviewCount: 76,
      venueType: 'photography',
      capacity: null,
    ),
    Venue(
      venueId: 'venue_photo_003',
      name: 'R K Photo Studio – Siddipet',
      address: 'Azampura, Siddipet',
      city: 'Siddipet',
      pincode: '502103',
      latitude: 18.1043,
      longitude: 78.8509,
      imageUrl: 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800&q=80',
      rating: 4.4,
      reviewCount: 65,
      venueType: 'photography',
      capacity: null,
    ),
    Venue(
      venueId: 'venue_photo_004',
      name: 'Creative Kids Studio – Siddipet',
      address: 'Hyderabad Road, Siddipet',
      city: 'Siddipet',
      pincode: '502103',
      latitude: 18.0998,
      longitude: 78.8561,
      imageUrl: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800&q=80',
      rating: 4.7,
      reviewCount: 102,
      venueType: 'photography',
      capacity: null,
    ),
    Venue(
      venueId: 'venue_photo_005',
      name: 'Sree Ram Portrait Studio',
      address: 'Prashanth Nagar, Siddipet',
      city: 'Siddipet',
      pincode: '502103',
      latitude: 18.0979,
      longitude: 78.8534,
      imageUrl: 'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=800&q=80',
      rating: 4.3,
      reviewCount: 54,
      venueType: 'photography',
      capacity: null,
    ),
  ];

  static List<Venue> getNearbyVenues(double latitude, double longitude, {double radiusKm = 10.0}) {
    // Calculate distance for all venues
    final venuesWithDistance = allVenues.map((venue) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        venue.latitude,
        venue.longitude,
      );
      return {'venue': venue, 'distance': distance};
    }).toList();

    // Filter venues within radius
    var nearbyVenues = venuesWithDistance
        .where((item) => item['distance'] as double <= radiusKm)
        .map((item) => item['venue'] as Venue)
        .toList();

    // If no venues found within radius, return closest 6 venues
    if (nearbyVenues.isEmpty) {
      venuesWithDistance.sort((a, b) {
        return (a['distance'] as double).compareTo(b['distance'] as double);
      });
      nearbyVenues = venuesWithDistance
          .take(6)
          .map((item) => item['venue'] as Venue)
          .toList();
    } else {
      // Sort by distance
      nearbyVenues.sort((a, b) {
        final distA = _calculateDistance(latitude, longitude, a.latitude, a.longitude);
        final distB = _calculateDistance(latitude, longitude, b.latitude, b.longitude);
        return distA.compareTo(distB);
      });
    }

    return nearbyVenues;
  }

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (3.141592653589793 / 180.0);
  }

  static Venue? getVenueById(String venueId) {
    try {
      return allVenues.firstWhere((venue) => venue.venueId == venueId);
    } catch (e) {
      return null;
    }
  }
}

