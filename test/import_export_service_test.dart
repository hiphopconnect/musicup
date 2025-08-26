import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockJsonService extends Mock implements JsonService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ImportExportService Basic Tests', () {
    late JsonService jsonService;
    late ConfigManager configManager;
    late Directory tempDir;
    late List<Album> testAlbums;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      tempDir = await Directory.systemTemp.createTemp('import_export_test');
      
      configManager = ConfigManager();
      await configManager.loadConfig();
      await configManager.setJsonFilePath('${tempDir.path}/albums.json');
      
      jsonService = JsonService(configManager);
      
      // Create test data
      testAlbums = [
        Album(
          id: '1',
          name: 'Test Album',
          artist: 'Test Artist',
          genre: 'Rock',
          year: '2020',
          medium: 'CD',
          digital: true,
          tracks: [
            Track(trackNumber: '01', title: 'Track 1'),
            Track(trackNumber: '02', title: 'Track 2'),
          ],
        ),
        Album(
          id: '2',
          name: 'Another Album',
          artist: 'Another Artist',
          genre: 'Jazz',
          year: '2021',
          medium: 'Vinyl',
          digital: false,
          tracks: [
            Track(trackNumber: '01', title: 'Jazz Track'),
          ],
        ),
      ];
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Save and load albums through JsonService', () async {
      // Save albums
      await jsonService.saveAlbums(testAlbums);
      
      // Load albums
      final loaded = await jsonService.loadAlbums();
      
      expect(loaded.length, 2);
      expect(loaded[0].name, 'Test Album');
      expect(loaded[1].name, 'Another Album');
    });

    test('Import albums from external JSON file', () async {
      // Save initial album
      await jsonService.saveAlbums([testAlbums[0]]);
      
      // Import another album
      final imported = await jsonService.importAlbumsFromFile('${tempDir.path}/albums.json');
      
      expect(imported.length, 1);
      expect(imported[0].name, 'Test Album');
    });

    test('Handle empty album list', () async {
      await jsonService.saveAlbums([]);
      
      final loaded = await jsonService.loadAlbums();
      
      expect(loaded.isEmpty, true);
    });

    test('Albums preserve track information', () async {
      await jsonService.saveAlbums(testAlbums);
      
      // Load with tracks (for detail view)
      final albumWithTracks = await jsonService.loadAlbumWithTracks('1');
      
      expect(albumWithTracks, isNotNull);
      expect(albumWithTracks!.tracks.length, 2);
      expect(albumWithTracks.tracks[0].title, 'Track 1');
    });
  });
}