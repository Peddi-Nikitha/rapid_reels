import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

/// Creates a VideoPlayerController for the given XFile (mobile/desktop).
VideoPlayerController createVideoController(XFile xFile) {
  return VideoPlayerController.file(File(xFile.path));
}
