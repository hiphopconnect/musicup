// test/discogs_service_unified_test.dart

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/discogs_service_unified.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sets up SharedPreferences with valid OAuth credentials and tokens,
/// then loads ConfigManager so it reads from those preferences.
Future<ConfigManager> _createConfigWithOAuth() async {
  SharedPreferences.setMockInitialValues({
    'discogs_consumer_key': 'test_consumer_key',
    'discogs_consumer_secret': 'test_consumer_secret',
    'discogs_oauth_token': 'test_oauth_token',
    'discogs_oauth_token_secret': 'test_oauth_token_secret',
  });
  final config = ConfigManager();
  await config.loadConfig();
  return config;
}

/// Sets up SharedPreferences without any OAuth tokens,
/// simulating an unauthenticated state.
Future<ConfigManager> _createConfigWithoutOAuth() async {
  SharedPreferences.setMockInitialValues({});
  final config = ConfigManager();
  await config.loadConfig();
  return config;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ===== hasAuth =====
  group('hasAuth', () {
    test('returns true when OAuth tokens are set', () async {
      final config = await _createConfigWithOAuth();
      final service = DiscogsServiceUnified(config);

      expect(service.hasAuth, isTrue);
    });

    test('returns false when no OAuth tokens are set', () async {
      final config = await _createConfigWithoutOAuth();
      final service = DiscogsServiceUnified(config);

      expect(service.hasAuth, isFalse);
    });

    test('returns false when tokens are empty strings', () async {
      SharedPreferences.setMockInitialValues({
        'discogs_oauth_token': '',
        'discogs_oauth_token_secret': '',
      });
      final config = ConfigManager();
      await config.loadConfig();
      final service = DiscogsServiceUnified(config);

      expect(service.hasAuth, isFalse);
    });

    test('returns false when only token is set but secret is missing', () async {
      SharedPreferences.setMockInitialValues({
        'discogs_oauth_token': 'some_token',
      });
      final config = ConfigManager();
      await config.loadConfig();
      final service = DiscogsServiceUnified(config);

      expect(service.hasAuth, isFalse);
    });
  });

  // ===== hasWriteAccess =====
  group('hasWriteAccess', () {
    test('returns true when OAuth tokens are set', () async {
      final config = await _createConfigWithOAuth();
      final service = DiscogsServiceUnified(config);

      expect(service.hasWriteAccess, isTrue);
    });

    test('returns false when no OAuth tokens are set', () async {
      final config = await _createConfigWithoutOAuth();
      final service = DiscogsServiceUnified(config);

      expect(service.hasWriteAccess, isFalse);
    });
  });

  // ===== testAuthentication =====
  group('testAuthentication', () {
    test('returns true on successful 200 response', () async {
      final config = await _createConfigWithOAuth();

      final mockClient = MockClient((request) async {
        expect(request.url.path, '/oauth/identity');
        return http.Response('{"id": 1, "username": "testuser"}', 200);
      });

      final service = DiscogsServiceUnified(config, httpClient: mockClient);
      final result = await service.testAuthentication();

      expect(result, isTrue);
    });

    test('returns false on 401 unauthorized response', () async {
      final config = await _createConfigWithOAuth();

      final mockClient = MockClient((request) async {
        return http.Response('{"message": "Unauthorized"}', 401);
      });

      final service = DiscogsServiceUnified(config, httpClient: mockClient);
      final result = await service.testAuthentication();

      expect(result, isFalse);
    });

    test('returns false when no auth is configured', () async {
      final config = await _createConfigWithoutOAuth();

      // MockClient should never be called since hasAuth is false
      final mockClient = MockClient((request) async {
        fail('HTTP request should not be made when auth is missing');
      });

      final service = DiscogsServiceUnified(config, httpClient: mockClient);
      final result = await service.testAuthentication();

      expect(result, isFalse);
    });

    test('returns false on network error', () async {
      final config = await _createConfigWithOAuth();

      final mockClient = MockClient((request) async {
        throw Exception('Network error');
      });

      final service = DiscogsServiceUnified(config, httpClient: mockClient);
      final result = await service.testAuthentication();

      expect(result, isFalse);
    });
  });

  // ===== searchReleases =====
  group('searchReleases', () {
    test('returns results on successful search', () async {
      final config = await _createConfigWithOAuth();

      final responseBody = json.encode({
        'results': [
          {
            'id': 12345,
            'title': 'Nas - Illmatic',
            'year': '1994',
            'format': ['Vinyl'],
            'genre': ['Hip Hop'],
            'thumb': 'https://example.com/thumb.jpg',
          },
          {
            'id': 67890,
            'title': 'Wu-Tang Clan - Enter The Wu-Tang',
            'year': '1993',
            'format': ['CD'],
            'genre': ['Hip Hop'],
            'thumb': '',
          },
        ],
      });

      final mockClient = MockClient((request) async {
        expect(request.url.path, '/database/search');
        expect(request.url.queryParameters['q'], 'Illmatic');
        expect(request.url.queryParameters['type'], 'release');
        return http.Response(responseBody, 200);
      });

      final service = DiscogsServiceUnified(config, httpClient: mockClient);
      final results = await service.searchReleases('Illmatic');

      expect(results, isA<List<Map<String, dynamic>>>());
      expect(results.length, 2);
      expect(results[0]['id'], 12345);
      expect(results[0]['title'], 'Nas - Illmatic');
      expect(results[1]['id'], 67890);
    });

    test('returns empty list when no results found', () async {
      final config = await _createConfigWithOAuth();

      final responseBody = json.encode({
        'results': [],
      });

      final mockClient = MockClient((request) async {
        return http.Response(responseBody, 200);
      });

      final service = DiscogsServiceUnified(config, httpClient: mockClient);
      final results = await service.searchReleases('nonexistent_album_xyz');

      expect(results, isEmpty);
    });

    test('throws exception on API error', () async {
      final config = await _createConfigWithOAuth();

      final mockClient = MockClient((request) async {
        return http.Response('{"message": "Rate limit exceeded"}', 429);
      });

      final service = DiscogsServiceUnified(config, httpClient: mockClient);

      expect(
        () => service.searchReleases('test'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('429'),
        )),
      );
    });

    test('throws exception when not authenticated', () async {
      final config = await _createConfigWithoutOAuth();

      final mockClient = MockClient((request) async {
        fail('HTTP request should not be made without auth');
      });

      final service = DiscogsServiceUnified(config, httpClient: mockClient);

      expect(
        () => service.searchReleases('test'),
        throwsA(isA<Exception>()),
      );
    });

    test('passes optional filter parameters', () async {
      final config = await _createConfigWithOAuth();

      final mockClient = MockClient((request) async {
        expect(request.url.queryParameters['artist'], 'Nas');
        expect(request.url.queryParameters['release_title'], 'Illmatic');
        expect(request.url.queryParameters['format'], 'Vinyl');
        expect(request.url.queryParameters['country'], 'US');
        return http.Response(json.encode({'results': []}), 200);
      });

      final service = DiscogsServiceUnified(config, httpClient: mockClient);
      final results = await service.searchReleases(
        '',
        artist: 'Nas',
        releaseTitle: 'Illmatic',
        format: 'Vinyl',
        country: 'US',
      );

      expect(results, isEmpty);
    });
  });

  // ===== getReleaseTracklist =====
  group('getReleaseTracklist', () {
    test('returns tracks on successful response', () async {
      final config = await _createConfigWithOAuth();

      final responseBody = json.encode({
        'tracklist': [
          {'position': '1', 'title': 'The Genesis'},
          {'position': '2', 'title': 'N.Y. State of Mind'},
          {'position': 'A1', 'title': 'Life\'s a Bitch'},
          {'position': '', 'title': 'The World Is Yours'},
        ],
      });

      final mockClient = MockClient((request) async {
        expect(request.url.path, '/releases/12345');
        return http.Response(responseBody, 200);
      });

      final service = DiscogsServiceUnified(config, httpClient: mockClient);
      final tracks = await service.getReleaseTracklist('12345');

      expect(tracks.length, 4);
      expect(tracks[0].title, 'The Genesis');
      expect(tracks[0].trackNumber, '01');
      expect(tracks[1].title, 'N.Y. State of Mind');
      expect(tracks[1].trackNumber, '02');
      expect(tracks[2].title, 'Life\'s a Bitch');
      expect(tracks[2].trackNumber, 'A1');
      expect(tracks[3].title, 'The World Is Yours');
      // Empty position falls back to index-based numbering (index 4 -> "04")
      expect(tracks[3].trackNumber, '04');
    });

    test('returns empty list when tracklist is empty', () async {
      final config = await _createConfigWithOAuth();

      final responseBody = json.encode({
        'tracklist': [],
      });

      final mockClient = MockClient((request) async {
        return http.Response(responseBody, 200);
      });

      final service = DiscogsServiceUnified(config, httpClient: mockClient);
      final tracks = await service.getReleaseTracklist('99999');

      expect(tracks, isEmpty);
    });

    test('returns empty list when tracklist is null', () async {
      final config = await _createConfigWithOAuth();

      final responseBody = json.encode({
        'title': 'Some Album',
      });

      final mockClient = MockClient((request) async {
        return http.Response(responseBody, 200);
      });

      final service = DiscogsServiceUnified(config, httpClient: mockClient);
      final tracks = await service.getReleaseTracklist('99999');

      expect(tracks, isEmpty);
    });

    test('returns empty list when no auth is configured', () async {
      final config = await _createConfigWithoutOAuth();

      final mockClient = MockClient((request) async {
        fail('HTTP request should not be made without auth');
      });

      final service = DiscogsServiceUnified(config, httpClient: mockClient);
      final tracks = await service.getReleaseTracklist('12345');

      expect(tracks, isEmpty);
    });

    test('returns empty list on non-200 response', () async {
      final config = await _createConfigWithOAuth();

      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final service = DiscogsServiceUnified(config, httpClient: mockClient);
      final tracks = await service.getReleaseTracklist('00000');

      expect(tracks, isEmpty);
    });

    test('skips tracks with empty titles', () async {
      final config = await _createConfigWithOAuth();

      final responseBody = json.encode({
        'tracklist': [
          {'position': '1', 'title': 'Real Track'},
          {'position': '2', 'title': ''},
          {'position': '3', 'title': '   '},
          {'position': '4', 'title': 'Another Track'},
        ],
      });

      final mockClient = MockClient((request) async {
        return http.Response(responseBody, 200);
      });

      final service = DiscogsServiceUnified(config, httpClient: mockClient);
      final tracks = await service.getReleaseTracklist('12345');

      expect(tracks.length, 2);
      expect(tracks[0].title, 'Real Track');
      expect(tracks[1].title, 'Another Track');
    });

    test('returns empty list on network error', () async {
      final config = await _createConfigWithOAuth();

      final mockClient = MockClient((request) async {
        throw Exception('Connection timeout');
      });

      final service = DiscogsServiceUnified(config, httpClient: mockClient);
      final tracks = await service.getReleaseTracklist('12345');

      expect(tracks, isEmpty);
    });
  });

  // ===== statusMessage =====
  group('statusMessage', () {
    test('returns full access message when write access is available', () async {
      final config = await _createConfigWithOAuth();
      final service = DiscogsServiceUnified(config);

      // With OAuth tokens set, both hasAuth and hasWriteAccess are true
      expect(service.statusMessage, 'Vollzugriff (OAuth)');
    });

    test('returns no access message when no auth is configured', () async {
      final config = await _createConfigWithoutOAuth();
      final service = DiscogsServiceUnified(config);

      expect(service.statusMessage, 'Kein Zugriff');
    });
  });
}
