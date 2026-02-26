// test/add_album_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/screens/add_album_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AddAlbumScreen Tests', () {
    setUp(() {
      // Clear SharedPreferences to prevent draft dialog from appearing
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Adds a new album', (WidgetTester tester) async {
      Album? addedAlbum;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('de'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddAlbumScreen(),
                    ),
                  );
                  addedAlbum = result as Album?;
                },
                child: const Text('Go to AddAlbumScreen'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to navigate to AddAlbumScreen
      await tester.tap(find.text('Go to AddAlbumScreen'));
      await tester.pumpAndSettle();

      // Enter album details using TextField (not TextFormField)
      await tester.enterText(
        find.widgetWithText(TextField, 'Album-Name *'),
        'New Album',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Künstler *'),
        'New Artist',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Genre (optional)'),
        'New Genre',
      );

      // Select Year
      final yearDropdown = find.widgetWithText(DropdownButtonFormField<String>, 'Jahr');
      await tester.ensureVisible(yearDropdown);
      await tester.pumpAndSettle();
      await tester.tap(yearDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('2021').last);
      await tester.pumpAndSettle();

      // Select Medium
      final mediumDropdown = find.widgetWithText(DropdownButtonFormField<String>, 'Medium');
      await tester.ensureVisible(mediumDropdown);
      await tester.pumpAndSettle();
      await tester.tap(mediumDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('CD').last);
      await tester.pumpAndSettle();

      // Enter track title (required since validation checks for non-empty tracks)
      final trackField = find.widgetWithText(TextField, 'Track 01');
      await tester.ensureVisible(trackField);
      await tester.pumpAndSettle();
      await tester.enterText(trackField, 'First Track');
      await tester.pumpAndSettle();

      // Scroll to and tap save button
      final saveButton = find.text('Album speichern');
      await tester.ensureVisible(saveButton.first);
      await tester.pumpAndSettle();
      await tester.tap(saveButton.first);
      await tester.pumpAndSettle();

      // Verify that the album was added
      expect(addedAlbum, isNotNull);
      expect(addedAlbum!.name, 'New Album');
      expect(addedAlbum!.artist, 'New Artist');
    });
  });
}