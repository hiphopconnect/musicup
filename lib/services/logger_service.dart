// lib/services/logger_service.dart

import 'package:flutter/foundation.dart';

class LoggerService {
  static const String _tag = 'MusicUp';

  // Erfolgreiche Operationen
  static void success(String operation, [String? details]) {
    if (kDebugMode) {
      final message = details != null ? '$operation: $details' : operation;
      debugPrint('SUCCESS $_tag $message');
    }
  }

  // Fehler die behandelt werden
  static void error(String operation, dynamic error, [String? context]) {
    if (kDebugMode) {
      final contextInfo = context != null ? ' ($context)' : '';
      debugPrint('ERROR $_tag $operation failed$contextInfo: $error');
    }
  }

  // Warnungen für nicht-kritische Probleme
  static void warning(String operation, String message) {
    if (kDebugMode) {
      debugPrint('WARNING $_tag $operation: $message');
    }
  }

  // Informationen für wichtige Zustandsänderungen
  static void info(String operation, String message) {
    if (kDebugMode) {
      debugPrint('INFO $_tag $operation: $message');
    }
  }

  // OAuth spezifische Logs
  static void oauth(String operation, [bool success = true]) {
    final icon = success ? 'OAUTH SUCCESS' : 'OAUTH ERROR';
    if (kDebugMode) {
      debugPrint('$icon $_tag OAuth $operation');
    }
  }

  // API spezifische Logs
  static void api(String endpoint, int statusCode, [String? details]) {
    final icon = statusCode >= 200 && statusCode < 300 ? 'API SUCCESS' : 'API ERROR';
    if (kDebugMode) {
      final detailsStr = details != null ? ' - $details' : '';
      debugPrint('$icon $_tag API $endpoint: $statusCode$detailsStr');
    }
  }

  // Datenoperationen
  static void data(String operation, [int? count, String? type]) {
    if (kDebugMode) {
      final countStr = count != null ? ' ($count items)' : '';
      final typeStr = type != null ? ' $type' : '';
      debugPrint('DATA $_tag Data $operation$typeStr$countStr');
    }
  }
}