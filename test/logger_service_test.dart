import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/services/logger_service.dart';

void main() {
  group('LoggerService Tests', () {
    test('Log info message', () {
      // Should not throw
      expect(
        () => LoggerService.info('Test Category', 'Test message'),
        returnsNormally,
      );
    });

    test('Log success message', () {
      expect(
        () => LoggerService.success('Operation', 'Successfully completed'),
        returnsNormally,
      );
    });

    test('Log warning message', () {
      expect(
        () => LoggerService.warning('Warning Category', 'Warning message'),
        returnsNormally,
      );
    });

    test('Log error without context', () {
      expect(
        () => LoggerService.error('Error Category', Exception('Test error')),
        returnsNormally,
      );
    });

    test('Log error with context', () {
      expect(
        () => LoggerService.error(
          'Error Category',
          Exception('Test error'),
          'Additional context',
        ),
        returnsNormally,
      );
    });

    test('Log data with single item', () {
      expect(
        () => LoggerService.data('Data loaded', 100, 'items'),
        returnsNormally,
      );
    });

    test('Log OAuth success', () {
      expect(
        () => LoggerService.oauth('Token received', true),
        returnsNormally,
      );
    });

    test('Log OAuth failure', () {
      expect(
        () => LoggerService.oauth('Token failed', false),
        returnsNormally,
      );
    });

    test('Log API success', () {
      expect(
        () => LoggerService.api('/albums', 200, 'Success'),
        returnsNormally,
      );
    });

    test('Log API error', () {
      expect(
        () => LoggerService.api('/albums', 404, 'Not found'),
        returnsNormally,
      );
    });

    test('Handle null error gracefully', () {
      expect(
        () => LoggerService.error('Category', null),
        returnsNormally,
      );
    });

    test('Handle empty strings', () {
      expect(
        () => LoggerService.info('', ''),
        returnsNormally,
      );
    });

    test('Handle very long messages', () {
      final longMessage = 'A' * 1000;
      expect(
        () => LoggerService.info('Category', longMessage),
        returnsNormally,
      );
    });

    test('Log with special characters', () {
      expect(
        () => LoggerService.info('Category', 'Message with \n newlines \t tabs'),
        returnsNormally,
      );
    });

    test('Log with unicode characters', () {
      expect(
        () => LoggerService.info('Category', 'Message with 🎵 emoji'),
        returnsNormally,
      );
    });
  });
}