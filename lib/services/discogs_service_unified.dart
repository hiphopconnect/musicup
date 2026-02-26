// lib/services/discogs_service_unified.dart

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/discogs_oauth_service.dart';
import 'package:music_up/services/logger_service.dart';

class DiscogsServiceUnified {
  final ConfigManager _configManager;
  final http.Client _httpClient;
  DiscogsOAuthService? _oauthService;

  final String _baseUrl = 'https://api.discogs.com';
  final String _userAgent =
      'MusicUp/2.2.0 +https://github.com/hiphopconnect/musicup';

  String? _cachedConsumerKey;
  String? _cachedConsumerSecret;
  String? _cachedToken;
  String? _cachedTokenSecret;

  DiscogsServiceUnified(this._configManager, {http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  // Nur OAuth
  bool get hasAuth => _configManager.hasDiscogsOAuthTokens();

  bool get hasWriteAccess => _configManager.hasDiscogsOAuthTokens();

  Map<String, String> _createOAuthHeaders(String method, String url) {
    _ensureOAuthInitialized();

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

  void _ensureOAuthInitialized() {
    final creds = _configManager.getDiscogsConsumerCredentials();
    final tokens = _configManager.getDiscogsOAuthTokens();

    final key = creds['consumer_key'] ?? '';
    final secret = creds['consumer_secret'] ?? '';
    final token = tokens['token'];
    final tokenSecret = tokens['secret'];

    // Nur neu erstellen wenn sich Credentials oder Tokens geaendert haben
    if (key == _cachedConsumerKey &&
        secret == _cachedConsumerSecret &&
        token == _cachedToken &&
        tokenSecret == _cachedTokenSecret &&
        _oauthService != null) {
      return;
    }

    _cachedConsumerKey = key;
    _cachedConsumerSecret = secret;
    _cachedToken = token;
    _cachedTokenSecret = tokenSecret;

    if (key.isNotEmpty && secret.isNotEmpty) {
      _oauthService = DiscogsOAuthService(
        consumerKey: key,
        consumerSecret: secret,
      );

      if (token != null &&
          tokenSecret != null &&
          token.isNotEmpty &&
          tokenSecret.isNotEmpty) {
        _oauthService!.setAccessToken(token, tokenSecret);
        LoggerService.oauth('Service initialized and authenticated');
      } else {
        LoggerService.warning(
            'OAuth Init', 'Service created but no access tokens found');
      }
    } else {
      _oauthService = null;
      LoggerService.warning(
          'OAuth Init', 'Service set to null - missing consumer credentials');
    }
  }

  Future<bool> testAuthentication() async {
    if (!hasAuth) return false;
    try {
      final url = '$_baseUrl/oauth/identity';
      final response = await _httpClient.get(Uri.parse(url),
          headers: _createOAuthHeaders('GET', url));
      LoggerService.api('oauth/identity', response.statusCode);
      return response.statusCode == 200;
    } catch (e) {
      LoggerService.error('OAuth test', e);
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

      final firstResp = await _httpClient.get(Uri.parse(firstUrl),
          headers: _createOAuthHeaders('GET', firstUrl));
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
        final pageResp = await _httpClient.get(Uri.parse(pageUrl),
            headers: _createOAuthHeaders('GET', pageUrl));
        if (pageResp.statusCode != 200) {
          throw Exception(
              'Wantlist-Seite $page fehlgeschlagen: ${pageResp.statusCode}');
        }
        final pageData = json.decode(pageResp.body);
        allWants.addAll(pageData['wants'] as List? ?? const []);
      }

      LoggerService.data('Wantlist loaded', allWants.length, 'items');

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
      LoggerService.error('Wantlist load', e);
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

      final response = await _httpClient.put(
        Uri.parse(url),
        headers: {
          ..._createOAuthHeaders('PUT', url),
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

      LoggerService.success('Added to Discogs wantlist', releaseId);
    } catch (e) {
      LoggerService.error('Add to wantlist', e, releaseId);
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

      final response = await _httpClient.delete(Uri.parse(url),
          headers: _createOAuthHeaders('DELETE', url));

      if (response.statusCode != 204 &&
          response.statusCode != 200 &&
          response.statusCode != 404) {
        throw Exception(
            'Entfernen fehlgeschlagen: ${response.statusCode} - ${response.body}');
      }

      LoggerService.success('Removed from Discogs wantlist', releaseId);
    } catch (e) {
      LoggerService.error('Remove from wantlist', e, releaseId);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchReleases(
    String query, {
    String? artist,
    String? releaseTitle,
    String? format,
    String? country,
  }) async {
    if (!hasAuth) {
      throw Exception('Keine Discogs-Authentifizierung verfügbar');
    }

    try {
      final params = <String, String>{
        'type': 'release',
      };

      if (query.isNotEmpty) {
        params['q'] = query;
      }
      if (artist != null && artist.isNotEmpty) {
        params['artist'] = artist;
      }
      if (releaseTitle != null && releaseTitle.isNotEmpty) {
        params['release_title'] = releaseTitle;
      }
      if (format != null && format.isNotEmpty) {
        params['format'] = format;
      }
      if (country != null && country.isNotEmpty) {
        params['country'] = country;
      }

      final uri = Uri.parse('$_baseUrl/database/search')
          .replace(queryParameters: params);
      final url = uri.toString();

      final response =
          await _httpClient.get(uri, headers: _createOAuthHeaders('GET', url));

      if (response.statusCode != 200) {
        throw Exception(
            'Suche fehlgeschlagen: ${response.statusCode} - ${response.body}');
      }

      final data = json.decode(response.body);
      final List results = data['results'] ?? [];

      LoggerService.data('Search results', results.length, 'releases');

      return results.cast<Map<String, dynamic>>();
    } catch (e) {
      LoggerService.error('Release search', e, query);
      rethrow;
    }
  }

  Future<List<Track>> getReleaseTracklist(String releaseId) async {
    if (!hasAuth) return [];

    try {
      final url = '$_baseUrl/releases/$releaseId';

      final response =
          await _httpClient.get(Uri.parse(url), headers: _createOAuthHeaders('GET', url));

      if (response.statusCode != 200) {
        LoggerService.api('releases/$releaseId', response.statusCode);
        return [];
      }

      final data = json.decode(response.body);
      final List? tracklist = data['tracklist'];

      if (tracklist == null || tracklist.isEmpty) {
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

      LoggerService.data('Tracks loaded', tracks.length, 'for release');
      return tracks;
    } catch (e) {
      LoggerService.error('Track loading', e, releaseId);
      return [];
    }
  }

  Future<String> _getOAuthUsername() async {
    final url = '$_baseUrl/oauth/identity';
    final response = await _httpClient.get(Uri.parse(url),
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
      return 'Vollzugriff (OAuth)';
    } else if (hasAuth) {
      return 'OAuth vorhanden';
    } else {
      return 'Kein Zugriff';
    }
  }
}
