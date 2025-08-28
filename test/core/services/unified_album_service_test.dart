import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:music_up/core/services/unified_album_service.dart';
import 'package:music_up/core/repositories/album_repository.dart';
import 'package:music_up/core/error/error_handler.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/validation_service.dart';

// Generate mocks
@GenerateMocks([JsonService, ConfigManager, ValidationService])
import 'unified_album_service_test.mocks.dart';

void main() {
  group('UnifiedAlbumService', () {
    late UnifiedAlbumService service;
    late MockJsonService mockJsonService;
    late MockConfigManager mockConfigManager;
    late MockValidationService mockValidationService;
    
    setUp(() {
      mockJsonService = MockJsonService();
      mockConfigManager = MockConfigManager();
      mockValidationService = MockValidationService();
      
      service = UnifiedAlbumService(
        jsonService: mockJsonService,
        configManager: mockConfigManager,
        validationService: mockValidationService,
      );
    });

    group('getAlbums', () {
      test('should return albums from json service', () async {
        // Arrange
        final expectedAlbums = [
          Album(
            id: '1',
            title: 'Test Album',
            artist: 'Test Artist',
            genre: 'Rock',
            year: 2023,
          ),
        ];
        when(mockJsonService.loadAlbums()).thenAnswer((_) async => expectedAlbums);

        // Act
        final result = await service.getAlbums();

        // Assert
        expect(result, equals(expectedAlbums));
        verify(mockJsonService.loadAlbums()).called(1);
      });

      test('should handle storage errors', () async {
        // Arrange
        when(mockJsonService.loadAlbums()).thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => service.getAlbums(),
          throwsA(isA<AppException>().having(
            (e) => e.type,
            'type',
            AppExceptionType.storage,
          )),
        );
      });
    });

    group('saveAlbum', () {
      test('should save valid album', () async {
        // Arrange
        final album = Album(
          id: '1',
          title: 'Test Album',
          artist: 'Test Artist',
        );
        final validationResult = ValidationResult(isValid: true, errors: []);
        
        when(mockValidationService.validateAlbum(album))
            .thenReturn(validationResult);
        when(mockJsonService.addAlbum(album)).thenAnswer((_) async {});

        // Act
        await service.saveAlbum(album);

        // Assert
        verify(mockValidationService.validateAlbum(album)).called(1);
        verify(mockJsonService.addAlbum(album)).called(1);
      });

      test('should throw validation error for invalid album', () async {
        // Arrange
        final album = Album(id: '1', title: '', artist: '');
        final validationResult = ValidationResult(
          isValid: false,
          errors: ['Title is required', 'Artist is required'],
        );
        
        when(mockValidationService.validateAlbum(album))
            .thenReturn(validationResult);

        // Act & Assert
        expect(
          () => service.saveAlbum(album),
          throwsA(isA<AppException>().having(
            (e) => e.type,
            'type',
            AppExceptionType.validation,
          )),
        );
        
        verifyNever(mockJsonService.addAlbum(album));
      });
    });

    group('searchAlbums', () {
      test('should return filtered albums by title', () async {
        // Arrange
        final albums = [
          Album(id: '1', title: 'Dark Side of the Moon', artist: 'Pink Floyd'),
          Album(id: '2', title: 'The Wall', artist: 'Pink Floyd'),
          Album(id: '3', title: 'Abbey Road', artist: 'The Beatles'),
        ];
        when(mockJsonService.loadAlbums()).thenAnswer((_) async => albums);

        // Act
        final result = await service.searchAlbums('Dark');

        // Assert
        expect(result.length, equals(1));
        expect(result.first.title, equals('Dark Side of the Moon'));
      });

      test('should return all albums for empty query', () async {
        // Arrange
        final albums = [
          Album(id: '1', title: 'Album 1', artist: 'Artist 1'),
          Album(id: '2', title: 'Album 2', artist: 'Artist 2'),
        ];
        when(mockJsonService.loadAlbums()).thenAnswer((_) async => albums);

        // Act
        final result = await service.searchAlbums('');

        // Assert
        expect(result, equals(albums));
      });

      test('should search by artist name', () async {
        // Arrange
        final albums = [
          Album(id: '1', title: 'Album 1', artist: 'Pink Floyd'),
          Album(id: '2', title: 'Album 2', artist: 'The Beatles'),
        ];
        when(mockJsonService.loadAlbums()).thenAnswer((_) async => albums);

        // Act
        final result = await service.searchAlbums('Beatles');

        // Assert
        expect(result.length, equals(1));
        expect(result.first.artist, equals('The Beatles'));
      });
    });

    group('getAlbumStats', () {
      test('should return correct statistics', () async {
        // Arrange
        final albums = [
          Album(
            id: '1',
            title: 'Album 1',
            artist: 'Artist 1',
            genre: 'Rock',
            year: 2020,
            format: 'CD',
            tracks: ['Track 1', 'Track 2'],
          ),
          Album(
            id: '2',
            title: 'Album 2',
            artist: 'Artist 2',
            genre: 'Rock',
            year: 2021,
            format: 'Vinyl',
            tracks: ['Track 1', 'Track 2', 'Track 3'],
          ),
          Album(
            id: '3',
            title: 'Album 3',
            artist: 'Artist 3',
            genre: 'Jazz',
            year: 2020,
            format: 'CD',
            tracks: ['Track 1'],
          ),
        ];
        when(mockJsonService.loadAlbums()).thenAnswer((_) async => albums);

        // Act
        final stats = await service.getAlbumStats();

        // Assert
        expect(stats.totalAlbums, equals(3));
        expect(stats.totalTracks, equals(6));
        expect(stats.genreCount['Rock'], equals(2));
        expect(stats.genreCount['Jazz'], equals(1));
        expect(stats.yearCount['2020'], equals(2));
        expect(stats.yearCount['2021'], equals(1));
        expect(stats.formatCount['CD'], equals(2));
        expect(stats.formatCount['Vinyl'], equals(1));
      });

      test('should handle albums with null properties', () async {
        // Arrange
        final albums = [
          Album(id: '1', title: 'Album 1', artist: 'Artist 1'),
          Album(
            id: '2',
            title: 'Album 2',
            artist: 'Artist 2',
            genre: 'Rock',
          ),
        ];
        when(mockJsonService.loadAlbums()).thenAnswer((_) async => albums);

        // Act
        final stats = await service.getAlbumStats();

        // Assert
        expect(stats.totalAlbums, equals(2));
        expect(stats.totalTracks, equals(0));
        expect(stats.genreCount['Rock'], equals(1));
        expect(stats.genreCount.containsKey(null), isFalse);
      });
    });

    group('exportAlbums', () {
      test('should export to JSON format', () async {
        // Arrange
        final albums = [
          Album(
            id: '1',
            title: 'Test Album',
            artist: 'Test Artist',
            genre: 'Rock',
            year: 2023,
          ),
        ];
        when(mockJsonService.loadAlbums()).thenAnswer((_) async => albums);

        // Act
        final result = await service.exportAlbums(format: ExportFormat.json);

        // Assert
        expect(result, isA<String>());
        expect(result, contains('"title": "Test Album"'));
        expect(result, contains('"artist": "Test Artist"'));
      });

      test('should export to CSV format', () async {
        // Arrange
        final albums = [
          Album(
            id: '1',
            title: 'Test Album',
            artist: 'Test Artist',
            genre: 'Rock',
            year: 2023,
          ),
        ];
        when(mockJsonService.loadAlbums()).thenAnswer((_) async => albums);

        // Act
        final result = await service.exportAlbums(format: ExportFormat.csv);

        // Assert
        expect(result, isA<String>());
        expect(result, contains('ID,Title,Artist'));
        expect(result, contains('1,Test Album,Test Artist'));
      });

      test('should export to XML format', () async {
        // Arrange
        final albums = [
          Album(
            id: '1',
            title: 'Test Album',
            artist: 'Test Artist',
            genre: 'Rock',
            year: 2023,
          ),
        ];
        when(mockJsonService.loadAlbums()).thenAnswer((_) async => albums);

        // Act
        final result = await service.exportAlbums(format: ExportFormat.xml);

        // Assert
        expect(result, isA<String>());
        expect(result, contains('<albums>'));
        expect(result, contains('<title>Test Album</title>'));
        expect(result, contains('<artist>Test Artist</artist>'));
      });
    });
  });
}

// Mock ValidationResult class for testing
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({required this.isValid, required this.errors});
}