import 'package:firebase_auth/firebase_auth.dart';

import '../firebase/services/firestore_service.dart';
import 'firebase_admin_role.dart';

/// Caches Firestore admin role for [GoRouter.redirect] and invalidates on auth changes.
class AdminRouteCache {
  AdminRouteCache._();

  static String? _cachedUid;
  static bool? _isAdmin;

  static void invalidate() {
    _cachedUid = null;
    _isAdmin = null;
  }

  /// Whether the current Firebase user has admin/superadmin `userType` in Firestore.
  static Future<bool> isCurrentUserAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      invalidate();
      return false;
    }
    if (_cachedUid == user.uid && _isAdmin != null) {
      return _isAdmin!;
    }
    final profile = await FirestoreService().getUser(user.uid);
    final admin = isFirestoreAdmin(profile);
    _cachedUid = user.uid;
    _isAdmin = admin;
    return admin;
  }
}
