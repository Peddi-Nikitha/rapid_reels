import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../../core/constants/app_colors.dart';
import '../../core/firebase/models/firebase_reel_model.dart';

/// Video layer for a reel - plays when active, shows thumbnail while loading.
/// Use in vertical feed (Discover, ReelPlayer) for inline autoplay.
class ReelVideoLayer extends StatefulWidget {
  final FirebaseReelModel reel;
  final bool isActive;

  const ReelVideoLayer({
    super.key,
    required this.reel,
    required this.isActive,
  });

  @override
  State<ReelVideoLayer> createState() => _ReelVideoLayerState();
}

class _ReelVideoLayerState extends State<ReelVideoLayer> {
  VideoPlayerController? _controller;
  bool _loadError = false;

  String get _videoUrl {
    final video = widget.reel.videoUrl.trim();
    if (video.isNotEmpty) return video;
    final thumb = widget.reel.thumbnailUrl.trim();
    if (thumb.isNotEmpty &&
        (thumb.contains('firebasestorage') ||
            thumb.contains('.mp4') ||
            thumb.contains('.mov'))) {
      return thumb;
    }
    return '';
  }

  void _playIfActive() {
    if (widget.isActive &&
        _controller != null &&
        _controller!.value.isInitialized &&
        !_controller!.value.isPlaying) {
      _controller!.play();
    }
  }

  @override
  void initState() {
    super.initState();
    final url = _videoUrl;
    if (url.isEmpty) return;
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..setLooping(true)
      ..setVolume(1.0)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _playIfActive();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _playIfActive();
          });
        }
      }).catchError((e) {
        if (mounted) setState(() => _loadError = true);
      });
  }

  @override
  void didUpdateWidget(covariant ReelVideoLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller != null &&
        _controller!.value.isInitialized &&
        oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _controller!.play();
      } else {
        _controller!.pause();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVideoReady = _controller != null && _controller!.value.isInitialized;
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: widget.reel.thumbnailUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppColors.surface,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: AppColors.surface,
            child: const Icon(Icons.error_outline, color: AppColors.textSecondary),
          ),
        ),
        if (isVideoReady && _controller != null)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (_controller!.value.isPlaying) {
                  _controller!.pause();
                } else {
                  _controller!.play();
                }
                setState(() {});
              },
              child: Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
          ),
        // Play/pause overlay - visible when paused so user can tap if autoplay is blocked
        if (isVideoReady &&
            _controller != null &&
            !_controller!.value.isPlaying)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _controller!.play();
                setState(() {});
              },
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        if (_loadError)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam_off_rounded, size: 48, color: Colors.white70),
                    const SizedBox(height: 8),
                    Text(
                      'Video unavailable',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
