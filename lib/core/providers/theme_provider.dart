import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/json_service.dart';

// Simple providers without code generation for now
final configManagerProvider = Provider<ConfigManager>((ref) {
  throw UnimplementedError('ConfigManager provider needs to be overridden');
});

final jsonServiceProvider = Provider<JsonService>((ref) {
  throw UnimplementedError('JsonService provider needs to be overridden');
});

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final configManager = ref.read(configManagerProvider);
  return ThemeNotifier(configManager);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final ConfigManager _configManager;

  ThemeNotifier(this._configManager) : super(_configManager.getThemeMode());

  Future<void> updateTheme(ThemeMode mode) async {
    await _configManager.setThemeMode(mode);
    state = mode;
  }
}