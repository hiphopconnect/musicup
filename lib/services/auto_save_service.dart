// lib/services/auto_save_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:music_up/services/logger_service.dart';

/// Service für automatisches Speichern von Form-Drafts
class AutoSaveService {
  static const String _keyPrefix = 'auto_save_';
  static const Duration _saveDelay = Duration(seconds: 2);
  
  Timer? _saveTimer;
  
  /// Speichert Form-Daten mit Verzögerung
  void saveFormData(String formId, Map<String, dynamic> data) {
    _saveTimer?.cancel();
    
    _saveTimer = Timer(_saveDelay, () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final jsonData = jsonEncode(data);
        await prefs.setString('$_keyPrefix$formId', jsonData);
        
        LoggerService.info('AUTO_SAVE', 'Form data saved for $formId');
      } catch (e) {
        LoggerService.error('AUTO_SAVE', e, 'Failed to save form data for $formId');
      }
    });
  }
  
  /// Lädt gespeicherte Form-Daten
  Future<Map<String, dynamic>?> loadFormData(String formId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString('$_keyPrefix$formId');
      
      if (jsonData != null) {
        final data = jsonDecode(jsonData) as Map<String, dynamic>;
        LoggerService.info('AUTO_SAVE', 'Form data loaded for $formId');
        return data;
      }
    } catch (e) {
      LoggerService.error('AUTO_SAVE', e, 'Failed to load form data for $formId');
    }
    
    return null;
  }
  
  /// Löscht gespeicherte Form-Daten
  Future<void> clearFormData(String formId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_keyPrefix$formId');
      LoggerService.info('AUTO_SAVE', 'Form data cleared for $formId');
    } catch (e) {
      LoggerService.error('AUTO_SAVE', e, 'Failed to clear form data for $formId');
    }
  }
  
  /// Löscht alle Auto-Save Daten
  Future<void> clearAllFormData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
      
      for (final key in keys) {
        await prefs.remove(key);
      }
      
      LoggerService.info('AUTO_SAVE', 'All form data cleared');
    } catch (e) {
      LoggerService.error('AUTO_SAVE', e, 'Failed to clear all form data');
    }
  }
  
  /// Prüft ob Draft-Daten existieren
  Future<bool> hasDraftData(String formId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('$_keyPrefix$formId');
    } catch (e) {
      LoggerService.error('AUTO_SAVE', e, 'Failed to check draft data for $formId');
      return false;
    }
  }
  
  /// Bereinigt alte Draft-Daten (älter als 7 Tage)
  Future<void> cleanupOldDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));
      final cutoffDate = DateTime.now().subtract(const Duration(days: 7));
      
      for (final key in keys) {
        final jsonData = prefs.getString(key);
        if (jsonData != null) {
          try {
            final data = jsonDecode(jsonData) as Map<String, dynamic>;
            final timestamp = data['_timestamp'] as int?;
            
            if (timestamp != null) {
              final saveDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
              if (saveDate.isBefore(cutoffDate)) {
                await prefs.remove(key);
                LoggerService.info('AUTO_SAVE', 'Cleaned up old draft: $key');
              }
            }
          } catch (e) {
            // Invalid JSON, remove it
            await prefs.remove(key);
          }
        }
      }
    } catch (e) {
      LoggerService.error('AUTO_SAVE', e, 'Failed to cleanup old drafts');
    }
  }
  
  /// Fügt Timestamp zu Form-Daten hinzu
  Map<String, dynamic> _addTimestamp(Map<String, dynamic> data) {
    return {
      ...data,
      '_timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
  
  void dispose() {
    _saveTimer?.cancel();
  }
}