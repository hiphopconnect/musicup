import 'package:flutter/material.dart';
import 'package:music_up/screens/main_screen.dart';
import 'package:music_up/screens/settings_screen.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisiere den ConfigManager
  ConfigManager configManager = ConfigManager();
  await configManager.loadConfig();

  // Erstelle eine Instanz des JsonService
  JsonService jsonService = JsonService(configManager);

  runApp(MyApp(jsonService: jsonService, configManager: configManager));
}

class MyApp extends StatefulWidget {
  final JsonService jsonService;
  final ConfigManager configManager;

  const MyApp(
      {super.key, required this.jsonService, required this.configManager});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.configManager.getThemeMode();
  }

  void _updateTheme(ThemeMode mode) {
    // Nur setState aufrufen, ConfigManager wird in den Settings gespeichert
    if (_themeMode != mode) {
      // Wichtige Änderung: Nur bei Änderung aktualisieren
      setState(() {
        _themeMode = mode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MusicUp',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: MainScreen(
        jsonService: widget.jsonService,
        onThemeChanged: _updateTheme, // Callback für Theme-Änderungen
      ),
      routes: {
        // Named-Route für Einstellungen
        '/settings': (context) => SettingsScreen(
              jsonService: widget.jsonService,
              onThemeChanged: _updateTheme,
            ),
      },
    );
  }
}
