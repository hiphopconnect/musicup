import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConfigManager Tests', () {
    late ConfigManager configManager;

    setUp(() async {
      // Set up the mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      configManager = ConfigManager();
      await configManager.loadConfig();
    });

    test('Should save and retrieve JSON file path', () async {
      await configManager.loadConfig();
      await configManager.setJsonFilePath('/test/path/albums.json');
      String? filePath = configManager.getJsonFilePath();
      expect(filePath, '/test/path/albums.json');
    });
    
    test('Should save and retrieve wantlist file path', () async {
      await configManager.loadConfig();
      await configManager.setWantlistFilePath('/path/to/wantlist.json');
      String? filePath = configManager.getWantlistFilePath();
      expect(filePath, '/path/to/wantlist.json');
    });

    test('Should save and retrieve discogs token', () async {
      await configManager.loadConfig();
      await configManager.setDiscogsToken('test_token_123');
      String token = configManager.getDiscogsToken();
      expect(token, 'test_token_123');
    });

    test('Should check configuration status', () async {
      await configManager.loadConfig();
      
      // Initially not configured
      expect(configManager.isConfigured(), isFalse);
      
      // After setting JSON path
      await configManager.setJsonFilePath('/test/albums.json');
      expect(configManager.isConfigured(), isTrue);
    });
  });
}
