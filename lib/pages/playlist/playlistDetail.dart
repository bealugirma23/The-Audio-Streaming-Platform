import 'package:flutter/material.dart';

class PlayListDetail extends StatefulWidget {
  const PlayListDetail({super.key});

  @override
  State<PlayListDetail> createState() => _PlayListDetailState();
}

class _PlayListDetailState extends State<PlayListDetail> {
  @override
  Widget build(BuildContext context) {
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
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Image(
                      image: AssetImage('assets/icon.png'),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Chill Vibes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '12 videos',
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
                onPressed: () {},
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
                onPressed: () {},
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
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: const [
                ListTile(
                  leading: Icon(Icons.music_note, color: Colors.white),
                  title: Text('video Title 1',
                      style: TextStyle(color: Colors.white)),
                  subtitle:
                      Text('Artist 1', style: TextStyle(color: Colors.grey)),
                  trailing: Icon(Icons.more_vert, color: Colors.grey),
                ),
                ListTile(
                  leading: Icon(Icons.music_note, color: Colors.white),
                  title: Text('video Title 2',
                      style: TextStyle(color: Colors.white)),
                  subtitle:
                      Text('Artist 2', style: TextStyle(color: Colors.grey)),
                  trailing: Icon(Icons.more_vert, color: Colors.grey),
                ),
                ListTile(
                  leading: Icon(Icons.music_note, color: Colors.white),
                  title: Text('video Title 3',
                      style: TextStyle(color: Colors.white)),
                  subtitle:
                      Text('Artist 3', style: TextStyle(color: Colors.grey)),
                  trailing: Icon(Icons.more_vert, color: Colors.grey),
                ),
                ListTile(
                  leading: Icon(Icons.music_note, color: Colors.white),
                  title: Text('video Title 4',
                      style: TextStyle(color: Colors.white)),
                  subtitle:
                      Text('Artist 4', style: TextStyle(color: Colors.grey)),
                  trailing: Icon(Icons.more_vert, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: TextButton(
          //     onPressed: () {},
          //     child: const Text(
          //       'Add videos',
          //       style: TextStyle(color: Colors.red, fontSize: 16),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
