// Extracted Custom AppBar
import 'package:audiobinge/utils/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
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
              // color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsetsGeometry.fromLTRB(0, 0, 16, 0),
          child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SettingPage()));
              },
              child: Icon(
                Icons.settings_outlined,
                // color: Colors.white,
              )),
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
