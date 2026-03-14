import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/firebase/models/firebase_user_model.dart';
import '../../../../core/firebase/models/firebase_booking_model.dart';
import '../../../../core/firebase/models/firebase_reel_model.dart';
import '../../../../core/firebase/models/firebase_wallet_model.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// User Profile Provider
final userProfileProvider = StreamProvider.family<FirebaseUserModel?, String>(
  (ref, userId) {
    final service = ref.watch(firestoreServiceProvider);
    return service.streamUser(userId);
  },
);

// Recent Bookings Provider (limit 5)
final recentBookingsProvider = FutureProvider.family<List<FirebaseBookingModel>, String>(
  (ref, userId) async {
    final service = ref.watch(firestoreServiceProvider);
    final bookings = await service.getUserBookings(userId);
    return bookings.take(5).toList();
  },
);

// Recent Reels Provider (limit 5)
final recentReelsProvider = FutureProvider.family<List<FirebaseReelModel>, String>(
  (ref, userId) async {
    final service = ref.watch(firestoreServiceProvider);
    final reels = await service.getUserReels(userId);
    return reels.take(5).toList();
  },
);

// Wallet Balance Provider - Uses walletBalance from user model
final walletBalanceProvider = Provider.family<double, String>(
  (ref, userId) {
    final userAsync = ref.watch(userProfileProvider(userId));
    return userAsync.when(
      data: (user) => user?.walletBalance ?? 0.0,
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );
  },
);

