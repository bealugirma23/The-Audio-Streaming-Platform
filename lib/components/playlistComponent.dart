import 'package:audiobinge/models/PlayList.dart';
import 'package:audiobinge/pages/playlist/playlistDetail.dart';
import 'package:flutter/material.dart';

class PlaylistComponent extends StatelessWidget {
  final MyPlayList playlist;

  const PlaylistComponent({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlayListDetail(
              playlist: playlist,
            ),
          ),
        );
      },
      child: SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  playlist.coverImage,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/icon.png',
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${playlist.videos.length} songs',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
