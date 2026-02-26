// lib/services/logger_service.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error;

  bool operator >=(LogLevel other) => index >= other.index;
}

class LoggerService {
  static const String _tag = 'MusicUp';
  static const int _maxLogAgeDays = 7;

  static IOSink? _logSink;
  static File? _currentLogFile;
  static Directory? _logDirectory;
  static bool _initialized = false;
  static LogLevel _minLevel = LogLevel.debug;

  static LogLevel get minLevel => _minLevel;

  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  static LogLevel parseLogLevel(String level) {
    switch (level.toLowerCase()) {
      case 'info':
        return LogLevel.info;
      case 'warning':
        return LogLevel.warning;
      case 'error':
        return LogLevel.error;
      default:
        return LogLevel.debug;
    }
  }

  static Future<void> init() async {
    if (_initialized) return;

    try {
      final appDir = await getApplicationSupportDirectory();
      _logDirectory = Directory('${appDir.path}/logs');

      if (!await _logDirectory!.exists()) {
        await _logDirectory!.create(recursive: true);
      }

      final today = _formatDate(DateTime.now());
      _currentLogFile = File('${_logDirectory!.path}/musicup_$today.log');
      _logSink = _currentLogFile!.openWrite(mode: FileMode.append);

      _initialized = true;

      _writeToFile('INFO', 'LoggerService initialized');
      _rotateOldLogs();
    } catch (e) {
      debugPrint('ERROR $_tag LoggerService init failed: $e');
    }
  }

  static void success(String operation, [String? details]) {
    if (!(LogLevel.info >= _minLevel)) return;
    final message = details != null ? '$operation: $details' : operation;
    _printDebug('SUCCESS', message);
    _writeToFile('SUCCESS', message);
  }

  static void error(String operation, dynamic error, [String? context]) {
    if (!(LogLevel.error >= _minLevel)) return;
    final contextInfo = context != null ? ' ($context)' : '';
    final message = '$operation failed$contextInfo: $error';
    _printDebug('ERROR', message);
    _writeToFile('ERROR', message);
  }

  static void warning(String operation, String message) {
    if (!(LogLevel.warning >= _minLevel)) return;
    final fullMessage = '$operation: $message';
    _printDebug('WARNING', fullMessage);
    _writeToFile('WARNING', fullMessage);
  }

  static void info(String operation, String message) {
    if (!(LogLevel.info >= _minLevel)) return;
    final fullMessage = '$operation: $message';
    _printDebug('INFO', fullMessage);
    _writeToFile('INFO', fullMessage);
  }

  static void oauth(String operation, [bool success = true]) {
    if (!(LogLevel.info >= _minLevel)) return;
    final status = success ? 'SUCCESS' : 'ERROR';
    final message = 'OAuth $operation';
    _printDebug('OAUTH $status', message);
    _writeToFile('OAUTH', '$operation: $status');
  }

  static void api(String endpoint, int statusCode, [String? details]) {
    if (!(LogLevel.info >= _minLevel)) return;
    final status = statusCode >= 200 && statusCode < 300 ? 'SUCCESS' : 'ERROR';
    final detailsStr = details != null ? ' - $details' : '';
    final message = 'API $endpoint: $statusCode$detailsStr';
    _printDebug('API $status', message);
    _writeToFile('API', '$endpoint: $statusCode$detailsStr');
  }

  static void data(String operation, [int? count, String? type]) {
    if (!(LogLevel.debug >= _minLevel)) return;
    final countStr = count != null ? ' ($count items)' : '';
    final typeStr = type != null ? ' $type' : '';
    final message = 'Data $operation$typeStr$countStr';
    _printDebug('DATA', message);
    _writeToFile('DATA', '$operation$typeStr$countStr');
  }

  // -- File access methods --

  static Directory? getLogDirectory() => _logDirectory;

  static List<File> getLogFiles() {
    if (_logDirectory == null || !_logDirectory!.existsSync()) return [];
    return _logDirectory!
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.log'))
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path));
  }

  /// Shares the current log file. On Android via native share dialog,
  /// on Linux by copying the path to clipboard.
  /// [platformAction] can be overridden for testing to avoid platform channels.
  static Future<void> shareLogs(
    BuildContext context, {
    Future<void> Function(String path)? platformAction,
  }) async {
    if (_currentLogFile == null || !await _currentLogFile!.exists()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keine Log-Datei vorhanden')),
        );
      }
      return;
    }

    // Flush pending writes before sharing
    await _logSink?.flush();

    final path = _currentLogFile!.path;

    if (platformAction != null) {
      await platformAction(path);
    } else if (Platform.isAndroid) {
      await Share.shareXFiles([XFile(path)]);
    } else {
      await Clipboard.setData(ClipboardData(text: path));
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Log-Pfad kopiert: $path'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  static Future<int> getCurrentLogSize() async {
    if (_currentLogFile == null || !await _currentLogFile!.exists()) return 0;
    return await _currentLogFile!.length();
  }

  // -- Internal methods --

  static void _printDebug(String level, String message) {
    if (kDebugMode) {
      debugPrint('$level $_tag $message');
    }
  }

  static void _writeToFile(String level, String message) {
    if (!_initialized || _logSink == null) return;
    final timestamp = _formatTimestamp(DateTime.now());
    _logSink!.writeln('$timestamp [$level] $message');
  }

  static Future<void> _rotateOldLogs() async {
    if (_logDirectory == null || !await _logDirectory!.exists()) return;

    try {
      final cutoff = DateTime.now().subtract(const Duration(days: _maxLogAgeDays));
      final entries = _logDirectory!.listSync();

      for (final entry in entries) {
        if (entry is File && entry.path.endsWith('.log')) {
          final stat = await entry.stat();
          if (stat.modified.isBefore(cutoff)) {
            await entry.delete();
          }
        }
      }
    } catch (e) {
      _printDebug('WARNING', 'Log rotation failed: $e');
    }
  }

  static String _formatDate(DateTime dt) {
    return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)}';
  }

  static String _formatTimestamp(DateTime dt) {
    return '${_formatDate(dt)} ${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}';
  }

  static String _pad(int value) => value.toString().padLeft(2, '0');

  @visibleForTesting
  static Future<void> dispose() async {
    await _logSink?.flush();
    await _logSink?.close();
    _logSink = null;
    _currentLogFile = null;
    _logDirectory = null;
    _initialized = false;
    _minLevel = LogLevel.debug;
  }

  @visibleForTesting
  static Future<void> rotateOldLogs() => _rotateOldLogs();

  @visibleForTesting
  static Future<void> initWithDirectory(Directory directory) async {
    _logDirectory = directory;

    if (!await _logDirectory!.exists()) {
      await _logDirectory!.create(recursive: true);
    }

    final today = _formatDate(DateTime.now());
    _currentLogFile = File('${_logDirectory!.path}/musicup_$today.log');
    _logSink = _currentLogFile!.openWrite(mode: FileMode.append);
    _initialized = true;
  }
}
