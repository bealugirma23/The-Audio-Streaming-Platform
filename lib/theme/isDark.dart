import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeState extends ChangeNotifier {
  bool _isDark = ui.PlatformDispatcher.instance.platformBrightness == Brightness.dark;

  bool get isDark => _isDark;

  Future<void> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool('isDark');
    _isDark = saved ?? (ui.PlatformDispatcher.instance.platformBrightness == Brightness.dark);
    notifyListeners();
  }

  Future<void> changeTheme(bool mode) async {
    _isDark = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
    notifyListeners();
  }
}

