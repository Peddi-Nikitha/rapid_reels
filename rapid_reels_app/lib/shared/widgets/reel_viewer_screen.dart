import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/constants/app_colors.dart';
import '../utils/reel_video_url_resolver.dart';

/// Shared full-screen video viewer - same as provider's _ReelViewerScreen.
/// Uses VideoPlayerController.networkUrl + AspectRatio + auto-play on open.
/// Use this when tapping a reel to play video (provider My Reels, user Discover, etc.).
class ReelViewerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const ReelViewerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<ReelViewerScreen> createState() => _ReelViewerScreenState();
}

class _ReelViewerScreenState extends State<ReelViewerScreen> {
  VideoPlayerController? _controller;
  bool _loadError = false;
  bool _isInitializing = false;

  Future<void> _tryAutoPlay() async {
    if (!mounted || _controller == null) return;
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

  VideoPlayerController _buildController(String url) {
    return VideoPlayerController.networkUrl(
      Uri.parse(url),
      formatHint: _inferFormatHint(url),
      httpHeaders: const {'Cache-Control': 'no-cache'},
    );
  }

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final raw = widget.videoUrl.trim();
    if (raw.isEmpty) {
      setState(() => _loadError = true);
      return;
    }

    setState(() {
      _isInitializing = true;
      _loadError = false;
    });

    try {
      final playableUrl = await resolvePlayableVideoUrl(raw);
      if (!mounted || playableUrl == null || playableUrl.isEmpty) {
        if (mounted) {
          setState(() {
            _loadError = true;
            _isInitializing = false;
          });
        }
        return;
      }

      var controller = _buildController(playableUrl);
      try {
        await controller.initialize();
      } catch (_) {
        await controller.dispose();
        controller = VideoPlayerController.network(playableUrl);
        await controller.initialize();
      }
      if (!mounted) {
        controller.dispose();
        return;
      }
      _controller?.dispose();
      _controller = controller;
      await _tryAutoPlay();
      Future<void>.delayed(const Duration(milliseconds: 180), _tryAutoPlay);
      Future<void>.delayed(const Duration(milliseconds: 420), _tryAutoPlay);
      setState(() => _isInitializing = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = true;
          _isInitializing = false;
        });
      }
      debugPrint('ReelViewerScreen playback init failed for ${widget.videoUrl}: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _controller != null && _controller!.value.isInitialized;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16, color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Center(
        child: _loadError
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off_rounded, size: 48, color: Colors.white70),
                  const SizedBox(height: 16),
                  Text(
                    'Video unavailable',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              )
            : isReady
                ? AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  )
                : _isInitializing
                    ? const CircularProgressIndicator(color: AppColors.primary)
                    : const SizedBox.shrink(),
      ),
      floatingActionButton: isReady
          ? FloatingActionButton(
              onPressed: () => setState(() {
                _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
              }),
              child: Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
            )
          : null,
    );
  }
}
