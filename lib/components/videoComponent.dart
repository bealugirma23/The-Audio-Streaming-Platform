import 'dart:async';
import 'dart:io';
import 'package:audiobinge/models/PlayList.dart';
import 'package:audiobinge/pages/channelVideosPage.dart';
import 'package:audiobinge/services/donwloadService.dart';
import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:provider/provider.dart';
import '../services/player.dart';
import '../utils/downloadUtils.dart';
// Replace with the actual path
import '../utils/likedPlaylistUtils.dart';
import '../provider/connectivityProvider.dart';
import '../models/MyVideo.dart';

enum FromWhere { HOME, SEARCH }

class VideoComponent extends StatefulWidget {
  final MyVideo video;
  final FromWhere from;

  const VideoComponent({super.key, required this.video, required this.from});

  @override
  _VideoComponentState createState() => _VideoComponentState();
}

class _VideoComponentState extends State<VideoComponent> {
  late Future<List<bool>> _future;
  StreamSubscription? _downloadSubscription;
  List<MyPlayList> _playlists = [];
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    fetchPlaylists();
    _future = Future.wait([
      isLikedVideo(widget.video),
      isDownloaded(widget.video),
    ]);
  }

  Future<void> fetchPlaylists() async {
    setState(() {
      _isLoading = true;
    });
    final db = Localstore.instance;
    final playlists = await db.collection('playlists').get();
    print("Pla $playlists");

    if (playlists != null) {
      setState(() {
        _playlists = playlists.values
            .map((e) => MyPlayList.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    }
  }

  // Function to show playlist selection dialog
  void _showPlaylistDialog(BuildContext context) async {
    // Prepare a list of playlist names derived from _playlists
    List<String> playlistNames =
        _playlists.map((p) => p.title ?? 'Untitled').toList();

    // Show dialog with playlist options
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Text('Add to Playlist'),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () async {
                      // Add new playlist functionality

                      String? newPlaylistName =
                          await _showCreatePlaylistDialog(context);

                      if (newPlaylistName != null) {
                        setState(() {
                          // Update the local name list shown in the dialog.
                          // Persisting/creating a MyPlayList entry in storage
                          // can be done where you handle playlist creation.
                          playlistNames.add(newPlaylistName);
                        });
                      }
                    },
                  ),
                ],
              ),
              content: Container(
                width: double.maxFinite,
                height: 300, // Fixed height for the list
                child: playlistNames.isEmpty
                    ? Center(child: Text('No playlists found'))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: playlistNames.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: Icon(Icons.playlist_play),
                            title: Text(playlistNames[index]),
                            onTap: () {
                              // Add video to selected playlist by name
                              _addToPlaylist(
                                  playlistNames[index], widget.video);

                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Added to ${playlistNames[index]}'),
                                  elevation: 10,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(5),
                                ),
                              );

                              Navigator.of(context).pop(); // Close dialog
                            },
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Function to show dialog for creating a new playlist
  Future<String?> _showCreatePlaylistDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create New Playlist'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Playlist name"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.of(context)
                      .pop(controller.text.trim()); // Return playlist name
                }
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  // Function to add video to playlist
  void _addToPlaylist(String playlistName, MyVideo video) {
    // If adding to "Liked Songs", use existing liked playlist utility
    if (playlistName == 'Liked Songs') {
      addToLikedPlaylist(video);
    } else {
      // For other playlists, you would implement your own logic here
      // This might involve saving to a database or file
      print('Adding video to custom playlist: $playlistName');
      // In a real implementation, you would add your database logic here
    }
  }

  @override
  void dispose() {
    _downloadSubscription?.cancel(); // Cancel any ongoing download subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playing = Provider.of<Playing>(context, listen: false);
    bool isOnline = Provider.of<NetworkProvider>(context).isOnline;
    final downloadService = Provider.of<DownloadService>(context);

    return FutureBuilder<List<bool>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return Text('No data available');
        } else {
          bool isLiked = (snapshot.data![0] ?? false);
          bool isDownloaded = (snapshot.data![1] ?? false);

          return StreamBuilder<Map<String, double>>(
            stream: downloadService.progressStream,
            builder: (context, progressSnapshot) {
              final progress = progressSnapshot.hasData
                  ? progressSnapshot.data![widget.video.videoId!] ?? 0.0
                  : 0.0;
              final downloading =
                  downloadService.getDownloadingState(widget.video.videoId!);

              // Check if this video is the currently playing video
              final isCurrentVideo =
                  playing.video.videoId == widget.video.videoId;

              return GestureDetector(
                onTap: () {
                  playing.assign(widget.video, true);
                },
                child: Container(
                  height: 100,
                  width: widget.from == FromWhere.HOME
                      ? 180
                      : double.infinity, // ✅ Add this
                  decoration: BoxDecoration(
                    // color: Colors.black87,
                    // color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    //   border: isCurrentVideo
                    //       ? Border.all(
                    //           color: AppColors
                    //               .primaryColor, // Highlight border if current video
                    //           width: 2,
                    //         )
                    //       : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                              bottom: Radius.circular(12),
                            ),
                            child: (widget.video.localimage != null)
                                ? Image.file(
                                    File(widget.video.localimage!),
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : (isOnline)
                                    ? Image.network(
                                        widget.video.thumbnails![0].url!,
                                        height: 80,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/icon.png',
                                            height: 80,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        'assets/icon.png',
                                        height: 80,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                          ),
                          Positioned(
                            top: -4,
                            right: -4,
                            child: PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                // color: Colors.white,
                                size: 20,
                              ),
                              onSelected: (String value) {
                                switch (value) {
                                  case 'add_to_queue':
                                    if (playing.queue.contains(widget.video)) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('Already in Queue'),
                                          backgroundColor: Colors.white,
                                          elevation: 10,
                                          behavior: SnackBarBehavior.floating,
                                          margin: EdgeInsets.all(5),
                                        ),
                                      );
                                    } else {
                                      playing.addToQueue(widget.video);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('Added to Queue'),
                                          // backgroundColor: Colors.white,
                                          elevation: 10,
                                          behavior: SnackBarBehavior.floating,
                                          margin: EdgeInsets.all(5),
                                        ),
                                      );
                                    }
                                    break;
                                  case 'add_to_liked':
                                    addToLikedPlaylist(widget.video);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Added to Liked Songs'),
                                        elevation: 10,
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(5),
                                      ),
                                    );
                                    break;
                                  case 'remove_from_liked':
                                    removeFromLikedPlaylist(widget.video);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Removed from Liked Songs'),
                                        elevation: 10,
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(5),
                                      ),
                                    );
                                    break;
                                  case 'add_to_playlist':
                                    _showPlaylistDialog(context);
                                    break;
                                  case 'add_to_downloads':
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text('Download started'),
                                      elevation: 10,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(5),
                                    ));
                                    downloadService.startDownload(
                                        context, widget.video);
                                    break;
                                  case 'remove_from_downloads':
                                    deleteDownload(widget.video);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Removed from downloads'),
                                        elevation: 10,
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(5),
                                      ),
                                    );
                                    break;
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem<String>(
                                    value: 'add_to_queue',
                                    child: Text('Add to Queue'),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'add_to_playlist',
                                    child: Text('Add to Playlist'),
                                  ),
                                  isLiked
                                      ? PopupMenuItem<String>(
                                          value: 'remove_from_liked',
                                          child:
                                              Text('Remove from Liked Songs'),
                                        )
                                      : PopupMenuItem<String>(
                                          value: 'add_to_liked',
                                          child: Text('Add to Liked Songs'),
                                        ),
                                  isDownloaded
                                      ? PopupMenuItem<String>(
                                          value: 'remove_from_downloads',
                                          child: Text('Remove from downloads'),
                                        )
                                      : PopupMenuItem<String>(
                                          value: 'add_to_downloads',
                                          child: Text('Download'),
                                        ),
                                ];
                              },
                            ),
                          ),
                          if (widget.video.duration != null &&
                              widget.video.duration!.isNotEmpty)
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.video.duration!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          if (isCurrentVideo) // Show play icon if current video
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Icon(
                                Icons.play_arrow,
                                // color: AppColors.primaryColor,
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                      if (downloading)
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.black87,
                          //   valueColor: AlwaysStoppedAnimation<Color>(
                          //       AppColors.primaryColor),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.video.title ?? 'No title',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.2,
                                color: isCurrentVideo
                                    ? Theme.of(context).colorScheme.primary
                                    : null,
                                // color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior
                                  .opaque, // Makes the widget capture the tap
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChannelVideosPage(
                                      videoId: widget.video.videoId!,
                                      channelName:
                                          widget.video.channelName ?? '',
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                widget.video.channelName ?? 'Unknown channel',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  // color: Colors.grey,
                                  color: isCurrentVideo
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.secondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
