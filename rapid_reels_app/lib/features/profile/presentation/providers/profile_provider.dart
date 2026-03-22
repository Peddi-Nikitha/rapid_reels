import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/firebase/models/firebase_user_model.dart';
import '../../../../core/firebase/models/firebase_booking_model.dart';
import '../../../../core/firebase/models/firebase_reel_model.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// User Profile Provider (autoDispose: signed-out users cannot read their doc; avoid
// retaining PERMISSION_DENIED on the provider when switching accounts.)
final userProfileProvider =
    StreamProvider.autoDispose.family<FirebaseUserModel?, String>(
  (ref, userId) {
    final service = ref.watch(firestoreServiceProvider);
    return service.streamUser(userId);
  },
);

// Recent Bookings Provider (limit 5)
final recentBookingsProvider =
    FutureProvider.autoDispose.family<List<FirebaseBookingModel>, String>(
  (ref, userId) async {
    final service = ref.watch(firestoreServiceProvider);
    final bookings = await service.getUserBookings(userId);
    return bookings.take(5).toList();
  },
);

// Recent Reels Provider (limit 5)
final recentReelsProvider =
    FutureProvider.autoDispose.family<List<FirebaseReelModel>, String>(
  (ref, userId) async {
    final service = ref.watch(firestoreServiceProvider);
    final reels = await service.getUserReels(userId);
    return reels.take(5).toList();
  },
);

// Wallet Balance Provider - Uses walletBalance from user model
final walletBalanceProvider = Provider.autoDispose.family<double, String>(
  (ref, userId) {
    final userAsync = ref.watch(userProfileProvider(userId));
    return userAsync.when(
      data: (user) => user?.walletBalance ?? 0.0,
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );
  },
);

// Real-time counts (avoid relying on stored totals in the user document)
final userBookingsCountProvider =
    StreamProvider.autoDispose.family<int, String>(
  (ref, userId) {
    final service = ref.watch(firestoreServiceProvider);
    return service.streamUserBookingsCount(userId);
  },
);

final userReelsCountProvider = StreamProvider.autoDispose.family<int, String>(
  (ref, userId) {
    final service = ref.watch(firestoreServiceProvider);
    return service.streamUserReelsCount(userId);
  },
);

