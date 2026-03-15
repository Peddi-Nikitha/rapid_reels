import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/firebase/models/firebase_booking_model.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

// My Events Provider - Stream of all user bookings
final myEventsProvider = StreamProvider.family<List<FirebaseBookingModel>, String>(
  (ref, userId) {
    final service = ref.watch(firestoreServiceProvider);
    return service.streamUserBookings(userId);
  },
);

// Filtered Events Provider
final filteredEventsProvider = Provider.family<List<FirebaseBookingModel>, ({String userId, String? status})>(
  (ref, params) {
    final eventsAsync = ref.watch(myEventsProvider(params.userId));
    return eventsAsync.when(
      data: (events) {
        if (params.status == null || params.status == 'all') return events;
        return events.where((e) => e.status == params.status).toList();
      },
      loading: () => [],
      error: (_, __) => [],
    );
  },
);

// Search Events Provider
final searchEventsProvider = Provider.family<List<FirebaseBookingModel>, ({String userId, String query})>(
  (ref, params) {
    final eventsAsync = ref.watch(myEventsProvider(params.userId));
    return eventsAsync.when(
      data: (events) {
        if (params.query.isEmpty) return events;
        final query = params.query.toLowerCase();
        return events.where((e) {
          return e.eventName.toLowerCase().contains(query) ||
              e.eventType.toLowerCase().contains(query) ||
              e.venue.name.toLowerCase().contains(query) ||
              e.venue.city.toLowerCase().contains(query);
        }).toList();
      },
      loading: () => [],
      error: (_, __) => [],
    );
  },
);

// Event Statistics Provider
final eventStatsProvider = Provider.family<Map<String, int>, String>(
  (ref, userId) {
    final eventsAsync = ref.watch(myEventsProvider(userId));
    return eventsAsync.when(
      data: (events) {
        return {
          'total': events.length,
          'upcoming': events.where((e) => e.eventDate.isAfter(DateTime.now()) && e.status != 'cancelled').length,
          'ongoing': events.where((e) => e.status == 'ongoing').length,
          'completed': events.where((e) => e.status == 'completed').length,
          'cancelled': events.where((e) => e.status == 'cancelled').length,
        };
      },
      loading: () => {'total': 0, 'upcoming': 0, 'ongoing': 0, 'completed': 0, 'cancelled': 0},
      error: (_, __) => {'total': 0, 'upcoming': 0, 'ongoing': 0, 'completed': 0, 'cancelled': 0},
    );
  },
);

