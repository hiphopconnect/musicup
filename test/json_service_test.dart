// test/json_service_test.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/json_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class MockPathProviderPlatform extends Mock implements PathProviderPlatform {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('JsonService Tests', () {
    late JsonService jsonService;
    late Directory tempDir;
    late String testJsonFilePath;

    setUpAll(() async {
      final mockPathProviderPlatform = MockPathProviderPlatform();
      PathProviderPlatform.instance = mockPathProviderPlatform;
      // Create a temporary directory for testing
      tempDir = await Directory.systemTemp.createTemp('music_up_test');
      testJsonFilePath = '${tempDir.path}/test_albums.json';

      // Initialize ConfigManager and JsonService
      ConfigManager configManager = ConfigManager();
      await configManager.setJsonFilePath(testJsonFilePath);
      jsonService = JsonService(configManager);
    });

    tearDownAll(() async {
      // Clean up the temporary directory after tests
      await tempDir.delete(recursive: true);
    });

    test('Export and Import JSON', () async {
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

      // Save test data
      await jsonService.saveAlbums(albums);

      // Export JSON
      String exportPath = '${tempDir.path}/exported_albums.json';
      await jsonService.exportJson(exportPath);

      // Ensure export file exists
      expect(File(exportPath).existsSync(), true);

      // Clear albums
      await jsonService.saveAlbums([]);

      // Import JSON
      await jsonService.importAlbums(exportPath);

      // Load albums
      List<Album> importedAlbums = await jsonService.loadAlbums();

      // Verify data
      expect(importedAlbums.length, 1);
      expect(importedAlbums[0].name, 'Test Album');
    });

    test('Export and Import CSV', () async {
      // Prepare test data
      List<Album> albums = [
        Album(
          id: '2',
          name: 'CSV Album',
          artist: 'CSV Artist',
          genre: 'CSV Genre',
          year: '2022',
          medium: 'Vinyl',
          digital: true,
          tracks: [
            Track(title: 'CSV Track 1', trackNumber: '01'),
            Track(title: 'CSV Track 2', trackNumber: '02'),
          ],
        ),
      ];

      // Save test data
      await jsonService.saveAlbums(albums);

      // Export CSV
      String exportPath = '${tempDir.path}/exported_albums.csv';
      await jsonService.exportCsv(exportPath);

      // Ensure export file exists
      expect(File(exportPath).existsSync(), true);

      // Clear albums
      await jsonService.saveAlbums([]);

      // Import CSV
      await jsonService.importCsv(exportPath);

      // Load albums
      List<Album> importedAlbums = await jsonService.loadAlbums();

      // Verify data
      expect(importedAlbums.length, 1);
      expect(importedAlbums[0].name, 'CSV Album');
    });

    test('Export and Import XML', () async {
      // Prepare test data
      List<Album> albums = [
        Album(
          id: '3',
          name: 'XML Album',
          artist: 'XML Artist',
          genre: 'XML Genre',
          year: '2023',
          medium: 'Digital',
          digital: true,
          tracks: [
            Track(title: 'XML Track 1', trackNumber: '01'),
            Track(title: 'XML Track 2', trackNumber: '02'),
          ],
        ),
      ];

      // Save test data
      await jsonService.saveAlbums(albums);

      // Export XML
      String exportPath = '${tempDir.path}/exported_albums.xml';
      await jsonService.exportXml(exportPath);

      // Ensure export file exists
      expect(File(exportPath).existsSync(), true);

      // Clear albums
      await jsonService.saveAlbums([]);

      // Import XML
      await jsonService.importXml(exportPath);

      // Load albums
      List<Album> importedAlbums = await jsonService.loadAlbums();

      // Verify data
      expect(importedAlbums.length, 1);
      expect(importedAlbums[0].name, 'XML Album');
    });

    test('Avoid Duplicate Albums on Import', () async {
      // Prepare initial data
      List<Album> initialAlbums = [
        Album(
          id: '4',
          name: 'Duplicate Album',
          artist: 'Duplicate Artist',
          genre: 'Genre',
          year: '2024',
          medium: 'CD',
          digital: false,
          tracks: [
            Track(title: 'Track A', trackNumber: '01'),
          ],
        ),
      ];

      await jsonService.saveAlbums(initialAlbums);

      // Prepare import data
      List<Album> importAlbums = [
        Album(
          id: '5',
          name: 'Duplicate Album',
          artist: 'Duplicate Artist',
          genre: 'Genre',
          year: '2024',
          medium: 'CD',
          digital: false,
          tracks: [
            Track(title: 'Track B', trackNumber: '02'),
          ],
        ),
      ];

      // Export import data to JSON
      String importPath = '${tempDir.path}/import_albums.json';
      String jsonString =
          json.encode(importAlbums.map((album) => album.toMap()).toList());
      await File(importPath).writeAsString(jsonString);

      // Import albums
      await jsonService.importAlbums(importPath);

      // Load albums
      List<Album> allAlbums = await jsonService.loadAlbums();

      // Verify that only one album exists and tracks are merged
      expect(allAlbums.length, 1);
      expect(allAlbums[0].tracks.length, 2);
    });
  });
}
