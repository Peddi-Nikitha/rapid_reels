import '../mock/mock_users.dart';
import '../mock/mock_providers.dart';
import '../mock/mock_events.dart';
import '../mock/mock_reels.dart';
import '../mock/mock_packages.dart';
import '../mock/mock_venues.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/booking/data/models/service_provider_model.dart';
import '../../features/booking/data/models/event_booking_model.dart';

/// Central service for managing all mock data
/// This simulates backend API calls with realistic data
class MockDataService {
  // Singleton pattern
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  // Current logged-in user
  UserModel get currentUser => MockUsers.currentUser;

  // ========== User Data ==========
  
  UserModel? getUserById(String userId) {
    return MockUsers.getUserById(userId);
  }

  List<UserModel> getAllUsers() {
    return MockUsers.allUsers;
  }

  // ========== Provider Data ==========
  
  List<ServiceProvider> getAllProviders() {
    return MockProviders.allProviders;
  }

  ServiceProvider? getProviderById(String providerId) {
    return MockProviders.getProviderById(providerId);
  }

  List<ServiceProvider> getProvidersByCity(String city) {
    return MockProviders.getProvidersByCity(city);
  }

  List<ServiceProvider> getFeaturedProviders() {
    return MockProviders.getFeaturedProviders();
  }

  List<ServiceProvider> getProvidersByEventType(String eventType, String city) {
    return MockProviders.allProviders
        .where((provider) =>
            provider.eventTypes.contains(eventType) &&
            provider.serviceAreas.contains(city))
        .toList();
  }

  List<ServiceProvider> searchProviders({
    String? query,
    String? city,
    String? eventType,
    double? minRating,
    double? maxPrice,
  }) {
    var results = MockProviders.allProviders;

    if (city != null) {
      results = results
          .where((p) => p.serviceAreas.contains(city))
          .toList();
    }

    if (eventType != null) {
      results = results
          .where((p) => p.eventTypes.contains(eventType))
          .toList();
    }

    if (minRating != null) {
      results = results
          .where((p) => p.rating >= minRating)
          .toList();
    }

    if (query != null && query.isNotEmpty) {
      results = results
          .where((p) =>
              p.businessName.toLowerCase().contains(query.toLowerCase()) ||
              p.ownerName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    return results;
  }

  // ========== Package Data ==========
  
  List<PackageOffering> getAllPackages() {
    return MockPackages.allPackages;
  }

  PackageOffering? getPackageById(String packageId) {
    return MockPackages.getPackageById(packageId);
  }

  String getPackageDescription(String packageId) {
    return MockPackages.getPackageDescription(packageId);
  }

  // ========== Event/Booking Data ==========
  
  List<EventBooking> getAllEvents() {
    return MockEvents.allEvents;
  }

  EventBooking? getEventById(String eventId) {
    return MockEvents.getEventById(eventId);
  }

  List<EventBooking> getUserEvents(String userId) {
    return MockEvents.getUserEvents(userId);
  }

  List<EventBooking> getUpcomingEvents(String userId) {
    return MockEvents.getUpcomingEvents(userId);
  }

  List<EventBooking> getLiveEvents(String userId) {
    return MockEvents.getLiveEvents(userId);
  }

  List<EventBooking> getPastEvents(String userId) {
    return MockEvents.getPastEvents(userId);
  }

  List<EventBooking> getProviderEvents(String providerId) {
    return MockEvents.getProviderEvents(providerId);
  }

  // ========== Reel Data ==========
  
  List<ReelModel> getAllReels() {
    return MockReels.allReels;
  }

  ReelModel? getReelById(String reelId) {
    return MockReels.getReelById(reelId);
  }

  List<ReelModel> getEventReels(String eventId) {
    return MockReels.getEventReels(eventId);
  }

  List<ReelModel> getUserReels(String userId) {
    return MockReels.getUserReels(userId);
  }

  List<ReelModel> getPublicReels() {
    return MockReels.getPublicReels();
  }

  List<ReelModel> getTrendingReels() {
    return MockReels.getTrendingReels();
  }

  // ========== Statistics & Analytics ==========
  
  Map<String, dynamic> getUserStats(String userId) {
    final events = getUserEvents(userId);
    final reels = getUserReels(userId);
    
    return {
      'totalBookings': events.length,
      'upcomingBookings': events.where((e) => e.eventDate.isAfter(DateTime.now())).length,
      'completedBookings': events.where((e) => e.status == 'completed').length,
      'totalReels': reels.length,
      'totalSpent': events.fold<double>(0, (sum, event) => sum + event.totalAmount),
      'walletBalance': currentUser.walletBalance,
    };
  }

  Map<String, dynamic> getProviderStats(String providerId) {
    final events = getProviderEvents(providerId);
    final reels = MockReels.allReels.where((r) => r.providerId == providerId).toList();
    
    return {
      'totalBookings': events.length,
      'pendingBookings': events.where((e) => e.status == 'pending').length,
      'confirmedBookings': events.where((e) => e.status == 'confirmed').length,
      'completedBookings': events.where((e) => e.status == 'completed').length,
      'totalReels': reels.length,
      'totalEarnings': events
          .where((e) => e.paymentStatus == 'fully_paid')
          .fold<double>(0, (sum, event) => sum + (event.totalAmount * 0.85)), // After 15% commission
      'averageRating': MockProviders.getProviderById(providerId)?.rating ?? 0.0,
    };
  }

  // ========== Referral Data (Mock) ==========
  
  List<Map<String, dynamic>> getUserReferrals(String userId) {
    return [
      {
        'referredUser': 'Amit Patel',
        'status': 'completed',
        'reward': 200.0,
        'date': DateTime.now().subtract(const Duration(days: 30)),
      },
      {
        'referredUser': 'Sneha Reddy',
        'status': 'pending',
        'reward': 200.0,
        'date': DateTime.now().subtract(const Duration(days: 15)),
      },
    ];
  }

  List<Map<String, dynamic>> getWalletTransactions(String userId) {
    return [
      {
        'type': 'credit',
        'amount': 200.0,
        'description': 'Referral bonus for inviting Amit',
        'date': DateTime.now().subtract(const Duration(days: 30)),
      },
      {
        'type': 'debit',
        'amount': 500.0,
        'description': 'Applied to booking #event_001',
        'date': DateTime.now().subtract(const Duration(days: 60)),
      },
      {
        'type': 'credit',
        'amount': 300.0,
        'description': 'Referral bonus for inviting Priya',
        'date': DateTime.now().subtract(const Duration(days: 90)),
      },
    ];
  }

  // ========== Search & Filter ==========
  
  List<ReelModel> searchReels(String query) {
    return MockReels.allReels
        .where((reel) =>
            reel.title.toLowerCase().contains(query.toLowerCase()) ||
            reel.description.toLowerCase().contains(query.toLowerCase()) ||
            reel.eventType.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<ReelModel> filterReelsByEventType(String eventType) {
    return MockReels.allReels
        .where((reel) => reel.eventType == eventType)
        .toList();
  }

  // ========== Mock Actions (Simulate API calls) ==========
  
  Future<bool> createBooking(EventBooking booking) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    // In a real app, this would save to backend
    MockEvents.allEvents.add(booking);
    return true;
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real app, this would update backend
    return true;
  }

  Future<bool> cancelBooking(String bookingId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<bool> likeReel(String reelId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Future<bool> shareReel(String reelId, String platform) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<bool> downloadReel(String reelId) async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  // ========== Venue Data ==========
  
  List<Venue> getNearbyVenues(double latitude, double longitude, {double radiusKm = 10.0}) {
    return MockVenues.getNearbyVenues(latitude, longitude, radiusKm: radiusKm);
  }

  Venue? getVenueById(String venueId) {
    return MockVenues.getVenueById(venueId);
  }

  List<Venue> getAllVenues() {
    return MockVenues.allVenues;
  }
}

