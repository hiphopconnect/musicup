import 'package:flutter/material.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/screens/main_screen.dart';
import 'package:music_up/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisiere den ConfigManager
  ConfigManager configManager = ConfigManager();
  await configManager.loadConfig();

  // Erstelle eine Instanz des JsonService
  JsonService jsonService = JsonService(configManager);

  runApp(MyApp(jsonService: jsonService, configManager: configManager));
}

class MyApp extends StatelessWidget {
  final JsonService jsonService;
  final ConfigManager configManager;

  const MyApp({super.key, required this.jsonService, required this.configManager});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MusicUp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(jsonService: jsonService), // Übergibt jsonService hier
      routes: {
        '/settings': (context) => SettingsScreen(jsonService: jsonService), // Korrigiert die Übergabe von jsonService
      },
    );
  }
}
