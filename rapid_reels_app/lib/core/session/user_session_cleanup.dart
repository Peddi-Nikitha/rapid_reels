import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/my_events/presentation/providers/my_events_provider.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../../features/reels/presentation/providers/my_reels_provider.dart';
import '../../features/reels/presentation/providers/reel_provider.dart';

/// Clears Riverpod caches tied to [userId] on sign-out so Firestore permission
/// errors (e.g. after auth is cleared) are not reused on the next login.
void invalidateUserSessionProviders(WidgetRef ref, String userId) {
  ref.invalidate(userProfileProvider(userId));
  ref.invalidate(recentBookingsProvider(userId));
  ref.invalidate(recentReelsProvider(userId));
  ref.invalidate(walletBalanceProvider(userId));
  ref.invalidate(userBookingsCountProvider(userId));
  ref.invalidate(userReelsCountProvider(userId));
  ref.invalidate(myEventsProvider(userId));
  ref.invalidate(myReelsProvider(userId));
  ref.invalidate(userReelsProvider(userId));
}
