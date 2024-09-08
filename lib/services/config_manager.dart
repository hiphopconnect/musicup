import 'package:shared_preferences/shared_preferences.dart';

class ConfigManager {
  static const String jsonPathKey = 'jsonPath';
  SharedPreferences? _prefs;

  Future<void> loadConfig() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setJsonPath(String path) async {
    if (_prefs != null) {
      await _prefs!.setString(jsonPathKey, path);
    }
  }

  String? getJsonPath() {
    return _prefs?.getString(jsonPathKey);
  }

  Future<void> saveConfig() async {
    if (_prefs != null) {
      String? path = getJsonPath();
      if (path != null) {
        await _prefs!.setString(jsonPathKey, path);
      }
    }
  }
}
