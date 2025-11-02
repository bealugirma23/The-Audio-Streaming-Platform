import 'package:flutter/material.dart';

class AppColors {
  static const accentColor = Colors.amber;
  static const primaryColor = Color(0xFFCFB53B);
}

ThemeData darkYellowTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.yellow,
    surface: Colors.black,
    brightness: Brightness.dark,
  ),
);

ThemeData lightYellowTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.yellow,
    surface: Colors.white,
    brightness: Brightness.light,
  ),
);

ThemeData darkRedTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.red,
    surface: Colors.black,
    brightness: Brightness.dark,
  ),
);

ThemeData lightRedTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.red,
    surface: Colors.white,
    brightness: Brightness.light,
  ),
);

ThemeData darkGreenTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.green,
    surface: Colors.black,
    brightness: Brightness.dark,
  ),
);

ThemeData lightGreenTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.green,
    surface: Colors.white,
    brightness: Brightness.light,
  ),
);
