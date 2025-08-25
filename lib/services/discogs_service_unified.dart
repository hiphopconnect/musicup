// lib/services/discogs_service_unified.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/discogs_oauth_service.dart';

class DiscogsServiceUnified {
  final ConfigManager _configManager;
  DiscogsOAuthService? _oauthService;

  final String _baseUrl = 'https://api.discogs.com';
  final String _userAgent =
      'MusicUp/1.3.1 +https://github.com/hiphopconnect/musicup';

  DiscogsServiceUnified(this._configManager);

  // Nur OAuth
  bool get hasAuth => _configManager.hasDiscogsOAuthTokens();

  bool get hasWriteAccess => _configManager.hasDiscogsOAuthTokens();

  Map<String, String> _createHeaders(String method, String url) {
    return _createOAuthHeaders(method, url);
  }

  Map<String, String> _createOAuthHeaders(String method, String url) {
    // FIXED: Immer OAuth-Service neu initialisieren um Token-Updates zu berücksichtigen
    _initializeOAuth();
    
    if (_oauthService == null || !_oauthService!.isAuthenticated) {
      throw Exception('OAuth nicht verfügbar oder nicht authentifiziert');
    }
    final headers = _oauthService!.createOAuthHeaders(method, url);
    return {
      ...headers,
      'Accept': 'application/json',
      'User-Agent': _userAgent,
    };
  }

  void _initializeOAuth() {
    final creds = _configManager.getDiscogsConsumerCredentials();
    final tokens = _configManager.getDiscogsOAuthTokens();

    final key = creds['consumer_key'] ?? '';
    final secret = creds['consumer_secret'] ?? '';

    if (kDebugMode) {
      debugPrint('🔐 OAuth Init - Consumer Key: ${key.isNotEmpty ? "***SET***" : "EMPTY"}');
      debugPrint('🔐 OAuth Init - Consumer Secret: ${secret.isNotEmpty ? "***SET***" : "EMPTY"}');
    }

    if (key.isNotEmpty && secret.isNotEmpty) {
      // FIXED: Immer neuen Service erstellen oder existierenden aktualisieren
      _oauthService = DiscogsOAuthService(
        consumerKey: key,
        consumerSecret: secret,
      );

      final token = tokens['token'];
      final tokenSecret = tokens['secret'];
      
      if (kDebugMode) {
        debugPrint('🔐 OAuth Init - Access Token: ${token != null && token.isNotEmpty ? "***SET***" : "EMPTY"}');
        debugPrint('🔐 OAuth Init - Access Secret: ${tokenSecret != null && tokenSecret.isNotEmpty ? "***SET***" : "EMPTY"}');
      }
      
      if (token != null && tokenSecret != null && token.isNotEmpty && tokenSecret.isNotEmpty) {
        _oauthService!.setAccessToken(token, tokenSecret);
        if (kDebugMode) debugPrint('🔐 OAuth service initialized and authenticated');
      } else {
        if (kDebugMode) debugPrint('🔐 OAuth service created but no access tokens found');
      }
    } else {
      // FIXED: Service auf null setzen wenn Credentials fehlen
      _oauthService = null;
      if (kDebugMode) debugPrint('🔐 OAuth service set to null - missing consumer credentials');
    }
  }

  Future<bool> testAuthentication() async {
    if (!hasAuth) return false;
    try {
      final url = '$_baseUrl/oauth/identity';
      final response = await http.get(Uri.parse(url),
          headers: _createOAuthHeaders('GET', url));
      if (kDebugMode) debugPrint('🔑 OAuth test: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('🔑 OAuth test failed: $e');
      return false;
    }
  }

  Future<List<Album>> getWantlist() async {
    if (!hasAuth) {
      throw Exception('OAuth nicht konfiguriert');
    }

    try {
      final username = await _getOAuthUsername();
      final urlBase = '$_baseUrl/users/$username/wants';

      final firstUrl = '$urlBase?per_page=100&page=1';
      if (kDebugMode) debugPrint('📋 Loading wantlist from: $firstUrl');

      final firstResp = await http.get(Uri.parse(firstUrl),
          headers: _createHeaders('GET', firstUrl));
      if (firstResp.statusCode != 200) {
        throw Exception(
            'Wantlist-Abruf fehlgeschlagen: ${firstResp.statusCode} - ${firstResp.body}');
      }

      final firstData = json.decode(firstResp.body);
      final pagination = firstData['pagination'] as Map<String, dynamic>?;
      final totalPages = (pagination?['pages'] as num?)?.toInt() ?? 1;

      final List<dynamic> allWants = [];
      allWants.addAll(firstData['wants'] as List? ?? const []);

      for (int page = 2; page <= totalPages; page++) {
        final pageUrl = '$urlBase?per_page=100&page=$page';
        if (kDebugMode)
          debugPrint('📋 Loading wantlist page $page/$totalPages: $pageUrl');
        final pageResp = await http.get(Uri.parse(pageUrl),
            headers: _createHeaders('GET', pageUrl));
        if (pageResp.statusCode != 200) {
          throw Exception(
              'Wantlist-Seite $page fehlgeschlagen: ${pageResp.statusCode}');
        }
        final pageData = json.decode(pageResp.body);
        allWants.addAll(pageData['wants'] as List? ?? const []);
      }

      if (kDebugMode) {
        debugPrint('📋 Found ${allWants.length} wantlist items (aggregated)');
      }

      return allWants.map((want) {
        final Map basicInfo = (want is Map && want['basic_information'] is Map)
            ? want['basic_information']
            : {};
        final releaseId = basicInfo['id']?.toString() ?? '';

        String artist = 'Unknown Artist';
        final List? artists = basicInfo['artists'];
        if (artists != null && artists.isNotEmpty && artists[0] is Map) {
          artist = artists[0]['name']?.toString() ?? artist;
        }

        final String medium = (basicInfo['formats'] is List &&
                (basicInfo['formats'] as List).isNotEmpty)
            ? (basicInfo['formats'][0]?['name']?.toString() ?? 'Unknown')
            : 'Unknown';

        final String genre = (basicInfo['genres'] is List &&
                (basicInfo['genres'] as List).isNotEmpty)
            ? (basicInfo['genres'][0]?.toString() ?? '')
            : '';

        return Album(
          id: 'want_rel_$releaseId',
          name: basicInfo['title']?.toString() ?? 'Unknown Title',
          artist: artist,
          genre: genre,
          year: basicInfo['year']?.toString() ?? '',
          medium: medium,
          digital: false,
          tracks: const [],
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('📋 Wantlist error: $e');
      rethrow;
    }
  }

  Future<void> addToWantlist(String releaseId) async {
    if (!hasWriteAccess) {
      throw Exception('Schreibzugriff erfordert OAuth-Authentifizierung');
    }
    try {
      final username = await _getOAuthUsername();
      final url = '$_baseUrl/users/$username/wants/$releaseId';

      if (kDebugMode) debugPrint('❤️ Adding to wantlist: $releaseId');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          ..._createHeaders('PUT', url),
          'Content-Type': 'application/json',
        },
        body: '{}',
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        if (response.statusCode == 422 && response.body.contains('already')) {
          throw Exception('Album ist bereits in der Wantlist');
        }
        throw Exception(
            'Hinzufügen fehlgeschlagen: ${response.statusCode} - ${response.body}');
      }

      if (kDebugMode) debugPrint('❤️ Successfully added to wantlist');
    } catch (e) {
      if (kDebugMode) debugPrint('❤️ Add to wantlist error: $e');
      rethrow;
    }
  }

  Future<void> removeFromWantlist(String releaseId) async {
    if (!hasWriteAccess) {
      throw Exception('Schreibzugriff erfordert OAuth-Authentifizierung');
    }
    try {
      final username = await _getOAuthUsername();
      final url = '$_baseUrl/users/$username/wants/$releaseId';

      if (kDebugMode) debugPrint('💔 Removing from wantlist: $releaseId');

      final response = await http.delete(Uri.parse(url),
          headers: _createHeaders('DELETE', url));

      if (response.statusCode != 204 &&
          response.statusCode != 200 &&
          response.statusCode != 404) {
        throw Exception(
            'Entfernen fehlgeschlagen: ${response.statusCode} - ${response.body}');
      }

      if (kDebugMode) debugPrint('💔 Successfully removed from wantlist');
    } catch (e) {
      if (kDebugMode) debugPrint('💔 Remove from wantlist error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchReleases(String query) async {
    if (!hasAuth) {
      throw Exception('Keine Discogs-Authentifizierung verfügbar');
    }

    try {
      final url =
          '$_baseUrl/database/search?q=${Uri.encodeComponent(query)}&type=release';

      if (kDebugMode) debugPrint('🔍 Searching: $query');

      final response =
          await http.get(Uri.parse(url), headers: _createHeaders('GET', url));

      if (response.statusCode != 200) {
        throw Exception(
            'Suche fehlgeschlagen: ${response.statusCode} - ${response.body}');
      }

      final data = json.decode(response.body);
      final List results = data['results'] ?? [];

      if (kDebugMode) debugPrint('🔍 Found ${results.length} search results');

      return results.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) debugPrint('🔍 Search error: $e');
      rethrow;
    }
  }

  Future<List<Track>> getReleaseTracklist(String releaseId) async {
    if (!hasAuth) return [];

    try {
      final url = '$_baseUrl/releases/$releaseId';

      if (kDebugMode) debugPrint('🎵 Loading tracks for: $releaseId');

      final response =
          await http.get(Uri.parse(url), headers: _createHeaders('GET', url));

      if (response.statusCode != 200) {
        if (kDebugMode) {
          debugPrint('🎵 Tracks load failed: ${response.statusCode}');
        }
        return [];
      }

      final data = json.decode(response.body);
      final List? tracklist = data['tracklist'];

      if (tracklist == null || tracklist.isEmpty) {
        if (kDebugMode) debugPrint('🎵 No tracks found');
        return [];
      }

      final tracks = <Track>[];
      for (int i = 0; i < tracklist.length; i++) {
        final track = tracklist[i] as Map<String, dynamic>;
        final title = track['title']?.toString().trim() ?? '';
        if (title.isEmpty) continue;

        tracks.add(Track(
          trackNumber: _normalizeTrackPosition(track['position'], i + 1),
          title: title,
        ));
      }

      if (kDebugMode) debugPrint('🎵 Loaded ${tracks.length} tracks');
      return tracks;
    } catch (e) {
      if (kDebugMode) debugPrint('🎵 Tracks error: $e');
      return [];
    }
  }

  Future<String> _getOAuthUsername() async {
    final url = '$_baseUrl/oauth/identity';
    final response = await http.get(Uri.parse(url),
        headers: _createOAuthHeaders('GET', url));

    if (response.statusCode != 200) {
      throw Exception(
          'Username-Ermittlung fehlgeschlagen: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final username = data['username']?.toString().trim() ?? '';
    if (username.isEmpty) {
      throw Exception('Username konnte nicht ermittelt werden');
    }
    return Uri.encodeComponent(username.toLowerCase());
  }

  String _normalizeTrackPosition(dynamic position, int fallbackNumber) {
    if (position == null) {
      return fallbackNumber.toString().padLeft(2, '0');
    }

    final posStr = position.toString().trim();
    if (posStr.isEmpty) {
      return fallbackNumber.toString().padLeft(2, '0');
    }

    final numMatch = RegExp(r'^\d+$').firstMatch(posStr);
    if (numMatch != null) {
      final num = int.parse(numMatch.group(0)!);
      return num.toString().padLeft(2, '0');
    }

    if (RegExp(r'^[A-Za-z]\d+$').hasMatch(posStr)) {
      return posStr.toUpperCase();
    }

    return fallbackNumber.toString().padLeft(2, '0');
  }

  String get statusMessage {
    if (hasWriteAccess) {
      return '✅ Vollzugriff (OAuth)';
    } else if (hasAuth) {
      return '✅ OAuth vorhanden';
    } else {
      return '❌ Kein Zugriff';
    }
  }
}
