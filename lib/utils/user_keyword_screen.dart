import 'package:audiobinge/main.dart';
import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';

class UserKeywordScreen extends StatefulWidget {
  const UserKeywordScreen({super.key});

  @override
  State<UserKeywordScreen> createState() => _UserKeywordScreenState();
}

class _UserKeywordScreenState extends State<UserKeywordScreen> {
  final List<String> selected = [];
  final List<String> _tags = ["podcasts", 'audiobooks', "news"];
  final TextEditingController _controller = TextEditingController();

  void _addTag(String text) {
    final tag = text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
    _controller.clear();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  void initState() {
    super.initState();

    // Example: skip if not first time
    final bool isFirstTime = true; // change to false to skip
    if (!isFirstTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const YouTubeTwitchTabs()),
        );
      });
    }
  }

  void toggleSelection(String interest) {
    setState(() {
      if (selected.contains(interest)) {
        selected.remove(interest);
      } else {
        selected.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Choose your interests",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Select a few topics you like and we’ll tailor content for you.",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in _tags)
                          Chip(
                            label: Text(tag),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () => _removeTag(tag),
                          ),
                        // The input field at the end of the chips
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: 'Add keyword...',
                              border: InputBorder.none,
                            ),
                            onSubmitted: _addTag,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Tags: ${_tags.join(", ")}'),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: AnimatedOpacity(
          opacity: _tags.isEmpty ? 0.5 : 1,
          duration: const Duration(milliseconds: 200),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: _tags.isEmpty
                ? null
                : () async {
                    // TODO: Save selections and continue

                    // final db = Localstore.instance;
                    // await db
                    // .collection('interests')
                    // .doc('')
                    // .set(_tags.toJson());
                    Future.delayed(Duration(milliseconds: 200));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const YouTubeTwitchTabs(),
                      ),
                    );
                  },
            child: const Text(
              "Continue",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Dummy next page for navigation example
