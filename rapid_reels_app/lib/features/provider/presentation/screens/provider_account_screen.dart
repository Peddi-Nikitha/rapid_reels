import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/provider_app_theme.dart';
import '../../../../shared/widgets/provider/provider_action_card.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import 'provider_bank_details_screen.dart';

/// Provider hub: profile shortcuts, bank, policy, logout.
class ProviderAccountScreen extends StatelessWidget {
  const ProviderAccountScreen({super.key, required this.providerId});

  final String providerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProviderAppTheme.wrap(
                    const NotificationsScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProviderActionCard(
            icon: Icons.account_balance_outlined,
            title: 'Bank & payout details',
            subtitle: 'Where we send your earnings',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProviderAppTheme.wrap(
                    ProviderBankDetailsScreen(providerId: providerId),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          ProviderActionCard(
            icon: Icons.storefront_outlined,
            title: 'Business profile',
            subtitle: 'Update studio name, bio, and media',
            onTap: () => context.push(AppRoutes.providerBusinessProfile),
          ),
          const SizedBox(height: 12),
          ProviderActionCard(
            icon: Icons.collections_outlined,
            title: 'Event catalogue',
            subtitle: 'Offerings and packages',
            onTap: () =>
                context.push('${AppRoutes.providerCatalogue}/$providerId'),
          ),
          const SizedBox(height: 12),
          ProviderActionCard(
            icon: Icons.verified_outlined,
            title: 'Verification',
            subtitle: 'Documents and approval status',
            onTap: () => context.push(AppRoutes.providerVerification),
          ),
          const SizedBox(height: 12),
          ProviderActionCard(
            icon: Icons.policy_outlined,
            title: 'Refund & cancellation policy',
            subtitle: 'View policy',
            onTap: () => context.push(AppRoutes.refundCancellationPolicy),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(AppRoutes.providerLogin);
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
