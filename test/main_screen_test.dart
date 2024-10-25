import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/screens/main_screen.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/json_service.dart';

// Mock class for JsonService
class MockJsonService extends Mock implements JsonService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MainScreen displays a list of albums',
      (WidgetTester tester) async {
    // Log to check test progress
    print('Creating mockJsonService');

    // Create a mock JsonService
    MockJsonService mockJsonService = MockJsonService();

    // Initialize services
    ConfigManager configManager = ConfigManager();
    await configManager.loadConfig();

    // Create a test album with tracks
    List<Album> testAlbums = [
      Album(
        id: '1',
        name: 'Test Album 1',
        artist: 'Test Artist',
        genre: 'Test Genre',
        year: '2021',
        medium: 'CD',
        digital: false,
        tracks: [
          Track(title: 'Track 1', trackNumber: '01'),
          Track(title: 'Track 2', trackNumber: '02'),
        ],
      ),
      Album(
        id: '2',
        name: 'Test Album 2',
        artist: 'Another Artist',
        genre: 'Another Genre',
        year: '2022',
        medium: 'Vinyl',
        digital: true,
        tracks: [
          Track(title: 'Track A', trackNumber: '01'),
          Track(title: 'Track B', trackNumber: '02'),
        ],
      ),
    ];

    // Mock loading albums
    when(mockJsonService.loadAlbums()).thenAnswer((_) async => testAlbums);

    // Build the MainScreen widget
    print('Before pumpWidget');
    await tester.pumpWidget(
      MaterialApp(
        home: MainScreen(jsonService: mockJsonService),
      ),
    );
    print('After pumpWidget');

    // Wait for asynchronous operations with a timeout
    print('Before pumpAndSettle');
    await tester
        .pumpAndSettle(Duration(seconds: 10)); // Timeout nach 10 Sekunden
    print('After pumpAndSettle');

    // Verify that the list of albums is displayed
    expect(find.text('Test Album 1'), findsOneWidget);
    expect(find.text('Test Album 2'), findsOneWidget);
  });
}
