import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Centralized error handling for the application
class AppErrorHandler {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// Handle errors with different severity levels
  static void handle(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    ErrorLevel level = ErrorLevel.error,
  }) {
    final errorMessage = _formatErrorMessage(error, context);
    
    switch (level) {
      case ErrorLevel.warning:
        _logger.w(errorMessage, error: error, stackTrace: stackTrace);
        break;
      case ErrorLevel.error:
        _logger.e(errorMessage, error: error, stackTrace: stackTrace);
        break;
      case ErrorLevel.fatal:
        _logger.f(errorMessage, error: error, stackTrace: stackTrace);
        _reportToAnalytics(error, stackTrace, context);
        break;
    }

    if (kDebugMode) {
      developer.log(
        errorMessage,
        name: 'MusicUp',
        error: error,
        stackTrace: stackTrace,
        level: level.logLevel,
      );
    }
  }

  /// Handle network-related errors
  static AppException handleNetworkError(Object error, {String? context}) {
    final exception = AppException.network(
      message: 'Network error occurred',
      originalError: error,
      context: context,
    );
    
    handle(exception, StackTrace.current, context: context);
    return exception;
  }

  /// Handle storage-related errors
  static AppException handleStorageError(Object error, {String? context}) {
    final exception = AppException.storage(
      message: 'Storage error occurred',
      originalError: error,
      context: context,
    );
    
    handle(exception, StackTrace.current, context: context);
    return exception;
  }

  /// Handle validation errors
  static AppException handleValidationError(String message, {String? context}) {
    final exception = AppException.validation(
      message: message,
      context: context,
    );
    
    handle(exception, StackTrace.current, context: context, level: ErrorLevel.warning);
    return exception;
  }

  static String _formatErrorMessage(Object error, String? context) {
    final buffer = StringBuffer();
    
    if (context != null) {
      buffer.write('[$context] ');
    }
    
    if (error is AppException) {
      buffer.write('${error.type.name.toUpperCase()}: ${error.message}');
      if (error.originalError != null) {
        buffer.write(' (Original: ${error.originalError})');
      }
    } else {
      buffer.write(error.toString());
    }
    
    return buffer.toString();
  }

  static void _reportToAnalytics(Object error, StackTrace? stackTrace, String? context) {
    // TODO: Implement analytics reporting (Firebase Crashlytics, Sentry, etc.)
    // This would be implemented based on your analytics provider
  }
}

/// Error severity levels
enum ErrorLevel {
  warning(800),
  error(1000),
  fatal(1200);

  const ErrorLevel(this.logLevel);
  final int logLevel;
}

/// Custom application exception
class AppException implements Exception {
  final AppExceptionType type;
  final String message;
  final Object? originalError;
  final String? context;

  const AppException({
    required this.type,
    required this.message,
    this.originalError,
    this.context,
  });

  AppException.network({
    required String message,
    Object? originalError,
    String? context,
  }) : this(
          type: AppExceptionType.network,
          message: message,
          originalError: originalError,
          context: context,
        );

  AppException.storage({
    required String message,
    Object? originalError,
    String? context,
  }) : this(
          type: AppExceptionType.storage,
          message: message,
          originalError: originalError,
          context: context,
        );

  AppException.validation({
    required String message,
    String? context,
  }) : this(
          type: AppExceptionType.validation,
          message: message,
          context: context,
        );

  AppException.unknown({
    required String message,
    Object? originalError,
    String? context,
  }) : this(
          type: AppExceptionType.unknown,
          message: message,
          originalError: originalError,
          context: context,
        );

  @override
  String toString() {
    return 'AppException(type: $type, message: $message, context: $context)';
  }
}

enum AppExceptionType {
  network,
  storage,
  validation,
  unknown,
}