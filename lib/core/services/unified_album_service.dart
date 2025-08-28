import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:xml/xml.dart';
import 'package:music_up/core/error/error_handler.dart';
import 'package:music_up/core/repositories/album_repository.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/validation_service.dart';

/// Unified service that consolidates album-related operations
class UnifiedAlbumService implements AlbumRepository {
  final JsonService _jsonService;
  final ConfigManager _configManager;
  final ValidationService _validationService;

  UnifiedAlbumService({
    required JsonService jsonService,
    required ConfigManager configManager,
    required ValidationService validationService,
  })  : _jsonService = jsonService,
        _configManager = configManager,
        _validationService = validationService;

  @override
  Future<List<Album>> getAlbums() async {
    try {
      return await _jsonService.loadAlbums();
    } catch (error, stackTrace) {
      throw AppErrorHandler.handleStorageError(
        error,
        context: 'UnifiedAlbumService.getAlbums',
      );
    }
  }

  @override
  Future<Album?> getAlbumById(String id) async {
    try {
      final albums = await getAlbums();
      return albums.where((album) => album.id == id).firstOrNull;
    } catch (error) {
      throw AppErrorHandler.handleStorageError(
        error,
        context: 'UnifiedAlbumService.getAlbumById',
      );
    }
  }

  @override
  Future<void> saveAlbum(Album album) async {
    try {
      // Validate album before saving
      final validationResult = _validationService.validateAlbum(album);
      if (!validationResult.isValid) {
        throw AppErrorHandler.handleValidationError(
          'Album validation failed: ${validationResult.errors.join(', ')}',
          context: 'UnifiedAlbumService.saveAlbum',
        );
      }

      await _jsonService.addAlbum(album);
    } catch (error) {
      if (error is AppException) rethrow;
      throw AppErrorHandler.handleStorageError(
        error,
        context: 'UnifiedAlbumService.saveAlbum',
      );
    }
  }

  @override
  Future<void> updateAlbum(Album album) async {
    try {
      // Validate album before updating
      final validationResult = _validationService.validateAlbum(album);
      if (!validationResult.isValid) {
        throw AppErrorHandler.handleValidationError(
          'Album validation failed: ${validationResult.errors.join(', ')}',
          context: 'UnifiedAlbumService.updateAlbum',
        );
      }

      await _jsonService.updateAlbum(album);
    } catch (error) {
      if (error is AppException) rethrow;
      throw AppErrorHandler.handleStorageError(
        error,
        context: 'UnifiedAlbumService.updateAlbum',
      );
    }
  }

  @override
  Future<void> deleteAlbum(String id) async {
    try {
      await _jsonService.deleteAlbum(id);
    } catch (error) {
      throw AppErrorHandler.handleStorageError(
        error,
        context: 'UnifiedAlbumService.deleteAlbum',
      );
    }
  }

  @override
  Future<List<Album>> searchAlbums(String query) async {
    try {
      final albums = await getAlbums();
      if (query.isEmpty) return albums;

      return albums.where((album) {
        final searchText = query.toLowerCase();
        return album.title.toLowerCase().contains(searchText) ||
            album.artist.toLowerCase().contains(searchText) ||
            (album.genre?.toLowerCase().contains(searchText) ?? false) ||
            (album.year?.toString().contains(searchText) ?? false);
      }).toList();
    } catch (error) {
      throw AppErrorHandler.handleStorageError(
        error,
        context: 'UnifiedAlbumService.searchAlbums',
      );
    }
  }

  @override
  Future<List<Album>> getAlbumsByGenre(String genre) async {
    try {
      final albums = await getAlbums();
      return albums.where((album) => 
        album.genre?.toLowerCase() == genre.toLowerCase()
      ).toList();
    } catch (error) {
      throw AppErrorHandler.handleStorageError(
        error,
        context: 'UnifiedAlbumService.getAlbumsByGenre',
      );
    }
  }

  @override
  Future<AlbumStats> getAlbumStats() async {
    try {
      final albums = await getAlbums();
      
      final genreCount = <String, int>{};
      final yearCount = <String, int>{};
      final formatCount = <String, int>{};
      var totalTracks = 0;

      for (final album in albums) {
        // Count genres
        if (album.genre != null) {
          genreCount[album.genre!] = (genreCount[album.genre!] ?? 0) + 1;
        }

        // Count years
        if (album.year != null) {
          final yearStr = album.year.toString();
          yearCount[yearStr] = (yearCount[yearStr] ?? 0) + 1;
        }

        // Count formats
        if (album.format != null) {
          formatCount[album.format!] = (formatCount[album.format!] ?? 0) + 1;
        }

        // Count tracks
        totalTracks += album.tracks?.length ?? 0;
      }

      return AlbumStats(
        totalAlbums: albums.length,
        totalTracks: totalTracks,
        genreCount: genreCount,
        yearCount: yearCount,
        formatCount: formatCount,
      );
    } catch (error) {
      throw AppErrorHandler.handleStorageError(
        error,
        context: 'UnifiedAlbumService.getAlbumStats',
      );
    }
  }

  @override
  Future<String> exportAlbums({required ExportFormat format}) async {
    try {
      final albums = await getAlbums();
      
      switch (format) {
        case ExportFormat.json:
          return _exportToJson(albums);
        case ExportFormat.csv:
          return _exportToCsv(albums);
        case ExportFormat.xml:
          return _exportToXml(albums);
      }
    } catch (error) {
      throw AppErrorHandler.handleStorageError(
        error,
        context: 'UnifiedAlbumService.exportAlbums',
      );
    }
  }

  @override
  Future<ImportResult> importAlbums(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        throw AppErrorHandler.handleValidationError(
          'Import file does not exist: $filePath',
          context: 'UnifiedAlbumService.importAlbums',
        );
      }

      final content = await file.readAsString();
      final extension = filePath.split('.').last.toLowerCase();
      
      List<Album> importedAlbums;
      switch (extension) {
        case 'json':
          importedAlbums = _importFromJson(content);
          break;
        case 'csv':
          importedAlbums = _importFromCsv(content);
          break;
        case 'xml':
          importedAlbums = _importFromXml(content);
          break;
        default:
          throw AppErrorHandler.handleValidationError(
            'Unsupported import format: $extension',
            context: 'UnifiedAlbumService.importAlbums',
          );
      }

      var importedCount = 0;
      var skippedCount = 0;
      final errors = <String>[];

      for (final album in importedAlbums) {
        try {
          await saveAlbum(album);
          importedCount++;
        } catch (error) {
          errors.add('Failed to import album "${album.title}": $error');
          skippedCount++;
        }
      }

      return ImportResult(
        success: errors.isEmpty,
        importedCount: importedCount,
        skippedCount: skippedCount,
        errors: errors,
      );
    } catch (error) {
      if (error is AppException) rethrow;
      throw AppErrorHandler.handleStorageError(
        error,
        context: 'UnifiedAlbumService.importAlbums',
      );
    }
  }

  String _exportToJson(List<Album> albums) {
    final jsonList = albums.map((album) => album.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(jsonList);
  }

  String _exportToCsv(List<Album> albums) {
    final headers = ['ID', 'Title', 'Artist', 'Genre', 'Year', 'Format', 'Tracks'];
    final rows = <List<String>>[headers];
    
    for (final album in albums) {
      rows.add([
        album.id,
        album.title,
        album.artist,
        album.genre ?? '',
        album.year?.toString() ?? '',
        album.format ?? '',
        (album.tracks?.length ?? 0).toString(),
      ]);
    }
    
    return const ListToCsvConverter().convert(rows);
  }

  String _exportToXml(List<Album> albums) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('albums', nest: () {
      for (final album in albums) {
        builder.element('album', nest: () {
          builder.element('id', nest: album.id);
          builder.element('title', nest: album.title);
          builder.element('artist', nest: album.artist);
          if (album.genre != null) builder.element('genre', nest: album.genre);
          if (album.year != null) builder.element('year', nest: album.year);
          if (album.format != null) builder.element('format', nest: album.format);
          if (album.tracks?.isNotEmpty == true) {
            builder.element('tracks', nest: () {
              for (final track in album.tracks!) {
                builder.element('track', nest: track);
              }
            });
          }
        });
      }
    });
    return builder.buildDocument().toXmlString(pretty: true);
  }

  List<Album> _importFromJson(String content) {
    final jsonList = jsonDecode(content) as List;
    return jsonList.map((json) => Album.fromJson(json)).toList();
  }

  List<Album> _importFromCsv(String content) {
    final rows = const CsvToListConverter().convert(content);
    if (rows.isEmpty) return [];
    
    final albums = <Album>[];
    final headers = rows.first.map((e) => e.toString().toLowerCase()).toList();
    
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      final albumData = <String, dynamic>{};
      
      for (int j = 0; j < headers.length && j < row.length; j++) {
        final header = headers[j];
        final value = row[j]?.toString();
        
        switch (header) {
          case 'id':
            albumData['id'] = value;
            break;
          case 'title':
            albumData['title'] = value;
            break;
          case 'artist':
            albumData['artist'] = value;
            break;
          case 'genre':
            if (value?.isNotEmpty == true) albumData['genre'] = value;
            break;
          case 'year':
            if (value?.isNotEmpty == true) {
              albumData['year'] = int.tryParse(value!);
            }
            break;
          case 'format':
            if (value?.isNotEmpty == true) albumData['format'] = value;
            break;
        }
      }
      
      if (albumData['title'] != null && albumData['artist'] != null) {
        albums.add(Album.fromJson(albumData));
      }
    }
    
    return albums;
  }

  List<Album> _importFromXml(String content) {
    final document = XmlDocument.parse(content);
    final albumElements = document.findAllElements('album');
    
    return albumElements.map((element) {
      final albumData = <String, dynamic>{};
      
      final id = element.findElements('id').firstOrNull?.text;
      final title = element.findElements('title').firstOrNull?.text;
      final artist = element.findElements('artist').firstOrNull?.text;
      final genre = element.findElements('genre').firstOrNull?.text;
      final yearText = element.findElements('year').firstOrNull?.text;
      final format = element.findElements('format').firstOrNull?.text;
      
      if (id != null) albumData['id'] = id;
      if (title != null) albumData['title'] = title;
      if (artist != null) albumData['artist'] = artist;
      if (genre != null) albumData['genre'] = genre;
      if (yearText != null) albumData['year'] = int.tryParse(yearText);
      if (format != null) albumData['format'] = format;
      
      final tracksElement = element.findElements('tracks').firstOrNull;
      if (tracksElement != null) {
        final trackElements = tracksElement.findElements('track');
        albumData['tracks'] = trackElements.map((e) => e.text).toList();
      }
      
      return Album.fromJson(albumData);
    }).toList();
  }
}