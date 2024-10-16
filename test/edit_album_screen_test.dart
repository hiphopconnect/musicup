// test/edit_album_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/screens/edit_album_screen.dart';

void main() {
  group('EditAlbumScreen Tests', () {
    late Album testAlbum;

    setUp(() {
      testAlbum = Album(
        id: '1',
        name: 'Test Album',
        artist: 'Test Artist',
        genre: 'Test Genre',
        year: '2021',
        medium: 'CD',
        digital: false,
        tracks: [
          Track(title: 'Track 1', trackNumber: '01'),
          Track(title: 'Track 2', trackNumber: '02'),
        ],
      );
    });

    testWidgets('Edits album details and saves', (WidgetTester tester) async {
      Album? updatedAlbum;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAlbumScreen(album: testAlbum),
                    ),
                  );
                  updatedAlbum = result as Album?;
                },
                child: const Text('Go to EditAlbumScreen'),
              ),
            ),
          ),
        ),
      );

      // Tap the button to navigate to EditAlbumScreen
      await tester.tap(find.text('Go to EditAlbumScreen'));
      await tester.pumpAndSettle();

      // Modify album name
      await tester.enterText(find.byType(TextFormField).at(0), 'Updated Album');

      // Tap Save Album
      await tester.tap(find.text('Save Album'));
      await tester.pumpAndSettle();

      // Verify that the album was updated
      expect(updatedAlbum, isNotNull);
      expect(updatedAlbum!.name, 'Updated Album');
    });
  });
}
