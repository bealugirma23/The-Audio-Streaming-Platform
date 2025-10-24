import 'dart:io';

import 'package:audiobinge/pages/downloadsPage.dart';
import 'package:audiobinge/theme/isDark.dart';
import 'package:audiobinge/utils/settings/themes_page.dart';
import 'package:audiobinge/utils/settings/user_interests_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _autoPlayEnabled = false;
  int cacheSize = 0;
  double _audioQuality = 2;

  @override
  void initState() {
    super.initState();
    getCacheSize();
  }

  Future<void> getCacheSize() async {
    Directory tempDir = await getTemporaryDirectory();
    int tempDirSize = await _getSize(tempDir);
    setState(() {
      cacheSize = tempDirSize;
    });
  }

  Future<int> _getSize(FileSystemEntity file) async {
    if (file is File) {
      return file.lengthSync();
    } else if (file is Directory) {
      int sum = 0;
      List<FileSystemEntity> children = file.listSync();
      for (FileSystemEntity child in children) {
        sum += await _getSize(child);
      }
      return sum;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModeState>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Playback'),
          // _buildSwitchTile(
          //   icon: Icons.play_circle_outline,
          //   title: 'Auto-play',
          //   subtitle: 'Continue playing similar songs',
          //   value: _autoPlayEnabled,
          //   onChanged: (value) {
          //     setState(() {
          //       _autoPlayEnabled = value;
          //     });
          //   },
          // ),
          _buildSettingTile(
            enabled: false,
            icon: Icons.graphic_eq,
            title: 'Audio Quality',
            subtitle: _getAudioQualityText(),
            onTap: () {
              _showAudioQualityDialog();
            },
          ),
          _buildSettingTile(
            enabled: false,
            icon: Icons.equalizer,
            title: 'Equalizer',
            onTap: () {},
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Preferences'),
          // _buildSwitchTile(
          //   icon: Icons.notifications_outlined,
          //   title: 'Notifications',
          //   subtitle: 'Enable push notifications',
          //   value: _notificationsEnabled,
          //   onChanged: (value) {
          //     setState(() {
          //       _notificationsEnabled = value;
          //     });
          //   },
          // ),
          _buildSettingTile(
            enabled: false,
            icon: Icons.interests,
            title: 'Interests',
            subtitle: 'Change what you want to see',
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChangeInterests()));
            },
          ),

          _buildSettingTile(
            icon: Icons.color_lens,
            title: 'Themes',
            subtitle: 'Change themes you prefer',
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ThemesPage()));
            },
          ),

          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Use dark theme',
            value: isDarkMode.isDark,
            onChanged: (value) {
              isDarkMode.changeTheme(value);
            },
          ),
          // _buildSettingTile(
          //   icon: Icons.language,
          //   title: 'Language',
          //   subtitle: 'English',
          //   onTap: () {},
          // ),
          const SizedBox(height: 20),
          _buildSectionHeader('Storage'),
          _buildSettingTile(
            icon: Icons.download_outlined,
            title: 'Downloads',
            subtitle: 'Manage downloaded songs',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DownloadScreen(),
                ),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.storage_outlined,
            title: 'Clear Cache',
            subtitle: '${(cacheSize / (1024 * 1024)).toStringAsFixed(2)} MB',
            onTap: () {
              _showClearCacheDialog();
            },
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Support'),
          // _buildSettingTile(
          //   icon: Icons.help_outline,
          //   title: 'Help & Support',
          //   onTap: () {},
          // ),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Version 1.0.0',
            onTap: () {},
          ),
          // _buildSettingTile(
          //   icon: Icons.privacy_tip_outlined,
          //   title: 'Privacy Policy',
          //   onTap: () {},
          // ),
          // const SizedBox(height: 30),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //   child: ElevatedButton(
          //     onPressed: () {
          //       _showLogoutDialog();
          //     },
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.transparent,
          //       foregroundColor: Colors.red,
          //       side: const BorderSide(color: Colors.red, width: 1),
          //       padding: const EdgeInsets.symmetric(vertical: 16),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(30),
          //       ),
          //     ),
          //     child: const Text(
          //       'Log Out',
          //       style: TextStyle(
          //         fontSize: 16,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ),
          // ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          // color: AppColors.primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: () {
        if (enabled) {
          onTap();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Coming soon...'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled
              ? theme.colorScheme.surfaceContainer
              : Colors.grey[300], // Greyed background if disabled
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 24,
          color: enabled
              ? theme.iconTheme.color
              : Colors.grey[500], // Muted icon color
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: enabled ? null : Colors.grey[600],
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: enabled ? Colors.grey[600] : Colors.grey[500],
                fontSize: 14,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: enabled ? Colors.grey[400] : Colors.grey[300],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        // activeColor: AppColors.primaryColor,
      ),
    );
  }

  String _getAudioQualityText() {
    switch (_audioQuality.toInt()) {
      case 0:
        return 'Low';
      case 1:
        return 'Normal';
      case 2:
        return 'High';
      case 3:
        return 'Very High';
      default:
        return 'Normal';
    }
  }

  void _showAudioQualityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Audio Quality',
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select your preferred audio quality',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                RadioListTile<int>(
                  title: const Text(
                    'Low',
                  ),
                  subtitle:
                      const Text('96 kbps', style: TextStyle(fontSize: 12)),
                  value: 0,
                  groupValue: _audioQuality.toInt(),
                  // activeColor: AppColors.primaryColor,
                  onChanged: (value) {
                    setDialogState(() {
                      _audioQuality = value!.toDouble();
                    });
                  },
                ),
                RadioListTile<int>(
                  title: const Text(
                    'Normal',
                  ),
                  subtitle: const Text(
                    '160 kbps',
                  ),
                  value: 1,
                  groupValue: _audioQuality.toInt(),
                  // activeColor: AppColors.primaryColor,
                  onChanged: (value) {
                    setDialogState(() {
                      _audioQuality = value!.toDouble();
                    });
                  },
                ),
                RadioListTile<int>(
                  title: const Text(
                    'High',
                  ),
                  subtitle:
                      const Text('320 kbps', style: TextStyle(fontSize: 12)),
                  value: 2,
                  groupValue: _audioQuality.toInt(),
                  // activeColor: AppColors.primaryColor,
                  onChanged: (value) {
                    setDialogState(() {
                      _audioQuality = value!.toDouble();
                    });
                  },
                ),
                RadioListTile<int>(
                  title: const Text(
                    'Very High',
                  ),
                  subtitle: const Text(
                    'FLAC',
                  ),
                  value: 3,
                  groupValue: _audioQuality.toInt(),
                  // activeColor: AppColors.primaryColor,
                  onChanged: (value) {
                    setDialogState(() {
                      _audioQuality = value!.toDouble();
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text(
              'OK',
              // style: TextStyle(color: AppColors.primaryColor)
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Clear Cache',
        ),
        content: const Text(
          'Are you sure you want to clear the cache? This will free up 120 MB of storage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  // backgroundColor: AppColors.primaryColor,
                ),
              );
            },
            child: const Text(
              'Clear',
              // style: TextStyle(color: AppColors.primaryColor)
            ),
          ),
        ],
      ),
    );
  }
}
