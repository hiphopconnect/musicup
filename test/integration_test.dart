import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/screens/main_screen.dart';
import 'package:music_up/screens/add_album_screen.dart';
import 'package:music_up/screens/edit_album_screen.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/services/config_manager.dart';
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
      mockJsonService = MockJsonService();
      
      testAlbums = [];
      
      // Mock initial empty state
      when(mockJsonService.loadAlbums()).thenAnswer((_) async => testAlbums);
      when(mockJsonService.saveAlbums(any)).thenAnswer((invocation) async {
        testAlbums = invocation.positionalArguments[0] as List<Album>;
      });
      
      // Mock config manager
      when(mockJsonService.configManager).thenReturn(ConfigManager());
    });

    testWidgets('Complete flow: View empty state → Add album → Edit album → Delete album', 
      (WidgetTester tester) async {
      
      // 1. START: Launch app with empty album list
      await tester.pumpWidget(
        MaterialApp(
          home: MainScreen(jsonService: mockJsonService),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify empty state is shown
      expect(find.text('Keine Alben gefunden'), findsOneWidget);
      expect(find.text('Fügen Sie Ihr erstes Album hinzu'), findsOneWidget);
      
      // 2. ADD: Navigate to Add Album screen
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Should navigate to AddAlbumScreen
      expect(find.byType(AddAlbumScreen), findsOneWidget);
      expect(find.text('Neues Album hinzufügen'), findsOneWidget);
      
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
      
      // Save album
      await tester.tap(find.byIcon(Icons.save).last);
      await tester.pumpAndSettle();
      
      // Should return to main screen
      expect(find.byType(MainScreen), findsOneWidget);
      
      // Album should be visible
      await tester.pumpAndSettle();
      expect(find.text('Test Integration Album'), findsOneWidget);
      expect(find.text('Test Artist'), findsOneWidget);
      
      // 3. VIEW: Tap album to view details
      await tester.tap(find.text('Test Integration Album'));
      await tester.pumpAndSettle();
      
      // Should show album detail screen
      expect(find.text('Test Integration Album'), findsWidgets); // Title and in content
      expect(find.text('Test Artist'), findsOneWidget);
      expect(find.text('Rock'), findsOneWidget);
      
      // Go back to main screen
      await tester.pageBack();
      await tester.pumpAndSettle();
      
      // 4. EDIT: Edit the album
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();
      
      // Should navigate to EditAlbumScreen
      expect(find.byType(EditAlbumScreen), findsOneWidget);
      expect(find.text('Album bearbeiten'), findsOneWidget);
      
      // Modify album name
      await tester.enterText(
        find.widgetWithText(TextField, 'Album-Name *'),
        'Updated Album Name',
      );
      
      // Save changes
      await tester.tap(find.byIcon(Icons.save).last);
      await tester.pumpAndSettle();
      
      // Should return to main screen with updated album
      expect(find.byType(MainScreen), findsOneWidget);
      expect(find.text('Updated Album Name'), findsOneWidget);
      expect(find.text('Test Artist'), findsOneWidget);
      
      // 5. DELETE: Delete the album
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
      
      // Confirm deletion dialog
      expect(find.text('Album löschen'), findsOneWidget);
      expect(find.text('Möchten Sie \"Updated Album Name\" wirklich löschen?'), findsOneWidget);
      
      await tester.tap(find.text('Löschen'));
      await tester.pumpAndSettle();
      
      // Should show empty state again
      expect(find.text('Keine Alben gefunden'), findsOneWidget);
      expect(find.text('Fügen Sie Ihr erstes Album hinzu'), findsOneWidget);
      
      // Verify album was deleted
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
          home: MainScreen(jsonService: mockJsonService),
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

    testWidgets('Handle form validation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AddAlbumScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Try to save without required fields
      await tester.tap(find.byIcon(Icons.save).last);
      await tester.pumpAndSettle();

      // Should show validation error (stays on same screen)
      expect(find.byType(AddAlbumScreen), findsOneWidget);

      // Now fill required fields
      await tester.enterText(
        find.widgetWithText(TextField, 'Album-Name *'),
        'Valid Album',
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Künstler *'),
        'Valid Artist',
      );

      // Try to save again
      await tester.tap(find.byIcon(Icons.save).last);
      await tester.pumpAndSettle();

      // Should successfully navigate back
      expect(find.byType(MainScreen), findsOneWidget);
      expect(find.text('Valid Album'), findsOneWidget);
    });
  });
}