import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/constants/app_colors.dart';

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

  @override
  void initState() {
    super.initState();
    final url = widget.videoUrl.trim();
    if (url.isEmpty) {
      _loadError = true;
      return;
    }
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (!mounted) return;
        _controller!.play();
        setState(() {});
      }).catchError((e) {
        if (mounted) setState(() => _loadError = true);
      });
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
                : const CircularProgressIndicator(color: AppColors.primary),
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
