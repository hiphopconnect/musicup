// lib/services/json_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:csv/csv.dart';
import 'package:xml/xml.dart' as xml;
import 'package:flutter/foundation.dart'; // Für listEquals
import 'package:uuid/uuid.dart'; // Für UUID-Generierung

class JsonService {
  final ConfigManager configManager;

  JsonService(this.configManager);

  Future<String> _getJsonFilePath() async {
    return await configManager.getJsonFilePathAsync();
  }

  // Lädt Alben aus einer JSON-Datei
  Future<List<Album>> loadAlbums() async {
    String jsonPath = await _getJsonFilePath();

    File file = File(jsonPath);
    if (!await file.exists()) {
      // Erstelle eine leere Datei, wenn sie nicht existiert
      await file.writeAsString('[]');
    }

    String contents = await file.readAsString();
    List<dynamic> jsonData = json.decode(contents);
    return jsonData.map((item) => Album.fromMap(item as Map<String, dynamic>)).toList();
  }

  // Speichert Alben in der JSON-Datei mit Formatierung
  Future<void> saveAlbums(List<Album> albums) async {
    String jsonPath = await _getJsonFilePath();

    File file = File(jsonPath);
    String jsonString = const JsonEncoder.withIndent('  ').convert(albums.map((album) => album.toMap()).toList());
    await file.writeAsString(jsonString);
  }

  // Hilfsfunktion zum Erstellen eines Album-Schlüssels basierend auf den Schlüsselattributen
  String _generateAlbumKey(Album album) {
    return '${album.name}|${album.artist}|${album.year}|${album.medium}|${album.digital}';
  }

  // Exportiert Alben als JSON
  Future<void> exportJson(String exportPath) async {
    List<Album> albums = await loadAlbums();
    String jsonString = const JsonEncoder.withIndent('  ').convert(albums.map((album) => album.toMap()).toList());
    File file = File(exportPath);
    await file.writeAsString(jsonString);
  }

  // Exportiert Alben als XML
  Future<void> exportXml(String exportPath) async {
    List<Album> albums = await loadAlbums();
    final builder = xml.XmlBuilder();

    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('albums', nest: () {
      for (Album album in albums) {
        builder.element('album', nest: () {
          builder.element('id', nest: album.id);
          builder.element('name', nest: album.name);
          builder.element('artist', nest: album.artist);
          builder.element('genre', nest: album.genre);
          builder.element('year', nest: album.year);
          builder.element('medium', nest: album.medium);
          builder.element('digital', nest: album.digital.toString());
          builder.element('tracks', nest: () {
            for (Track track in album.tracks) {
              builder.element('track', nest: () {
                builder.element('title', nest: track.title);
                builder.element('trackNumber', nest: track.trackNumber);
              });
            }
          });
        });
      }
    });

    final xmlDocument = builder.buildDocument();
    File file = File(exportPath);
    await file.writeAsString(xmlDocument.toXmlString(pretty: true, indent: '  '));
  }

  // Exportiert Alben als CSV
  Future<void> exportCsv(String exportPath) async {
    List<Album> albums = await loadAlbums();
    List<List<dynamic>> csvData = [
      ['id', 'name', 'artist', 'genre', 'year', 'medium', 'digital', 'trackNumber', 'title'],
    ];

    for (Album album in albums) {
      for (Track track in album.tracks) {
        csvData.add([
          album.id,
          album.name,
          album.artist,
          album.genre,
          album.year,
          album.medium,
          album.digital,
          track.trackNumber,
          track.title,
        ]);
      }
    }

    String csvString = const ListToCsvConverter().convert(csvData);
    File file = File(exportPath);
    await file.writeAsString(csvString);
  }

  // Importiert Alben aus einer JSON-Datei und vermeidet Duplikate
  Future<void> importAlbums(String filePath) async {
    File file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Import file not found');
    }

    String contents = await file.readAsString();
    List<dynamic> jsonData = json.decode(contents);

    var uuid = const Uuid();

    List<Album> existingAlbums = await loadAlbums();

    // Erstellen einer Map vorhandener Alben anhand des Album-Schlüssels
    Map<String, Album> existingAlbumMap = {
      for (var album in existingAlbums) _generateAlbumKey(album): album,
    };

    for (var item in jsonData) {
      Map<String, dynamic> albumData = item as Map<String, dynamic>;

      Album importedAlbum = Album.fromMap(albumData);

      // Erstellen eines Album-Schlüssels für das importierte Album
      String albumKey = _generateAlbumKey(importedAlbum);

      if (!existingAlbumMap.containsKey(albumKey)) {
        // Generiere eine neue eindeutige ID
        importedAlbum = importedAlbum.copyWith(id: uuid.v4());

        existingAlbums.add(importedAlbum);
        existingAlbumMap[albumKey] = importedAlbum;
      }
    }

    await saveAlbums(existingAlbums);
  }

  // Importiert Alben aus einer CSV-Datei und vermeidet Duplikate
  Future<void> importCsv(String filePath) async {
    File file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Import file not found');
    }

    String contents = await file.readAsString();

    List<List<dynamic>> csvTable = const CsvToListConverter().convert(contents);

    if (csvTable.isEmpty) {
      throw Exception('CSV file is empty');
    }

    // Die erste Zeile sollte der Header sein
    List<dynamic> headers = csvTable[0];

    // Erwartete Header
    List<String> expectedHeaders = ['id', 'name', 'artist', 'genre', 'year', 'medium', 'digital', 'trackNumber', 'title'];

    if (!listEquals(headers, expectedHeaders)) {
      throw Exception('CSV headers do not match expected format');
    }

    Map<String, Album> albumMap = {};
    var uuid = const Uuid();

    List<Album> existingAlbums = await loadAlbums();

    // Erstellen einer Map vorhandener Alben anhand des Album-Schlüssels
    Map<String, Album> existingAlbumMap = {
      for (var album in existingAlbums) _generateAlbumKey(album): album,
    };

    for (int i = 1; i < csvTable.length; i++) {
      List<dynamic> row = csvTable[i];

      if (row.length != expectedHeaders.length) {
        throw Exception('Invalid CSV format at line ${i + 1}');
      }

      Map<String, dynamic> data = {};
      for (int j = 0; j < headers.length; j++) {
        data[headers[j]] = row[j];
      }

      String albumName = data['name'].toString();
      String artist = data['artist'].toString();
      String genre = data['genre'].toString();
      String year = data['year'].toString();
      String medium = data['medium'].toString();
      bool digital = data['digital'].toString().toLowerCase() == 'true';

      // Erstellen eines Album-Schlüssels
      String albumKey = '$albumName|$artist|$year|$medium|$digital';

      String trackNumber = data['trackNumber'].toString();
      String trackTitle = data['title'].toString();

      Track track = Track(
        title: trackTitle,
        trackNumber: trackNumber,
      );

      if (existingAlbumMap.containsKey(albumKey)) {
        // Album existiert bereits, füge den Track hinzu, wenn er nicht bereits existiert
        Album existingAlbum = existingAlbumMap[albumKey]!;

        bool trackExists = existingAlbum.tracks.any((t) => t.trackNumber == track.trackNumber && t.title == track.title);

        if (!trackExists) {
          existingAlbum.tracks.add(track);
        }
      } else if (albumMap.containsKey(albumKey)) {
        // Album ist bereits im Import, füge den Track hinzu
        albumMap[albumKey]!.tracks.add(track);
      } else {
        // Neues Album, generiere neue ID
        String newAlbumId = uuid.v4();

        Album album = Album(
          id: newAlbumId,
          name: albumName,
          artist: artist,
          genre: genre,
          year: year,
          medium: medium,
          digital: digital,
          tracks: [track],
        );
        albumMap[albumKey] = album;
      }
    }

    // Füge die neuen Alben hinzu
    existingAlbums.addAll(albumMap.values);

    await saveAlbums(existingAlbums);
  }

  // Importiert Alben aus einer XML-Datei und vermeidet Duplikate
  Future<void> importXml(String filePath) async {
    File file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Import file not found');
    }

    String contents = await file.readAsString();

    final document = xml.XmlDocument.parse(contents);

    List<Album> existingAlbums = await loadAlbums();
    var uuid = const Uuid();

    // Erstellen einer Map vorhandener Alben anhand des Album-Schlüssels
    Map<String, Album> existingAlbumMap = {
      for (var album in existingAlbums) _generateAlbumKey(album): album,
    };

    final albumElements = document.findAllElements('album');

    List<Album> importedAlbums = [];

    for (var albumElement in albumElements) {
      String name = albumElement.findElements('name').first.innerText;
      String artist = albumElement.findElements('artist').first.innerText;
      String genre = albumElement.findElements('genre').first.innerText;
      String year = albumElement.findElements('year').first.innerText;
      String medium = albumElement.findElements('medium').first.innerText;
      bool digital = albumElement.findElements('digital').first.innerText.toLowerCase() == 'true';

      // Erstellen eines Album-Schlüssels
      String albumKey = '$name|$artist|$year|$medium|$digital';

      List<Track> tracks = [];

      final trackElements = albumElement.findAllElements('track');

      for (var trackElement in trackElements) {
        String title = trackElement.findElements('title').first.innerText;
        String trackNumber = trackElement.findElements('trackNumber').first.innerText;

        tracks.add(Track(
          title: title,
          trackNumber: trackNumber,
        ));
      }

      if (existingAlbumMap.containsKey(albumKey)) {
        // Album existiert bereits, füge neue Tracks hinzu
        Album existingAlbum = existingAlbumMap[albumKey]!;

        for (var track in tracks) {
          bool trackExists = existingAlbum.tracks.any((t) => t.trackNumber == track.trackNumber && t.title == track.title);

          if (!trackExists) {
            existingAlbum.tracks.add(track);
          }
        }
      } else {
        // Neues Album, generiere neue ID
        String newAlbumId = uuid.v4();

        Album album = Album(
          id: newAlbumId,
          name: name,
          artist: artist,
          genre: genre,
          year: year,
          medium: medium,
          digital: digital,
          tracks: tracks,
        );

        importedAlbums.add(album);
        existingAlbumMap[albumKey] = album;
      }
    }

    existingAlbums.addAll(importedAlbums);

    await saveAlbums(existingAlbums);
  }
}
