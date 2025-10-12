import 'package:audiobinge/pages/playlist/playlistDetail.dart';
import 'package:flutter/material.dart';

class RecentlyPlayedCard extends StatelessWidget {
  final String title;
  final String? length;
  final String? coverImage;
  const RecentlyPlayedCard(
      {super.key, required this.title, this.coverImage, this.length});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => PlayListDetail()));
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                // color: Colors.grey[800],
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.album, size: 40),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            length ?? "",
            style: TextStyle(fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
