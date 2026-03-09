import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event_booking_model.dart';
import '../../data/models/service_provider_model.dart';
import '../../data/repositories/booking_repository.dart';

// Repository Provider
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository();
});

// Get Providers by Event Type
final providersProvider = FutureProvider.family<List<ServiceProvider>, Map<String, String>>((ref, params) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getProvidersByEventType(
    eventType: params['eventType']!,
    city: params['city']!,
  );
});

// Get All Providers
final allProvidersProvider = FutureProvider.family<List<ServiceProvider>, String?>((ref, city) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getAllProviders(city: city);
});

// Get Featured Providers
final featuredProvidersProvider = FutureProvider.family<List<ServiceProvider>, String?>((ref, city) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getFeaturedProviders(city: city);
});

// Get Provider Details
final providerDetailsProvider = FutureProvider.family<ServiceProvider?, String>((ref, providerId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getProviderDetails(providerId);
});

// User Bookings Stream
final userBookingsProvider = StreamProvider.family<List<EventBooking>, String>((ref, userId) {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getUserBookings(userId);
});

// User Upcoming Bookings Stream
final userUpcomingBookingsProvider = StreamProvider.family<List<EventBooking>, String>((ref, userId) {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getUserUpcomingBookings(userId);
});

// User Past Bookings Stream
final userPastBookingsProvider = StreamProvider.family<List<EventBooking>, String>((ref, userId) {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getUserPastBookings(userId);
});

// Get Booking by ID
final bookingByIdProvider = FutureProvider.family<EventBooking?, String>((ref, bookingId) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getBookingById(bookingId);
});

// Provider Bookings Stream (for provider app)
final providerBookingsProvider = StreamProvider.family<List<EventBooking>, String>((ref, providerId) {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getProviderBookings(providerId);
});

// Booking Creation State Notifier
class BookingNotifier extends StateNotifier<AsyncValue<String?>> {
  final BookingRepository _repository;

  BookingNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<String?> createBooking(EventBooking booking) async {
    state = const AsyncValue.loading();
    try {
      final bookingId = await _repository.createBooking(booking);
      state = AsyncValue.data(bookingId);
      return bookingId;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _repository.updateBookingStatus(bookingId: bookingId, status: status);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> cancelBooking(String bookingId, String reason) async {
    try {
      await _repository.cancelBooking(bookingId: bookingId, reason: reason);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> rescheduleBooking({
    required String bookingId,
    required DateTime newDate,
    required String newTime,
  }) async {
    try {
      await _repository.rescheduleBooking(
        bookingId: bookingId,
        newDate: newDate,
        newTime: newTime,
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updatePaymentStatus({
    required String bookingId,
    required String paymentStatus,
    required PaymentRecord payment,
  }) async {
    try {
      await _repository.updatePaymentStatus(
        bookingId: bookingId,
        paymentStatus: paymentStatus,
        payment: payment,
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final bookingNotifierProvider = StateNotifierProvider<BookingNotifier, AsyncValue<String?>>((ref) {
  return BookingNotifier(ref.watch(bookingRepositoryProvider));
});

// Provider-side Actions Notifier
class ProviderBookingNotifier extends StateNotifier<AsyncValue<void>> {
  final BookingRepository _repository;

  ProviderBookingNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> acceptBooking(String bookingId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.acceptBooking(bookingId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> declineBooking(String bookingId, String reason) async {
    state = const AsyncValue.loading();
    try {
      await _repository.declineBooking(bookingId: bookingId, reason: reason);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> startEvent(String bookingId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.startEvent(bookingId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> completeEvent(String bookingId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.completeEvent(bookingId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final providerBookingNotifierProvider = StateNotifierProvider<ProviderBookingNotifier, AsyncValue<void>>((ref) {
  return ProviderBookingNotifier(ref.watch(bookingRepositoryProvider));
});

