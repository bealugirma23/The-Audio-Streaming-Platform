import 'package:audiobinge/models/MyVideo.dart';
import 'dart:convert';

class MyPlayList {
  final String title;
  final String coverImage;
  final List<MyVideo> videos;

  MyPlayList({
    required this.title,
    required this.coverImage,
    required this.videos,
  });

  /// Create from JSON map
  factory MyPlayList.fromJson(Map<String, dynamic> json) {
    return MyPlayList(
      title: json['title'] ?? '',
      coverImage: json['coverImage'] ?? '',
      videos: (json['videos'] as List<dynamic>? ?? [])
          .map((v) => MyVideo.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Create from JSON string
  factory MyPlayList.fromJsonString(String source) =>
      MyPlayList.fromJson(jsonDecode(source));

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
        'title': title,
        'coverImage': coverImage,
        'videos': videos.map((v) => v.toJson()).toList(),
      };

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());
}
