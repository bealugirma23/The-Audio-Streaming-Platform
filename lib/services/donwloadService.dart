import 'dart:async';

import 'package:audiobinge/models/MyVideo.dart';
import 'package:audiobinge/utils/downloadUtils.dart';
import 'package:flutter/material.dart';

class DownloadService {
  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _downloadingState = {};
  final StreamController<Map<String, double>> _progressStreamController =
      StreamController<Map<String, double>>.broadcast();

  Stream<Map<String, double>> get progressStream =>
      _progressStreamController.stream;

  double getProgress(String videoId) {
    return _downloadProgress[videoId] ?? 0.0;
  }

  bool getDownloadingState(String videoId) {
    return _downloadingState[videoId] ?? false;
  }

  Future<void> startDownload(BuildContext context, MyVideo video) async {
    _downloadingState[video.videoId!] = true;
    downloadAndSaveMetaData(context, video, (progress) {
      _downloadProgress[video.videoId!] = progress;
      _progressStreamController.add(_downloadProgress);
      if (progress >= 1.0) {
        _downloadingState[video.videoId!] = false;
      }
    });
  }

  void dispose() {
    _progressStreamController.close();
  }
}

