// File: lib/youtubePage.dart
import 'package:audiobinge/components/widgets/cards.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youtube_scrape_api/models/video.dart';
import 'package:youtube_scrape_api/youtube_scrape_api.dart';
import '../components/videoComponent.dart';
import '../utils/thumbnailUtils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../provider/connectivityProvider.dart';
import '../models/MyVideo.dart';
import '../theme/colors.dart';

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
  bool _isLoadingPodcasts = false;
  bool _isLoadingMusic = false;
  bool _isLoadingNews = false;

  @override
  void initState() {
    super.initState();
    fetchTrendingPodcasts();
    fetchTrendingMusic();
    fetchTrendingNews();
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
          height: 180,
          width: double.infinity, // ✅ ensures bounded width
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: isLoading ? 6 : videos.length,
            itemBuilder: (context, index) {
              if (isLoading) {
                return Shimmer.fromColors(
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
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<NetworkProvider>(context).isOnline;

    return Scaffold(
      backgroundColor: Colors.black,
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
                          const RecentlyPlayedCard(),
                          const SizedBox(width: 12),
                          const RecentlyPlayedCard(),
                          const SizedBox(width: 12),
                          const RecentlyPlayedCard(),
                          const SizedBox(width: 12),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 60),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: SizedBox(
                                // width: 48, // control size here
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    shape: const CircleBorder(),
                                    padding: EdgeInsets
                                        .zero, // ensures it's perfectly round
                                  ),
                                  child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.add, size: 24)),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Trending sections
                    _buildTrendingSection(
                      title: "Trending Podcasts",
                      isLoading: _isLoadingPodcasts,
                      videos: _podcastVideos,
                      onRefresh: fetchTrendingPodcasts,
                    ),
                    _buildTrendingSection(
                      title: "Trending Musics",
                      isLoading: _isLoadingMusic,
                      videos: _musicVideos,
                      onRefresh: fetchTrendingMusic,
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
