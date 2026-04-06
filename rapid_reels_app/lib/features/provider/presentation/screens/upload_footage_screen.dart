import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/provider_app_colors.dart';
import '../../../../core/firebase/services/firestore_service.dart';
import '../../../../core/firebase/models/firebase_reel_model.dart';
import '../../../../core/firebase/models/firebase_provider_model.dart';
import '../../../../shared/widgets/provider/provider_gradient_button.dart';
import 'video_controller_io.dart' if (dart.library.html) 'video_controller_web.dart' as video_helper;

const _eventTypes = ['wedding', 'engagement', 'birthday', 'corporate', 'brand'];

class UploadFootageScreen extends StatefulWidget {
  const UploadFootageScreen({super.key});

  @override
  State<UploadFootageScreen> createState() => _UploadFootageScreenState();
}

class _UploadFootageScreenState extends State<UploadFootageScreen> {
  final List<Map<String, dynamic>> _selectedReels = [];
  final _firestoreService = FirestoreService();
  final _picker = ImagePicker();
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  bool _enableCompression = true;

  @override
  void dispose() {
    for (final item in _selectedReels) {
      final controller = item['controller'] as VideoPlayerController?;
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        backgroundColor: ProviderAppColors.background,
        appBar: AppBar(
          backgroundColor: ProviderAppColors.surface,
          elevation: 0,
          title: const Text('Upload Reels', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 24),
                Text(
                  'Please log in as a provider to upload reels',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FutureBuilder<FirebaseProviderModel?>(
      future: _firestoreService.getProvider(user.uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: ProviderAppColors.background,
            appBar: AppBar(
              backgroundColor: ProviderAppColors.surface,
              elevation: 0,
              title: const Text(
                'Upload Reels',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(color: ProviderAppColors.primary),
            ),
          );
        }
        final prov = snap.data;
        if (prov == null || prov.verificationStatus != 'approved') {
          return Scaffold(
            backgroundColor: ProviderAppColors.background,
            appBar: AppBar(
              backgroundColor: ProviderAppColors.surface,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: const Text(
                'Upload Reels',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Reels upload is available after Rapid Reels approves your provider profile.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        }
        return Scaffold(
      backgroundColor: ProviderAppColors.background,
      appBar: AppBar(
        backgroundColor: ProviderAppColors.surface,
        elevation: 0,
        title: const Text('Upload Reels', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          if (_selectedReels.isNotEmpty)
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.queue),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: ProviderAppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_selectedReels.length}',
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: _showUploadQueue,
            ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedReels.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: ProviderAppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(Icons.cloud_upload, size: 64, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Upload reels', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Supports MP4, MOV files up to 5GB', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _enableCompression,
                          onChanged: (value) {
                            setState(() => _enableCompression = value ?? true);
                          },
                          activeColor: ProviderAppColors.primary,
                        ),
                        Text('Compress videos before upload', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 200,
                      child: ProviderGradientButton(
                        label: 'Select Video',
                        onPressed: _selectVideo,
                        fullWidth: true,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _selectedReels.length,
                      itemBuilder: (context, index) {
                        return _buildReelCard(_selectedReels[index], index);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: OutlinedButton.icon(
                      onPressed: _isUploading ? null : _selectVideo,
                      icon: const Icon(Icons.add),
                      label: const Text('Add More Videos'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ProviderAppColors.primary,
                        side: const BorderSide(color: ProviderAppColors.primary),
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_isUploading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: Colors.grey[300],
                    color: ProviderAppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Uploading... ${(_uploadProgress * 100).toInt()}%',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          if (_selectedReels.isNotEmpty && !_isUploading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearAll,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ProviderGradientButton(
                      label:
                          'Upload ${_selectedReels.length} ${_selectedReels.length == 1 ? 'Reel' : 'Reels'}',
                      onPressed: _uploadReels,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildReelCard(Map<String, dynamic> item, int index) {
    final status = item['status'] as String? ?? 'pending';
    final progress = item['progress'] as double? ?? 0.0;
    final hasError = status == 'failed';
    final controller = item['controller'] as VideoPlayerController?;
    final xFile = item['xFile'] as XFile?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProviderAppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: hasError ? Border.all(color: Colors.red, width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: _buildPreview(controller, xFile, status, progress),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] as String? ?? 'Video',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (status == 'uploading')
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(fontSize: 12, color: ProviderAppColors.primary),
                      ),
                    if (hasError)
                      Text(
                        'Upload failed. Tap to retry',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                  ],
                ),
              ),
              if (hasError)
                IconButton(
                  icon: const Icon(Icons.refresh, color: ProviderAppColors.primary),
                  onPressed: () => _retryUpload(index),
                ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _removeReel(index),
              ),
            ],
          ),
          if (status != 'uploading' && status != 'completed') ...[
            const SizedBox(height: 16),
            TextField(
              controller: item['captionController'] as TextEditingController?,
              decoration: const InputDecoration(
                labelText: 'Caption',
                hintText: 'Add a caption for this reel',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: item['tagsController'] as TextEditingController?,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'wedding, ceremony, bride (comma separated)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: item['eventType'] as String? ?? 'wedding',
              decoration: const InputDecoration(
                labelText: 'Event Type',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: _eventTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => item['eventType'] = v);
                }
              },
            ),
          ],
          if (status == 'uploading')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[800],
                color: ProviderAppColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreview(VideoPlayerController? controller, XFile? xFile, String status, double progress) {
    if (status == 'uploading') {
      return Container(
        color: ProviderAppColors.primary.withValues(alpha: 0.1),
        child: Center(
          child: CircularProgressIndicator(value: progress, strokeWidth: 2, color: ProviderAppColors.primary),
        ),
      );
    }
    if (controller != null && controller.value.isInitialized) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      );
    }
    return Container(
      color: ProviderAppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          status == 'failed' ? Icons.error : Icons.videocam,
          color: status == 'failed' ? Colors.red : ProviderAppColors.primary,
          size: 32,
        ),
      ),
    );
  }

  Future<void> _selectVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;

    final name = picked.name;
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    if (ext != 'mp4') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only MP4 videos are supported for reliable playback.'),
          ),
        );
      }
      return;
    }
    VideoPlayerController? controller;
    try {
      controller = video_helper.createVideoController(picked);
      await controller.initialize();
    } catch (e) {
      debugPrint('Video preview init failed (e.g. on web): $e');
      controller?.dispose();
      controller = null;
    }

    final captionController = TextEditingController();
    final tagsController = TextEditingController();

    setState(() {
      _selectedReels.add({
        'xFile': picked,
        'name': name,
        'caption': '',
        'tags': '',
        'captionController': captionController,
        'tagsController': tagsController,
        'eventType': 'wedding',
        'status': 'pending',
        'progress': 0.0,
        'controller': controller,
      });
    });
  }

  void _removeReel(int index) {
    final item = _selectedReels[index];
    (item['controller'] as VideoPlayerController?)?.dispose();
    (item['captionController'] as TextEditingController?)?.dispose();
    (item['tagsController'] as TextEditingController?)?.dispose();
    setState(() => _selectedReels.removeAt(index));
  }

  void _clearAll() {
    for (final item in _selectedReels) {
      (item['controller'] as VideoPlayerController?)?.dispose();
      (item['captionController'] as TextEditingController?)?.dispose();
      (item['tagsController'] as TextEditingController?)?.dispose();
    }
    setState(() => _selectedReels.clear());
  }

  Future<void> _uploadReels() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to upload')),
      );
      return;
    }

    final providerId = user.uid;
    setState(() => _isUploading = true);

    if (_enableCompression) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading videos...')),
      );
    }

    final storage = FirebaseStorage.instance;
    final total = _selectedReels.length;
    var completed = 0;

    try {
      for (var i = 0; i < _selectedReels.length; i++) {
        final item = _selectedReels[i];
        if (item['status'] == 'completed') continue;

        setState(() {
          item['status'] = 'uploading';
          item['progress'] = 0.0;
        });

        try {
          final xFile = item['xFile'] as XFile;
          final bytes = await xFile.readAsBytes();
          final ext = xFile.name.split('.').last;
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
          final ref = storage.ref().child('providers').child(providerId).child('reels').child(fileName);

          // Set contentType so video_player can recognize the format (critical for playback)
          final contentType = ext.toLowerCase() == 'mov' ? 'video/quicktime' : 'video/mp4';
          final metadata = SettableMetadata(contentType: contentType);
          final uploadTask = ref.putData(bytes, metadata);
          uploadTask.snapshotEvents.listen((taskSnapshot) {
            if (mounted) {
              final p = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
              setState(() {
                item['progress'] = p;
                _uploadProgress = (completed + p) / total;
              });
            }
          });

          await uploadTask;
          final videoUrl = await ref.getDownloadURL();
          final caption = (item['captionController'] as TextEditingController?)?.text.trim() ??
              item['caption'] as String? ??
              '';
          final tagsStr = (item['tagsController'] as TextEditingController?)?.text.trim() ??
              item['tags'] as String? ??
              '';
          final tags = tagsStr.isNotEmpty
              ? tagsStr.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList()
              : <String>[];
          final eventType = item['eventType'] as String? ?? 'wedding';

          final reel = FirebaseReelModel(
            reelId: '',
            bookingId: '',
            customerId: '',
            providerId: providerId,
            eventType: eventType,
            eventName: caption.isNotEmpty ? caption : eventType,
            title: caption.isNotEmpty ? caption : 'Portfolio reel',
            description: null,
            videoUrl: videoUrl,
            thumbnailUrl: videoUrl,
            duration: 0,
            status: 'published',
            metadata: ReelMetadata(
              editingStyle: 'standard',
              quality: '1080p',
              fileSize: bytes.length,
            ),
            analytics: ReelAnalytics(),
            tags: tags.isNotEmpty ? tags : null,
            hashtags: null,
            isPublic: true,
            isFeatured: false,
            createdAt: DateTime.now(),
            deliveredAt: null,
            publishedAt: DateTime.now(),
            editingDetails: null,
          );

          final reelId = await _firestoreService.createReel(reel);

          await _firestoreService.addPortfolioItemToProvider(
            providerId,
            PortfolioItem(
              reelId: reelId,
              eventType: eventType,
              thumbnailUrl: videoUrl,
              videoUrl: videoUrl,
              duration: 0,
              views: 0,
              likes: 0,
            ),
          );

          setState(() {
            item['status'] = 'completed';
            item['progress'] = 1.0;
            completed++;
            _uploadProgress = completed / total;
          });
        } catch (e) {
          setState(() {
            item['status'] = 'failed';
            item['progress'] = 0.0;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Upload failed: $e')),
            );
          }
        }
      }

      if (mounted) {
        setState(() => _isUploading = false);
        final allDone = _selectedReels.every((i) => i['status'] == 'completed');
        if (allDone) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reels uploaded successfully!')),
          );
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) Navigator.pop(context);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload error: $e')),
        );
      }
    }
  }

  void _retryUpload(int index) {
    setState(() {
      _selectedReels[index]['status'] = 'pending';
      _selectedReels[index]['progress'] = 0.0;
    });
    _uploadReels();
  }

  void _showUploadQueue() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ProviderAppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Queue',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._selectedReels.map((item) => ListTile(
              leading: Icon(
                item['status'] == 'completed' ? Icons.check_circle : Icons.pending,
                color: item['status'] == 'completed' ? ProviderAppColors.success : Colors.grey,
              ),
              title: Text(item['name'] as String? ?? 'Video'),
              subtitle: Text(item['status'] as String? ?? 'pending'),
              trailing: item['status'] == 'failed'
                  ? IconButton(
                      icon: const Icon(Icons.refresh, color: ProviderAppColors.primary),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
            )).toList(),
          ],
        ),
      ),
    );
  }
}
