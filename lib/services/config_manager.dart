// lib/services/config_manager.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigManager {
  late SharedPreferences _prefs;
  String? _jsonFilePath;
  String? _wantlistFilePath;
  String? _discogsToken;
  ThemeMode? _themeMode; // NEU

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

    // Theme Mode laden
    String? themeModeString = _prefs.getString('theme_mode');
    _themeMode = _parseThemeMode(themeModeString);
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

  // THEME MODE METHODS
  ThemeMode getThemeMode() => _themeMode ?? ThemeMode.system;

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString('theme_mode', mode.name);
  }

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
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
    await _prefs.remove('theme_mode');
    await _prefs.remove('discogs_oauth_token');
    await _prefs.remove('discogs_oauth_token_secret');
    await _prefs.remove('discogs_consumer_key');
    await _prefs.remove('discogs_consumer_secret');

    // Setze interne Variablen zurück
    _jsonFilePath = null;
    _wantlistFilePath = null;
    _discogsToken = null;
    _themeMode = null;

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
      'theme_mode': _themeMode?.name ?? 'system',
    };
  }

  // ===== DISCOGS OAUTH METHODS =====
  // OAuth Token und Secret speichern
  Future<void> setDiscogsOAuthTokens(String token, String secret) async {
    await _prefs.setString('discogs_oauth_token', token);
    await _prefs.setString('discogs_oauth_token_secret', secret);
  }

  // OAuth Tokens laden
  Map<String, String?> getDiscogsOAuthTokens() {
    return {
      'token': _prefs.getString('discogs_oauth_token'),
      'secret': _prefs.getString('discogs_oauth_token_secret'),
    };
  }

  // Prüfen ob OAuth Tokens vorhanden sind
  bool hasDiscogsOAuthTokens() {
    final tokens = getDiscogsOAuthTokens();
    return tokens['token'] != null &&
        tokens['secret'] != null &&
        tokens['token']!.isNotEmpty &&
        tokens['secret']!.isNotEmpty;
  }

  // OAuth Tokens löschen
  Future<void> clearDiscogsOAuthTokens() async {
    await _prefs.remove('discogs_oauth_token');
    await _prefs.remove('discogs_oauth_token_secret');
  }

  // ===== NEU: DISCOGS CONSUMER CREDENTIALS =====
  Future<void> setDiscogsConsumerCredentials({
    required String consumerKey,
    required String consumerSecret,
  }) async {
    await _prefs.setString('discogs_consumer_key', consumerKey);
    await _prefs.setString('discogs_consumer_secret', consumerSecret);
  }

  Map<String, String?> getDiscogsConsumerCredentials() {
    return {
      'consumer_key': _prefs.getString('discogs_consumer_key'),
      'consumer_secret': _prefs.getString('discogs_consumer_secret'),
    };
  }
}
