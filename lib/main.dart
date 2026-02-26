import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/screens/main_screen.dart';
import 'package:music_up/screens/setup_wizard_screen.dart';
import 'package:music_up/services/logger_service.dart';
import 'package:music_up/services/service_locator.dart';
import 'package:music_up/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LoggerService.init();
  await ServiceLocator.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;
  late Locale _locale;
  late bool _setupCompleted;
  bool _shouldStartTour = false;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _themeMode = sl.configManager.getThemeMode();
    _locale = sl.configManager.getLocale();
    _setupCompleted = sl.configManager.isSetupCompleted();
  }

  void _updateTheme(ThemeMode mode) {
    if (_themeMode != mode) {
      setState(() {
        _themeMode = mode;
      });
    }
  }

  void _updateLocale(Locale locale) {
    if (_locale != locale) {
      setState(() {
        _locale = locale;
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
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorKey: _navigatorKey,
      builder: (context, child) {
        return Listener(
          onPointerDown: (PointerDownEvent event) {
            // Handle mouse back button
            final backButtonValues = [8, 16, 4, 32];

            if (backButtonValues.contains(event.buttons)) {
              final navigatorState = _navigatorKey.currentState;
              if (navigatorState != null && navigatorState.canPop()) {
                navigatorState.pop();
              }
            }
          },
          child: KeyboardListener(
            focusNode: FocusNode(),
            autofocus: true,
            onKeyEvent: (KeyEvent event) {
              if (event is KeyDownEvent) {
                final isAltPressed = HardwareKeyboard.instance.isAltPressed;
                final isLeftArrow = event.logicalKey == LogicalKeyboardKey.arrowLeft;
                final isBrowserBack = event.logicalKey == LogicalKeyboardKey.browserBack;

                if ((isAltPressed && isLeftArrow) || isBrowserBack) {
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
      home: _setupCompleted
          ? MainScreen(
              onThemeChanged: _updateTheme,
              onLocaleChanged: _updateLocale,
              startTour: _shouldStartTour,
            )
          : SetupWizardScreen(
              onSetupComplete: () {
                setState(() {
                  _setupCompleted = true;
                  _shouldStartTour = !sl.configManager.isTourCompleted();
                });
              },
            ),
      debugShowCheckedModeBanner: false,
    );
  }
}
