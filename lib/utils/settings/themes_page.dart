import 'package:audiobinge/theme/colors.dart';
import 'package:audiobinge/theme/isDark.dart';
import 'package:audiobinge/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemesPage extends StatefulWidget {
  const ThemesPage({super.key});

  @override
  State<ThemesPage> createState() => _ThemesPageState();
}

class _ThemesPageState extends State<ThemesPage> {
  final themeNameMap = <AppTheme, String>{
    AppTheme.darkGreen: 'Green',
    AppTheme.darkYellow: 'Yellow',
    AppTheme.darkRed: 'Red',
  };

  final themeNameDarkMap = <AppTheme, String>{
    AppTheme.lightRed: 'Red',
    AppTheme.lightGreen: 'Green',
    AppTheme.lightYellow: 'Yellow',
  };

  final primaryColorMap = <AppTheme, Color>{
    AppTheme.darkGreen: darkGreenTheme.colorScheme.primary,
    AppTheme.lightGreen: lightGreenTheme.colorScheme.primary,
    AppTheme.darkYellow: darkYellowTheme.colorScheme.primary,
    AppTheme.lightYellow: lightYellowTheme.colorScheme.primary,
    AppTheme.darkRed: darkRedTheme.colorScheme.primary,
    AppTheme.lightRed: lightRedTheme.colorScheme.primary,
  };

  final secondaryColorMap = <AppTheme, Color>{
    AppTheme.darkGreen: darkGreenTheme.colorScheme.secondary,
    AppTheme.lightGreen: lightGreenTheme.colorScheme.secondary,
    AppTheme.darkYellow: darkYellowTheme.colorScheme.secondary,
    AppTheme.lightYellow: lightYellowTheme.colorScheme.secondary,
    AppTheme.darkRed: darkRedTheme.colorScheme.secondary,
    AppTheme.lightRed: lightRedTheme.colorScheme.secondary,
  };

  final tertiaryColorMap = <AppTheme, Color>{
    AppTheme.darkGreen: darkGreenTheme.colorScheme.tertiary,
    AppTheme.lightGreen: lightGreenTheme.colorScheme.tertiary,
    AppTheme.darkYellow: darkYellowTheme.colorScheme.tertiary,
    AppTheme.lightYellow: lightYellowTheme.colorScheme.tertiary,
    AppTheme.darkRed: darkRedTheme.colorScheme.tertiary,
    AppTheme.lightRed: lightRedTheme.colorScheme.tertiary,
  };

  @override
  Widget build(BuildContext context) {
    final appThemes = Provider.of<ThemeModeState>(context).isDark
        ? themeNameMap.keys.toList()
        : themeNameDarkMap.keys.toList();
    final theme = Provider.of<ThemeService>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Themes')),
      body: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        itemCount: appThemes.length,
        itemBuilder: (context, index) {
          final itemAppTheme = appThemes[index];
          final name = themeNameMap[itemAppTheme]!;
          final isTheme = theme.currentTheme == itemAppTheme;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => theme.setTheme(itemAppTheme),
                  child: Container(
                    padding: EdgeInsets.all(7),
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        border: BoxBorder.all(
                            color: isTheme
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 1)),
                    child: Column(
                      children: [
                        Text(name,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildColorCircle(primaryColorMap[itemAppTheme]!),
                            _buildColorCircle(secondaryColorMap[itemAppTheme]!),
                            _buildColorCircle(tertiaryColorMap[itemAppTheme]!),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorCircle(Color color) => Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
      );
}
