import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/admin/admin_access_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/firebase/models/firebase_review_model.dart';
import '../../../../core/firebase/services/firestore_service.dart';

class AdminReviewsModerationScreen extends ConsumerStatefulWidget {
  const AdminReviewsModerationScreen({super.key});

  @override
  ConsumerState<AdminReviewsModerationScreen> createState() =>
      _AdminReviewsModerationScreenState();
}

class _AdminReviewsModerationScreenState
    extends ConsumerState<AdminReviewsModerationScreen> {
  final _firestoreService = FirestoreService();

  int _refreshKey = 0;

  Future<List<FirebaseReviewModel>> _fetch(String status) {
    return _firestoreService.getReviewsForAdmin(status: status, limit: 200);
  }

  void _showModerateDialog(FirebaseReviewModel review) {
    String newStatus = review.status;
    bool isPublic = review.isPublic;

    String? titlePreview = (review.title ?? '').trim().isNotEmpty
        ? review.title
        : (review.comment ?? '').trim().isNotEmpty
            ? review.comment
            : review.response ?? '';

    const statusOptions = ['pending', 'approved', 'rejected', 'hidden'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text('Moderate Review'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Review ID: ${review.reviewId}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    if (titlePreview != null && titlePreview.isNotEmpty)
                      Text(
                        titlePreview,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: newStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                      ),
                      items: statusOptions
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setDialogState(() => newStatus = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: isPublic,
                      onChanged: (v) {
                        setDialogState(() => isPublic = v);
                      },
                      title: const Text('Public'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _firestoreService.updateReview(
                        review.reviewId,
                        {
                          'status': newStatus,
                          'isPublic': isPublic,
                        },
                      );
                      if (!mounted) return;
                      Navigator.pop(context);
                      setState(() {
                        _refreshKey++;
                      });
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Update failed: $e')),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildList(String status) {
    final access = ref.watch(hasAdminPanelAccessProvider);
    if (access == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (access == false) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'You do not have access to Review Moderation.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return FutureBuilder<List<FirebaseReviewModel>>(
      key: ValueKey('reviews-$status-$_refreshKey'),
      future: _fetch(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Failed to load reviews: ${snapshot.error}'),
            ),
          );
        }

        final reviews = snapshot.data ?? const [];
        if (reviews.isEmpty) {
          return const Center(
            child: Text(
              'No reviews found',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            final previewText = (review.comment ??
                    review.title ??
                    review.response ??
                    '')
                .toString()
                .trim();

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Provider: ${review.providerId}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        'Rating: ${review.rating.toStringAsFixed(1)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (previewText.isNotEmpty)
                    Text(
                      previewText,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[800], fontSize: 13),
                    ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text('Status: ${review.status}'),
                      ),
                      Chip(
                        label: Text('Public: ${review.isPublic ? "Yes" : "No"}'),
                      ),
                      Chip(
                        label: Text('Verified: ${review.isVerified ? "Yes" : "No"}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () => _showModerateDialog(review),
                      child: const Text('Moderate'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: const Text(
            'Review Moderation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Approved'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList('pending'),
            _buildList('approved'),
          ],
        ),
      ),
    );
  }
}

