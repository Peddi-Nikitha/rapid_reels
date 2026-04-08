import 'package:firebase_storage/firebase_storage.dart';

/// Resolves reel URLs into a playable network URL for `video_player`.
///
/// Supports:
/// - Firebase Storage refs (`gs://...`) by converting to download URL
/// - Direct `http/https` URLs
/// - Bare Firebase Storage host paths by prepending `https://`
Future<String?> resolvePlayableVideoUrl(String rawUrl) async {
  var candidate = rawUrl.trim();
  if (candidate.isEmpty) return null;

  // Release builds enforce cleartext policy; prefer HTTPS for Firebase Storage hosts.
  if (candidate.startsWith('http://')) {
    final lower = candidate.toLowerCase();
    if (lower.contains('firebasestorage.googleapis.com') ||
        lower.contains('firebasestorage.app')) {
      candidate = 'https://${candidate.substring('http://'.length)}';
    }
  }

  // Firebase Storage reference URL -> signed download URL
  if (candidate.startsWith('gs://')) {
    try {
      final resolved = await FirebaseStorage.instance.refFromURL(candidate).getDownloadURL();
      return _normalizePlayableUrl(resolved);
    } catch (_) {
      return null;
    }
  }

  // Already a direct URL
  if (candidate.startsWith('http://') || candidate.startsWith('https://')) {
    final normalized = _normalizePlayableUrl(candidate);
    return _refreshFirebaseDownloadUrlIfNeeded(normalized);
  }

  // Handle bare host form like "firebasestorage.googleapis.com/v0/..."
  if (candidate.startsWith('firebasestorage.googleapis.com/') ||
      candidate.startsWith('firebasestorage.app/')) {
    final normalized = _normalizePlayableUrl('https://$candidate');
    return _refreshFirebaseDownloadUrlIfNeeded(normalized);
  }

  return null;
}

String _normalizePlayableUrl(String url) {
  var normalized = url.trim();
  // Some stored URLs are accidentally double/triple encoded (e.g. `%252F`, `%25252F`).
  // Decode repeatedly (bounded) so Firebase object paths become valid (`%2F`).
  for (var i = 0; i < 3; i++) {
    if (!normalized.contains('%25')) break;
    try {
      final decoded = Uri.decodeFull(normalized);
      if (decoded == normalized) break;
      normalized = decoded;
    } catch (_) {
      break;
    }
  }
  return _canonicalizeFirebaseDownloadUrl(normalized);
}

String _canonicalizeFirebaseDownloadUrl(String url) {
  Uri uri;
  try {
    uri = Uri.parse(url);
  } catch (_) {
    return url;
  }

  final host = uri.host.toLowerCase();
  if (!host.contains('firebasestorage.googleapis.com') &&
      !host.contains('firebasestorage.app')) {
    return url;
  }

  // Expected form: /v0/b/<bucket>/o/<object-encoded>
  final marker = '/o/';
  final path = uri.path;
  final idx = path.indexOf(marker);
  if (idx < 0) return url;

  final prefix = path.substring(0, idx + marker.length);
  var objectPart = path.substring(idx + marker.length);
  if (objectPart.isEmpty) return url;

  // Decode repeatedly to remove accidental multi-encoding.
  for (var i = 0; i < 6; i++) {
    final before = objectPart;
    try {
      objectPart = Uri.decodeComponent(objectPart);
    } catch (_) {
      break;
    }
    if (objectPart == before) break;
  }

  // Re-encode once for Firebase object path (slashes become %2F).
  final canonicalObject = Uri.encodeComponent(objectPart);
  final canonicalPath = '$prefix$canonicalObject';
  return uri.replace(path: canonicalPath).toString();
}

Future<String> _refreshFirebaseDownloadUrlIfNeeded(String url) async {
  Uri uri;
  try {
    uri = Uri.parse(url);
  } catch (_) {
    return url;
  }

  final host = uri.host.toLowerCase();
  if (!host.contains('firebasestorage.googleapis.com') &&
      !host.contains('firebasestorage.app')) {
    return url;
  }

  // Most reliable path: ask Firebase SDK to resolve a fresh signed URL
  // from the provided Firebase Storage download URL.
  try {
    final freshUrl = await FirebaseStorage.instance.refFromURL(url).getDownloadURL();
    return _canonicalizeFirebaseDownloadUrl(freshUrl);
  } catch (_) {
    // Continue to manual parse fallback.
  }

  // Try to refresh the download URL from object path to recover from stale/invalid tokens.
  try {
    final pathSegments = uri.pathSegments;
    final bIndex = pathSegments.indexOf('b');
    final oIndex = pathSegments.indexOf('o');
    if (bIndex < 0 || oIndex < 0 || bIndex + 1 >= pathSegments.length || oIndex + 1 >= pathSegments.length) {
      return url;
    }

    final bucket = pathSegments[bIndex + 1];
    final encodedObject = pathSegments.sublist(oIndex + 1).join('/');
    var objectPath = encodedObject;
    for (var i = 0; i < 4; i++) {
      final decoded = Uri.decodeComponent(objectPath);
      if (decoded == objectPath) break;
      objectPath = decoded;
    }

    final storage = FirebaseStorage.instanceFor(bucket: 'gs://$bucket');
    final freshUrl = await storage.ref(objectPath).getDownloadURL();
    return _canonicalizeFirebaseDownloadUrl(freshUrl);
  } catch (_) {
    return url;
  }
}
