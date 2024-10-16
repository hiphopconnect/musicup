// test/main_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/screens/main_screen.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/json_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MainScreen displays a list of albums',
      (WidgetTester tester) async {
    // Initialize services
    ConfigManager configManager = ConfigManager();
    JsonService jsonService = JsonService(configManager);

    await tester.pumpWidget(
      MaterialApp(
        home: MainScreen(jsonService: jsonService),
      ),
    );

    // Wait for asynchronous operations
    await tester.pumpAndSettle();

    // Verify that the list of albums is displayed
    expect(find.text('No albums found.'), findsNothing);
    // Add more specific checks based on your UI
  });
}
