// Extracted Custom AppBar
import 'package:audiobinge/utils/settings_page.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // Hide the back button
      title: Row(
        children: [
          // App Logo
          Image.asset(
            'assets/icon.png',
            height: 40, // Adjusted for better proportions
            width: 40,
          ),
          SizedBox(width: 10), // Spacing between logo and title
          // App Title
          Text(
            "Audifier",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SettingPage()));
              },
              icon: Icon(Icons.settings_outlined, color: Colors.white)),
        ),
      ],
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
