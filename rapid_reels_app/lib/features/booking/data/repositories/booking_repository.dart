import '../models/event_booking_model.dart';
import '../models/service_provider_model.dart';
import '../../../../core/mock/mock_providers.dart';
import '../../../../core/mock/mock_events.dart';

/// Mock Booking Repository
/// No Firebase - Pure static mock implementation
class BookingRepository {
  // Get service providers by event type and location (Mock)
  Future<List<ServiceProvider>> getProvidersByEventType({
    required String eventType,
    required String city,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return MockProviders.allProviders
        .where((provider) => 
            provider.eventTypes.contains(eventType) &&
            provider.serviceAreas.contains(city) &&
            provider.isActive &&
            provider.isVerified)
        .toList();
  }

  // Get all providers (Mock)
  Future<List<ServiceProvider>> getAllProviders({String? city}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (city != null) {
      return MockProviders.getProvidersByCity(city);
    }
    return MockProviders.allProviders;
  }

  // Get featured providers (Mock)
  Future<List<ServiceProvider>> getFeaturedProviders({String? city}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return MockProviders.allProviders
        .where((provider) => 
            provider.isFeatured &&
            provider.isActive &&
            provider.isVerified &&
            (city == null || provider.serviceAreas.contains(city)))
        .toList();
  }

  // Get provider details by ID (Mock)
  Future<ServiceProvider?> getProviderDetails(String providerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockProviders.getProviderById(providerId);
  }

  // Create a new booking (Mock)
  Future<String> createBooking(EventBooking booking) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulate successful booking creation
    return 'booking_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Get all user bookings (Mock)
  Stream<List<EventBooking>> getUserBookings(String userId) {
    return Stream.value(
      MockEvents.allEvents
          .where((event) => event.customerId == userId)
          .toList(),
    );
  }

  // Get user's upcoming bookings (Mock)
  Stream<List<EventBooking>> getUserUpcomingBookings(String userId) {
    return Stream.value(
      MockEvents.allEvents
          .where((event) => 
              event.customerId == userId &&
              event.status == 'confirmed' &&
              event.eventDate.isAfter(DateTime.now()))
          .toList(),
    );
  }

  // Get user's ongoing bookings (Mock)
  Stream<List<EventBooking>> getUserOngoingBookings(String userId) {
    return Stream.value(
      MockEvents.allEvents
          .where((event) => 
              event.customerId == userId &&
              event.status == 'ongoing')
          .toList(),
    );
  }

  // Get user's past bookings (Mock)
  Stream<List<EventBooking>> getUserPastBookings(String userId) {
    return Stream.value(
      MockEvents.allEvents
          .where((event) => 
              event.customerId == userId &&
              event.status == 'completed')
          .toList(),
    );
  }

  // Get booking by ID (Mock)
  Future<EventBooking?> getBookingById(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockEvents.getEventById(bookingId);
  }

  // Get provider's bookings (Mock)
  Stream<List<EventBooking>> getProviderBookings(String providerId) {
    return Stream.value(
      MockEvents.allEvents
          .where((event) => event.providerId == providerId)
          .toList(),
    );
  }

  // Update booking status (Mock)
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock update - no actual change
  }

  // Cancel booking (Mock)
  Future<void> cancelBooking({
    required String bookingId,
    required String reason,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock cancellation
  }

  // Reschedule booking (Mock)
  Future<void> rescheduleBooking({
    required String bookingId,
    required DateTime newDate,
    required String newTime,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock reschedule
  }

  // Update payment status (Mock)
  Future<void> updatePaymentStatus({
    required String bookingId,
    required String paymentStatus,
    required PaymentRecord payment,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock payment update
  }

  // Provider accept booking (Mock)
  Future<void> acceptBooking(String bookingId) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock accept
  }

  // Provider decline booking (Mock)
  Future<void> declineBooking({
    required String bookingId,
    required String reason,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock decline
  }

  // Start event (Mock)
  Future<void> startEvent(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock start
  }

  // Complete event (Mock)
  Future<void> completeEvent(String bookingId) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock complete
  }
}
