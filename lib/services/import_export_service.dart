// lib/services/import_export_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/json_service.dart';
import 'package:path/path.dart' as path;
import 'package:xml/xml.dart';

enum ExportFormat { json, csv, xml }

enum ImportFormat { json, csv, xml }

class ImportExportService {
  final JsonService _jsonService;

  ImportExportService(this._jsonService);

  // ===== EXPORT FUNCTIONS =====

  /// Main export function - shows format selection dialog
  Future<String?> exportCollection({
    required List<Album> albums,
    ExportFormat? format,
  }) async {
    try {
      format ??= await _showExportFormatDialog();
      if (format == null) return null;

      String? filePath = await _selectSaveLocation(format);
      if (filePath == null) return null;

      switch (format) {
        case ExportFormat.json:
          return await _exportToJson(albums, filePath);
        case ExportFormat.csv:
          return await _exportToCsv(albums, filePath);
        case ExportFormat.xml:
          return await _exportToXml(albums, filePath);
      }
    } catch (e) {
      throw Exception('Export failed: $e');
    }
  }

  Future<String> _exportToJson(List<Album> albums, String filePath) async {
    final jsonData = albums.map((album) => album.toMap()).toList();
    final file = File(filePath);

    // Pretty-formatted JSON
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(jsonData));

    return filePath;
  }

  Future<String> _exportToCsv(List<Album> albums, String filePath) async {
    List<List<dynamic>> rows = [];

    // Header
    rows.add([
      'ID',
      'Album Name',
      'Artist',
      'Genre',
      'Year',
      'Medium',
      'Digital',
      'Track Count',
      'Tracks'
    ]);

    // Data rows
    for (Album album in albums) {
      String tracksString = album.tracks
          .map((track) => '${track.trackNumber}: ${track.title}')
          .join(' | ');

      rows.add([
        album.id,
        album.name,
        album.artist,
        album.genre,
        album.year,
        album.medium,
        album.digital ? 'Yes' : 'No',
        album.tracks.length,
        tracksString,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final file = File(filePath);
    await file.writeAsString(csv);

    return filePath;
  }

  Future<String> _exportToXml(List<Album> albums, String filePath) async {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('MusicCollection', nest: () {
      builder.attribute('version', '1.3.1');
      builder.attribute('exported', DateTime.now().toIso8601String());

      builder.element('Albums', nest: () {
        for (Album album in albums) {
          builder.element('Album', nest: () {
            builder.element('ID', nest: album.id);
            builder.element('Name', nest: album.name);
            builder.element('Artist', nest: album.artist);
            builder.element('Genre', nest: album.genre);
            builder.element('Year', nest: album.year);
            builder.element('Medium', nest: album.medium);
            builder.element('Digital', nest: album.digital.toString());

            if (album.tracks.isNotEmpty) {
              builder.element('Tracks', nest: () {
                for (Track track in album.tracks) {
                  builder.element('Track', nest: () {
                    builder.attribute('number', track.trackNumber);
                    builder.text(track.title);
                  });
                }
              });
            }
          });
        }
      });
    });

    final file = File(filePath);
    await file.writeAsString(builder.buildDocument().toXmlString(pretty: true));

    return filePath;
  }

  // ===== IMPORT FUNCTIONS =====

  /// Main import function - shows format selection dialog
  Future<List<Album>> importCollection({ImportFormat? format}) async {
    try {
      format ??= await _showImportFormatDialog();
      if (format == null) return [];

      String? filePath = await _selectImportFile(format);
      if (filePath == null) return [];

      switch (format) {
        case ImportFormat.json:
          return await _importFromJson(filePath);
        case ImportFormat.csv:
          return await _importFromCsv(filePath);
        case ImportFormat.xml:
          return await _importFromXml(filePath);
      }
    } catch (e) {
      throw Exception('Import failed: $e');
    }
  }

  Future<List<Album>> _importFromJson(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    final List<dynamic> jsonList = json.decode(content);

    return jsonList.map((item) => Album.fromMap(item)).toList();
  }

  Future<List<Album>> _importFromCsv(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    final List<List<dynamic>> rows =
        const CsvToListConverter().convert(content);

    if (rows.isEmpty) return [];

    // Skip header row
    List<Album> albums = [];
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length >= 7) {
        // Parse tracks from string
        List<Track> tracks = [];
        if (row.length > 8 && row[8] != null && row[8].toString().isNotEmpty) {
          String tracksString = row[8].toString();
          List<String> trackParts = tracksString.split(' | ');
          for (String trackPart in trackParts) {
            if (trackPart.contains(': ')) {
              List<String> parts = trackPart.split(': ');
              tracks.add(Track(
                trackNumber: parts[0],
                title: parts.length > 1 ? parts[1] : 'Unknown',
              ));
            }
          }
        }

        albums.add(Album(
          id: row[0]?.toString() ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          name: row[1]?.toString() ?? '',
          artist: row[2]?.toString() ?? '',
          genre: row[3]?.toString() ?? '',
          year: row[4]?.toString() ?? '',
          medium: row[5]?.toString() ?? 'Vinyl',
          digital: row[6]?.toString().toLowerCase() == 'yes',
          tracks: tracks,
        ));
      }
    }

    return albums;
  }

  Future<List<Album>> _importFromXml(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    final document = XmlDocument.parse(content);

    List<Album> albums = [];
    final albumElements = document.findAllElements('Album');

    for (XmlElement albumElement in albumElements) {
      String id = albumElement.findElements('ID').first.innerText;
      String name = albumElement.findElements('Name').first.innerText;
      String artist = albumElement.findElements('Artist').first.innerText;
      String genre = albumElement.findElements('Genre').first.innerText;
      String year = albumElement.findElements('Year').first.innerText;
      String medium = albumElement.findElements('Medium').first.innerText;
      bool digital =
          albumElement.findElements('Digital').first.innerText.toLowerCase() ==
              'true';

      // Parse tracks
      List<Track> tracks = [];
      final tracksElement = albumElement.findElements('Tracks');
      if (tracksElement.isNotEmpty) {
        final trackElements = tracksElement.first.findElements('Track');
        for (XmlElement trackElement in trackElements) {
          String trackNumber = trackElement.getAttribute('number') ?? '1';
          String title = trackElement.innerText;
          tracks.add(Track(trackNumber: trackNumber, title: title));
        }
      }

      albums.add(Album(
        id: id,
        name: name,
        artist: artist,
        genre: genre,
        year: year,
        medium: medium,
        digital: digital,
        tracks: tracks,
      ));
    }

    return albums;
  }

  // ===== UI HELPER FUNCTIONS =====

  Future<ExportFormat?> _showExportFormatDialog() async {
    // This would be implemented in the UI layer
    // For now, return JSON as default
    return ExportFormat.json;
  }

  Future<ImportFormat?> _showImportFormatDialog() async {
    // This would be implemented in the UI layer
    // For now, return JSON as default
    return ImportFormat.json;
  }

  Future<String?> _selectSaveLocation(ExportFormat format) async {
    String extension = _getFileExtension(format);

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Collection',
      fileName:
          'music_collection_${DateTime.now().millisecondsSinceEpoch}.$extension',
      type: FileType.custom,
      allowedExtensions: [extension],
    );

    return outputFile;
  }

  Future<String?> _selectImportFile(ImportFormat format) async {
    String extension = _getFileExtension(format);

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import Collection',
      type: FileType.custom,
      allowedExtensions: [extension],
    );

    return result?.files.single.path;
  }

  String _getFileExtension(dynamic format) {
    if (format is ExportFormat) {
      switch (format) {
        case ExportFormat.json:
          return 'json';
        case ExportFormat.csv:
          return 'csv';
        case ExportFormat.xml:
          return 'xml';
      }
    } else if (format is ImportFormat) {
      switch (format) {
        case ImportFormat.json:
          return 'json';
        case ImportFormat.csv:
          return 'csv';
        case ImportFormat.xml:
          return 'xml';
      }
    }
    return 'json';
  }

  // ===== VALIDATION =====

  Future<bool> validateImportFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      String extension = path.extension(filePath).toLowerCase();

      switch (extension) {
        case '.json':
          final content = await file.readAsString();
          json.decode(content); // Will throw if invalid JSON
          return true;
        case '.csv':
          final content = await file.readAsString();
          const CsvToListConverter().convert(content);
          return true;
        case '.xml':
          final content = await file.readAsString();
          XmlDocument.parse(content);
          return true;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }
}
