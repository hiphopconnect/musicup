import 'package:music_up/models/album_model.dart';

/// Abstract repository interface for album operations
abstract class AlbumRepository {
  /// Get all albums
  Future<List<Album>> getAlbums();
  
  /// Get album by ID
  Future<Album?> getAlbumById(String id);
  
  /// Save album
  Future<void> saveAlbum(Album album);
  
  /// Update album
  Future<void> updateAlbum(Album album);
  
  /// Delete album
  Future<void> deleteAlbum(String id);
  
  /// Search albums by query
  Future<List<Album>> searchAlbums(String query);
  
  /// Filter albums by genre
  Future<List<Album>> getAlbumsByGenre(String genre);
  
  /// Get album statistics
  Future<AlbumStats> getAlbumStats();
  
  /// Export albums to various formats
  Future<String> exportAlbums({required ExportFormat format});
  
  /// Import albums from file
  Future<ImportResult> importAlbums(String filePath);
}

/// Album statistics
class AlbumStats {
  final int totalAlbums;
  final int totalTracks;
  final Map<String, int> genreCount;
  final Map<String, int> yearCount;
  final Map<String, int> formatCount;

  const AlbumStats({
    required this.totalAlbums,
    required this.totalTracks,
    required this.genreCount,
    required this.yearCount,
    required this.formatCount,
  });
}

/// Export formats supported
enum ExportFormat {
  json,
  csv,
  xml,
}

/// Import result with success/error information
class ImportResult {
  final bool success;
  final int importedCount;
  final int skippedCount;
  final List<String> errors;

  const ImportResult({
    required this.success,
    required this.importedCount,
    required this.skippedCount,
    required this.errors,
  });
}