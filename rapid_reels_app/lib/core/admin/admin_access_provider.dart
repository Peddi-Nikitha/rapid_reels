import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import 'firebase_admin_role.dart';

/// Firestore `userType` admin/superadmin (requires Firebase Auth). `null` while profile loads.
final hasAdminPanelAccessProvider = Provider<bool?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  final async = ref.watch(userProfileProvider(user.uid));
  return async.when(
    data: (u) => isFirestoreAdmin(u),
    loading: () => null,
    error: (_, __) => false,
  );
});
