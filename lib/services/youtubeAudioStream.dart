import 'dart:io';
import 'package:audiobinge/models/MyVideo.dart';
import 'package:audiobinge/pages/channelVideosPage.dart';
import 'package:audiobinge/theme/isDark.dart';
import 'package:audiobinge/utils/likedPlaylistUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../provider/connectivityProvider.dart';
import 'fetchYoutubeStreamUrl.dart';
import 'player.dart';
import '../utils/thumbnailUtils.dart';

// LikeNotifier provider
class LikeNotifier extends ChangeNotifier {
  bool _isLiked = false;
  MyVideo? _currentVideo;

  bool get isLiked => _isLiked;

  void setVideo(MyVideo video) async {
    _currentVideo = video;
    _isLiked = await isLikedVideo(video);
    notifyListeners();
  }

  void toggleLike() {
    _isLiked = !_isLiked;
    if (_isLiked) {
      addToLikedPlaylist(_currentVideo!);
    } else {
      removeFromLikedPlaylist(_currentVideo!);
    }
    notifyListeners();
  }
}

class YoutubeAudioPlayer extends StatefulWidget {
  final String videoId;
  const YoutubeAudioPlayer({super.key, required this.videoId});

  @override
  _YoutubeAudioPlayerState createState() => _YoutubeAudioPlayerState();
}

class _YoutubeAudioPlayerState extends State<YoutubeAudioPlayer> {
  bool _showLyrics = false;
  double playbackSpeed = 1.0;
  bool _speedControlExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<NetworkProvider>(context).isOnline;
    final playing = context.watch<Playing>();
    final likeNotifier = context.watch<LikeNotifier>();
    likeNotifier.setVideo(playing.video);

    final isDarkMode = Provider.of<ThemeModeState>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            systemOverlayStyle: isDarkMode.isDark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Now Playing'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.queue_music,
                ),
                onPressed: () {
                  _showQueue(context, playing, isOnline);
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              // Background
              // Positioned.fill(
              //   child: _buildBackground(playing, isOnline),
              // ),

              // Main content
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Album Art
                      Container(
                        height: screenHeight * 0.35,
                        width: screenWidth * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          image: _buildAlbumImage(playing, isOnline),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      // Speed control
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.06),
                        child: _buildSpeedControl(playing),
                      ),
                      SizedBox(height: screenHeight * 0.04),

                      // Title and Channel
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.06),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 35,
                              child: buildMarqueeVideoTitle(
                                  playing.video.title ?? 'Unknown Title'),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChannelVideosPage(
                                            videoId: playing.video.videoId!,
                                            channelName:
                                                playing.video.channelName ?? '',
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      playing.video.channelName ??
                                          'Unknown channel',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Consumer<LikeNotifier>(
                                      builder: (context, notifier, _) {
                                        return _animatedButton(
                                          notifier.isLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          notifier.toggleLike,
                                          28,
                                          color: notifier.isLiked
                                              ? Colors.red
                                              : Colors.white,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 20),
                                    _animatedButton(
                                      Icons.lyrics,
                                      () {
                                        setState(() {
                                          _showLyrics = !_showLyrics;
                                          fetchYoutubeClosedCaptions(
                                              playing.video.videoId!);
                                        });
                                      },
                                      28,
                                      color: _showLyrics
                                          ? Colors.blue
                                          : Colors.white,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Lyrics
                      if (_showLyrics)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.06, vertical: 16),
                          child: Text(
                            playing.currentCaption,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),

                      // Progress bar
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.06),
                        child: Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(),
                              child: Slider(
                                min: 0,
                                max: playing.duration.inSeconds.toDouble(),
                                value:
                                    playing.position.inSeconds.toDouble().clamp(
                                          0,
                                          playing.duration.inSeconds.toDouble(),
                                        ),
                                onChanged: (value) {
                                  playing.seekAudio(
                                      Duration(seconds: value.toInt()));
                                },
                              ),
                            ),
                            buildTimeDisplay(
                                playing.position, playing.duration),
                          ],
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.03),

                      // Playback controls
                      _buildControls(context, playing),
                      SizedBox(height: screenHeight * 0.05),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Background image with blur
  Widget _buildBackground(Playing playing, bool isOnline) {
    return Stack(
      fit: StackFit.expand,
      children: [
        (playing.video.localimage != null)
            ? Image.file(File(playing.video.localimage!), fit: BoxFit.cover)
            : (isOnline)
                ? Image.network(playing.video.thumbnails![0].url!,
                    fit: BoxFit.contain)
                : Image.asset('assets/icon.png', fit: BoxFit.cover),
        // BackdropFilter(
        //   filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        //   child: Container(
        //       // color:
        //       // Colors.black.withOpacity(0.6), // Adjustable background overlay
        //       ),
        // ),
      ],
    );
  }

  // Album art image
  DecorationImage _buildAlbumImage(Playing playing, bool isOnline) {
    if (playing.video.localimage != null) {
      return DecorationImage(
          image: FileImage(File(playing.video.localimage!)), fit: BoxFit.cover);
    } else if (isOnline) {
      return DecorationImage(
          image: NetworkImage(playing.video.thumbnails![0].url!),
          fit: BoxFit.cover);
    } else {
      return const DecorationImage(
          image: AssetImage('assets/logo.png'), fit: BoxFit.cover);
    }
  }

  // Speed control section
  Widget _buildSpeedControl(Playing playing) {
    return _speedControlExpanded
        ? Row(
            children: [
              const Text(
                "Speed",
              ),
              Expanded(
                child: Slider(
                  min: 0.5,
                  max: 2.0,
                  divisions: 6,
                  value: playbackSpeed,
                  onChanged: (value) {
                    setState(() {
                      playbackSpeed = value;
                    });
                    playing.audioPlayer.setSpeed(value);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.expand_less),
                onPressed: () => setState(() {
                  _speedControlExpanded = false;
                }),
              ),
            ],
          )
        : GestureDetector(
            onTap: () => setState(() => _speedControlExpanded = true),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.speed,
                ),
                const SizedBox(width: 8),
                Text(
                  "${playbackSpeed.toStringAsFixed(1)}x",
                ),
              ],
            ),
          );
  }

  // Playback controls row
  Widget _buildControls(BuildContext context, Playing playing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _animatedButton(Icons.shuffle, playing.toggleShuffle, 24,
            color: playing.isShuffling ? Colors.blue : Colors.white),
        const SizedBox(width: 16),
        _animatedButton(Icons.skip_previous, playing.previous, 32),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            playing.isPlaying ? playing.pause() : playing.play();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Icon(
              playing.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
              size: 72,
            ),
          ),
        ),
        const SizedBox(width: 16),
        _animatedButton(Icons.skip_next, playing.next, 32),
        const SizedBox(width: 16),
        _animatedButton(
          playing.isLooping == 1 ? Icons.repeat_one : Icons.repeat_rounded,
          playing.toggleLooping,
          24,
          color: playing.isLooping == 0 ? Colors.white : Colors.blueAccent,
        ),
      ],
    );
  }

  // Reuse your existing queue function (but fix Expanded issue)
  void _showQueue(BuildContext context, Playing playing, bool isOnline) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        return Container(
          height: screenHeight * 0.6,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Queue',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: playing.queue.length,
                  itemBuilder: (context, index) {
                    final video = playing.queue[index];
                    final isCurrent = video.videoId == playing.video.videoId;
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (video.localimage != null)
                            ? Image.file(File(video.localimage!),
                                height: 50, width: 50, fit: BoxFit.cover)
                            : (isOnline)
                                ? Image.network(video.thumbnails![0].url!,
                                    height: 50, width: 50, fit: BoxFit.cover)
                                : Image.asset('assets/icon.png',
                                    height: 50, width: 50, fit: BoxFit.cover),
                      ),
                      title: Text(video.title ?? '',
                          style: TextStyle(
                              color: isCurrent ? Colors.blue : Colors.white)),
                      subtitle: Text(video.channelName ?? '',
                          style: TextStyle(
                              color: isCurrent
                                  ? Colors.blue.shade200
                                  : Colors.white70)),
                      onTap: () {
                        playing.assign(video, false);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _animatedButton(IconData icon, VoidCallback onPressed, double size,
      {Color color = Colors.white}) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
        ),
        child: Icon(
          icon,
          size: size,
        ),
      ),
    );
  }
}
