// File: lib/youtubePage.dart
import 'package:audiobinge/models/PlayList.dart';
import 'package:audiobinge/utils/likedPlaylistUtils.dart';
import 'package:audiobinge/components/playlistComponent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:youtube_scrape_api/youtube_scrape_api.dart';
import '../components/videoComponent.dart';
import '../utils/thumbnailUtils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../provider/connectivityProvider.dart';
import '../models/MyVideo.dart';

class YoutubeScreen extends StatefulWidget {
  const YoutubeScreen({super.key});

  @override
  _YoutubeScreenState createState() => _YoutubeScreenState();
}

class _YoutubeScreenState extends State<YoutubeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<MyVideo> _podcastVideos = [];
  List<MyVideo> _musicVideos = [];
  List<MyVideo> _newsVideos = [];
  List<MyVideo> _audiobookVideos = [];
  MyPlayList? _likedPlaylist;
  bool _isLoadingPodcasts = false;
  bool _isLoadingAudiobooks = false;
  bool _isLoadingMusic = false;
  bool _isLoadingNews = false;
  bool _isLoadingLikedPlaylist = false;
  final cacheManager = DefaultCacheManager();

  @override
  void initState() {
    super.initState();
    fetchLikedPlaylist();
    fetchTrendingPodcasts();
    fetchTrendingAudiBooks();
    fetchTrendingMusic();
    fetchTrendingNews();
  }

  Future<void> fetchLikedPlaylist() async {
    setState(() => _isLoadingLikedPlaylist = true);
    final likedPlaylist = await getLikedPlaylist();
    setState(() {
      _likedPlaylist = likedPlaylist;
      _isLoadingLikedPlaylist = false;
    });
  }

  Future<void> fetchTrendingAudiBooks() async {
    setState(() => _isLoadingAudiobooks = true);
    YoutubeDataApi api = YoutubeDataApi();
    final videos = await api.fetchSearchVideo("audiobooks");
   
    final processed = videos.map((v) => processVideoThumbnails(v)).toList();
    setState(() {
      _audiobookVideos = processed;
      _isLoadingAudiobooks = false;
    });
  }

  Future<void> fetchTrendingPodcasts() async {
    setState(() => _isLoadingPodcasts = true);
    YoutubeDataApi api = YoutubeDataApi();
    final videos = await api.fetchSearchVideo("podcasts");
    final processed = videos.map((v) => processVideoThumbnails(v)).toList();
    setState(() {
      _podcastVideos = processed;
      _isLoadingPodcasts = false;
    });
  }

  Future<void> fetchTrendingMusic() async {
    setState(() => _isLoadingMusic = true);
    YoutubeDataApi api = YoutubeDataApi();
    final videos = await api.fetchSearchVideo("music");
    final processed = videos.map((v) => processVideoThumbnails(v)).toList();
    setState(() {
      _musicVideos = processed;
      _isLoadingMusic = false;
    });
  }

  Future<void> fetchTrendingNews() async {
    setState(() => _isLoadingMusic = true);
    YoutubeDataApi api = YoutubeDataApi();
    final videos = await api.fetchSearchVideo("news");
    final processed = videos.map((v) => processVideoThumbnails(v)).toList();
    setState(() {
      _newsVideos = processed;
      _isLoadingNews = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildTrendingSection({
    required String title,
    required bool isLoading,
    required List<MyVideo> videos,
    required Future<void> Function() onRefresh,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          width: double.infinity, // ✅ ensures bounded width
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: isLoading ? 6 : videos.length,
            itemBuilder: (context, index) {
              if (isLoading) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[500]!,
                  highlightColor: Colors.grey[400]!,
                  child: Container(
                    width: 180,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: VideoComponent(
                  video: videos[index],
                  from: FromWhere.HOME,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<NetworkProvider>(context).isOnline;
    // if (isOnline == null) {
    //   return CircularProgressIndicator();
    // }
    return Scaffold(
      body: isOnline
          ? SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chips
                    // Row(
                    //   children: [
                    //     ChoiceChip(
                    //       label: const Text('All',
                    //           style: TextStyle(color: Colors.black)),
                    //       selected: true,
                    //       selectedColor: Colors.amber,
                    //     ),
                    //     const SizedBox(width: 8),
                    //     const ChoiceChip(
                    //         label: Text('Podcasts'), selected: false),
                    //     const SizedBox(width: 8),
                    //     const ChoiceChip(label: Text('Music'), selected: false),
                    //   ],
                    // ),
                    // const SizedBox(height: 16),

                    // Greeting
                    // const Text(
                    //   'Good Morning',
                    //   style:
                    //       TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    // ),
                    // const SizedBox(height: 16),

                    // Recently played
                    SizedBox(
                      height: 180,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _isLoadingLikedPlaylist
                              ? Shimmer.fromColors(
                                  baseColor: Colors.grey[800]!,
                                  highlightColor: Colors.grey[700]!,
                                  child: Container(
                                    width: 180,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                )
                              : _likedPlaylist != null
                                  ? PlaylistComponent(
                                      playlist: _likedPlaylist!,
                                    )
                                  : Container(),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 24),

                    // Trending sections

                    _buildTrendingSection(
                      title: "Trending Podcasts",
                      isLoading: _isLoadingPodcasts,
                      videos: _podcastVideos,
                      onRefresh: fetchTrendingPodcasts,
                    ),
                    _buildTrendingSection(
                      title: "Channels",
                      isLoading: _isLoadingMusic,
                      videos: _musicVideos,
                      onRefresh: fetchTrendingMusic,
                    ),
                    _buildTrendingSection(
                      title: "Audio Books",
                      isLoading: _isLoadingAudiobooks,
                      videos: _audiobookVideos,
                      onRefresh: fetchTrendingAudiBooks,
                    ),

                    _buildTrendingSection(
                      title: "Recent News",
                      isLoading: _isLoadingNews,
                      videos: _newsVideos,
                      onRefresh: fetchTrendingMusic,
                    ),
                  ],
                ),
              ),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "You're offline. Go to downloads.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}
