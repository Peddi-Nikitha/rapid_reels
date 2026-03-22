import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/models/firebase_catalogue_event_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../shared/widgets/catalogue_event_card.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../data/models/service_provider_model.dart';
import 'catalogue_event_detail_screen.dart';

/// After choosing a provider: pick a published catalogue entry for the current [eventType], or fall back to package-only flow.
class CatalogueSelectionScreen extends StatelessWidget {
  final ServiceProvider provider;
  final Map<String, dynamic> bookingData;

  const CatalogueSelectionScreen({
    super.key,
    required this.provider,
    required this.bookingData,
  });

  List<FirebaseCatalogueEventModel> _filterForFlow(
    List<FirebaseCatalogueEventModel> all,
    String? eventType,
  ) {
    final t = eventType ?? '';
    return all
        .where((e) => e.isPublished && (t.isEmpty || e.eventType == t))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Widget build(BuildContext context) {
    final eventType = bookingData['eventType'] as String?;
    final firestore = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Choose an offering'),
      body: StreamBuilder<List<FirebaseCatalogueEventModel>>(
        stream: firestore.streamCatalogueEvents(provider.providerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load offerings: ${snapshot.error}'),
              ),
            );
          }
          final filtered = _filterForFlow(snapshot.data ?? [], eventType);

          if (filtered.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 56, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  const Text(
                    'This provider has no published catalogue entries for your event type yet. You can continue with their standard packages.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Choose a package',
                    onPressed: () => context.push(
                      AppRoutes.providerPackagePick,
                      extra: {'provider': provider, 'bookingData': bookingData},
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: filtered.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Select how you want this ${eventType ?? 'event'} covered — or skip to packages.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                );
              }
              final item = filtered[index - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CatalogueEventCard(
                  event: item,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (ctx) => CatalogueEventDetailScreen(
                          provider: provider,
                          bookingData: bookingData,
                          catalogueEvent: item,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: TextButton(
            onPressed: () => context.push(
              AppRoutes.providerPackagePick,
              extra: {'provider': provider, 'bookingData': bookingData},
            ),
            child: const Text('Skip to standard packages'),
          ),
        ),
      ),
    );
  }
}
