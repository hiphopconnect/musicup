// lib/services/json_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:path_provider/path_provider.dart';

class JsonService {
  final ConfigManager configManager;

  JsonService(this.configManager);

  // ✅ KORREKTUR: Verwende ConfigManager statt hardcodierte Pfade!
  Future<String> _getAlbumsFilePath() async {
    String? configPath = configManager.getJsonFilePath();

    if (configPath != null && configPath.isNotEmpty) {
      return configPath; // Verwende konfigurierten Pfad
    }

    // Fallback: Standard-Pfad wenn nicht konfiguriert
    if (Platform.isAndroid || Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/albums.json'; // ✅ KORRIGIERT: albums.json statt music_up_albums.json
    } else {
      return 'albums.json'; // Desktop Fallback
    }
  }

  // ✅ KORREKTUR: Verwende ConfigManager für Wantlist!
  Future<String> _getWantlistFilePath() async {
    return await configManager.getWantlistFilePathOrDefault();
  }

  // Load albums from JSON file
  Future<List<Album>> loadAlbums() async {
    try {
      final filePath = await _getAlbumsFilePath();
      print('🔍 DEBUG: Loading albums from: "$filePath"'); // ✅ DEBUG

      final file = File(filePath);

      if (await file.exists()) {
        final contents = await file.readAsString();
        print('🔍 DEBUG: File content length: ${contents.length}'); // ✅ DEBUG

        if (contents.trim().isEmpty) {
          print('⚠️ WARNING: Albums file is empty');
          return [];
        }

        final List<dynamic> jsonList = json.decode(contents);
        print(
            '✅ SUCCESS: Parsed ${jsonList.length} albums from JSON'); // ✅ DEBUG

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
        print('⚠️ WARNING: Albums file does not exist: "$filePath"');

        // ✅ Erstelle leere Datei automatisch
        await file.create(recursive: true);
        await file.writeAsString('[]');
        print('📁 Created empty albums file');

        return [];
      }
    } catch (e) {
      print('❌ ERROR loading albums: $e');
      return [];
    }
  }

  // Save albums to JSON file
  Future<void> saveAlbums(List<Album> albums) async {
    try {
      final filePath = await _getAlbumsFilePath();
      print(
          '🔍 DEBUG: Saving ${albums.length} albums to: "$filePath"'); // ✅ DEBUG

      final file = File(filePath);

      // ✅ Erstelle Directory falls nötig
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

      await file.writeAsString(json.encode(jsonList));
      print('✅ SUCCESS: Saved albums to file'); // ✅ DEBUG
    } catch (e) {
      print('❌ ERROR saving albums: $e');
      throw Exception('Failed to save albums: $e');
    }
  }

  // Load wantlist from JSON file
  Future<List<Album>> loadWantlist() async {
    try {
      final filePath = await _getWantlistFilePath();
      print('🔍 DEBUG: Loading wantlist from: "$filePath"'); // ✅ DEBUG

      final file = File(filePath);

      if (await file.exists()) {
        final contents = await file.readAsString();
        print(
            '🔍 DEBUG: Wantlist content length: ${contents.length}'); // ✅ DEBUG

        if (contents.trim().isEmpty) {
          print('⚠️ WARNING: Wantlist file is empty');
          return [];
        }

        final List<dynamic> jsonList = json.decode(contents);
        print(
            '✅ SUCCESS: Parsed ${jsonList.length} wantlist items from JSON'); // ✅ DEBUG

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
        print('⚠️ WARNING: Wantlist file does not exist: "$filePath"');

        // ✅ Erstelle leere Datei automatisch
        await file.create(recursive: true);
        await file.writeAsString('[]');
        print('📁 Created empty wantlist file');

        return [];
      }
    } catch (e) {
      print('❌ ERROR loading wantlist: $e');
      return [];
    }
  }

  // Save wantlist to JSON file
  Future<void> saveWantlist(List<Album> wantlist) async {
    try {
      final filePath = await _getWantlistFilePath();
      print(
          '🔍 DEBUG: Saving ${wantlist.length} wantlist items to: "$filePath"'); // ✅ DEBUG

      final file = File(filePath);

      // ✅ Erstelle Directory falls nötig
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

      await file.writeAsString(json.encode(jsonList));
      print('✅ SUCCESS: Saved wantlist to file'); // ✅ DEBUG
    } catch (e) {
      print('❌ ERROR saving wantlist: $e');
      throw Exception('Failed to save wantlist: $e');
    }
  }

  // ✅ BONUS: Import-Funktion für externe JSON-Dateien
  Future<List<Album>> importAlbumsFromFile(String importFilePath) async {
    try {
      print('🔍 DEBUG: Importing albums from: "$importFilePath"');

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

      print('✅ SUCCESS: Imported ${importedAlbums.length} albums');

      // Merge with existing albums and save
      List<Album> existingAlbums = await loadAlbums();

      // Simple merge - add all imported albums (you might want to handle duplicates)
      List<Album> mergedAlbums = [...existingAlbums, ...importedAlbums];
      await saveAlbums(mergedAlbums);

      return importedAlbums;
    } catch (e) {
      print('❌ ERROR importing albums: $e');
      throw Exception('Failed to import albums: $e');
    }
  }
}
