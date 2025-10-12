import 'package:flutter/material.dart';

class AppColors {
  static const accentColor = Colors.amber;
  static const primaryColor = Color(0xFFCFB53B);
}

ThemeData darkYellowTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.yellow,
    brightness: Brightness.dark,
  ),
);

ThemeData lightYellowTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.yellow,
    brightness: Brightness.light,
  ),
);

ThemeData darkRedTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.red,
    brightness: Brightness.dark,
  ),
);

ThemeData lightRedTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.red,
    brightness: Brightness.light,
  ),
);

ThemeData darkGreenTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.green,
    brightness: Brightness.dark,
  ),
);

ThemeData lightGreenTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.green,
    brightness: Brightness.light,
  ),
);
