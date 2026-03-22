import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// True for HTTPS Firebase Storage download URLs (v0/b/... and GCS-style hosts).
bool isFirebaseStorageDownloadUrl(String url) {
  try {
    final u = Uri.parse(url.trim());
    if (u.scheme != 'http' && u.scheme != 'https') return false;
    return u.host.contains('firebasestorage.googleapis.com') ||
        u.host.contains('firebasestorage.app');
  } catch (_) {
    return false;
  }
}

/// Loads Firebase Storage pictures without breaking on Flutter web.
///
/// - **Web:** [Reference.getData] hits a FlutterFire JS interop bug (`ClientException`
///   vs `JavaScriptObject`). We use [Image.network] with [WebHtmlElementStrategy.prefer]
///   so the browser loads via `<img>` (same as a normal page).
/// - **Mobile/desktop (IO):** [Reference.getData] + [Image.memory] avoids extra decode work
///   and matches previous behavior.
class FirebaseStorageImage extends StatefulWidget {
  const FirebaseStorageImage({
    super.key,
    required this.url,
    required this.fit,
    this.width,
    this.height,
    required this.placeholder,
    required this.errorWidget,
    this.maxBytes = 15 * 1024 * 1024,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget placeholder;
  final Widget errorWidget;
  final int maxBytes;

  @override
  State<FirebaseStorageImage> createState() => _FirebaseStorageImageState();
}

class _FirebaseStorageImageState extends State<FirebaseStorageImage> {
  Uint8List? _bytes;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _load();
    } else {
      _loading = false;
    }
  }

  @override
  void didUpdateWidget(FirebaseStorageImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url && !kIsWeb) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
      _bytes = null;
    });
    try {
      final ref = FirebaseStorage.instance.refFromURL(widget.url);
      final data = await ref.getData(widget.maxBytes);
      if (!mounted) return;
      final ok = data != null && data.isNotEmpty;
      setState(() {
        _bytes = data;
        _loading = false;
        _failed = !ok;
      });
    } catch (e, st) {
      debugPrint('FirebaseStorageImage getData failed: $e\n$st');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(
        widget.url,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        gaplessPlayback: true,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return widget.placeholder;
        },
        errorBuilder: (_, __, ___) => widget.errorWidget,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      );
    }

    if (_loading) return widget.placeholder;
    if (_failed || _bytes == null) return widget.errorWidget;
    return Image.memory(
      _bytes!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      gaplessPlayback: true,
    );
  }
}
