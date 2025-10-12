import 'package:youtube_scrape_api/models/video.dart';
class MyVideo extends Video {
  final String? localimage;
  final String? localaudio;

  MyVideo({
    super.videoId,
    super.duration,
    super.title,
    super.channelName,
    super.views,
    super.uploadDate,
    super.thumbnails,
    this.localimage,
    this.localaudio,
  });

  /// Create from Map (useful when adding local overrides)
  factory MyVideo.fromMap(
    Map<String, dynamic>? map, {
    String? localimage,
    String? localaudio,
  }) {
    if (map == null) return MyVideo();
    final video = Video.fromMap(map);
    return MyVideo(
      videoId: video.videoId,
      duration: video.duration,
      title: video.title,
      channelName: video.channelName,
      views: video.views,
      uploadDate: video.uploadDate,
      thumbnails: video.thumbnails,
      localimage: localimage ?? map['localimage'],
      localaudio: localaudio ?? map['localaudio'],
    );
  }

  /// Create from JSON string or Map<String, dynamic>
  factory MyVideo.fromJson(Map<String, dynamic> json) {
    return MyVideo(
      videoId: json['videoId'],
      duration: json['duration'],
      title: json['title'],
      channelName: json['channelName'],
      views: json['views'],
      uploadDate: json['uploadDate'],
      thumbnails: json['thumbnails'],
      localimage: json['localimage'],
      localaudio: json['localaudio'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final videoJson = super.toJson();
    videoJson.addAll({
      'localimage': localimage,
      'localaudio': localaudio,
    });
    return videoJson;
  }
}

