import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ConfigManager configManager;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    configManager = ConfigManager();
    await configManager.loadConfig();
  });

  // -------------------------------------------------------
  // 1. loadConfig - loads values from SharedPreferences
  // -------------------------------------------------------
  group('loadConfig', () {
    test('loads previously stored json_file_path', () async {
      SharedPreferences.setMockInitialValues({
        'json_file_path': '/home/user/music/albums.json',
      });

      final cm = ConfigManager();
      await cm.loadConfig();

      expect(cm.getJsonFilePath(), '/home/user/music/albums.json');
    });

    test('loads previously stored wantlist_file_path', () async {
      SharedPreferences.setMockInitialValues({
        'wantlist_file_path': '/home/user/music/wantlist.json',
      });

      final cm = ConfigManager();
      await cm.loadConfig();

      expect(cm.getWantlistFilePath(), '/home/user/music/wantlist.json');
    });

    test('loads previously stored discogs_token', () async {
      SharedPreferences.setMockInitialValues({
        'discogs_token': 'my-secret-token',
      });

      final cm = ConfigManager();
      await cm.loadConfig();

      expect(cm.getDiscogsToken(), 'my-secret-token');
    });

    test('loads previously stored theme_mode', () async {
      SharedPreferences.setMockInitialValues({
        'theme_mode': 'dark',
      });

      final cm = ConfigManager();
      await cm.loadConfig();

      expect(cm.getThemeMode(), ThemeMode.dark);
    });

    test('defaults to null paths on desktop when nothing stored', () async {
      SharedPreferences.setMockInitialValues({});

      final cm = ConfigManager();
      await cm.loadConfig();

      // On desktop (Linux test runner), paths default to null
      expect(cm.getJsonFilePath(), isNull);
      expect(cm.getWantlistFilePath(), isNull);
    });
  });

  // -------------------------------------------------------
  // 2. getJsonFilePath / setJsonFilePath roundtrip
  // -------------------------------------------------------
  group('getJsonFilePath / setJsonFilePath', () {
    test('returns null initially on desktop', () {
      expect(configManager.getJsonFilePath(), isNull);
    });

    test('set then get returns same value', () async {
      await configManager.setJsonFilePath('/tmp/albums.json');
      expect(configManager.getJsonFilePath(), '/tmp/albums.json');
    });

    test('persists value in SharedPreferences', () async {
      await configManager.setJsonFilePath('/tmp/albums.json');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('json_file_path'), '/tmp/albums.json');
    });

    test('getCollectionFilePath alias returns same value', () async {
      await configManager.setJsonFilePath('/tmp/albums.json');
      expect(configManager.getCollectionFilePath(), '/tmp/albums.json');
    });

    test('setCollectionFilePath alias works', () async {
      await configManager.setCollectionFilePath('/tmp/collection.json');
      expect(configManager.getJsonFilePath(), '/tmp/collection.json');
    });

    test('getCollectionFilePath returns empty string when null', () {
      expect(configManager.getCollectionFilePath(), '');
    });
  });

  // -------------------------------------------------------
  // 3. getWantlistFilePath / setWantlistFilePath roundtrip
  // -------------------------------------------------------
  group('getWantlistFilePath / setWantlistFilePath', () {
    test('returns null initially on desktop', () {
      expect(configManager.getWantlistFilePath(), isNull);
    });

    test('set then get returns same value', () async {
      await configManager.setWantlistFilePath('/tmp/wantlist.json');
      expect(configManager.getWantlistFilePath(), '/tmp/wantlist.json');
    });

    test('persists value in SharedPreferences', () async {
      await configManager.setWantlistFilePath('/tmp/wantlist.json');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('wantlist_file_path'), '/tmp/wantlist.json');
    });
  });

  // -------------------------------------------------------
  // 4. getDiscogsToken / setDiscogsToken / hasDiscogsToken
  // -------------------------------------------------------
  group('Discogs token', () {
    test('getDiscogsToken returns empty string initially', () {
      expect(configManager.getDiscogsToken(), '');
    });

    test('getDiscogsTokenNullable returns null initially', () {
      expect(configManager.getDiscogsTokenNullable(), isNull);
    });

    test('hasDiscogsToken returns false initially', () {
      expect(configManager.hasDiscogsToken(), isFalse);
    });

    test('set then get returns same value', () async {
      await configManager.setDiscogsToken('abc123');
      expect(configManager.getDiscogsToken(), 'abc123');
    });

    test('hasDiscogsToken returns true after setting token', () async {
      await configManager.setDiscogsToken('abc123');
      expect(configManager.hasDiscogsToken(), isTrue);
    });

    test('hasDiscogsToken returns false for empty string token', () async {
      await configManager.setDiscogsToken('');
      expect(configManager.hasDiscogsToken(), isFalse);
    });

    test('persists value in SharedPreferences', () async {
      await configManager.setDiscogsToken('abc123');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('discogs_token'), 'abc123');
    });
  });

  // -------------------------------------------------------
  // 5. getThemeMode / setThemeMode - all three modes
  // -------------------------------------------------------
  group('Theme mode', () {
    test('defaults to ThemeMode.system', () {
      expect(configManager.getThemeMode(), ThemeMode.system);
    });

    test('set light then get returns light', () async {
      await configManager.setThemeMode(ThemeMode.light);
      expect(configManager.getThemeMode(), ThemeMode.light);
    });

    test('set dark then get returns dark', () async {
      await configManager.setThemeMode(ThemeMode.dark);
      expect(configManager.getThemeMode(), ThemeMode.dark);
    });

    test('set system then get returns system', () async {
      await configManager.setThemeMode(ThemeMode.system);
      expect(configManager.getThemeMode(), ThemeMode.system);
    });

    test('persists value in SharedPreferences', () async {
      await configManager.setThemeMode(ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'dark');
    });

    test('theme mode survives reload', () async {
      await configManager.setThemeMode(ThemeMode.light);

      // Reload from SharedPreferences
      final cm2 = ConfigManager();
      await cm2.loadConfig();

      expect(cm2.getThemeMode(), ThemeMode.light);
    });
  });

  // -------------------------------------------------------
  // 6. _parseThemeMode - known values and unknown value
  // -------------------------------------------------------
  group('_parseThemeMode (tested indirectly via loadConfig)', () {
    test('parses "light" correctly', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
      final cm = ConfigManager();
      await cm.loadConfig();
      expect(cm.getThemeMode(), ThemeMode.light);
    });

    test('parses "dark" correctly', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final cm = ConfigManager();
      await cm.loadConfig();
      expect(cm.getThemeMode(), ThemeMode.dark);
    });

    test('parses "system" correctly', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'system'});
      final cm = ConfigManager();
      await cm.loadConfig();
      expect(cm.getThemeMode(), ThemeMode.system);
    });

    test('unknown value defaults to system', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'unknown_value'});
      final cm = ConfigManager();
      await cm.loadConfig();
      expect(cm.getThemeMode(), ThemeMode.system);
    });

    test('null value defaults to system', () async {
      SharedPreferences.setMockInitialValues({});
      final cm = ConfigManager();
      await cm.loadConfig();
      expect(cm.getThemeMode(), ThemeMode.system);
    });
  });

  // -------------------------------------------------------
  // 7. isConfigured - true when path set, false when null
  // -------------------------------------------------------
  group('isConfigured', () {
    test('returns false when jsonFilePath is null', () {
      expect(configManager.isConfigured(), isFalse);
    });

    test('returns true when jsonFilePath is set', () async {
      await configManager.setJsonFilePath('/tmp/albums.json');
      expect(configManager.isConfigured(), isTrue);
    });

    test('returns false when jsonFilePath is empty string', () async {
      await configManager.setJsonFilePath('');
      expect(configManager.isConfigured(), isFalse);
    });
  });

  // -------------------------------------------------------
  // 8. resetConfig - clears all values
  // -------------------------------------------------------
  group('resetConfig', () {
    test('clears json file path', () async {
      await configManager.setJsonFilePath('/tmp/albums.json');
      expect(configManager.isConfigured(), isTrue);

      await configManager.resetConfig();

      // On desktop without stored prefs, path goes back to null
      expect(configManager.getJsonFilePath(), isNull);
    });

    test('clears wantlist file path', () async {
      await configManager.setWantlistFilePath('/tmp/wantlist.json');
      await configManager.resetConfig();
      expect(configManager.getWantlistFilePath(), isNull);
    });

    test('clears discogs token', () async {
      await configManager.setDiscogsToken('secret');
      await configManager.resetConfig();
      expect(configManager.hasDiscogsToken(), isFalse);
      expect(configManager.getDiscogsToken(), '');
    });

    test('resets theme mode to system', () async {
      await configManager.setThemeMode(ThemeMode.dark);
      await configManager.resetConfig();
      expect(configManager.getThemeMode(), ThemeMode.system);
    });

    test('clears OAuth tokens', () async {
      await configManager.setDiscogsOAuthTokens('token', 'secret');
      await configManager.resetConfig();
      expect(configManager.hasDiscogsOAuthTokens(), isFalse);
    });

    test('clears consumer credentials', () async {
      await configManager.setDiscogsConsumerCredentials(
        consumerKey: 'key',
        consumerSecret: 'secret',
      );
      await configManager.resetConfig();
      final creds = configManager.getDiscogsConsumerCredentials();
      expect(creds['consumer_key'], isNull);
      expect(creds['consumer_secret'], isNull);
    });

    test('clears setup_completed', () async {
      await configManager.setSetupCompleted();
      expect(configManager.isSetupCompleted(), isTrue);

      await configManager.resetConfig();
      expect(configManager.isSetupCompleted(), isFalse);
    });

    test('clears tour_completed', () async {
      await configManager.setTourCompleted();
      expect(configManager.isTourCompleted(), isTrue);

      await configManager.resetConfig();
      expect(configManager.isTourCompleted(), isFalse);
    });

    test('clears log_level', () async {
      await configManager.setLogLevel('error');
      await configManager.resetConfig();
      expect(configManager.getLogLevel(), 'debug');
    });
  });

  // -------------------------------------------------------
  // 9. getDebugInfo - returns expected keys
  // -------------------------------------------------------
  group('getDebugInfo', () {
    test('contains all expected keys', () {
      final info = configManager.getDebugInfo();

      expect(info.containsKey('json_file_path'), isTrue);
      expect(info.containsKey('wantlist_file_path'), isTrue);
      expect(info.containsKey('discogs_token'), isTrue);
      expect(info.containsKey('is_configured'), isTrue);
      expect(info.containsKey('has_discogs_token'), isTrue);
      expect(info.containsKey('theme_mode'), isTrue);
    });

    test('shows NOT_SET when no discogs token', () {
      final info = configManager.getDebugInfo();
      expect(info['discogs_token'], 'NOT_SET');
    });

    test('hides discogs token when set', () async {
      await configManager.setDiscogsToken('secret-token');
      final info = configManager.getDebugInfo();
      expect(info['discogs_token'], '***HIDDEN***');
    });

    test('shows correct is_configured value', () async {
      var info = configManager.getDebugInfo();
      expect(info['is_configured'], 'false');

      await configManager.setJsonFilePath('/tmp/albums.json');
      info = configManager.getDebugInfo();
      expect(info['is_configured'], 'true');
    });

    test('shows correct theme_mode', () async {
      await configManager.setThemeMode(ThemeMode.dark);
      final info = configManager.getDebugInfo();
      expect(info['theme_mode'], 'dark');
    });

    test('shows system as default theme_mode', () {
      final info = configManager.getDebugInfo();
      expect(info['theme_mode'], 'system');
    });
  });

  // -------------------------------------------------------
  // 10. OAuth token methods - set, get, has, clear
  // -------------------------------------------------------
  group('OAuth token methods', () {
    test('no OAuth tokens initially', () {
      expect(configManager.hasDiscogsOAuthTokens(), isFalse);
    });

    test('getDiscogsOAuthTokens returns nulls initially', () {
      final tokens = configManager.getDiscogsOAuthTokens();
      expect(tokens['token'], isNull);
      expect(tokens['secret'], isNull);
    });

    test('set then get returns correct values', () async {
      await configManager.setDiscogsOAuthTokens('my-token', 'my-secret');

      final tokens = configManager.getDiscogsOAuthTokens();
      expect(tokens['token'], 'my-token');
      expect(tokens['secret'], 'my-secret');
    });

    test('hasDiscogsOAuthTokens returns true after setting', () async {
      await configManager.setDiscogsOAuthTokens('my-token', 'my-secret');
      expect(configManager.hasDiscogsOAuthTokens(), isTrue);
    });

    test('hasDiscogsOAuthTokens returns false when token is empty', () async {
      await configManager.setDiscogsOAuthTokens('', 'my-secret');
      expect(configManager.hasDiscogsOAuthTokens(), isFalse);
    });

    test('hasDiscogsOAuthTokens returns false when secret is empty', () async {
      await configManager.setDiscogsOAuthTokens('my-token', '');
      expect(configManager.hasDiscogsOAuthTokens(), isFalse);
    });

    test('clearDiscogsOAuthTokens removes tokens', () async {
      await configManager.setDiscogsOAuthTokens('my-token', 'my-secret');
      expect(configManager.hasDiscogsOAuthTokens(), isTrue);

      await configManager.clearDiscogsOAuthTokens();
      expect(configManager.hasDiscogsOAuthTokens(), isFalse);

      final tokens = configManager.getDiscogsOAuthTokens();
      expect(tokens['token'], isNull);
      expect(tokens['secret'], isNull);
    });
  });

  // -------------------------------------------------------
  // 11. Consumer credentials - set, get
  // -------------------------------------------------------
  group('Consumer credentials', () {
    test('returns nulls initially', () {
      final creds = configManager.getDiscogsConsumerCredentials();
      expect(creds['consumer_key'], isNull);
      expect(creds['consumer_secret'], isNull);
    });

    test('set then get returns correct values', () async {
      await configManager.setDiscogsConsumerCredentials(
        consumerKey: 'my-key',
        consumerSecret: 'my-secret',
      );

      final creds = configManager.getDiscogsConsumerCredentials();
      expect(creds['consumer_key'], 'my-key');
      expect(creds['consumer_secret'], 'my-secret');
    });

    test('persists values in SharedPreferences', () async {
      await configManager.setDiscogsConsumerCredentials(
        consumerKey: 'my-key',
        consumerSecret: 'my-secret',
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('discogs_consumer_key'), 'my-key');
      expect(prefs.getString('discogs_consumer_secret'), 'my-secret');
    });
  });

  // -------------------------------------------------------
  // 12. Setup wizard - isSetupCompleted, setSetupCompleted
  // -------------------------------------------------------
  group('Setup wizard', () {
    test('not completed initially', () {
      expect(configManager.isSetupCompleted(), isFalse);
    });

    test('setSetupCompleted marks as completed', () async {
      await configManager.setSetupCompleted();
      expect(configManager.isSetupCompleted(), isTrue);
    });

    test('persists in SharedPreferences', () async {
      await configManager.setSetupCompleted();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('setup_completed'), isTrue);
    });

    test('survives reload', () async {
      await configManager.setSetupCompleted();

      final cm2 = ConfigManager();
      await cm2.loadConfig();
      expect(cm2.isSetupCompleted(), isTrue);
    });
  });

  // -------------------------------------------------------
  // 13. Tour - isTourCompleted, setTourCompleted, resetTourCompleted
  // -------------------------------------------------------
  group('Guided tour', () {
    test('not completed initially', () {
      expect(configManager.isTourCompleted(), isFalse);
    });

    test('setTourCompleted marks as completed', () async {
      await configManager.setTourCompleted();
      expect(configManager.isTourCompleted(), isTrue);
    });

    test('resetTourCompleted clears the flag', () async {
      await configManager.setTourCompleted();
      expect(configManager.isTourCompleted(), isTrue);

      await configManager.resetTourCompleted();
      expect(configManager.isTourCompleted(), isFalse);
    });

    test('persists in SharedPreferences', () async {
      await configManager.setTourCompleted();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('tour_completed'), isTrue);
    });

    test('survives reload', () async {
      await configManager.setTourCompleted();

      final cm2 = ConfigManager();
      await cm2.loadConfig();
      expect(cm2.isTourCompleted(), isTrue);
    });
  });

  // -------------------------------------------------------
  // 14. Log level - getLogLevel, setLogLevel
  // -------------------------------------------------------
  group('Log level', () {
    test('defaults to debug', () {
      expect(configManager.getLogLevel(), 'debug');
    });

    test('set then get returns same value', () async {
      await configManager.setLogLevel('error');
      expect(configManager.getLogLevel(), 'error');
    });

    test('supports all log levels', () async {
      for (final level in ['debug', 'info', 'warning', 'error']) {
        await configManager.setLogLevel(level);
        expect(configManager.getLogLevel(), level);
      }
    });

    test('persists in SharedPreferences', () async {
      await configManager.setLogLevel('warning');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('log_level'), 'warning');
    });

    test('survives reload', () async {
      await configManager.setLogLevel('info');

      final cm2 = ConfigManager();
      await cm2.loadConfig();
      expect(cm2.getLogLevel(), 'info');
    });
  });
}
