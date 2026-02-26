import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/screens/main_screen.dart';
import 'package:music_up/screens/add_album_screen.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/discogs_service_unified.dart';
import 'package:music_up/services/service_locator.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Generate mocks
@GenerateNiceMocks([MockSpec<JsonService>()])
import 'integration_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Test: Complete Album Management Flow', () {
    late MockJsonService mockJsonService;
    late List<Album> testAlbums;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      ServiceLocator.instance.reset();

      mockJsonService = MockJsonService();
      testAlbums = [];

      // Mock initial empty state
      when(mockJsonService.loadAlbums()).thenAnswer((_) async => testAlbums);
      when(mockJsonService.saveAlbums(any)).thenAnswer((invocation) async {
        testAlbums = invocation.positionalArguments[0] as List<Album>;
      });

      final configManager = ConfigManager();
      await configManager.loadConfig();

      // Mock config manager
      when(mockJsonService.configManager).thenReturn(configManager);

      ServiceLocator.instance.initForTest(
        configManager: configManager,
        jsonService: mockJsonService,
        discogsService: DiscogsServiceUnified(configManager),
      );
    });

    testWidgets('Complete flow: Add album and delete album',
      (WidgetTester tester) async {

      // 1. START: Launch app with empty album list
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
          home: const MainScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify empty state
      expect(find.text('Keine Alben gefunden'), findsOneWidget);
      expect(find.text('Fügen Sie Ihr erstes Album hinzu'), findsOneWidget);

      // 2. ADD: Navigate to Add Album screen
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.byType(AddAlbumScreen), findsOneWidget);

      // Fill in album details
      await tester.enterText(
        find.widgetWithText(TextField, 'Album-Name *'),
        'Test Integration Album',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Künstler *'),
        'Test Artist',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Genre (optional)'),
        'Rock',
      );

      // Select medium (required for filter to show album)
      await tester.tap(find.text('Medium auswählen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CD').last);
      await tester.pumpAndSettle();

      // Enter track title (required since validation checks for non-empty tracks)
      final trackField = find.widgetWithText(TextField, 'Track 01');
      await tester.ensureVisible(trackField);
      await tester.pumpAndSettle();
      await tester.enterText(trackField, 'Test Track');
      await tester.pumpAndSettle();

      // Save album
      await tester.tap(find.byIcon(Icons.save).last);
      await tester.pumpAndSettle();

      // Should return to main screen with album visible
      expect(find.byType(MainScreen), findsOneWidget);
      expect(find.text('Test Integration Album'), findsOneWidget);
      expect(find.text('Test Artist'), findsOneWidget);

      // 3. DELETE: Delete the album
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      // Confirm deletion
      expect(find.text('Album löschen'), findsOneWidget);
      await tester.tap(find.text('Löschen'));
      await tester.pumpAndSettle();

      // Should show empty state again
      expect(find.text('Keine Alben gefunden'), findsOneWidget);
      expect(testAlbums.isEmpty, true);
    });

    testWidgets('Search and filter albums', (WidgetTester tester) async {
      // Setup test data
      testAlbums = [
        Album(
          id: '1',
          name: 'Rock Album',
          artist: 'Rock Artist',
          genre: 'Rock',
          year: '2020',
          medium: 'Vinyl',
          digital: true,
          tracks: [],
        ),
        Album(
          id: '2',
          name: 'Jazz Album',
          artist: 'Jazz Artist',
          genre: 'Jazz',
          year: '2021',
          medium: 'CD',
          digital: false,
          tracks: [],
        ),
        Album(
          id: '3',
          name: 'Electronic Album',
          artist: 'Electronic Artist',
          genre: 'Electronic',
          year: '2022',
          medium: 'Digital',
          digital: true,
          tracks: [],
        ),
      ];

      when(mockJsonService.loadAlbums()).thenAnswer((_) async => testAlbums);

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
          home: const MainScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // All albums should be visible
      expect(find.text('Rock Album'), findsOneWidget);
      expect(find.text('Jazz Album'), findsOneWidget);
      expect(find.text('Electronic Album'), findsOneWidget);

      // Search for "Rock"
      await tester.enterText(find.byType(TextField).first, 'Rock');
      await tester.pump(const Duration(milliseconds: 500));

      // Only Rock Album should be visible
      expect(find.text('Rock Album'), findsOneWidget);
      expect(find.text('Jazz Album'), findsNothing);
      expect(find.text('Electronic Album'), findsNothing);

      // Clear search
      await tester.enterText(find.byType(TextField).first, '');
      await tester.pump(const Duration(milliseconds: 500));

      // Filter by medium - uncheck Vinyl
      final vinylCheckbox = find.widgetWithText(CheckboxListTile, 'Vinyl');
      if (vinylCheckbox.evaluate().isNotEmpty) {
        await tester.tap(vinylCheckbox);
        await tester.pumpAndSettle();

        // Rock Album (Vinyl) should be hidden
        expect(find.text('Rock Album'), findsNothing);
        expect(find.text('Jazz Album'), findsOneWidget);
        expect(find.text('Electronic Album'), findsOneWidget);
      }
    });

    testWidgets('Track data preserved when adding a new album',
      (WidgetTester tester) async {
      // Setup: existing albums with tracks
      testAlbums = [
        Album(
          id: '1',
          name: 'Existing Album',
          artist: 'Existing Artist',
          genre: 'Rock',
          year: '2020',
          medium: 'Vinyl',
          digital: true,
          tracks: [
            Track(title: 'Song One', trackNumber: '01'),
            Track(title: 'Song Two', trackNumber: '02'),
            Track(title: 'Song Three', trackNumber: '03'),
          ],
        ),
        Album(
          id: '2',
          name: 'Other Album',
          artist: 'Other Artist',
          genre: 'Jazz',
          year: '2021',
          medium: 'CD',
          digital: false,
          tracks: [
            Track(title: 'Jazz Track A', trackNumber: '01'),
            Track(title: 'Jazz Track B', trackNumber: '02'),
          ],
        ),
      ];

      when(mockJsonService.loadAlbums()).thenAnswer((_) async => testAlbums);

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
          home: const MainScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify both albums are shown
      expect(find.text('Existing Album'), findsOneWidget);
      expect(find.text('Other Album'), findsOneWidget);

      // Add a new album
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Album-Name *'),
        'New Album',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Künstler *'),
        'New Artist',
      );

      // Enter track title (required for validation)
      final trackField = find.widgetWithText(TextField, 'Track 01');
      await tester.ensureVisible(trackField);
      await tester.pumpAndSettle();
      await tester.enterText(trackField, 'New Track');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save).last);
      await tester.pumpAndSettle();

      // Verify saveAlbums was called with all albums including tracks
      final captured = verify(mockJsonService.saveAlbums(captureAny)).captured;
      expect(captured.isNotEmpty, true);

      final savedAlbums = captured.last as List<Album>;
      expect(savedAlbums.length, 3);

      // Existing albums must still have their tracks
      final existing = savedAlbums.firstWhere((a) => a.id == '1');
      expect(existing.tracks.length, 3);
      expect(existing.tracks[0].title, 'Song One');
      expect(existing.tracks[1].title, 'Song Two');
      expect(existing.tracks[2].title, 'Song Three');

      final other = savedAlbums.firstWhere((a) => a.id == '2');
      expect(other.tracks.length, 2);
      expect(other.tracks[0].title, 'Jazz Track A');
      expect(other.tracks[1].title, 'Jazz Track B');
    });

    testWidgets('Track data preserved when deleting an album',
      (WidgetTester tester) async {
      // Namen so gewaehlt, dass alphabetische Sortierung klar ist:
      // "Alpha Delete" (A) kommt vor "Zulu Surviving" (Z)
      testAlbums = [
        Album(
          id: '1',
          name: 'Alpha Delete',
          artist: 'Delete Artist',
          genre: 'Pop',
          year: '2020',
          medium: 'CD',
          digital: true,
          tracks: [
            Track(title: 'Delete Song', trackNumber: '01'),
          ],
        ),
        Album(
          id: '2',
          name: 'Zulu Surviving',
          artist: 'Surviving Artist',
          genre: 'HipHop',
          year: '2021',
          medium: 'Vinyl',
          digital: false,
          tracks: [
            Track(title: 'Survive Track 1', trackNumber: '01'),
            Track(title: 'Survive Track 2', trackNumber: '02'),
            Track(title: 'Survive Track 3', trackNumber: '03'),
          ],
        ),
      ];

      when(mockJsonService.loadAlbums()).thenAnswer((_) async => testAlbums);

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
          home: const MainScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Delete first album (alphabetically: "Alpha Delete")
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Löschen'));
      await tester.pumpAndSettle();

      // Verify saveAlbums was called
      final captured = verify(mockJsonService.saveAlbums(captureAny)).captured;
      expect(captured.isNotEmpty, true);

      final savedAlbums = captured.last as List<Album>;

      // Only surviving album should remain
      expect(savedAlbums.length, 1);
      expect(savedAlbums[0].id, '2');
      expect(savedAlbums[0].name, 'Zulu Surviving');

      // Its tracks must be preserved
      expect(savedAlbums[0].tracks.length, 3);
      expect(savedAlbums[0].tracks[0].title, 'Survive Track 1');
      expect(savedAlbums[0].tracks[1].title, 'Survive Track 2');
      expect(savedAlbums[0].tracks[2].title, 'Survive Track 3');
    });

    testWidgets('Handle form validation', (WidgetTester tester) async {
      when(mockJsonService.loadAlbums()).thenAnswer((_) async => []);

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
          home: const MainScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to AddAlbumScreen
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.byType(AddAlbumScreen), findsOneWidget);

      // Try to save without required fields
      await tester.tap(find.byIcon(Icons.save).last);
      await tester.pumpAndSettle();

      // Should stay on AddAlbumScreen (validation prevents save)
      expect(find.byType(AddAlbumScreen), findsOneWidget);

      // Fill only album name, leave artist empty
      await tester.enterText(
        find.widgetWithText(TextField, 'Album-Name *'),
        'Incomplete Album',
      );

      // Try to save again - should still fail (artist required)
      await tester.tap(find.byIcon(Icons.save).last);
      await tester.pumpAndSettle();

      // Should still be on AddAlbumScreen
      expect(find.byType(AddAlbumScreen), findsOneWidget);

      // saveAlbums should never have been called
      verifyNever(mockJsonService.saveAlbums(any));
    });
  });
}
