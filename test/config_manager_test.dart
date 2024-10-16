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
    });

    test('Should save and retrieve JSON file name', () async {
      await configManager.setJsonFileName('test.json');
      String fileName = configManager.getJsonFileName();
      expect(fileName, 'test.json');
    });

    test('Should save and retrieve JSON file path', () async {
      await configManager.setJsonFilePath('/path/to/test.json');
      String? filePath = configManager.getJsonFilePath();
      expect(filePath, '/path/to/test.json');
    });
  });
}
