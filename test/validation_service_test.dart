import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/services/validation_service.dart';

void main() {
  group('ValidationService Tests', () {

    group('Album Name Validation', () {
      test('Valid album name passes', () {
        String? result = ValidationService.validateAlbumName('Valid Album Name');
        expect(result, isNull);
      });

      test('Empty album name fails', () {
        String? result = ValidationService.validateAlbumName('');
        expect(result, equals('albumNameRequired'));
      });

      test('Null album name fails', () {
        String? result = ValidationService.validateAlbumName(null);
        expect(result, equals('albumNameRequired'));
      });

      test('Album name with only spaces fails', () {
        String? result = ValidationService.validateAlbumName('   ');
        expect(result, equals('albumNameRequired'));
      });

      test('Very long album name fails', () {
        String longName = 'A' * 201;
        String? result = ValidationService.validateAlbumName(longName);
        expect(result, equals('albumNameTooLong'));
      });

      test('Album name at exactly 200 characters passes', () {
        String exactName = 'A' * 200;
        String? result = ValidationService.validateAlbumName(exactName);
        expect(result, isNull);
      });
    });

    group('Artist Name Validation', () {
      test('Valid artist name passes', () {
        String? result = ValidationService.validateArtistName('Valid Artist');
        expect(result, isNull);
      });

      test('Empty artist name fails', () {
        String? result = ValidationService.validateArtistName('');
        expect(result, equals('artistRequired'));
      });

      test('Null artist name fails', () {
        String? result = ValidationService.validateArtistName(null);
        expect(result, equals('artistRequired'));
      });

      test('Artist name with only spaces fails', () {
        String? result = ValidationService.validateArtistName('   ');
        expect(result, equals('artistRequired'));
      });

      test('Very long artist name fails', () {
        String longName = 'A' * 201;
        String? result = ValidationService.validateArtistName(longName);
        expect(result, equals('artistTooLong'));
      });

      test('Artist name at exactly 200 characters passes', () {
        String exactName = 'A' * 200;
        String? result = ValidationService.validateArtistName(exactName);
        expect(result, isNull);
      });
    });

    group('Genre Validation', () {
      test('Valid genre passes', () {
        String? result = ValidationService.validateGenre('Rock');
        expect(result, isNull);
      });

      test('Empty genre passes (optional field)', () {
        String? result = ValidationService.validateGenre('');
        expect(result, isNull);
      });

      test('Null genre passes (optional field)', () {
        String? result = ValidationService.validateGenre(null);
        expect(result, isNull);
      });

      test('Long genre fails', () {
        String longGenre = 'A' * 101;
        String? result = ValidationService.validateGenre(longGenre);
        expect(result, equals('genreTooLong'));
      });

      test('Genre at exactly 100 characters passes', () {
        String exactGenre = 'A' * 100;
        String? result = ValidationService.validateGenre(exactGenre);
        expect(result, isNull);
      });
    });

    group('Year Validation', () {
      test('Valid year passes', () {
        String? result = ValidationService.validateYear('2023');
        expect(result, isNull);
      });

      test('Empty year passes (optional field)', () {
        String? result = ValidationService.validateYear('');
        expect(result, isNull);
      });

      test('Null year passes (optional field)', () {
        String? result = ValidationService.validateYear(null);
        expect(result, isNull);
      });

      test('Special value "unknown" passes', () {
        expect(ValidationService.validateYear('unknown'), isNull);
      });

      test('Special value "unbekannt" passes', () {
        expect(ValidationService.validateYear('unbekannt'), isNull);
      });

      test('Special value "?" passes', () {
        expect(ValidationService.validateYear('?'), isNull);
      });

      test('Special value "-" passes', () {
        expect(ValidationService.validateYear('-'), isNull);
      });

      test('Special value "nan" passes', () {
        expect(ValidationService.validateYear('nan'), isNull);
      });

      test('Special value "N/A" passes', () {
        expect(ValidationService.validateYear('N/A'), isNull);
      });

      test('Invalid year format fails', () {
        String? result = ValidationService.validateYear('abc');
        expect(result, equals('yearFormat'));
      });

      test('Year too early fails', () {
        String? result = ValidationService.validateYear('1799');
        expect(result, equals('yearTooOld'));
      });

      test('Year at boundary 1800 passes', () {
        String? result = ValidationService.validateYear('1800');
        expect(result, isNull);
      });

      test('Year too late fails', () {
        int futureYear = DateTime.now().year + 6;
        String? result = ValidationService.validateYear(futureYear.toString());
        expect(result, equals('yearTooFuture'));
      });

      test('Year at upper boundary passes', () {
        int boundaryYear = DateTime.now().year + 5;
        String? result = ValidationService.validateYear(boundaryYear.toString());
        expect(result, isNull);
      });

      test('Year with whitespace is trimmed and validated', () {
        String? result = ValidationService.validateYear('  2023  ');
        expect(result, isNull);
      });
    });

    group('Medium Validation', () {
      test('Valid medium CD passes', () {
        String? result = ValidationService.validateMedium('CD');
        expect(result, isNull);
      });

      test('Valid medium Vinyl passes', () {
        String? result = ValidationService.validateMedium('Vinyl');
        expect(result, isNull);
      });

      test('Valid medium Cassette passes', () {
        String? result = ValidationService.validateMedium('Cassette');
        expect(result, isNull);
      });

      test('Valid medium Digital passes', () {
        String? result = ValidationService.validateMedium('Digital');
        expect(result, isNull);
      });

      test('Empty medium passes (optional field)', () {
        String? result = ValidationService.validateMedium('');
        expect(result, isNull);
      });

      test('Null medium passes (optional field)', () {
        String? result = ValidationService.validateMedium(null);
        expect(result, isNull);
      });

      test('Invalid medium fails', () {
        String? result = ValidationService.validateMedium('InvalidMedium');
        expect(result, equals('invalidMedium'));
      });

      test('Medium validation is case-sensitive', () {
        String? result = ValidationService.validateMedium('cd');
        expect(result, equals('invalidMedium'));
      });
    });

    group('Track Name Validation', () {
      test('Valid track name passes', () {
        String? result = ValidationService.validateTrackName('Bohemian Rhapsody');
        expect(result, isNull);
      });

      test('Empty track name fails', () {
        String? result = ValidationService.validateTrackName('');
        expect(result, equals('trackNameRequired'));
      });

      test('Null track name fails', () {
        String? result = ValidationService.validateTrackName(null);
        expect(result, equals('trackNameRequired'));
      });

      test('Track name with only spaces fails', () {
        String? result = ValidationService.validateTrackName('   ');
        expect(result, equals('trackNameRequired'));
      });

      test('Very long track name fails', () {
        String longName = 'A' * 151;
        String? result = ValidationService.validateTrackName(longName);
        expect(result, equals('trackNameTooLong'));
      });

      test('Track name at exactly 150 characters passes', () {
        String exactName = 'A' * 150;
        String? result = ValidationService.validateTrackName(exactName);
        expect(result, isNull);
      });

      test('Track name with leading/trailing spaces is trimmed for validation', () {
        String? result = ValidationService.validateTrackName('  Valid Track  ');
        expect(result, isNull);
      });
    });

    group('Track Duration Validation', () {
      test('Valid duration 3:45 passes', () {
        String? result = ValidationService.validateTrackDuration('3:45');
        expect(result, isNull);
      });

      test('Valid duration 12:00 passes', () {
        String? result = ValidationService.validateTrackDuration('12:00');
        expect(result, isNull);
      });

      test('Valid duration 0:00 passes', () {
        String? result = ValidationService.validateTrackDuration('0:00');
        expect(result, isNull);
      });

      test('Valid duration 99:59 passes', () {
        String? result = ValidationService.validateTrackDuration('99:59');
        expect(result, isNull);
      });

      test('Empty duration passes (optional field)', () {
        String? result = ValidationService.validateTrackDuration('');
        expect(result, isNull);
      });

      test('Null duration passes (optional field)', () {
        String? result = ValidationService.validateTrackDuration(null);
        expect(result, isNull);
      });

      test('Invalid format without colon fails', () {
        String? result = ValidationService.validateTrackDuration('345');
        expect(result, equals('timeFormat'));
      });

      test('Invalid format with letters fails', () {
        String? result = ValidationService.validateTrackDuration('ab:cd');
        expect(result, equals('timeFormat'));
      });

      test('Seconds above 59 fails', () {
        String? result = ValidationService.validateTrackDuration('3:60');
        expect(result, equals('secondsRange'));
      });

      test('Three-digit minutes fails format check', () {
        String? result = ValidationService.validateTrackDuration('100:00');
        expect(result, isNotNull);
      });

      test('Duration with whitespace is trimmed', () {
        String? result = ValidationService.validateTrackDuration('  3:45  ');
        expect(result, isNull);
      });

      test('Single digit seconds fails format (needs two digits)', () {
        String? result = ValidationService.validateTrackDuration('3:5');
        expect(result, equals('timeFormat'));
      });
    });

    group('isAlbumFormValid', () {
      test('Valid form returns true', () {
        bool result = ValidationService.isAlbumFormValid(
          albumName: 'Test Album',
          artistName: 'Test Artist',
          genre: 'Rock',
          year: '2023',
          selectedMedium: 'CD',
        );
        expect(result, isTrue);
      });

      test('Empty album name makes form invalid', () {
        bool result = ValidationService.isAlbumFormValid(
          albumName: '',
          artistName: 'Test Artist',
          genre: 'Rock',
          year: '2023',
          selectedMedium: 'CD',
        );
        expect(result, isFalse);
      });

      test('Empty artist name makes form invalid', () {
        bool result = ValidationService.isAlbumFormValid(
          albumName: 'Test Album',
          artistName: '',
          genre: 'Rock',
          year: '2023',
          selectedMedium: 'CD',
        );
        expect(result, isFalse);
      });

      test('Invalid year makes form invalid', () {
        bool result = ValidationService.isAlbumFormValid(
          albumName: 'Test Album',
          artistName: 'Test Artist',
          genre: 'Rock',
          year: 'abc',
          selectedMedium: 'CD',
        );
        expect(result, isFalse);
      });

      test('Invalid medium makes form invalid', () {
        bool result = ValidationService.isAlbumFormValid(
          albumName: 'Test Album',
          artistName: 'Test Artist',
          genre: 'Rock',
          year: '2023',
          selectedMedium: 'InvalidMedium',
        );
        expect(result, isFalse);
      });

      test('Optional fields empty is still valid', () {
        bool result = ValidationService.isAlbumFormValid(
          albumName: 'Test Album',
          artistName: 'Test Artist',
          genre: '',
          year: '',
          selectedMedium: null,
        );
        expect(result, isTrue);
      });
    });

    group('countValidationErrors', () {
      test('Valid form has zero errors', () {
        int count = ValidationService.countValidationErrors(
          albumName: 'Test Album',
          artistName: 'Test Artist',
          genre: 'Rock',
          year: '2023',
          selectedMedium: 'CD',
        );
        expect(count, 0);
      });

      test('All fields invalid returns correct error count', () {
        int count = ValidationService.countValidationErrors(
          albumName: '',
          artistName: '',
          genre: 'A' * 101,
          year: 'abc',
          selectedMedium: 'InvalidMedium',
        );
        expect(count, 5);
      });

      test('Only required fields missing counts two errors', () {
        int count = ValidationService.countValidationErrors(
          albumName: '',
          artistName: '',
          genre: '',
          year: '',
          selectedMedium: null,
        );
        expect(count, 2);
      });

      test('Single error is counted correctly', () {
        int count = ValidationService.countValidationErrors(
          albumName: '',
          artistName: 'Test Artist',
          genre: 'Rock',
          year: '2023',
          selectedMedium: 'CD',
        );
        expect(count, 1);
      });
    });

    group('Default Value Helpers', () {
      test('Get album name or default with value', () {
        expect(ValidationService.getAlbumNameOrDefault('My Album'), 'My Album');
      });

      test('Get album name or default with empty string', () {
        expect(ValidationService.getAlbumNameOrDefault(''), 'Unknown Title');
      });

      test('Get album name or default with null', () {
        expect(ValidationService.getAlbumNameOrDefault(null), 'Unknown Title');
      });

      test('Get album name or default trims whitespace', () {
        expect(ValidationService.getAlbumNameOrDefault('  My Album  '), 'My Album');
      });

      test('Get artist name or default with value', () {
        expect(ValidationService.getArtistNameOrDefault('Some Artist'), 'Some Artist');
      });

      test('Get artist name or default with empty string', () {
        expect(ValidationService.getArtistNameOrDefault(''), 'Unknown Artist');
      });

      test('Get artist name or default with null', () {
        expect(ValidationService.getArtistNameOrDefault(null), 'Unknown Artist');
      });

      test('Get genre or default', () {
        expect(ValidationService.getGenreOrDefault('Rock'), 'Rock');
        expect(ValidationService.getGenreOrDefault(''), 'Unknown Genre');
        expect(ValidationService.getGenreOrDefault(null), 'Unknown Genre');
      });

      test('Get year or default', () {
        expect(ValidationService.getYearOrDefault('2023'), '2023');
        expect(ValidationService.getYearOrDefault(''), 'Unknown');
        expect(ValidationService.getYearOrDefault(null), 'Unknown');
        expect(ValidationService.getYearOrDefault('nan'), 'Unknown');
        expect(ValidationService.getYearOrDefault('N/A'), 'Unknown');
      });

      test('Get year or default with special values', () {
        expect(ValidationService.getYearOrDefault('?'), 'Unknown');
        expect(ValidationService.getYearOrDefault('-'), 'Unknown');
      });

      test('Get medium or default', () {
        expect(ValidationService.getMediumOrDefault('CD'), 'CD');
        expect(ValidationService.getMediumOrDefault(''), 'Unknown');
        expect(ValidationService.getMediumOrDefault(null), 'Unknown');
      });

      test('Get digital or default', () {
        expect(ValidationService.getDigitalOrDefault(true), true);
        expect(ValidationService.getDigitalOrDefault(false), false);
        expect(ValidationService.getDigitalOrDefault(null), false);
      });
    });

    group('sanitizeInput', () {
      test('Trims leading and trailing whitespace', () {
        expect(ValidationService.sanitizeInput('  hello  '), 'hello');
      });

      test('Collapses multiple internal spaces to single space', () {
        expect(ValidationService.sanitizeInput('hello   world'), 'hello world');
      });

      test('Handles tabs and newlines as whitespace', () {
        expect(ValidationService.sanitizeInput('hello\t\nworld'), 'hello world');
      });

      test('Empty string returns empty string', () {
        expect(ValidationService.sanitizeInput(''), '');
      });

      test('Already clean input is unchanged', () {
        expect(ValidationService.sanitizeInput('hello world'), 'hello world');
      });
    });
  });
}
