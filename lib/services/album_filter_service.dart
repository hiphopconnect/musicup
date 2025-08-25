// lib/services/album_filter_service.dart

import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/logger_service.dart';

class AlbumFilterService {
  List<Album> filterAlbums({
    required List<Album> albums,
    required String searchQuery,
    required String searchCategory,
    required Map<String, bool> mediumFilters,
    required String digitalFilter,
  }) {
    List<Album> filtered = albums.where((album) {
      // Search filter
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        bool matchesSearch = false;

        switch (searchCategory) {
          case 'Album':
            matchesSearch = album.name.toLowerCase().contains(query);
            break;
          case 'Artist':
            matchesSearch = album.artist.toLowerCase().contains(query);
            break;
          case 'Song':
            matchesSearch = album.tracks.any((track) =>
                track.title.toLowerCase().contains(query));
            break;
        }

        if (!matchesSearch) return false;
      }

      // Medium filter
      if (mediumFilters[album.medium] != true) {
        return false;
      }

      // Digital filter
      if (digitalFilter != 'All') {
        final isDigitalYes = digitalFilter == 'Yes';
        if (album.digital != isDigitalYes) {
          return false;
        }
      }

      return true;
    }).toList();

    LoggerService.data('Albums filtered', filtered.length, 'of ${albums.length}');
    return filtered;
  }

  List<Album> sortAlbums({
    required List<Album> albums,
    required bool isAscending,
  }) {
    List<Album> sorted = List.from(albums);
    
    sorted.sort((a, b) {
      final comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return isAscending ? comparison : -comparison;
    });

    return sorted;
  }

  Map<String, int> calculateAlbumCounts(List<Album> albums) {
    int vinylCount = 0;
    int cdCount = 0;
    int cassetteCount = 0;
    int digitalCount = 0;
    int digitalYesCount = 0;
    int digitalNoCount = 0;

    for (var album in albums) {
      // Count by medium
      switch (album.medium) {
        case 'Vinyl':
          vinylCount++;
          break;
        case 'CD':
          cdCount++;
          break;
        case 'Cassette':
          cassetteCount++;
          break;
        case 'Digital':
          digitalCount++;
          break;
      }

      // Count by digital availability
      if (album.digital) {
        digitalYesCount++;
      } else {
        digitalNoCount++;
      }
    }

    return {
      'vinyl': vinylCount,
      'cd': cdCount,
      'cassette': cassetteCount,
      'digital': digitalCount,
      'digitalYes': digitalYesCount,
      'digitalNo': digitalNoCount,
      'total': albums.length,
    };
  }

  Map<String, bool> getDefaultMediumFilters() {
    return {
      'Vinyl': true,
      'CD': true,
      'Cassette': true,
      'Digital': true,
    };
  }

  List<String> getSearchCategories() {
    return ['Album', 'Artist', 'Song'];
  }

  List<String> getDigitalFilterOptions() {
    return ['All', 'Yes', 'No'];
  }
}