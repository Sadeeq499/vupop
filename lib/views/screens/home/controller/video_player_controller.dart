import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../utils/common_code.dart';

class VideoPlayerControllerX extends GetxController {
  CachedVideoPlayerPlus? videoPlayer;
  RxDouble videoProgress = 0.0.obs;

  void initializePlayer(String videoUrl) {
    // videoPlayer?.dispose();

    videoPlayer = CachedVideoPlayerPlus.networkUrl(Uri.parse(videoUrl), invalidateCacheIfOlderThan: const Duration(minutes: 30));
    videoPlayer!.initialize().then((_) {
      videoPlayer!.controller.play();
      videoPlayer!.controller.setLooping(true);
      videoPlayer!.controller.addListener(_updateProgress);
      update();
    }).catchError((onError) {
      if (kDebugMode) {
        printLogs('=========error init video controller ${onError.toString()}');
      }
    });
  }

  void _updateProgress() {
    if (videoPlayer != null && videoPlayer!.controller.value.isInitialized) {
      videoProgress.value =
          videoPlayer!.controller.value.position.inMilliseconds.toDouble() / videoPlayer!.controller.value.duration.inMilliseconds.toDouble();
    }
  }

  void disposePlayer() {
    videoPlayer?.controller.removeListener(_updateProgress);
    videoPlayer?.dispose();
  }

  @override
  void onClose() {
    disposePlayer();
    super.onClose();
  }
}
