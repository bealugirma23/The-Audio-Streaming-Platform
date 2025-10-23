// File: lib/searchPage.dart
import 'package:audiobinge/utils/search_history_saving.dart';
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
  List<String> apiSuggestions = [];
  final _service = SearchHistoryService();
  List<String> _history = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _showSuggestions = false;
      });
    } else {
      setState(() {
        _showSuggestions = true;
      });
    }
  }

  Future<void> _loadHistory() async {
    final history = await _service.getHistory();
    setState(() => _history = history);
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
          // backgroundColor: AppColors.primaryColor,
        ),
      );
      return;
    }
    if (query.trim().isEmpty) return;
    await _service.addSearchTerm(query);
    await _loadHistory();
    setState(() {
      _isSearching = true;
      _showSuggestions = false; // Hide suggestions when search is performed
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

  Future<void> searchSuggestions(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        apiSuggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    try {
      YoutubeDataApi youtubeDataApi = YoutubeDataApi();
      List<String> suggestions = await youtubeDataApi.fetchSuggestions(query);
      setState(() {
        apiSuggestions = suggestions.map((toElement) => toElement).toList();
        _showSuggestions = true; // Show suggestions when we have them
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isOnline = Provider.of<NetworkProvider>(context).isOnline;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 5),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  enableSuggestions: true,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    filled: true,
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
                      // borderSide:
                      // BorderSide(color: AppColors.primaryColor, width: 1.5),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(
                        'assets/icons/youtube.svg',
                        height: 24,
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
                                        icon: Icon(
                                          Icons.clear,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            apiSuggestions =
                                                []; // Clear suggestions
                                            _showSuggestions =
                                                false; // Hide suggestions
                                            _videos = [];
                                          });
                                        },
                                      )
                                    : SizedBox.shrink(),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.search,
                                ),
                                onPressed: () {
                                  searchYoutube(_searchController.text);
                                },
                              ),
                            ],
                          ),
                  ),
                  style: TextStyle(fontSize: 16),
                  onChanged: (text) async {
                    searchSuggestions(text);
                  },
                  onSubmitted: (query) {
                    _searchController.text = query;
                    searchYoutube(query);
                  },
                  textInputAction: TextInputAction.search,
                ),
                // Show search history when search field is empty and no suggestions are shown
                if (_searchController.text.isEmpty && _history.isNotEmpty)
                  SizedBox(
                    height: 400, // Increase height to show more history items
                    child: ListView(
                      children: _history.map((term) {
                        return ListTile(
                          title: Text(term),
                          leading: const Icon(Icons.history),
                          trailing: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _history.remove(term);
                              });
                            },
                          ),
                          onTap: () {
                            _searchController.text = term;
                            searchYoutube(term);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                // Show suggestions when user is typing
                if (_showSuggestions &&
                    _searchController.text.isNotEmpty &&
                    apiSuggestions.isNotEmpty)
                  SizedBox(
                    height: 400,
                    child: ListView.separated(
                      separatorBuilder: (_, __) => const Divider(height: 0),
                      itemCount: apiSuggestions.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Row(
                          children: [
                            Icon(Icons.search),
                            SizedBox(
                              width: 8,
                            ),
                            Text(apiSuggestions[index]),
                          ],
                        ),
                        onTap: () => {
                          _searchController.text = apiSuggestions[index],
                          searchYoutube(apiSuggestions[index])
                        },
                      ),
                    ),
                  )
              ],
            ),
          ),
          Expanded(
            child: isOnline
                ? LiquidPullToRefresh(
                    onRefresh: _handleRefresh,
                    // color: AppColors.primaryColor,
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
                            baseColor: Colors.grey[500]!,
                            highlightColor: Colors.grey[400]!,
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
