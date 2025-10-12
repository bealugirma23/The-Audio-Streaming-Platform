import 'package:audiobinge/main.dart';
import 'package:flutter/material.dart';

class UserKeywordScreen extends StatefulWidget {
  const UserKeywordScreen({super.key});

  @override
  State<UserKeywordScreen> createState() => _UserKeywordScreenState();
}

class _UserKeywordScreenState extends State<UserKeywordScreen> {
  final List<String> interests = [
    "Music",
    "Sports",
    "Fashion",
    "Technology",
    "Travel",
    "Food",
    "Gaming",
    "Movies",
    "Science",
    "Health",
    "Art",
    "Finance",
    "Education",
    "Comedy",
    "Fitness",
    "Lifestyle",
    "Animals",
  ];

  final List<String> selected = [];

  @override
  void initState() {
    super.initState();

    // Example: skip if not first time
    final bool isFirstTime = false; // change to false to skip
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
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Select a few topics you like and we’ll tailor content for you.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: interests.length,
                  itemBuilder: (context, index) {
                    final item = interests[index];
                    final isSelected = selected.contains(item);
                    return GestureDetector(
                      onTap: () => toggleSelection(item),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.amber : Colors.grey[850],
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            item,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              AnimatedOpacity(
                opacity: selected.isEmpty ? 0.5 : 1,
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: selected.isEmpty
                      ? null
                      : () {
                          // TODO: Save selections and continue
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
              // const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Dummy next page for navigation example
