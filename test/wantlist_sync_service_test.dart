import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/wantlist_sync_service.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/services/discogs_service_unified.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generate mocks
@GenerateNiceMocks([
  MockSpec<JsonService>(),
  MockSpec<DiscogsServiceUnified>(),
])
import 'wantlist_sync_service_test.mocks.dart';

void main() {
  group('WantlistSyncService Basic Tests', () {
    late WantlistSyncService syncService;
    late MockJsonService mockJsonService;
    late MockDiscogsServiceUnified mockDiscogsService;
    
    setUp(() {
      mockJsonService = MockJsonService();
      mockDiscogsService = MockDiscogsServiceUnified();
      syncService = WantlistSyncService(mockDiscogsService, mockJsonService);
    });

    test('Load wantlist from local storage when no Discogs auth', () async {
      final localAlbums = [
        Album(
          id: '1',
          name: 'Local Album',
          artist: 'Local Artist',
          genre: 'Rock',
          year: '2020',
          medium: 'CD',
          digital: false,
          tracks: [],
        ),
      ];

      when(mockJsonService.loadWantlist()).thenAnswer((_) async => localAlbums);
      when(mockDiscogsService.hasAuth).thenReturn(false);

      final result = await syncService.loadAndSyncWantlist();

      expect(result.length, 1);
      expect(result[0].name, 'Local Album');
      verify(mockJsonService.loadWantlist()).called(1);
    });

    test('Load wantlist with Discogs sync when authenticated', () async {
      final localAlbums = [
        Album(
          id: '1',
          name: 'Local Album',
          artist: 'Local Artist',
          genre: 'Rock',
          year: '2020',
          medium: 'CD',
          digital: false,
          tracks: [],
        ),
      ];

      final onlineAlbums = [
        Album(
          id: '2',
          name: 'Online Album',
          artist: 'Online Artist',
          genre: 'Jazz',
          year: '2021',
          medium: 'Vinyl',
          digital: true,
          tracks: [],
        ),
      ];

      when(mockJsonService.loadWantlist()).thenAnswer((_) async => localAlbums);
      when(mockDiscogsService.hasAuth).thenReturn(true);
      when(mockDiscogsService.testAuthentication()).thenAnswer((_) async => true);
      when(mockDiscogsService.getWantlist()).thenAnswer((_) async => onlineAlbums);

      final result = await syncService.loadAndSyncWantlist();

      // Online should be source of truth
      expect(result.length, 1);
      expect(result[0].name, 'Online Album');
      verify(mockDiscogsService.getWantlist()).called(1);
    });

    test('Handle Discogs authentication failure', () async {
      final localAlbums = [
        Album(
          id: '1',
          name: 'Local Album',
          artist: 'Local Artist',
          genre: 'Rock',
          year: '2020',
          medium: 'CD',
          digital: false,
          tracks: [],
        ),
      ];

      when(mockJsonService.loadWantlist()).thenAnswer((_) async => localAlbums);
      when(mockDiscogsService.hasAuth).thenReturn(true);
      when(mockDiscogsService.testAuthentication()).thenAnswer((_) async => false);

      final result = await syncService.loadAndSyncWantlist();

      // Should fall back to local data
      expect(result.length, 1);
      expect(result[0].name, 'Local Album');
      verifyNever(mockDiscogsService.getWantlist());
    });

    test('Handle Discogs API error gracefully', () async {
      final localAlbums = [
        Album(
          id: '1',
          name: 'Local Album',
          artist: 'Local Artist',
          genre: 'Rock',
          year: '2020',
          medium: 'CD',
          digital: false,
          tracks: [],
        ),
      ];

      when(mockJsonService.loadWantlist()).thenAnswer((_) async => localAlbums);
      when(mockDiscogsService.hasAuth).thenReturn(true);
      when(mockDiscogsService.testAuthentication()).thenAnswer((_) async => true);
      when(mockDiscogsService.getWantlist()).thenThrow(Exception('Network error'));

      final result = await syncService.loadAndSyncWantlist();

      // Should fall back to local data on error
      expect(result.length, 1);
      expect(result[0].name, 'Local Album');
    });

    test('Handle empty wantlist', () async {
      when(mockJsonService.loadWantlist()).thenAnswer((_) async => []);
      when(mockDiscogsService.hasAuth).thenReturn(false);

      final result = await syncService.loadAndSyncWantlist();

      expect(result.isEmpty, true);
    });

    test('Service handles null Discogs service', () async {
      final syncServiceWithoutDiscogs = WantlistSyncService(null, mockJsonService);
      
      final localAlbums = [
        Album(
          id: '1',
          name: 'Local Only Album',
          artist: 'Local Artist',
          genre: 'Rock',
          year: '2020',
          medium: 'CD',
          digital: false,
          tracks: [],
        ),
      ];

      when(mockJsonService.loadWantlist()).thenAnswer((_) async => localAlbums);

      final result = await syncServiceWithoutDiscogs.loadAndSyncWantlist();

      expect(result.length, 1);
      expect(result[0].name, 'Local Only Album');
    });

    test('Basic wantlist sync without optimization test', () async {
      final albums = [
        Album(
          id: '1',
          name: 'Same Album',
          artist: 'Same Artist',
          genre: 'Rock',
          year: '2020',
          medium: 'CD',
          digital: false,
          tracks: [],
        ),
      ];

      when(mockJsonService.loadWantlist()).thenAnswer((_) async => albums);
      when(mockDiscogsService.hasAuth).thenReturn(true);
      when(mockDiscogsService.testAuthentication()).thenAnswer((_) async => true);
      when(mockDiscogsService.getWantlist()).thenAnswer((_) async => albums);

      final result = await syncService.loadAndSyncWantlist();

      expect(result.length, 1);
      expect(result[0].name, 'Same Album');
    });
  });
}