// lib/services/config_manager.dart

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigManager {
  late SharedPreferences _prefs;
  String? _jsonFilePath;
  String? _wantlistFilePath;
  String? _discogsToken;

  Future<void> loadConfig() async {
    _prefs = await SharedPreferences.getInstance();

    if (Platform.isAndroid || Platform.isIOS) {
      // Mobile: Use app documents directory
      final directory = await getApplicationDocumentsDirectory();

      _jsonFilePath =
          _prefs.getString('json_file_path') ?? '${directory.path}/albums.json';
      _wantlistFilePath = _prefs.getString('wantlist_file_path') ??
          '${directory.path}/wantlist.json';
    } else {
      // Desktop: Use user-selected path or default
      _jsonFilePath = _prefs.getString('json_file_path');
      _wantlistFilePath = _prefs.getString('wantlist_file_path');
    }

    // Lade Discogs Token
    _discogsToken = _prefs.getString('discogs_token');
  }

  // ===== COLLECTION FILE PATH METHODS =====
  String? getJsonFilePath() => _jsonFilePath;

  // ALIAS für bessere Kompatibilität
  String getCollectionFilePath() => _jsonFilePath ?? '';

  Future<void> setJsonFilePath(String path) async {
    _jsonFilePath = path;
    await _prefs.setString('json_file_path', path);
  }

  // ALIAS für bessere Kompatibilität
  Future<void> setCollectionFilePath(String path) async {
    await setJsonFilePath(path);
  }

  // ===== WANTLIST FILE PATH METHODS =====
  String? getWantlistFilePath() => _wantlistFilePath;

  Future<void> setWantlistFilePath(String path) async {
    _wantlistFilePath = path;
    await _prefs.setString('wantlist_file_path', path);
  }

  // ===== DISCOGS TOKEN METHODS =====
  // NULLABLE version - für interne Verwendung
  String? getDiscogsTokenNullable() => _discogsToken;

  // NON-NULLABLE version - für UI-Verwendung
  String getDiscogsToken() => _discogsToken ?? '';

  Future<void> setDiscogsToken(String token) async {
    _discogsToken = token;
    await _prefs.setString('discogs_token', token);
  }

  Future<void> saveConfig() async {
    // Config wird bereits in den set-Methoden gespeichert
    // Diese Methode bleibt für Kompatibilität erhalten
  }

  // ===== VALIDATION METHODS =====
  /// Prüft ob alle notwendigen Pfade konfiguriert sind
  bool isConfigured() {
    return _jsonFilePath != null && _jsonFilePath!.isNotEmpty;
  }

  /// Prüft ob Discogs Token konfiguriert ist
  bool hasDiscogsToken() {
    return _discogsToken != null && _discogsToken!.isNotEmpty;
  }

  // ===== UTILITY METHODS =====
  /// Gibt Standard-Wantlist-Pfad zurück falls nicht konfiguriert
  Future<String> getWantlistFilePathOrDefault() async {
    if (_wantlistFilePath != null && _wantlistFilePath!.isNotEmpty) {
      return _wantlistFilePath!;
    }

    // Fallback auf Standard-Pfad
    if (Platform.isAndroid || Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/wantlist.json';
    } else {
      // Desktop fallback - gleicher Ordner wie Collection
      final jsonPath = _jsonFilePath ?? '';
      if (jsonPath.isNotEmpty) {
        final directory = File(jsonPath).parent.path;
        return '$directory/wantlist.json';
      }
      return 'wantlist.json'; // Letzter Fallback
    }
  }

  // ===== RESET FUNCTIONALITY =====
  /// Setzt alle Einstellungen auf Standard zurück
  Future<void> resetConfig() async {
    // Lösche alle gespeicherten Werte
    await _prefs.remove('json_file_path');
    await _prefs.remove('wantlist_file_path');
    await _prefs.remove('discogs_token');

    // Setze interne Variablen zurück
    _jsonFilePath = null;
    _wantlistFilePath = null;
    _discogsToken = null;

    // Lade Standard-Konfiguration neu
    await loadConfig();
  }

  // ===== MIGRATION HELPERS =====
  /// Für zukünftige Updates - Migration alter Config-Formate
  Future<void> migrateConfigIfNeeded() async {
    // Placeholder für zukünftige Migrations-Logik
    // z.B. wenn sich die Struktur ändert
  }

  // ===== DEBUG METHODS =====
  /// Gibt alle aktuellen Config-Werte für Debugging aus
  Map<String, String?> getDebugInfo() {
    return {
      'json_file_path': _jsonFilePath,
      'wantlist_file_path': _wantlistFilePath,
      'discogs_token': _discogsToken != null && _discogsToken!.isNotEmpty
          ? '***HIDDEN***'
          : 'NOT_SET',
      'is_configured': isConfigured().toString(),
      'has_discogs_token': hasDiscogsToken().toString(),
    };
  }
}
