// lib/services/service_locator.dart

import 'package:flutter/foundation.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/discogs_service_unified.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/services/logger_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._();
  static ServiceLocator get instance => _instance;
  ServiceLocator._();

  late ConfigManager configManager;
  late JsonService jsonService;
  late DiscogsServiceUnified discogsService;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;

    configManager = ConfigManager();
    await configManager.loadConfig();
    jsonService = JsonService(configManager);
    discogsService = DiscogsServiceUnified(configManager);

    LoggerService.setMinLevel(
      LoggerService.parseLogLevel(configManager.getLogLevel()),
    );

    _initialized = true;
  }

  @visibleForTesting
  void initForTest({
    required ConfigManager configManager,
    required JsonService jsonService,
    required DiscogsServiceUnified discogsService,
  }) {
    this.configManager = configManager;
    this.jsonService = jsonService;
    this.discogsService = discogsService;
    _initialized = true;
  }

  @visibleForTesting
  void reset() {
    _initialized = false;
  }
}

/// Shorthand accessor
ServiceLocator get sl => ServiceLocator.instance;
