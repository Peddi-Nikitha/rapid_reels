import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/reel_viewer_screen.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/firebase/models/firebase_reel_model.dart';
import '../../../../core/firebase/models/firebase_provider_model.dart';

const _eventTypes = ['wedding', 'engagement', 'birthday', 'corporate', 'brand'];

class ProviderMyReelsScreen extends StatefulWidget {
  final String providerId;

  const ProviderMyReelsScreen({
    super.key,
    required this.providerId,
  });

  @override
  State<ProviderMyReelsScreen> createState() => _ProviderMyReelsScreenState();
}

class _ProviderMyReelsScreenState extends State<ProviderMyReelsScreen> {
  final _firestoreService = FirestoreService();
  List<FirebaseReelModel> _reels = [];
  bool _isLoading = true;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadReels();
  }

  Future<void> _loadReels() async {
    setState(() => _isLoading = true);
    try {
      final reels = await _firestoreService.getProviderReels(widget.providerId);
      if (mounted) {
        setState(() {
          _reels = reels;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reels: $e')),
        );
      }
    }
  }

  int _getTotalViews() {
    return _reels.fold(0, (sum, r) => sum + r.analytics.views);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'My Reels',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_rounded),
            tooltip: 'Upload Reels',
            onPressed: () => context.push(AppRoutes.uploadFootage),
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadReels,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _reels.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadReels,
                  color: AppColors.primary,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildStatsRow()),
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: _isGridView ? _buildGrid() : _buildList(),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, size: 80, color: Colors.grey[600]),
            const SizedBox(height: 24),
            Text(
              'No reels yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload reels from the dashboard to get started',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.uploadFootage),
              icon: const Icon(Icons.upload_rounded),
              label: const Text('Upload Reels'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Total Reels', '${_reels.length}', Icons.video_library, AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Total Views', _formatViews(_getTotalViews()), Icons.visibility, AppColors.info),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildReelCard(_reels[index]),
        childCount: _reels.length,
      ),
    );
  }

  Widget _buildList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildReelListCard(_reels[index]),
        ),
        childCount: _reels.length,
      ),
    );
  }

  Widget _buildReelCard(FirebaseReelModel reel) {
    final thumbUrl = reel.thumbnailUrl.isNotEmpty ? reel.thumbnailUrl : reel.videoUrl;
    return GestureDetector(
      onTap: () => _viewReel(reel),
      onLongPress: () => _showReelOptions(reel),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBackground),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (thumbUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: thumbUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: AppColors.cardBackground, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                        errorWidget: (_, __, ___) => Container(color: AppColors.cardBackground, child: const Icon(Icons.videocam, size: 40)),
                      )
                    else
                      Container(color: AppColors.cardBackground, child: const Icon(Icons.videocam, size: 40)),
                    Center(child: Icon(Icons.play_circle_filled, size: 48, color: Colors.white.withValues(alpha: 0.9))),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: PopupMenuButton<String>(
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.more_vert, size: 18, color: Colors.white),
                        ),
                        onSelected: (v) {
                          if (v == 'view') _viewReel(reel);
                          else if (v == 'edit') _editReel(reel);
                          else if (v == 'delete') _confirmDelete(reel);
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.play_circle), SizedBox(width: 8), Text('View')])),
                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')])),
                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reel.title.isNotEmpty ? reel.title : reel.eventType,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.category, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(reel.eventType, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const Spacer(),
                      Icon(Icons.visibility, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Text(_formatViews(reel.analytics.views), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReelListCard(FirebaseReelModel reel) {
    final thumbUrl = reel.thumbnailUrl.isNotEmpty ? reel.thumbnailUrl : reel.videoUrl;
    return GestureDetector(
      onTap: () => _viewReel(reel),
      onLongPress: () => _showReelOptions(reel),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBackground),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: thumbUrl.isNotEmpty
                    ? CachedNetworkImage(imageUrl: thumbUrl, fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.videocam))
                    : const Icon(Icons.videocam),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reel.title.isNotEmpty ? reel.title : reel.eventType, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(reel.eventType, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text('${_formatViews(reel.analytics.views)} views', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'view') _viewReel(reel);
                else if (v == 'edit') _editReel(reel);
                else if (v == 'delete') _confirmDelete(reel);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'view', child: Row(children: [Icon(Icons.play_circle), SizedBox(width: 8), Text('View')])),
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReelOptions(FirebaseReelModel reel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_circle),
              title: const Text('View'),
              onTap: () {
                Navigator.pop(context);
                _viewReel(reel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _editReel(reel);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(reel);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _viewReel(FirebaseReelModel reel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReelViewerScreen(videoUrl: reel.videoUrl, title: reel.title),
      ),
    );
  }

  void _editReel(FirebaseReelModel reel) {
    final titleController = TextEditingController(text: reel.title);
    final tagsController = TextEditingController(text: (reel.tags ?? []).join(', '));
    var eventType = reel.eventType;
    var isPublic = reel.isPublic;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Reel', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Caption', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(labelText: 'Tags (comma separated)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: eventType,
                decoration: const InputDecoration(labelText: 'Event Type', border: OutlineInputBorder()),
                items: _eventTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => eventType = v ?? eventType,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Public (show in discover)'),
                value: isPublic,
                onChanged: (v) => isPublic = v,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final tags = tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
                    try {
                      await _firestoreService.updateReel(reel.reelId, {
                        'title': titleController.text.trim(),
                        'tags': tags,
                        'eventType': eventType,
                        'isPublic': isPublic,
                        'eventName': titleController.text.trim().isNotEmpty ? titleController.text.trim() : eventType,
                      });
                      if (context.mounted) Navigator.pop(context);
                      _loadReels();
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reel updated')));
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(FirebaseReelModel reel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Reel'),
        content: const Text('Are you sure you want to delete this reel? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestoreService.deleteReel(reel.reelId);
                try {
                  await _firestoreService.removePortfolioItemFromProvider(
                    widget.providerId,
                    PortfolioItem(
                      reelId: reel.reelId,
                      eventType: reel.eventType,
                      thumbnailUrl: reel.thumbnailUrl,
                      videoUrl: reel.videoUrl,
                      duration: reel.duration,
                      views: reel.analytics.views,
                      likes: reel.analytics.likes,
                    ),
                  );
                } catch (_) {}
                _loadReels();
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reel deleted')));
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatViews(int views) {
    if (views >= 1000000) return '${(views / 1000000).toStringAsFixed(1)}M';
    if (views >= 1000) return '${(views / 1000).toStringAsFixed(1)}K';
    return views.toString();
  }
}

