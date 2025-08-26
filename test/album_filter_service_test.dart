import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/album_filter_service.dart';

void main() {
  group('AlbumFilterService Tests', () {
    late AlbumFilterService filterService;
    late List<Album> testAlbums;

    setUp(() {
      filterService = AlbumFilterService();
      testAlbums = [
        Album(
          id: '1',
          name: 'Rock Album',
          artist: 'Rock Artist',
          genre: 'Rock',
          year: '2020',
          medium: 'Vinyl',
          digital: true,
          tracks: [], // No tracks for performance
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
          name: 'Electronic Music',
          artist: 'Electronic Artist',
          genre: 'Electronic',
          year: '2022',
          medium: 'Digital',
          digital: true,
          tracks: [],
        ),
      ];
    });

    test('Filter by album name', () {
      List<Album> filtered = filterService.filterAlbums(
        albums: testAlbums,
        searchQuery: 'rock',
        searchCategory: 'Album',
        mediumFilters: filterService.getDefaultMediumFilters(),
        digitalFilter: 'All',
      );

      expect(filtered.length, 1);
      expect(filtered[0].name, 'Rock Album');
    });

    test('Filter by artist name', () {
      List<Album> filtered = filterService.filterAlbums(
        albums: testAlbums,
        searchQuery: 'jazz',
        searchCategory: 'Artist',
        mediumFilters: filterService.getDefaultMediumFilters(),
        digitalFilter: 'All',
      );

      expect(filtered.length, 1);
      expect(filtered[0].artist, 'Jazz Artist');
    });

    test('Filter by medium', () {
      Map<String, bool> mediumFilters = {
        'Vinyl': true,
        'CD': false,
        'Cassette': true,
        'Digital': false,
      };

      List<Album> filtered = filterService.filterAlbums(
        albums: testAlbums,
        searchQuery: '',
        searchCategory: 'Album',
        mediumFilters: mediumFilters,
        digitalFilter: 'All',
      );

      expect(filtered.length, 1);
      expect(filtered[0].medium, 'Vinyl');
    });

    test('Filter by digital availability', () {
      List<Album> filtered = filterService.filterAlbums(
        albums: testAlbums,
        searchQuery: '',
        searchCategory: 'Album',
        mediumFilters: filterService.getDefaultMediumFilters(),
        digitalFilter: 'Yes',
      );

      expect(filtered.length, 2); // Rock and Electronic
      expect(filtered.every((album) => album.digital), isTrue);
    });

    test('Sort albums ascending', () {
      List<Album> sorted = filterService.sortAlbums(
        albums: testAlbums,
        isAscending: true,
      );

      expect(sorted[0].name, 'Electronic Music');
      expect(sorted[1].name, 'Jazz Album');
      expect(sorted[2].name, 'Rock Album');
    });

    test('Sort albums descending', () {
      List<Album> sorted = filterService.sortAlbums(
        albums: testAlbums,
        isAscending: false,
      );

      expect(sorted[0].name, 'Rock Album');
      expect(sorted[1].name, 'Jazz Album');
      expect(sorted[2].name, 'Electronic Music');
    });

    test('Calculate album counts', () {
      Map<String, int> counts = filterService.calculateAlbumCounts(testAlbums);

      expect(counts['vinyl'], 1);
      expect(counts['cd'], 1);
      expect(counts['digital'], 1);
      expect(counts['digitalYes'], 2);
      expect(counts['digitalNo'], 1);
      expect(counts['total'], 3);
    });

    test('Get default medium filters', () {
      Map<String, bool> defaults = filterService.getDefaultMediumFilters();

      expect(defaults['Vinyl'], isTrue);
      expect(defaults['CD'], isTrue);
      expect(defaults['Cassette'], isTrue);
      expect(defaults['Digital'], isTrue);
    });

    test('Get search categories (no song search for performance)', () {
      List<String> categories = filterService.getSearchCategories();

      expect(categories.length, 2);
      expect(categories.contains('Album'), isTrue);
      expect(categories.contains('Artist'), isTrue);
      expect(categories.contains('Song'), isFalse); // Deactivated for performance
    });
  });
}