// File: lib/youtubePage.dart
import 'dart:convert';
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
  final cacheManager = CacheManager(
    Config(
      "youtube_cache",
      stalePeriod: const Duration(hours: 1), // Cache expires after 1 hour
      maxNrOfCacheObjects: 100,
    ),
  );

  bool _isPodcastsLoaded = false;
  bool _isAudiobooksLoaded = false;
  bool _isMusicLoaded = false;
  bool _isNewsLoaded = false;
  bool _isLikedPlaylistLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    fetchLikedPlaylist();
    fetchTrendingPodcasts();
    fetchTrendingAudiBooks();
    fetchTrendingMusic();
    fetchTrendingNews();
  }

  Future<void> fetchLikedPlaylist() async {
    if (_isLikedPlaylistLoaded) return; // Don't refetch if already loaded

    setState(() => _isLoadingLikedPlaylist = true);
    final likedPlaylist = await getLikedPlaylist();
    setState(() {
      _likedPlaylist = likedPlaylist;
      _isLoadingLikedPlaylist = false;
      _isLikedPlaylistLoaded = true; // Mark as loaded
    });
  }

  Future<void> fetchTrendingAudiBooks() async {
    if (_isAudiobooksLoaded) return; // Don't refetch if already loaded

    // Try to get from cache first
    await _fetchVideosFromCacheOrApi(
      category: "audiobooks",
      setVideos: (videos) => setState(() {
        _audiobookVideos = videos;
        _isAudiobooksLoaded = true; // Mark as loaded after successful fetch
      }),
      setLoading: (loading) => setState(() => _isLoadingAudiobooks = loading),
      getVideos: () => _audiobookVideos,
    );
  }

  Future<void> fetchTrendingPodcasts() async {
    if (_isPodcastsLoaded) return; // Don't refetch if already loaded

    // Try to get from cache first
    await _fetchVideosFromCacheOrApi(
      category: "podcasts",
      setVideos: (videos) => setState(() {
        _podcastVideos = videos;
        _isPodcastsLoaded = true; // Mark as loaded after successful fetch
      }),
      setLoading: (loading) => setState(() => _isLoadingPodcasts = loading),
      getVideos: () => _podcastVideos,
    );
  }

  Future<void> fetchTrendingMusic() async {
    if (_isMusicLoaded) return; // Don't refetch if already loaded

    // Try to get from cache first
    await _fetchVideosFromCacheOrApi(
      category: "music",
      setVideos: (videos) => setState(() {
        _musicVideos = videos;
        _isMusicLoaded = true; // Mark as loaded after successful fetch
      }),
      setLoading: (loading) => setState(() => _isLoadingMusic = loading),
      getVideos: () => _musicVideos,
    );
  }

  Future<void> fetchTrendingNews() async {
    if (_isNewsLoaded) return; // Don't refetch if already loaded

    // Try to get from cache first
    await _fetchVideosFromCacheOrApi(
      category: "news",
      setVideos: (videos) => setState(() {
        _newsVideos = videos;
        _isNewsLoaded = true; // Mark as loaded after successful fetch
      }),
      setLoading: (loading) => setState(() => _isLoadingNews = loading),
      getVideos: () => _newsVideos,
    );
  }

  Future<void> _fetchVideosFromCacheOrApi({
    required String category,
    required Function(List<MyVideo>) setVideos,
    required Function(bool) setLoading,
    required List<MyVideo> Function() getVideos,
  }) async {
    setLoading(true);

    // Try to get from cache first
    try {
      final cacheKey = "trending_$category";
      final file = await cacheManager.getSingleFile(cacheKey);

      if (file != null) {
        final content = await file.readAsString();
        final cachedVideos = await _deserializeVideos(content);

        // Only use cached data if it's not empty
        if (cachedVideos.isNotEmpty) {
          setVideos(cachedVideos);
        }
      }
    } catch (e) {
      print("Cache miss for $category: $e");
    }

    // Only fetch from API if we don't have data yet
    if (getVideos().isEmpty) {
      try {
        YoutubeDataApi api = YoutubeDataApi();
        final videos = await api.fetchSearchVideo(category);
        final processed = videos.map((v) => processVideoThumbnails(v)).toList();

        // Update the UI with fresh data
        setVideos(processed);

        // Cache the new data
        final serializedData = await _serializeVideos(processed);
        await cacheManager.putFile(
          "trending_$category",
          utf8.encode(serializedData),
          fileExtension: 'json',
        );
      } catch (e) {
        print("Error fetching $category: $e");
        // If API fails and we have cached data, keep the cached data
        if (getVideos().isEmpty) {
          // If we have no cached data either, just keep it empty
          setVideos([]);
        }
      }
    }

    setLoading(false);
  }

  Future<String> _serializeVideos(List<MyVideo> videos) async {
    List<Map<String, dynamic>> videoMaps =
        videos.map((video) => video.toJson()).toList();
    return jsonEncode(videoMaps);
  }

  Future<List<MyVideo>> _deserializeVideos(String jsonString) async {
    try {
      List<dynamic> videoList = jsonDecode(jsonString);
      List<MyVideo> videos =
          videoList.map((map) => MyVideo.fromJson(map)).toList();
      return videos;
    } catch (e) {
      print("Error deserializing videos: $e");
      return [];
    }
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

  // Method to force refresh data (mark as not loaded and refetch)
  Future<void> _refreshPodcasts() async {
    setState(() {
      _isPodcastsLoaded = false;
      _podcastVideos = [];
    });
    await fetchTrendingPodcasts();
  }

  Future<void> _refreshMusic() async {
    setState(() {
      _isMusicLoaded = false;
      _musicVideos = [];
    });
    await fetchTrendingMusic();
  }

  Future<void> _refreshAudiobooks() async {
    setState(() {
      _isAudiobooksLoaded = false;
      _audiobookVideos = [];
    });
    await fetchTrendingAudiBooks();
  }

  Future<void> _refreshNews() async {
    setState(() {
      _isNewsLoaded = false;
      _newsVideos = [];
    });
    await fetchTrendingNews();
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
                      onRefresh: _refreshPodcasts,
                    ),
                    _buildTrendingSection(
                      title: "Channels",
                      isLoading: _isLoadingMusic,
                      videos: _musicVideos,
                      onRefresh: _refreshMusic,
                    ),
                    _buildTrendingSection(
                      title: "Audio Books",
                      isLoading: _isLoadingAudiobooks,
                      videos: _audiobookVideos,
                      onRefresh: _refreshAudiobooks,
                    ),

                    _buildTrendingSection(
                      title: "Recent News",
                      isLoading: _isLoadingNews,
                      videos: _newsVideos,
                      onRefresh: _refreshNews,
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
