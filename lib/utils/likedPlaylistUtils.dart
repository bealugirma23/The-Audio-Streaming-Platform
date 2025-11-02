import 'package:audiobinge/models/MyVideo.dart';
import 'package:audiobinge/models/PlayList.dart';
import 'package:audiobinge/services/fetchYoutubeStreamUrl.dart';
import 'package:localstore/localstore.dart';

final db = Localstore.instance;

Future<MyPlayList> getLikedPlaylist() async {
  final likedPlaylist = await db.collection('playlists').doc('liked').get();
  if (likedPlaylist != null) {
    return MyPlayList.fromJson(likedPlaylist);
  } else {
    // Create a new liked playlist if it doesn't exist
    final newLikedPlaylist = MyPlayList(
      title: 'Liked Songs',
      coverImage: '',
      videos: [],
    );
    await db
        .collection('playlists')
        .doc('liked')
        .set(newLikedPlaylist.toJson());
    return newLikedPlaylist;
  }
}

Future<bool> addToLikedPlaylist(MyVideo video) async {
  final likedPlaylist = await getLikedPlaylist();
  final localaudio = await fetchYoutubeStreamUrl(video.videoId!);
  final newVideo = MyVideo(
    videoId: video.videoId,
    duration: video.duration,
    title: video.title,
    channelName: video.channelName,
    views: video.views,
    uploadDate: video.uploadDate,
    thumbnails: video.thumbnails,
    localimage: video.localimage,
    localaudio: localaudio,
  );
  likedPlaylist.videos.add(newVideo);

  try {
    await db.collection('playlists').doc('liked').set(likedPlaylist.toJson());
    print("MyVideo saved to liked playlist successfully.");
    return true; // Indicate success
  } catch (e) {
    print("Error saving video to liked playlist: $e");
    return false; // Indicate failure
  }
}

Future<bool> removeFromLikedPlaylist(MyVideo video) async {
  final likedPlaylist = await getLikedPlaylist();
  likedPlaylist.videos.removeWhere((v) => v.videoId == video.videoId);

  try {
    await db.collection('playlists').doc('liked').set(likedPlaylist.toJson());
    print("MyVideo removed from liked playlist successfully.");
    return true; // Indicate success
  } catch (e) {
    print("Error removing video from liked playlist: $e");
    return false; // Indicate failure
  }
}

Future<bool> isLikedVideo(MyVideo video) async {
  final likedPlaylist = await getLikedPlaylist();
  return likedPlaylist.videos.any((v) => v.videoId == video.videoId);
}
