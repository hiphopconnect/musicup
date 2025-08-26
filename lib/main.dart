import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

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
      navigatorKey: _navigatorKey,
      builder: (context, child) {
        return Listener(
          onPointerDown: (PointerDownEvent event) {
            // Debug: Print button values to console
            print('Mouse button pressed: ${event.buttons} (kind: ${event.kind})');
            
            // Try multiple common values for back button
            // Different systems/mice use different values
            final backButtonValues = [8, 16, 4, 32]; // Common back button values
            
            if (backButtonValues.contains(event.buttons)) {
              print('Back button detected! Attempting navigation...');
              
              // Use the global navigator key
              final navigatorState = _navigatorKey.currentState;
              if (navigatorState != null && navigatorState.canPop()) {
                navigatorState.pop();
                print('Navigation successful!');
              } else {
                print('Cannot pop - already at root or no navigator found');
              }
            }
          },
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            autofocus: true,
            onKey: (RawKeyEvent event) {
              // Also handle keyboard shortcuts like Alt+Left
              if (event is RawKeyDownEvent) {
                final isAltPressed = event.isAltPressed;
                final isLeftArrow = event.logicalKey == LogicalKeyboardKey.arrowLeft;
                final isBrowserBack = event.logicalKey == LogicalKeyboardKey.browserBack;
                
                if ((isAltPressed && isLeftArrow) || isBrowserBack) {
                  print('Keyboard back shortcut detected!');
                  final navigatorState = _navigatorKey.currentState;
                  if (navigatorState != null && navigatorState.canPop()) {
                    navigatorState.pop();
                  }
                }
              }
            },
            child: child!,
          ),
        );
      },
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

// Intent for mouse back button
class _BackIntent extends Intent {
  const _BackIntent();
}

// Action for handling mouse back button
class _BackAction extends Action<_BackIntent> {
  @override
  Object? invoke(_BackIntent intent) {
    // Get the current navigator context
    final context = primaryFocus?.context;
    if (context != null && Navigator.canPop(context)) {
      Navigator.pop(context);
      return null;
    }
    return null;
  }
}
