import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/config/stripe_test_package.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/models/service_provider_model.dart';
import '../utils/booking_flow_maps.dart';

/// When a provider has no catalogue (or user skips), pick one of their [ServiceProvider.packages].
class ProviderPackagePickScreen extends StatelessWidget {
  final ServiceProvider provider;
  final Map<String, dynamic> bookingData;

  const ProviderPackagePickScreen({
    super.key,
    required this.provider,
    required this.bookingData,
  });

  @override
  Widget build(BuildContext context) {
    final packages = packagesWithStripeTest(provider.packages);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Choose a package'),
      body: packages.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'This provider has not added packages yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final p = packages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        final m = Map<String, dynamic>.from(bookingData);
                        m['package'] = packageOfferingToMap(p);
                        m['packageId'] = p.packageId;
                        context.push(AppRoutes.packageCustomization, extra: m);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${p.duration ~/ 60}h • ${p.reelsCount} reels',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              StripeTestPackage.formatListedPrice(p),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
