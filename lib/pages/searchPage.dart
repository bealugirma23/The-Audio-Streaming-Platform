// File: lib/youtubePage.dart
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

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<MyVideo> _videos = [];
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchTrendingYoutube();
  }

  Future<void> _handleRefresh() async {
    fetchTrendingYoutube();
  }

  void fetchTrendingYoutube() async {
    setState(() {
      _isLoading = true;
    });
    YoutubeDataApi youtubeDataApi = YoutubeDataApi();
    List<Video> videos = await youtubeDataApi.fetchSearchVideo("podcast");
    List<MyVideo> processedVideos = [];
    for (var videoData in videos) {
      MyVideo videoWithHighestThumbnail = processVideoThumbnails(videoData);
      processedVideos.add(videoWithHighestThumbnail);
    }
    print("Home Videos $processedVideos");
    setState(() {
      _videos = processedVideos;
      _isLoading = false;
    });
  }

  void searchYoutube(String query) async {
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a search query'),
          backgroundColor: AppColors.primaryColor,
        ),
      );
      return;
    }
    setState(() {
      _isSearching = true;
    });
    YoutubeDataApi youtubeDataApi = YoutubeDataApi();
    List videos = await youtubeDataApi.fetchSearchVideo(query);
    List<Video> temp = videos.whereType<Video>().toList();
    List<MyVideo> processedVideos = [];
    for (var videoData in temp) {
      MyVideo videoWithHighestThumbnail = processVideoThumbnails(videoData);
      processedVideos.add(videoWithHighestThumbnail);
    }
    setState(() {
      _videos = processedVideos;
      _isSearching = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isOnline = Provider.of<NetworkProvider>(context).isOnline;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 5),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.8)),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppColors.primaryColor, width: 1.5),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(
                        'assets/icons/youtube.svg',
                        height: 24,
                        color: Colors.white,
                      ),
                    ),
                    suffixIcon: _isSearching
                        ? SizedBox(
                            height: 50,
                            width: 50,
                            child: Padding(
                              padding: const EdgeInsets.all(13.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 200),
                                child: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        key: ValueKey('clear'),
                                        icon: Icon(Icons.clear,
                                            color: Colors.white),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {});
                                        },
                                      )
                                    : SizedBox.shrink(),
                              ),
                              IconButton(
                                icon: Icon(Icons.search, color: Colors.white),
                                onPressed: () {
                                  searchYoutube(_searchController.text);
                                },
                              ),
                            ],
                          ),
                  ),
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  onChanged: (text) {
                    setState(() {});
                  },
                  onSubmitted: (query) {
                    searchYoutube(query);
                  },
                  textInputAction: TextInputAction.search,
                ),
                // SizedBox(
                //   height: 10,
                // ),
                // Row(
                //   spacing: 10,
                //   children: [
                //     ChoiceChip(
                //       label: Text(
                //         'Music',
                //         style: TextStyle(color: Colors.black),
                //       ),
                //       selected: true,
                //       selectedColor: Colors.amber,
                //     ),
                //     // ChoiceChip(label: Text('Podcasts'), selected: false),
                //     // ChoiceChip(label: Text('Music'), selected: false),
                //   ],
                // )
              ],
            ),
          ),
          Expanded(
            child: isOnline
                ? LiquidPullToRefresh(
                    onRefresh: _handleRefresh,
                    color: AppColors.primaryColor,
                    animSpeedFactor: 3,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        // mainAxisSpacing: 5.0,
                      ),
                      padding: EdgeInsets.all(13),
                      itemCount: _isLoading ? 10 : _videos.length,
                      itemBuilder: (context, index) {
                        if (_isLoading) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[800]!,
                            highlightColor: Colors.grey[700]!,
                            child: Container(
                              height: 100,
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          );
                        } else {
                          final video = _videos[index];
                          return VideoComponent(
                            video: video,
                            from: FromWhere.SEARCH,
                          );
                        }
                      },
                    ),
                  )
                : Center(
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
          ),
        ],
      ),
    );
  }
}
