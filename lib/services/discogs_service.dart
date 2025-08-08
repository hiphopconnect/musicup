// lib/services/discogs_service.dart

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:music_up/models/album_model.dart';
import 'package:music_up/screens/discogs_search_screen.dart';

class DiscogsService {
  final String _token;
  final String _baseUrl = 'https://api.discogs.com';
  final String _userAgent =
      'MusicUp/1.3.1 +https://github.com/hiphopconnect/musicup';

  DiscogsService(this._token);

  Map<String, String> get _headers => {
        'Authorization': 'Discogs token=$_token',
        'User-Agent': _userAgent,
      };

  // Search for releases
  Future<List<DiscogsSearchResult>> searchReleases(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/database/search?q=$query&type=release'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'] ?? [];

      return results.map((item) => DiscogsSearchResult.fromJson(item)).toList();
    } else {
      throw Exception('Failed to search Discogs: ${response.statusCode}');
    }
  }

  // ✅ VERBESSERTE getReleaseTracklist FUNKTION:
  Future<List<Track>> getReleaseTracklist(String releaseId) async {
    try {
      print('🎵 FETCHING TRACKLIST for Release: $releaseId');

      final response = await http.get(
        Uri.parse('$_baseUrl/releases/$releaseId'),
        headers: _headers,
      );

      print('🎵 TRACKLIST RESPONSE: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List? tracklist = data['tracklist'];

        if (tracklist == null || tracklist.isEmpty) {
          print('⚠️ NO TRACKLIST found for Release: $releaseId');
          return [];
        }

        List<Track> tracks = [];
        print('🎵 PROCESSING ${tracklist.length} TRACKS...');

        for (int i = 0; i < tracklist.length; i++) {
          final track = tracklist[i];
          String trackNumber =
              track['position']?.toString() ?? (i + 1).toString();
          String title = track['title']?.toString() ?? 'Unknown Track ${i + 1}';

          // ✅ Entferne leere oder ungültige Tracks
          if (title.trim().isEmpty || title == 'Unknown Track ${i + 1}') {
            continue;
          }

          tracks.add(Track(
            trackNumber: trackNumber,
            title: title,
          ));

          print('✅ TRACK ${trackNumber}: $title');
        }

        print('🎵 FINAL TRACKS: ${tracks.length} valid tracks');
        return tracks;
      } else {
        print('❌ TRACKLIST ERROR: ${response.statusCode}');
        throw Exception(
            'Failed to get release details: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ TRACKLIST EXCEPTION for $releaseId: $e');
      return []; // Fallback: Leere Tracklist
    }
  }

  // Add to wantlist
  Future<void> addToWantlist(String releaseId) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/users/me/wants/$releaseId'),
      headers: _headers,
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add to wantlist: ${response.statusCode}');
    }
  }

  // Remove from wantlist
  Future<void> removeFromWantlist(String releaseId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/users/me/wants/$releaseId'),
      headers: _headers,
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to remove from wantlist: ${response.statusCode}');
    }
  }

  // ✅ ERWEITERTE getWantlistAsAlbums FUNKTION MIT TRACKS:
  Future<List<Album>> getWantlistAsAlbums() async {
    print('🔍 =======DISCOGS WANTLIST DEBUG START======= 🔍');

    try {
      final url = '$_baseUrl/users/hiphopconnected/wants?page=1&per_page=100';
      print('🔍 REQUEST URL: $url');
      print('🔍 HEADERS: $_headers');

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      print('🔍 RESPONSE STATUS: ${response.statusCode}');
      print('🔍 RAW RESPONSE BODY: ${response.body}');

      if (response.statusCode == 401) {
        throw Exception(
            'Invalid Discogs token. Please check your token in Settings.');
      }

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to get wantlist: ${response.statusCode} - ${response.body}');
      }

      final data = json.decode(response.body);
      final List wants = data['wants'] ?? [];

      print('🔍 WANTS ARRAY LENGTH: ${wants.length}');

      if (wants.isEmpty) {
        print('⚠️ WANTS ARRAY IS EMPTY!');
        print('🔍 FULL DATA STRUCTURE: $data');
        return [];
      }

      List<Album> albums = [];
      print('🔍 PROCESSING ${wants.length} WANT ITEMS...');

      for (int index = 0; index < wants.length; index++) {
        var want = wants[index];
        print('🔍 PROCESSING WANT #${index + 1}');

        try {
          final basicInfo = want['basic_information'];
          if (basicInfo == null) {
            print('❌ SKIPPING: No basic_information');
            continue;
          }

          // ✅ Extract data
          String wantId = want['id']?.toString() ?? '';
          String releaseId = basicInfo['id']?.toString() ?? ''; // ✅ NEU!
          String title = basicInfo['title']?.toString() ?? 'Unknown Title';
          String artist = 'Unknown Artist';

          // Extract artist
          final List? artists = basicInfo['artists'];
          if (artists != null && artists.isNotEmpty) {
            final artistData = artists[0];
            if (artistData is Map && artistData.containsKey('name')) {
              artist = artistData['name']?.toString() ?? 'Unknown Artist';
            } else if (artistData is String) {
              artist = artistData;
            }
          }

          String year = basicInfo['year']?.toString() ?? '';
          String genre = '';
          String format = 'Unknown';

          // Extract genre
          final List? genres = basicInfo['genres'];
          if (genres != null && genres.isNotEmpty) {
            genre = genres[0].toString();
          }

          // Extract format
          final List? formats = basicInfo['formats'];
          if (formats != null && formats.isNotEmpty) {
            final formatData = formats[0];
            if (formatData is Map && formatData.containsKey('name')) {
              format = formatData['name']?.toString() ?? 'Unknown';
            } else if (formatData is String) {
              format = formatData;
            }
          }

          // ✅ LADE TRACKLIST für dieses Release!
          List<Track> tracks = [];

          if (releaseId.isNotEmpty) {
            try {
              print('🎵 LOADING TRACKS for Release ID: $releaseId');
              tracks = await getReleaseTracklist(releaseId);
              print('✅ LOADED ${tracks.length} TRACKS for "$title"');
            } catch (e) {
              print('⚠️ ERROR LOADING TRACKS for "$title": $e');
              // Fallback: Leere Tracklist verwenden
              tracks = [];
            }
          }

          String uniqueId =
              'want_${wantId}_${DateTime.now().millisecondsSinceEpoch}';

          Album album = Album(
            id: uniqueId,
            name: title,
            artist: artist,
            genre: genre,
            year: year,
            medium: format,
            digital: false,
            tracks: tracks, // ✅ JETZT MIT ECHTEN TRACKS!
          );

          albums.add(album);
          print(
              '✅ ADDED: "$title" by $artist (${format}, ${year}) - ${tracks.length} tracks');
        } catch (e) {
          print('❌ ERROR PROCESSING WANT #${index + 1}: $e');
          continue;
        }
      }

      print('🎯 FINAL RESULT: ${albums.length} albums created');
      print('🔍 =======DISCOGS WANTLIST DEBUG END======= 🔍');

      return albums;
    } catch (e) {
      print('❌ EXCEPTION IN getWantlistAsAlbums: $e');
      print('🔍 =======DISCOGS WANTLIST DEBUG END (ERROR)======= 🔍');

      if (e.toString().contains('token')) {
        rethrow;
      }
      throw Exception('Failed to load Discogs wantlist: $e');
    }
  }

  // Get user's collection
  Future<List<Album>> getCollectionAsAlbums() async {
    try {
      // ✅ AUCH HIER: page=1 Parameter für Konsistenz
      final response = await http.get(
        Uri.parse(
            '$_baseUrl/users/me/collection/folders/0/releases?page=1&per_page=100'),
        headers: _headers,
      );

      if (response.statusCode == 401) {
        throw Exception(
            'Invalid Discogs token. Please check your token in Settings.');
      }

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to get collection: ${response.statusCode} - ${response.body}');
      }

      final data = json.decode(response.body);
      final List releases = data['releases'] ?? [];

      List<Album> albums = [];

      for (var release in releases) {
        try {
          final basicInfo = release['basic_information'];
          if (basicInfo == null) continue;

          String releaseId = basicInfo['id']?.toString() ?? '';
          String title = basicInfo['title']?.toString() ?? 'Unknown Title';
          String artist = 'Unknown Artist';

          // Extract artist correctly
          final List? artists = basicInfo['artists'];
          if (artists != null && artists.isNotEmpty) {
            final artistData = artists[0];
            if (artistData is Map && artistData.containsKey('name')) {
              artist = artistData['name']?.toString() ?? 'Unknown Artist';
            } else if (artistData is String) {
              artist = artistData;
            }
          }

          String year = basicInfo['year']?.toString() ?? '';
          String genre = '';
          String format = 'Vinyl';

          final List? genres = basicInfo['genres'];
          if (genres != null && genres.isNotEmpty) {
            genre = genres[0].toString();
          }

          final List? formats = basicInfo['formats'];
          if (formats != null && formats.isNotEmpty) {
            final formatData = formats[0];
            if (formatData is Map && formatData.containsKey('name')) {
              format = formatData['name']?.toString() ?? 'Vinyl';
            } else if (formatData is String) {
              format = formatData;
            }
          }

          List<Track> tracks = [];

          Album album = Album(
            id: 'col_$releaseId',
            name: title,
            artist: artist,
            genre: genre,
            year: year,
            medium: format,
            digital: false,
            tracks: tracks,
          );

          albums.add(album);
        } catch (e) {
          continue;
        }
      }

      return albums;
    } catch (e) {
      if (e.toString().contains('token')) {
        rethrow;
      }
      throw Exception('Failed to load Discogs collection: $e');
    }
  }

  // Test Token Validity
  Future<bool> testToken() async {
    try {
      print('🔍 TESTING TOKEN...');
      final response = await http.get(
        Uri.parse('$_baseUrl/oauth/identity'),
        headers: _headers,
      );

      print('🔍 TOKEN TEST RESPONSE: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ TOKEN TEST ERROR: $e');
      return false;
    }
  }

  // Get User Info
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/oauth/identity'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('❌ USER INFO ERROR: $e');
      return null;
    }
  }

  // ✅ ERWEITERTE DEBUG FUNKTION - Teste verschiedene Endpoints
  Future<void> debugAllWantlistEndpoints() async {
    print('🔍 ====== TESTING ALL WANTLIST ENDPOINTS ====== 🔍');

    final endpoints = [
      'https://api.discogs.com/users/me/wants',
      'https://api.discogs.com/users/me/wants?per_page=250',
      'https://api.discogs.com/users/me/wants?page=1&per_page=100',
      'https://api.discogs.com/users/hiphopconnected/wants',
      'https://api.discogs.com/users/hiphopconnected/wants?page=1&per_page=100',
      'https://api.discogs.com/users/me/collection/folders',
    ];

    for (int i = 0; i < endpoints.length; i++) {
      try {
        print('🔍 [$i] TESTING: ${endpoints[i]}');
        await Future.delayed(
            const Duration(seconds: 2)); // Rate limit protection

        final response = await http.get(
          Uri.parse(endpoints[i]),
          headers: _headers,
        );

        print('✅ [$i] STATUS: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          // Check for wants
          if (data.containsKey('wants')) {
            final wants = data['wants'] ?? [];
            print('🎯 [$i] FOUND ${wants.length} WANTS!');
          }

          // Check for folders
          if (data.containsKey('folders')) {
            final folders = data['folders'] ?? [];
            print('🎯 [$i] FOUND ${folders.length} FOLDERS!');
          }

          // Check for releases
          if (data.containsKey('releases')) {
            final releases = data['releases'] ?? [];
            print('🎯 [$i] FOUND ${releases.length} RELEASES!');
          }
        }
      } catch (e) {
        print('❌ [$i] ERROR: $e');
      }
    }

    print('🔍 ====== ENDPOINT TESTING COMPLETE ====== 🔍');
  }
}
