import 'dart:async';
import 'dart:io';
import '../pages/channelVideosPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/player.dart';
import '../utils/downloadUtils.dart';
import '../utils/likedPlaylistUtils.dart';
import '../provider/connectivityProvider.dart';
import '../models/MyVideo.dart';

enum FromWhere { HOME, SEARCH }

class HorizontalVideoComponent extends StatefulWidget {
  final MyVideo video;
  final FromWhere from;

  const HorizontalVideoComponent(
      {super.key, required this.video, required this.from});

  @override
  _HorizontalVideoComponentState createState() =>
      _HorizontalVideoComponentState();
}

class _HorizontalVideoComponentState extends State<HorizontalVideoComponent> {
  late Future<List<bool>> _future;

  @override
  void initState() {
    super.initState();
    _future = Future.wait([
      isLikedVideo(widget.video),
      isDownloaded(widget.video),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final playing = Provider.of<Playing>(context, listen: false);
    bool isOnline = Provider.of<NetworkProvider>(context).isOnline;

    return FutureBuilder<List<bool>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return const Text('No data available');
        } else {
          final isCurrentVideo =
              playing.video.videoId == widget.video.videoId;

          return InkWell(
            onTap: () {
              playing.assign(widget.video, true);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Stack(
                      children: [
                        if (widget.video.localimage != null)
                          Image.file(
                            File(widget.video.localimage!),
                            height: 80,
                            width: 120,
                            fit: BoxFit.cover,
                          )
                        else if (isOnline &&
                            widget.video.thumbnails != null &&
                            widget.video.thumbnails!.isNotEmpty)
                          Image.network(
                            widget.video.thumbnails![0].url!,
                            height: 80,
                            width: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/icon.png',
                                height: 80,
                                width: 120,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        else
                          Image.asset(
                            'assets/icon.png',
                            height: 80,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        if (widget.video.duration != null &&
                            widget.video.duration!.isNotEmpty)
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.video.duration!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
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
                  const Icon(Icons.more_vert, color: Colors.grey),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}