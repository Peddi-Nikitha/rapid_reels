import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/firebase/models/firebase_catalogue_event_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';

class ProviderCatalogueListScreen extends StatelessWidget {
  final String providerId;

  const ProviderCatalogueListScreen({
    super.key,
    required this.providerId,
  });

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Event catalogue'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(
          '${AppRoutes.providerCatalogueEdit}/$providerId/new',
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('New'),
      ),
      body: StreamBuilder<List<FirebaseCatalogueEventModel>>(
        stream: firestore.streamCatalogueEvents(providerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_note, size: 56, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    const Text(
                      'No catalogue entries yet. Create one with photos, copy, and linked packages so customers can book.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => context.push(
                        '${AppRoutes.providerCatalogueEdit}/$providerId/new',
                      ),
                      child: const Text('Create first entry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final e = items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${e.eventType} • ${e.isPublished ? "Published" : "Draft"}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Switch(
                    value: e.isPublished,
                    onChanged: (v) => firestore.updateCatalogueEventPublish(providerId, e.catalogueEventId, v),
                  ),
                  onTap: () => context.push(
                    '${AppRoutes.providerCatalogueEdit}/$providerId/${e.catalogueEventId}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
