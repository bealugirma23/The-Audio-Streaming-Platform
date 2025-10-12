import 'package:audiobinge/theme/colors.dart';
import 'package:audiobinge/theme/isDark.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme {
  darkYellow,
  lightYellow,
  darkRed,
  lightRed,
  darkGreen,
  lightGreen,
}

class ThemeService extends ChangeNotifier {
  final ThemeModeState themeModeState;
  late AppTheme _currentTheme;

  ThemeService(this.themeModeState) {
    {
      _currentTheme =
          themeModeState.isDark ? AppTheme.darkYellow : AppTheme.lightYellow;
    }
  }

  AppTheme get currentTheme => _currentTheme;

  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme.name);
    notifyListeners();
  }

  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme');
    _currentTheme = AppTheme.values.firstWhere(
      (e) => e.name == themeString,
      orElse: () => AppTheme.darkGreen,
    );
    notifyListeners();
  }

  ThemeData get themeData {
    if (themeModeState.isDark) {
      switch (_currentTheme) {
        case AppTheme.darkGreen:
          return darkGreenTheme;
        case AppTheme.darkRed:
          return darkRedTheme;
        case AppTheme.darkYellow:
          return darkYellowTheme;
        default:
          return darkYellowTheme;
      }
    } else {
      switch (_currentTheme) {
        case AppTheme.lightGreen:
          return lightGreenTheme;
        case AppTheme.lightRed:
          return lightRedTheme;
        case AppTheme.lightYellow:
          return lightYellowTheme;
        default:
          return lightYellowTheme;
      }
    }
  }
}

// final themeProvider = ChangeNotifierProvider(create: (_) => ThemeService());
