import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';


class ConfigManager {
  static const String jsonFileNameKey = 'jsonFileName';
  static const String jsonFilePathKey = 'jsonFilePath';
  SharedPreferences? _prefs;

  Future<void> loadConfig() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setJsonFileName(String fileName) async {
    if (_prefs != null) {
      await _prefs!.setString(jsonFileNameKey, fileName);
    }
  }

  String getJsonFileName() {
    return _prefs?.getString(jsonFileNameKey) ?? 'albums.json';
  }

  // **Hier fügen wir die fehlende Methode hinzu**
  Future<void> setJsonFilePath(String filePath) async {
    if (_prefs != null) {
      await _prefs!.setString(jsonFilePathKey, filePath);
    }
  }

  String? getJsonFilePath() {
    return _prefs?.getString(jsonFilePathKey);
  }

  Future<String> getJsonFilePathAsync() async {
    String? filePath = getJsonFilePath();

    if (filePath != null && filePath.isNotEmpty) {
      return filePath;
    } else {
      // Fallback auf Standardpfad
      String fileName = getJsonFileName();
      final directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/$fileName';
    }
  }

  Future<void> saveConfig() async {
    // Einstellungen werden direkt beim Setzen gespeichert
    // Diese Methode kann leer bleiben oder entfernt werden, wenn nicht benötigt
  }
}
