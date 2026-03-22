import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/admin/admin_route_cache.dart';
import '../../../../core/admin/static_admin_session_provider.dart';
import '../../../../core/router/router_refresh_notifier.dart';
import '../../../../core/session/user_session_cleanup.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';

class UnauthorizedScreen extends ConsumerWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 72,
                color: AppColors.error.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 24),
              const Text(
                'Unauthorized Access',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This area is restricted to administrators. '
                'If you believe this is a mistake, contact support.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    ref.read(staticAdminSessionProvider.notifier).state = false;
                    AdminRouteCache.invalidate();
                    appRouterAuthRefresh.refresh();
                    try {
                      await FirebaseAuth.instance.signOut();
                    } catch (_) {}
                    if (uid != null) {
                      invalidateUserSessionProviders(ref, uid);
                    }
                    if (context.mounted) {
                      context.go(AppRoutes.login);
                    }
                  },
                  child: const Text('Back to login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
