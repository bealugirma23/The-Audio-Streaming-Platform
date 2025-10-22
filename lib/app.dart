import 'dart:async';
import 'package:audiobinge/main.dart';
import 'package:audiobinge/services/player.dart';
import 'package:audiobinge/theme/isDark.dart';
import 'package:audiobinge/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:youtube_scrape_api/models/thumbnail.dart';
import 'package:youtube_scrape_api/models/video_data.dart';
import 'package:youtube_scrape_api/youtube_scrape_api.dart';
import 'package:flutter/material.dart';

import 'models/MyVideo.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _intentSub;
  final _sharedFiles = <SharedMediaFile>[];

  @override
  void initState() {
    super.initState();

    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      setState(() {
        _sharedFiles.clear();
        _sharedFiles.addAll(value);

        if (_sharedFiles.isNotEmpty) {
          final videoId =
              _sharedFiles.first.path.split('watch?v=').last.split('&').first;
          addSharedVideo(videoId);
        }

        print(_sharedFiles.map((f) => f.toMap()));
      });
    });

    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      setState(() {
        _sharedFiles.clear();
        _sharedFiles.addAll(value);
        print(_sharedFiles.map((f) => f.toMap()));

        // Tell the library that we are done processing the intent.
        ReceiveSharingIntent.instance.reset();
      });
    });
  }

  Future<void> addSharedVideo(String videoId) async {
    YoutubeDataApi youtubeDataApi = YoutubeDataApi();
    VideoData? sharedVideo = await youtubeDataApi.fetchVideoData(videoId);
    Provider.of<Playing>(context, listen: false).assign(
        MyVideo(
            videoId: videoId,
            channelName: sharedVideo?.video?.channelName,
            title: sharedVideo!.video?.title,
            thumbnails: [
              Thumbnail(
                  url: 'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                  width: 720,
                  height: 404)
            ]),
        true);
  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeService>(context);
    final isDarkMode = Provider.of<ThemeModeState>(context);
    return MaterialApp(
      title: 'Audifier',
      debugShowCheckedModeBanner: false,
      theme: theme.themeData,
      themeMode: isDarkMode.isDark ? ThemeMode.dark : ThemeMode.light,
      home: YouTubeTwitchTabs(),
      // home: UserKeywordScreen(),
    );
  }
}
