import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/main.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/json_service.dart';

void main() {
  testWidgets('App starts and displays MainScreen', (WidgetTester tester) async {
    ConfigManager configManager = ConfigManager();
    await configManager.loadConfig();
    JsonService jsonService = JsonService(configManager);

    await tester.pumpWidget(MyApp(jsonService: jsonService, configManager: configManager));

    expect(find.text('MusicUp'), findsOneWidget);
  });
}
