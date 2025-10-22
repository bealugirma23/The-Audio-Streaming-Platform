import 'package:audiobinge/main.dart';
import 'package:audiobinge/pages/youtubePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts and displays YoutubeScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: YouTubeTwitchTabs()));

    // Verify that the YoutubeScreen is displayed.
    expect(find.byType(YoutubeScreen), findsOneWidget);
  });
}
