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
        expect(result, isNotNull);
        expect(result, contains('erforderlich'));
      });

      test('Null album name fails', () {
        String? result = ValidationService.validateAlbumName(null);
        expect(result, isNotNull);
        expect(result, contains('erforderlich'));
      });

      test('Album name with only spaces fails', () {
        String? result = ValidationService.validateAlbumName('   ');
        expect(result, isNotNull);
        expect(result, contains('erforderlich'));
      });

      test('Very long album name fails', () {
        String longName = 'A' * 201; // 201 characters
        String? result = ValidationService.validateAlbumName(longName);
        expect(result, isNotNull);
        expect(result, contains('200 Zeichen'));
      });
    });

    group('Artist Name Validation', () {
      test('Valid artist name passes', () {
        String? result = ValidationService.validateArtistName('Valid Artist');
        expect(result, isNull);
      });

      test('Empty artist name fails', () {
        String? result = ValidationService.validateArtistName('');
        expect(result, isNotNull);
        expect(result, contains('erforderlich'));
      });

      test('Artist name with only spaces fails', () {
        String? result = ValidationService.validateArtistName('   ');
        expect(result, isNotNull);
        expect(result, contains('erforderlich'));
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

      test('Long genre fails', () {
        String longGenre = 'A' * 51; // 51 characters
        String? result = ValidationService.validateGenre(longGenre);
        expect(result, isNotNull);
        expect(result, contains('50 Zeichen'));
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

      test('Invalid year format fails', () {
        String? result = ValidationService.validateYear('abc');
        expect(result, isNotNull);
        expect(result, contains('gültige Jahreszahl'));
      });

      test('Year too early fails', () {
        String? result = ValidationService.validateYear('1899');
        expect(result, isNotNull);
        expect(result, contains('1900'));
      });

      test('Year too late fails', () {
        int nextYear = DateTime.now().year + 2;
        String? result = ValidationService.validateYear(nextYear.toString());
        expect(result, isNotNull);
        expect(result, contains('Zukunft'));
      });
    });

    group('Medium Validation', () {
      test('Valid medium passes', () {
        String? result = ValidationService.validateMedium('CD');
        expect(result, isNull);
      });

      test('Empty medium passes (optional field)', () {
        String? result = ValidationService.validateMedium('');
        expect(result, isNull);
      });

      test('Invalid medium fails', () {
        String? result = ValidationService.validateMedium('InvalidMedium');
        expect(result, isNotNull);
        expect(result, contains('gültiges Medium'));
      });
    });

    group('Default Value Helpers', () {
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
  });
}