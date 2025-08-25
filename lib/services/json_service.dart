// lib/services/json_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/logger_service.dart';
import 'package:path_provider/path_provider.dart';

class JsonService {
  final ConfigManager configManager;

  JsonService(this.configManager);

  // KORREKTUR: Verwende ConfigManager statt hardcodierte Pfade!
  Future<String> _getAlbumsFilePath() async {
    String? configPath = configManager.getJsonFilePath();

    if (configPath != null && configPath.isNotEmpty) {
      return configPath; // Verwende konfigurierten Pfad
    }

    // Fallback: Standard-Pfad wenn nicht konfiguriert
    if (Platform.isAndroid || Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/albums.json'; // KORRIGIERT: albums.json statt music_up_albums.json
    } else {
      return 'albums.json'; // Desktop Fallback
    }
  }

  // KORREKTUR: Verwende ConfigManager für Wantlist!
  Future<String> _getWantlistFilePath() async {
    return await configManager.getWantlistFilePathOrDefault();
  }

  // Load albums from JSON file
  Future<List<Album>> loadAlbums() async {
    try {
      final filePath = await _getAlbumsFilePath();

      final file = File(filePath);

      if (await file.exists()) {
        final contents = await file.readAsString();

        if (contents.trim().isEmpty) {
          LoggerService.warning('Albums load', 'File is empty');
          return [];
        }

        final List<dynamic> jsonList = json.decode(contents);
        LoggerService.data('Albums loaded', jsonList.length, 'items');

        return jsonList.map((albumMap) {
          final Map<String, dynamic> albumJson =
              Map<String, dynamic>.from(albumMap);

          // Parse tracks
          List<Track> tracks = [];
          if (albumJson['tracks'] != null) {
            final List<dynamic> tracksList = albumJson['tracks'];
            tracks = tracksList.map((trackMap) {
              final Map<String, dynamic> trackJson =
                  Map<String, dynamic>.from(trackMap);
              return Track(
                trackNumber: trackJson['trackNumber']?.toString() ?? '1',
                title: trackJson['title']?.toString() ?? 'Unknown Track',
              );
            }).toList();
          }

          return Album(
            id: albumJson['id']?.toString() ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            name: albumJson['name']?.toString() ?? '',
            artist: albumJson['artist']?.toString() ?? '',
            genre: albumJson['genre']?.toString() ?? '',
            year: albumJson['year']?.toString() ?? '',
            medium: albumJson['medium']?.toString() ?? 'Vinyl',
            digital: albumJson['digital'] == true,
            tracks: tracks,
          );
        }).toList();
      } else {
        LoggerService.info('Albums load', 'File does not exist, creating empty file');

        // Erstelle leere Datei automatisch (schön formatiert)
        await file.create(recursive: true);
        await file.writeAsString('[\n]\n');

        return [];
      }
    } catch (e) {
      LoggerService.error('Albums load', e);
      return [];
    }
  }

  // Save albums to JSON file
  Future<void> saveAlbums(List<Album> albums) async {
    try {
      final filePath = await _getAlbumsFilePath();

      final file = File(filePath);

      // Erstelle Directory falls nötig
      await file.parent.create(recursive: true);

      final List<Map<String, dynamic>> jsonList = albums.map((album) {
        return {
          'id': album.id,
          'name': album.name,
          'artist': album.artist,
          'genre': album.genre,
          'year': album.year,
          'medium': album.medium,
          'digital': album.digital,
          'tracks': album.tracks
              .map((track) => {
                    'trackNumber': track.trackNumber,
                    'title': track.title,
                  })
              .toList(),
        };
      }).toList();

      // Schön formatiert speichern
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString('${encoder.convert(jsonList)}\n');
      LoggerService.data('Albums saved', albums.length, 'items');
    } catch (e) {
      LoggerService.error('Albums save', e);
      throw Exception('Failed to save albums: $e');
    }
  }

  // Load wantlist from JSON file
  Future<List<Album>> loadWantlist() async {
    try {
      final filePath = await _getWantlistFilePath();

      final file = File(filePath);

      if (await file.exists()) {
        final contents = await file.readAsString();

        if (contents.trim().isEmpty) {
          LoggerService.warning('Wantlist load', 'File is empty');
          return [];
        }

        final List<dynamic> jsonList = json.decode(contents);
        LoggerService.data('Wantlist loaded', jsonList.length, 'items');

        return jsonList.map((albumMap) {
          final Map<String, dynamic> albumJson =
              Map<String, dynamic>.from(albumMap);

          // Parse tracks (same as albums)
          List<Track> tracks = [];
          if (albumJson['tracks'] != null) {
            final List<dynamic> tracksList = albumJson['tracks'];
            tracks = tracksList.map((trackMap) {
              final Map<String, dynamic> trackJson =
                  Map<String, dynamic>.from(trackMap);
              return Track(
                trackNumber: trackJson['trackNumber']?.toString() ?? '1',
                title: trackJson['title']?.toString() ?? 'Unknown Track',
              );
            }).toList();
          }

          return Album(
            id: albumJson['id']?.toString() ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            name: albumJson['name']?.toString() ?? '',
            artist: albumJson['artist']?.toString() ?? '',
            genre: albumJson['genre']?.toString() ?? '',
            year: albumJson['year']?.toString() ?? '',
            medium: albumJson['medium']?.toString() ?? 'Vinyl',
            digital: albumJson['digital'] == true,
            tracks: tracks,
          );
        }).toList();
      } else {
        LoggerService.info('Wantlist load', 'File does not exist, creating empty file');

        // Erstelle leere Datei automatisch (schön formatiert)
        await file.create(recursive: true);
        await file.writeAsString('[\n]\n');

        return [];
      }
    } catch (e) {
      LoggerService.error('Wantlist load', e);
      return [];
    }
  }

  // Save wantlist to JSON file
  Future<void> saveWantlist(List<Album> wantlist) async {
    try {
      final filePath = await _getWantlistFilePath();

      final file = File(filePath);

      // Erstelle Directory falls nötig
      await file.parent.create(recursive: true);

      final List<Map<String, dynamic>> jsonList = wantlist.map((album) {
        return {
          'id': album.id,
          'name': album.name,
          'artist': album.artist,
          'genre': album.genre,
          'year': album.year,
          'medium': album.medium,
          'digital': album.digital,
          'tracks': album.tracks
              .map((track) => {
                    'trackNumber': track.trackNumber,
                    'title': track.title,
                  })
              .toList(),
        };
      }).toList();

      // Schön formatiert speichern
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString('${encoder.convert(jsonList)}\n');
      LoggerService.data('Wantlist saved', wantlist.length, 'items');
    } catch (e) {
      LoggerService.error('Wantlist save', e);
      throw Exception('Failed to save wantlist: $e');
    }
  }

  // BONUS: Import-Funktion für externe JSON-Dateien
  Future<List<Album>> importAlbumsFromFile(String importFilePath) async {
    try {

      final file = File(importFilePath);
      if (!await file.exists()) {
        throw Exception('Import file does not exist');
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);

      List<Album> importedAlbums = jsonList.map((albumMap) {
        final Map<String, dynamic> albumJson =
            Map<String, dynamic>.from(albumMap);

        // Parse tracks (same logic as loadAlbums)
        List<Track> tracks = [];
        if (albumJson['tracks'] != null) {
          final List<dynamic> tracksList = albumJson['tracks'];
          tracks = tracksList.map((trackMap) {
            final Map<String, dynamic> trackJson =
                Map<String, dynamic>.from(trackMap);
            return Track(
              trackNumber: trackJson['trackNumber']?.toString() ?? '1',
              title: trackJson['title']?.toString() ?? 'Unknown Track',
            );
          }).toList();
        }

        return Album(
          id: albumJson['id']?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          name: albumJson['name']?.toString() ?? '',
          artist: albumJson['artist']?.toString() ?? '',
          genre: albumJson['genre']?.toString() ?? '',
          year: albumJson['year']?.toString() ?? '',
          medium: albumJson['medium']?.toString() ?? 'Vinyl',
          digital: albumJson['digital'] == true,
          tracks: tracks,
        );
      }).toList();

      LoggerService.data('Albums imported', importedAlbums.length, 'items');

      // Merge with existing albums and save
      List<Album> existingAlbums = await loadAlbums();

      // Simple merge - add all imported albums (you might want to handle duplicates)
      List<Album> mergedAlbums = [...existingAlbums, ...importedAlbums];
      await saveAlbums(mergedAlbums);

      return importedAlbums;
    } catch (e) {
      LoggerService.error('Albums import', e);
      throw Exception('Failed to import albums: $e');
    }
  }
}
