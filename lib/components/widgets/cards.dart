import 'package:flutter/material.dart';

class RecentlyPlayedCard extends StatelessWidget {
  const RecentlyPlayedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.album, size: 40),
          ),
          const SizedBox(height: 8),
          const Text(
            'Album Name',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            'Artist Name',
            style: TextStyle(color: Colors.grey[400], fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
