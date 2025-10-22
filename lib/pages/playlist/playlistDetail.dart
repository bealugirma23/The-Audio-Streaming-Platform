import '../../components/horizontal_video_component.dart';
import '../../models/PlayList.dart';
import '../../services/player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlayListDetail extends StatefulWidget {
  final MyPlayList playlist;
  const PlayListDetail({super.key, required this.playlist});

  @override
  State<PlayListDetail> createState() => _PlayListDetailState();
}

class _PlayListDetailState extends State<PlayListDetail> {
  @override
  Widget build(BuildContext context) {
    final playing = Provider.of<Playing>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: widget.playlist.coverImage.isEmpty
                        ? Image.asset(
                            'assets/icon.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            widget.playlist.coverImage,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/icon.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.playlist.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.playlist.videos.length} videos',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  playing.setQueue(widget.playlist.videos);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(15),
                ),
                child:
                    const Icon(Icons.play_arrow, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  playing.setQueue(widget.playlist.videos);
                  playing.toggleShuffle();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(15),
                ),
                child: const Icon(Icons.shuffle, color: Colors.white, size: 30),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Videos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.playlist.videos.length,
              itemBuilder: (context, index) {
                final video = widget.playlist.videos[index];
                return HorizontalVideoComponent(
                    video: video, from: FromWhere.HOME);
              },
            ),
          ),
        ],
      ),
    );
  }
}
