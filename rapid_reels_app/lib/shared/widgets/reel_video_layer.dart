import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../../core/constants/app_colors.dart';
import '../../core/firebase/models/firebase_reel_model.dart';
import '../utils/reel_video_url_resolver.dart';

/// Video layer for a reel - plays when active, shows thumbnail while loading.
/// Use in vertical feed (Discover, ReelPlayer) for inline autoplay.
class ReelVideoLayer extends StatefulWidget {
  final FirebaseReelModel reel;
  final bool isActive;
  final bool muted;
  /// Called on double-tap (e.g. like). Single tap toggles play/pause.
  final VoidCallback? onDoubleTap;

  const ReelVideoLayer({
    super.key,
    required this.reel,
    required this.isActive,
    this.muted = false,
    this.onDoubleTap,
  });

  @override
  State<ReelVideoLayer> createState() => _ReelVideoLayerState();
}

class _ReelVideoLayerState extends State<ReelVideoLayer> {
  VideoPlayerController? _controller;
  bool _loadError = false;
  bool _isInitializing = false;

  List<String> get _videoCandidates {
    final candidates = <String>[];
    final video = widget.reel.videoUrl.trim();
    if (video.isNotEmpty) candidates.add(video);
    final thumb = widget.reel.thumbnailUrl.trim();
    if (thumb.isNotEmpty &&
        (thumb.contains('firebasestorage') ||
            thumb.contains('.mp4') ||
            thumb.contains('.mov') ||
            thumb.startsWith('gs://'))) {
      candidates.add(thumb);
    }
    return candidates.toSet().toList();
  }

  bool get _hasImageThumbnail {
    final thumb = widget.reel.thumbnailUrl.trim().toLowerCase();
    if (thumb.isEmpty) return false;
    return thumb.contains('.jpg') ||
        thumb.contains('.jpeg') ||
        thumb.contains('.png') ||
        thumb.contains('.webp');
  }

  void _playIfActive() {
    if (widget.isActive &&
        _controller != null &&
        _controller!.value.isInitialized &&
        !_controller!.value.isPlaying) {
      _controller!.play();
    }
  }

  Future<void> _tryAutoPlay() async {
    if (!mounted || !widget.isActive || _controller == null) return;
    if (!_controller!.value.isInitialized) return;
    if (!_controller!.value.isPlaying) {
      try {
        await _controller!.play();
      } catch (_) {}
    }
  }

  VideoFormat? _inferFormatHint(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('.m3u8')) return VideoFormat.hls;
    if (lower.contains('.mpd')) return VideoFormat.dash;
    if (lower.contains('.ism') || lower.contains('manifest')) return VideoFormat.ss;
    if (lower.contains('.mp4') || lower.contains('.mov') || lower.contains('alt=media')) {
      return VideoFormat.other;
    }
    return null;
  }

  static const _videoHttpHeaders = <String, String>{
    'Cache-Control': 'no-cache',
    // Some CDNs / Storage gateways return errors without a conventional UA.
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
  };

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Tries texture view, then platform view on Android — avoids release-only
  /// ExoPlayer/MediaCodec failures on several OEM devices.
  Future<VideoPlayerController?> _createInitializedController(
    String playableUrl,
  ) async {
    final hint = _inferFormatHint(playableUrl);

    Future<VideoPlayerController?> tryView(VideoViewType viewType) async {
      var controller = VideoPlayerController.networkUrl(
        Uri.parse(playableUrl),
        formatHint: hint,
        httpHeaders: _videoHttpHeaders,
        viewType: viewType,
      );
      try {
        await controller.initialize();
        return controller;
      } catch (e) {
        debugPrint('ReelVideoLayer init failed ($viewType): $e');
        await controller.dispose();
        return null;
      }
    }

    if (_isAndroid) {
      final texture = await tryView(VideoViewType.textureView);
      if (texture != null) return texture;
      final surface = await tryView(VideoViewType.platformView);
      if (surface != null) return surface;
    } else {
      final c = await tryView(VideoViewType.textureView);
      if (c != null) return c;
    }

    try {
      // ignore: deprecated_member_use — last-resort path; some streams only initialize via this API.
      final legacy = VideoPlayerController.network(playableUrl);
      await legacy.initialize();
      return legacy;
    } catch (e) {
      debugPrint('ReelVideoLayer legacy network() init failed: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    final rawCandidates = _videoCandidates;
    if (rawCandidates.isEmpty) return;

    setState(() {
      _isInitializing = true;
      _loadError = false;
    });

    try {
      VideoPlayerController? initializedController;
      for (final rawUrl in rawCandidates) {
        final playableUrl = await resolvePlayableVideoUrl(rawUrl);
        if (!mounted || playableUrl == null || playableUrl.isEmpty) continue;
        final controller = await _createInitializedController(playableUrl);
        if (controller != null) {
          await controller.setLooping(true);
          await controller.setVolume(widget.muted ? 0.0 : 1.0);
          initializedController = controller;
          break;
        }
      }

      if (!mounted || initializedController == null) {
        if (mounted) {
          setState(() {
            _loadError = true;
            _isInitializing = false;
          });
        }
        return;
      }

      _controller?.dispose();
      _controller = initializedController;
      setState(() => _isInitializing = false);
      _playIfActive();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _playIfActive();
      });
      // Retry autoplay to handle Android timing cases where first play call is ignored.
      Future<void>.delayed(const Duration(milliseconds: 180), _tryAutoPlay);
      Future<void>.delayed(const Duration(milliseconds: 420), _tryAutoPlay);
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadError = true;
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant ReelVideoLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reel.reelId != widget.reel.reelId ||
        oldWidget.reel.videoUrl != widget.reel.videoUrl ||
        oldWidget.reel.thumbnailUrl != widget.reel.thumbnailUrl) {
      _controller?.dispose();
      _controller = null;
      _initializeController();
      return;
    }
    if (_controller != null &&
        _controller!.value.isInitialized &&
        oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _controller!.play();
      } else {
        _controller!.pause();
      }
    }
    if (_controller != null &&
        _controller!.value.isInitialized &&
        oldWidget.muted != widget.muted) {
      _controller!.setVolume(widget.muted ? 0.0 : 1.0);
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
        if (_hasImageThumbnail)
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
        if (!_hasImageThumbnail) Container(color: Colors.black),
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
              onDoubleTap: widget.onDoubleTap,
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
              onDoubleTap: widget.onDoubleTap,
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
        if (_isInitializing)
          const Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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
