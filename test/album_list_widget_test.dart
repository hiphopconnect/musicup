import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/widgets/album_list_widget.dart';

void main() {
  group('AlbumListWidget Tests', () {
    late List<Album> testAlbums;

    setUp(() {
      testAlbums = [
        Album(
          id: '1',
          name: 'Test Album 1',
          artist: 'Artist 1',
          genre: 'Rock',
          year: '2020',
          medium: 'Vinyl',
          digital: true,
          tracks: [], // Empty for performance
        ),
        Album(
          id: '2',
          name: 'Test Album 2',
          artist: 'Artist 2',
          genre: 'Jazz',
          year: '2021',
          medium: 'CD',
          digital: false,
          tracks: [],
        ),
      ];
    });

    testWidgets('Displays loading indicator when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlbumListWidget(
              albums: [],
              isLoading: true,
              onViewAlbum: (_) {},
              onEditAlbum: (_) {},
              onDeleteAlbum: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('Displays empty state when no albums', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlbumListWidget(
              albums: [],
              isLoading: false,
              onViewAlbum: (_) {},
              onEditAlbum: (_) {},
              onDeleteAlbum: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Keine Alben gefunden'), findsOneWidget);
      expect(find.text('Fügen Sie Ihr erstes Album hinzu'), findsOneWidget);
      expect(find.byIcon(Icons.album), findsOneWidget);
    });

    testWidgets('Displays list of albums', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlbumListWidget(
              albums: testAlbums,
              isLoading: false,
              onViewAlbum: (_) {},
              onEditAlbum: (_) {},
              onDeleteAlbum: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Album 1'), findsOneWidget);
      expect(find.text('Artist 1'), findsOneWidget);
      expect(find.text('Test Album 2'), findsOneWidget);
      expect(find.text('Artist 2'), findsOneWidget);
    });

    testWidgets('Shows correct medium icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlbumListWidget(
              albums: testAlbums,
              isLoading: false,
              onViewAlbum: (_) {},
              onEditAlbum: (_) {},
              onDeleteAlbum: (_) {},
            ),
          ),
        ),
      );

      // Vinyl and CD should both use album icon
      expect(find.byIcon(Icons.album), findsNWidgets(2));
    });

    testWidgets('Edit and delete buttons are visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlbumListWidget(
              albums: testAlbums,
              isLoading: false,
              onViewAlbum: (_) {},
              onEditAlbum: (_) {},
              onDeleteAlbum: (_) {},
            ),
          ),
        ),
      );

      // Each album should have edit and delete buttons
      expect(find.byIcon(Icons.edit), findsNWidgets(2));
      expect(find.byIcon(Icons.delete), findsNWidgets(2));
    });

    testWidgets('Tap on album triggers onViewAlbum', (WidgetTester tester) async {
      Album? tappedAlbum;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlbumListWidget(
              albums: testAlbums,
              isLoading: false,
              onViewAlbum: (album) => tappedAlbum = album,
              onEditAlbum: (_) {},
              onDeleteAlbum: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Test Album 1'));
      await tester.pumpAndSettle();

      expect(tappedAlbum, isNotNull);
      expect(tappedAlbum!.name, 'Test Album 1');
    });

    testWidgets('Edit button triggers onEditAlbum', (WidgetTester tester) async {
      Album? editedAlbum;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlbumListWidget(
              albums: testAlbums,
              isLoading: false,
              onViewAlbum: (_) {},
              onEditAlbum: (album) => editedAlbum = album,
              onDeleteAlbum: (_) {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      expect(editedAlbum, isNotNull);
      expect(editedAlbum!.name, 'Test Album 1');
    });

    testWidgets('Delete button triggers onDeleteAlbum', (WidgetTester tester) async {
      Album? deletedAlbum;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlbumListWidget(
              albums: testAlbums,
              isLoading: false,
              onViewAlbum: (_) {},
              onEditAlbum: (_) {},
              onDeleteAlbum: (album) => deletedAlbum = album,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      expect(deletedAlbum, isNotNull);
      expect(deletedAlbum!.name, 'Test Album 1');
    });

    testWidgets('ListView has correct performance optimizations', (WidgetTester tester) async {
      // Create many albums to test performance
      final manyAlbums = List.generate(100, (index) => Album(
        id: '$index',
        name: 'Album $index',
        artist: 'Artist $index',
        genre: 'Genre',
        year: '2020',
        medium: 'CD',
        digital: false,
        tracks: [],
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlbumListWidget(
              albums: manyAlbums,
              isLoading: false,
              onViewAlbum: (_) {},
              onEditAlbum: (_) {},
              onDeleteAlbum: (_) {},
            ),
          ),
        ),
      );

      // Check that ListView.builder is used (not all items rendered at once)
      final listViewFinder = find.byType(ListView);
      expect(listViewFinder, findsOneWidget);

      // Check that itemExtent is set for performance
      final ListView listView = tester.widget(listViewFinder);
      expect(listView.itemExtent, 80.0);
      expect(listView.cacheExtent, 400.0);
    });

    testWidgets('Cards have correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlbumListWidget(
              albums: testAlbums,
              isLoading: false,
              onViewAlbum: (_) {},
              onEditAlbum: (_) {},
              onDeleteAlbum: (_) {},
            ),
          ),
        ),
      );

      final cardFinder = find.byType(Card);
      expect(cardFinder, findsNWidgets(2));

      // Check first card's color
      final Card card = tester.widget(cardFinder.first);
      expect(card.color, const Color(0xFF2C2C2C)); // Charcoal background
    });

    testWidgets('Text overflow is handled correctly', (WidgetTester tester) async {
      final longNameAlbum = Album(
        id: 'long',
        name: 'A' * 100, // Very long name
        artist: 'B' * 100, // Very long artist
        genre: 'Genre',
        year: '2020',
        medium: 'CD',
        digital: false,
        tracks: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlbumListWidget(
              albums: [longNameAlbum],
              isLoading: false,
              onViewAlbum: (_) {},
              onEditAlbum: (_) {},
              onDeleteAlbum: (_) {},
            ),
          ),
        ),
      );

      // Find Text widgets with overflow property
      final titleTextFinder = find.byWidgetPredicate((widget) =>
        widget is Text && 
        widget.overflow == TextOverflow.ellipsis &&
        widget.data != null &&
        widget.data!.contains('A')
      );
      
      expect(titleTextFinder, findsOneWidget);
    });
  });
}