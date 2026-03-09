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
  // Popular venues in Hyderabad area (around Siddipet)
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
  ];

  static List<Venue> getNearbyVenues(double latitude, double longitude, {double radiusKm = 10.0}) {
    return allVenues.where((venue) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        venue.latitude,
        venue.longitude,
      );
      return distance <= radiusKm;
    }).toList()
      ..sort((a, b) {
        final distA = _calculateDistance(latitude, longitude, a.latitude, a.longitude);
        final distB = _calculateDistance(latitude, longitude, b.latitude, b.longitude);
        return distA.compareTo(distB);
      });
  }

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = (dLat / 2) * (dLat / 2) +
        _toRadians(lat1) * _toRadians(lat2) *
        (dLon / 2) * (dLon / 2);
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

