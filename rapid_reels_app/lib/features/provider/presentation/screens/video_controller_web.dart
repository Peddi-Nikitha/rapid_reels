import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

/// Creates a VideoPlayerController for the given XFile (web).
/// On web, XFile.path is a blob URL - use network controller.
VideoPlayerController createVideoController(XFile xFile) {
  return VideoPlayerController.networkUrl(Uri.parse(xFile.path));
}
