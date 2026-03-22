import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/firebase/models/firebase_reel_model.dart';
import '../../../core/firebase/services/firestore_service.dart';
import '../../../core/theme/text_styles.dart';

/// Shared like / share / comment flows for reel surfaces (player, discover, home).
class ReelEngagement {
  ReelEngagement._();

  static Future<void> toggleLike({
    required BuildContext context,
    required String? userId,
    required FirebaseReelModel reel,
    required FirestoreService firestore,
    required bool previousLiked,
    required void Function(bool liked) setLikedDisplay,
    required void Function(FirebaseReelModel? fresh) onSynced,
  }) async {
    if (userId == null || userId.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to like reels.')),
      );
      return;
    }

    setLikedDisplay(!previousLiked);

    try {
      final backendLiked = await firestore.toggleReelLike(
        reelId: reel.reelId,
        userId: userId,
      );
      setLikedDisplay(backendLiked);
      final fresh = await firestore.getReel(reel.reelId);
      onSynced(fresh);
    } catch (_) {
      setLikedDisplay(previousLiked);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update like right now.')),
      );
    }
  }

  static Future<void> shareReel({
    required BuildContext context,
    required FirebaseReelModel reel,
    required FirestoreService firestore,
    required void Function(FirebaseReelModel? fresh) onSynced,
  }) async {
    final deepLink = 'https://rapidreels.app/reel/${reel.reelId}';
    await Clipboard.setData(ClipboardData(text: deepLink));
    if (!context.mounted) return;

    try {
      await firestore.incrementReelShares(reel.reelId);
      final fresh = await firestore.getReel(reel.reelId);
      onSynced(fresh);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update share count right now.')),
      );
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reel link copied. Share it with others.')),
    );
  }

  static Future<void> showCommentsSheet({
    required BuildContext context,
    required String reelId,
    required String? userId,
    required FirestoreService firestore,
    required void Function(FirebaseReelModel? fresh) onSynced,
  }) async {
    if (userId == null || userId.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to comment on reels.')),
      );
      return;
    }

    final textController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            minChildSize: 0.45,
            initialChildSize: 0.65,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                    child: Row(
                      children: [
                        Text(
                          'Comments',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<ReelCommentDocument>>(
                      stream: firestore.streamReelComments(reelId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final items = snapshot.data ?? [];
                        if (items.isEmpty) {
                          return Center(
                            child: Text(
                              'No comments yet.\nBe the first to comment.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: items.length,
                          itemBuilder: (context, i) {
                            final c = items[i];
                            return ListTile(
                              contentPadding: const EdgeInsets.only(bottom: 8),
                              title: Text(
                                c.userId.length > 8
                                    ? '${c.userId.substring(0, 8)}…'
                                    : c.userId,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(c.text),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: textController,
                            maxLines: 3,
                            minLines: 1,
                            decoration: const InputDecoration(
                              hintText: 'Write a comment…',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () async {
                            final t = textController.text.trim();
                            if (t.isEmpty) return;
                            try {
                              await firestore.addReelComment(
                                reelId: reelId,
                                userId: userId,
                                commentText: t,
                              );
                              textController.clear();
                              final fresh = await firestore.getReel(reelId);
                              if (sheetContext.mounted) onSynced(fresh);
                            } catch (_) {
                              if (!sheetContext.mounted) return;
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not post comment right now.'),
                                ),
                              );
                            }
                          },
                          child: const Text('Post'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    textController.dispose();
  }
}
