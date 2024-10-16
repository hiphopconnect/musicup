// test/add_album_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/screens/add_album_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AddAlbumScreen Tests', () {
    testWidgets('Adds a new album', (WidgetTester tester) async {
      Album? addedAlbum;

      await tester.pumpWidget(
        MaterialApp(
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

      // Enter album details
      await tester.enterText(find.byType(TextFormField).at(0), 'New Album');
      await tester.enterText(find.byType(TextFormField).at(1), 'New Artist');
      await tester.enterText(find.byType(TextFormField).at(2), 'New Genre');

      // Select Year
      await tester.tap(find.byType(DropdownButtonFormField<String>).at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2021').last);
      await tester.pumpAndSettle();

      // Select Medium
      await tester.tap(find.byType(DropdownButtonFormField<String>).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CD').last);
      await tester.pumpAndSettle();

      // Select Digital
      await tester.tap(find.byType(DropdownButtonFormField<String>).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yes').last);
      await tester.pumpAndSettle();

      // Save the album
      await tester.tap(find.text('Save Album'));
      await tester.pumpAndSettle();

      // Verify that the album was added
      expect(addedAlbum, isNotNull);
      expect(addedAlbum!.name, 'New Album');
    });
  });
}
