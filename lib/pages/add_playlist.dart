import 'package:audiobinge/models/MyVideo.dart';
import 'package:audiobinge/models/PlayList.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstore/localstore.dart';
import 'package:youtube_scrape_api/models/video.dart';
import 'package:youtube_scrape_api/youtube_scrape_api.dart';

class AddPlayListScreen extends StatefulWidget {
  const AddPlayListScreen({super.key});

  @override
  State<AddPlayListScreen> createState() => _AddPlayListScreenState();
}

class _AddPlayListScreenState extends State<AddPlayListScreen> {
  final TextEditingController _linkController = TextEditingController();
  bool _isLoading = false;
  bool hasError = false;
  String error = '';
  bool successModal = false;

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<String?> pasteFromClipboard() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text; // Returns the text or null if no text data is found
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Add Playlist",
              style: TextStyle(fontSize: 18),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _linkController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Invitation link cannot be empty";
                          }
                          return null; // ✅ return null means no error
                        },
                        decoration: InputDecoration(
                          hintText: "Enter Playlist link",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey.shade700),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 57,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          final result = await pasteFromClipboard();
                          setState(() {
                            _linkController.text = result!;
                          });
                        },
                        child: const Text("Paste Link"),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                if (hasError)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(error, style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                const Text(
                  "Enter the playlist link below to add your playlist.",
                  textAlign: TextAlign.start,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),

                const Spacer(),

                // if (successModal) succesModal(),

                // Join button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    onPressed: () async {
                      final codetxt = _linkController.text;
                      final db = Localstore.instance;
                      YoutubeDataApi youtubeDataApi = YoutubeDataApi();
                      List videoResult =
                          await youtubeDataApi.fetchSearchVideo(codetxt);
                      print("element: ${videoResult.toString()}");
                      // final addedPlaylist = MyPlayList(
                      //     coverImage: videoResult[0]['cover_image'],
                      //     title: "Playlist 1",
                      //     videos: videoResult.forEach((element) {
                      //       element;
                      //     })
                      // if successful create and go to the  playlist
                      // add to database with title
                      // db.add(addedPlaylist);
                      // Navigator.of(context).push(
                      // MaterialPageRoute(builder: (context) => PlayListDetail()));
                      // },
                    },
                    child: const Text(
                      "Add to Playlist",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isLoading) CircularProgressIndicator(),
      ],
    );
  }
}
