import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/json_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Helper function to mock the path provider behavior
class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/mock/documents';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JsonService Tests', () {
    late JsonService jsonService;
    late Directory tempDir;
    late String testJsonFilePath;

    setUpAll(() async {
      // Set the mock platform instance for path provider
      PathProviderPlatform.instance = FakePathProviderPlatform();

      // Set mock initial values for SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Create a temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('music_up_test');
      testJsonFilePath = '${tempDir.path}/test_albums.json';

      // Initialize ConfigManager and JsonService
      ConfigManager configManager = ConfigManager();
      await configManager.loadConfig();
      await configManager.setJsonFilePath(testJsonFilePath);
      jsonService = JsonService(configManager);
    });

    tearDownAll(() async {
      // Clean up the temporary directory after tests
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Load albums without tracks (lazy loading)', () async {
      // Prepare test data
      List<Album> albums = [
        Album(
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
        ),
      ];

      // Save test data with tracks
      await jsonService.saveAlbums(albums);

      // Load albums (should not include tracks)
      List<Album> loadedAlbums = await jsonService.loadAlbums();

      // Verify metadata loaded but no tracks
      expect(loadedAlbums.length, 1);
      expect(loadedAlbums[0].name, 'Test Album');
      expect(loadedAlbums[0].artist, 'Test Artist');
      expect(loadedAlbums[0].tracks.length, 0); // No tracks loaded for performance
    });

    test('Load single album with tracks', () async {
      // Prepare test data
      List<Album> albums = [
        Album(
          id: 'test-id-123',
          name: 'Track Test Album',
          artist: 'Track Artist',
          genre: 'Rock',
          year: '2022',
          medium: 'Vinyl',
          digital: true,
          tracks: [
            Track(title: 'Track A', trackNumber: '01'),
            Track(title: 'Track B', trackNumber: '02'),
          ],
        ),
      ];

      // Save test data
      await jsonService.saveAlbums(albums);

      // Load specific album with tracks
      Album? albumWithTracks = await jsonService.loadAlbumWithTracks('test-id-123');

      // Verify album and tracks loaded
      expect(albumWithTracks, isNotNull);
      expect(albumWithTracks!.name, 'Track Test Album');
      expect(albumWithTracks.tracks.length, 2);
      expect(albumWithTracks.tracks[0].title, 'Track A');
      expect(albumWithTracks.tracks[1].title, 'Track B');
    });

    test('Import albums from external file', () async {
      // Create external import file
      List<Album> importAlbums = [
        Album(
          id: 'import-1',
          name: 'Imported Album',
          artist: 'Import Artist',
          genre: 'Import Genre',
          year: '2023',
          medium: 'Digital',
          digital: true,
          tracks: [
            Track(title: 'Import Track 1', trackNumber: '01'),
            Track(title: 'Import Track 2', trackNumber: '02'),
          ],
        ),
      ];

      // Create import file
      String importPath = '${tempDir.path}/import_albums.json';
      String jsonString = jsonEncode(importAlbums.map((album) => {
        'id': album.id,
        'name': album.name,
        'artist': album.artist,
        'genre': album.genre,
        'year': album.year,
        'medium': album.medium,
        'digital': album.digital,
        'tracks': album.tracks.map((track) => {
          'trackNumber': track.trackNumber,
          'title': track.title,
        }).toList(),
      }).toList());
      
      await File(importPath).writeAsString(jsonString);

      // Import albums
      List<Album> importedAlbums = await jsonService.importAlbumsFromFile(importPath);

      // Verify imported data
      expect(importedAlbums.length, 1);
      expect(importedAlbums[0].name, 'Imported Album');
      expect(importedAlbums[0].tracks.length, 2);
    });

    test('Load non-existent album returns null', () async {
      // Try to load album that doesn't exist
      Album? nonExistentAlbum = await jsonService.loadAlbumWithTracks('non-existent-id');

      // Should return null
      expect(nonExistentAlbum, isNull);
    });

    test('Save and load empty album list', () async {
      // Save empty list
      await jsonService.saveAlbums([]);

      // Load albums
      List<Album> loadedAlbums = await jsonService.loadAlbums();

      // Should be empty
      expect(loadedAlbums.length, 0);
    });
  });
}
