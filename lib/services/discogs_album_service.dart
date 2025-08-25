// lib/services/discogs_album_service.dart

import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/discogs_service_unified.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/services/logger_service.dart';
import 'package:uuid/uuid.dart';

class DiscogsAlbumService {
  final DiscogsServiceUnified _discogsService;
  final JsonService _jsonService;

  DiscogsAlbumService(this._discogsService, this._jsonService);

  Future<Album> convertToAlbumWithTracks(DiscogsSearchResult result) async {
    List<Track> tracks = [];

    try {
      if (_discogsService.hasAuth) {
        tracks = await _discogsService.getReleaseTracklist(result.id);
      }
    } catch (e) {
      LoggerService.warning('Track loading failed', 'Using basic track info: $e');
    }

    // Fallback: Create single track if no tracks loaded
    if (tracks.isEmpty) {
      tracks = [Track(trackNumber: '01', title: result.title)];
    }

    return Album(
      id: const Uuid().v4(),
      name: result.title,
      artist: result.artist,
      genre: result.genre.isEmpty ? 'Unknown' : result.genre,
      year: result.year.isEmpty ? 'Unknown' : result.year,
      medium: _mapFormat(result.format),
      digital: false,
      tracks: tracks,
    );
  }

  Future<bool> addToCollection(DiscogsSearchResult result) async {
    try {
      final album = await convertToAlbumWithTracks(result);
      
      // Load existing collection
      List<Album> existingAlbums = await _jsonService.loadAlbums();
      
      // Check for duplicates
      bool alreadyExists = existingAlbums.any((existing) =>
          existing.name.toLowerCase() == album.name.toLowerCase() &&
          existing.artist.toLowerCase() == album.artist.toLowerCase());
      
      if (alreadyExists) {
        throw Exception('Album bereits in Sammlung vorhanden');
      }
      
      // Add to collection
      existingAlbums.add(album);
      await _jsonService.saveAlbums(existingAlbums);
      
      LoggerService.info('Collection add', '${album.name} by ${album.artist}');
      return true;
    } catch (e) {
      LoggerService.error('Collection add failed', e, '${result.title} by ${result.artist}');
      rethrow;
    }
  }

  Future<bool> addToWantlist(DiscogsSearchResult result) async {
    try {
      if (!_discogsService.hasAuth) {
        // Fallback to local wantlist
        return await _addToLocalWantlist(result);
      }

      // Try to add to Discogs wantlist first
      await _discogsService.addToWantlist(result.id);
      
      // Then sync to local wantlist
      await _addToLocalWantlist(result);
      
      LoggerService.info('Wantlist add', '${result.title} by ${result.artist} (Discogs + Local)');
      return true;
    } catch (e) {
      LoggerService.warning('Discogs wantlist add failed', 'Falling back to local: $e');
      
      // Fallback to local wantlist only
      try {
        await _addToLocalWantlist(result);
        LoggerService.info('Wantlist add', '${result.title} by ${result.artist} (Local only)');
        return true;
      } catch (localError) {
        LoggerService.error('Local wantlist add failed', localError);
        rethrow;
      }
    }
  }

  Future<bool> _addToLocalWantlist(DiscogsSearchResult result) async {
    try {
      final album = Album(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: result.title,
        artist: result.artist,
        genre: result.genre.isEmpty ? 'Unknown' : result.genre,
        year: result.year.isEmpty ? 'Unknown' : result.year,
        medium: _mapFormat(result.format),
        digital: false,
        tracks: [],
      );

      List<Album> currentWantlist = await _jsonService.loadWantlist();
      
      // Check for duplicates
      bool alreadyExists = currentWantlist.any((existing) =>
          existing.name.toLowerCase() == album.name.toLowerCase() &&
          existing.artist.toLowerCase() == album.artist.toLowerCase());
      
      if (alreadyExists) {
        throw Exception('Album bereits in Wantlist vorhanden');
      }

      currentWantlist.add(album);
      await _jsonService.saveWantlist(currentWantlist);
      
      return true;
    } catch (e) {
      LoggerService.error('Local wantlist add failed', e);
      rethrow;
    }
  }

  String _mapFormat(String format) {
    final normalizedFormat = format.toLowerCase();
    if (normalizedFormat.contains('vinyl') || normalizedFormat.contains('lp')) {
      return 'Vinyl';
    } else if (normalizedFormat.contains('cd')) {
      return 'CD';
    } else if (normalizedFormat.contains('cassette') || normalizedFormat.contains('tape')) {
      return 'Cassette';
    } else if (normalizedFormat.contains('digital')) {
      return 'Digital';
    } else {
      return format.isEmpty ? 'Unknown' : format;
    }
  }
}