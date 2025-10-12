import 'dart:io';

import 'package:audiobinge/provider/connectivityProvider.dart';
import 'package:flutter/material.dart';
import '../services/youtubeAudioStream.dart';
import '../main.dart';
import 'package:provider/provider.dart';

import '../services/player.dart';

class BottomPlayer extends StatefulWidget {
  const BottomPlayer({super.key});

  @override
  State<BottomPlayer> createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<BottomPlayer> {
  @override
  Widget build(BuildContext context) {
    final playing = Provider.of<Playing>(context, listen: false);
    bool isOnline = Provider.of<NetworkProvider>(context).isOnline;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Center(
        child: Container(
          height: 90,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 250),
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              YoutubeAudioPlayer(videoId: 'fRh_vgS2dFE'),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
        
                            final tween = Tween(begin: begin, end: end);
                            final offsetAnimation = animation.drive(tween);
                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15),
                              bottom: Radius.circular(15),
                            ),
                            child: SizedBox(
                              width: 50, // Fixed width for thumbnail
                              height: 50, // Fixed height for thumbnail
                              child: AspectRatio(
                                aspectRatio: 1, // Maintain aspect ratio
                                child: (playing.video.localimage != null)
                                    ? Image.file(
                                        File(playing.video.localimage!),
                                        fit: BoxFit
                                            .cover, // Or BoxFit.fitWidth/fitHeight
                                      )
                                    : (isOnline)
                                        ? Image.network(
                                            playing.video.thumbnails![0].url!,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'assets/icon.png',
                                            fit: BoxFit.cover,
                                          ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 180,
                                child: Text(
                                  playing.video.title!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    // color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                playing.video.channelName!,
                                style: TextStyle(
                                  fontSize: 12,
                                  // color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        playing.setIsPlaying(!playing.isPlaying);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: playing.isloading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1,
                                  // color: Colors.white,
                                ),
                              )
                            : Icon(
                                playing.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                // color: Colors.white,
                                size: 24,
                              ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                SliderTheme(
                  data: SliderThemeData(
                    overlayShape: SliderComponentShape.noOverlay,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                    thumbColor: Colors.white,
                    trackShape: RectangularSliderTrackShape(),
                    trackHeight: 4,
                    // activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.grey[700],
                  ),
                  child: Slider(
                    value: playing.duration.inSeconds > 0.0
                        ? playing.position.inSeconds / playing.duration.inSeconds
                        : 0.0,
                    onChanged: (value) {
                      playing.seekAudio(Duration(
                          seconds: (value * playing.duration.inSeconds).toInt()));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
