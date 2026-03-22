import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../admin/admin_route_cache.dart';

/// Drives [GoRouter.refreshListenable] so redirects re-run on sign-in/sign-out.
class AuthStateRefreshNotifier extends ChangeNotifier {
  AuthStateRefreshNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) {
      AdminRouteCache.invalidate();
      notifyListeners();
    });
  }

  /// Notifies [GoRouter] (e.g. after toggling static admin session).
  void refresh() => notifyListeners();
}

/// Shared instance used by [GoRouter] and after toggling static admin session.
final appRouterAuthRefresh = AuthStateRefreshNotifier();
