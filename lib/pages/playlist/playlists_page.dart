import '../../components/playlistComponent.dart';
import '../../models/PlayList.dart';
// import 'package:youtube-lis/pages/playlist/create_playlist_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:localstore/localstore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../../provider/connectivityProvider.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  _PlaylistsScreenState createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen>
    with SingleTickerProviderStateMixin {
  List<MyPlayList> _playlists = [];
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    fetchPlaylists();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchPlaylists() async {
    setState(() {
      _isLoading = true;
    });
    final db = Localstore.instance;
    final playlists = await db.collection('playlists').get();
    if (playlists != null) {
      setState(() {
        _playlists = playlists.values
            .map((e) => MyPlayList.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await fetchPlaylists();
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    bool isOnline = Provider.of<NetworkProvider>(context).isOnline;

    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 48,
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    final formKey = GlobalKey<FormState>();
                                    String playlistName = '';
                                    return AlertDialog(
                                      title: const Text('Create Playlist'),
                                      content: Form(
                                        key: formKey,
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'Playlist Name',
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter a playlist name';
                                            }
                                            return null;
                                          },
                                          onSaved: (value) {
                                            playlistName = value!;
                                          },
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            if (formKey.currentState!.validate()) {
                                              formKey.currentState!.save();
                                              final newPlaylist = MyPlayList(
                                                title: playlistName,
                                                coverImage: '',
                                                videos: [],
                                              );
                                              final db = Localstore.instance;
                                              await db
                                                  .collection('playlists')
                                                  .doc(playlistName)
                                                  .set(newPlaylist.toJson());
                                              Navigator.pop(context);
                                              fetchPlaylists();
                                            }
                                          },
                                          child: const Text('Create'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Icon(Icons.add, size: 24),
                            ),
                            Text("Create Playlist")
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: isOnline
                  ? LiquidPullToRefresh(
                      onRefresh: _handleRefresh,
                      height: 100,
                      animSpeedFactor: 2,
                      showChildOpacityTransition: true,
                      child: _buildContent(),
                    )
                  : _buildOfflineState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 20.0,
        ),
        padding: EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[700]!,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          );
        },
      );
    }

    if (_playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note_rounded,
              size: 80,
              color: Colors.grey[700],
            ),
            SizedBox(height: 16),
            Text(
              'No Playlists yet',
              style: GoogleFonts.roboto(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You can create playlists to appear here',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 20.0,
      ),
      padding: EdgeInsets.all(16),
      itemCount: _playlists.length,
      itemBuilder: (context, index) {
        final playlist = _playlists[index];
        return PlaylistComponent(
          playlist: playlist,
        );
      },
    );
  }

  Widget _buildOfflineState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 60,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24),
          Text(
            "You're offline",
            style: GoogleFonts.roboto(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Playlists may not be up to date. Check your connection and try again.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}