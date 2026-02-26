// test/test_helpers.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:music_up/l10n/app_localizations.dart';

/// Creates a MaterialApp with localization delegates for widget tests.
/// Default locale is German to match the app's default behavior.
Widget createLocalizedApp({
  required Widget home,
  Locale locale = const Locale('de'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}
