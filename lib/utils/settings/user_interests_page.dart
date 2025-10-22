import 'package:flutter/material.dart';

class ChangeInterests extends StatefulWidget {
  const ChangeInterests({super.key});

  @override
  State<ChangeInterests> createState() => _ChangeInterestsState();
}

class _ChangeInterestsState extends State<ChangeInterests> {
  // List of available interests
  final List<Map<String, dynamic>> interests = [
    {"icon": Icons.code, "label": "Technology"},
    {"icon": Icons.palette, "label": "Arts"},
    {"icon": Icons.business_center, "label": "Business"},
    {"icon": Icons.language, "label": "Languages"},
    {"icon": Icons.science, "label": "Science"},
    {"icon": Icons.history_edu, "label": "History"},
    {"icon": Icons.menu_book, "label": "Literature"},
    {"icon": Icons.music_note, "label": "Music"},
    {"icon": Icons.favorite_border, "label": "Health"},
    {"icon": Icons.fitness_center, "label": "Fitness"},
    {"icon": Icons.restaurant_menu, "label": "Cooking"},
    {"icon": Icons.flight_takeoff, "label": "Travel"},
  ];

  final Set<String> selectedInterests = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Interests"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle
              const Text(
                "Select your interests to personalize your learning experience.",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'DM Sans',
                ),
              ),

              const SizedBox(height: 20),

              // Interests chips
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: interests.map((interest) {
                  final label = interest["label"] as String;
                  final icon = interest["icon"] as IconData;
                  final isSelected = selectedInterests.contains(label);

                  return ChoiceChip(
                    avatar: Icon(
                      icon,
                      size: 18,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          selectedInterests.add(label);
                        } else {
                          selectedInterests.remove(label);
                        }
                      });
                    },
                    selectedColor: Colors.black,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),

              // Set reminder button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    "Set Channels",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
