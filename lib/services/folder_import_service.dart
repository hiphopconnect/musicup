// lib/services/folder_import_service.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/logger_service.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class ExtractedTrack {
  final String trackNumber;
  final String title;

  ExtractedTrack({required this.trackNumber, required this.title});
}

class FolderImportService {
  Future<String?> selectFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    return selectedDirectory;
  }

  Future<List<File>> getMp3Files(String directoryPath) async {
    Directory directory = Directory(directoryPath);
    List<File> mp3Files = [];

    if (await directory.exists()) {
      List<FileSystemEntity> files = directory.listSync();
      for (FileSystemEntity file in files) {
        if (file is File && file.path.toLowerCase().endsWith('.mp3')) {
          mp3Files.add(file);
        }
      }
    }

    mp3Files.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));
    return mp3Files;
  }

  List<ExtractedTrack> parseTrackInfo(List<File> mp3Files) {
    List<ExtractedTrack> extractedTracks = [];
    
    for (int i = 0; i < mp3Files.length; i++) {
      final file = mp3Files[i];
      final fileName = p.basenameWithoutExtension(file.path);
      final fallbackNumber = i + 1;

      final track = _parseTrackFromFilename(fileName, fallbackNumber);
      extractedTracks.add(track);
    }

    return extractedTracks;
  }

  ExtractedTrack _parseTrackFromFilename(String fileName, int fallbackNumber) {
    // Pattern 1: "01 - Title" oder "1 - Title"
    final dashMatch = RegExp(r'^(\d{1,3})\s*[-–]\s*(.+)$').firstMatch(fileName);
    if (dashMatch != null) {
      final trackNum = dashMatch.group(1)!.padLeft(2, '0');
      final title = dashMatch.group(2)!.trim();
      if (title.isNotEmpty) {
        return ExtractedTrack(trackNumber: trackNum, title: title);
      }
    }

    // Pattern 2: "01. Title" oder "1. Title"
    final dotMatch = RegExp(r'^(\d{1,3})\.\s*(.+)$').firstMatch(fileName);
    if (dotMatch != null) {
      final trackNum = dotMatch.group(1)!.padLeft(2, '0');
      final title = dotMatch.group(2)!.trim();
      if (title.isNotEmpty) {
        return ExtractedTrack(trackNumber: trackNum, title: title);
      }
    }

    // Pattern 3: "Track01Title" oder "01Title"
    final attachedMatch = RegExp(r'^(?:Track)?(\d{1,3})(.+)$').firstMatch(fileName);
    if (attachedMatch != null) {
      final trackNum = attachedMatch.group(1)!.padLeft(2, '0');
      final title = attachedMatch.group(2)!.trim();
      if (title.isNotEmpty) {
        return ExtractedTrack(trackNumber: trackNum, title: title);
      }
    }

    // Pattern 4: Nur Nummer am Anfang: "01 Title"
    final numOnlyMatch = RegExp(r'^(\d{1,3})\s+(.+)$').firstMatch(fileName);
    if (numOnlyMatch != null) {
      final trackNum = numOnlyMatch.group(1)!.padLeft(2, '0');
      final title = numOnlyMatch.group(2)!.trim();
      if (title.isNotEmpty) {
        return ExtractedTrack(trackNumber: trackNum, title: title);
      }
    }

    // Fallback: Use entire filename as title with sequential numbering
    final fallbackTrackNum = fallbackNumber.toString().padLeft(2, '0');
    return ExtractedTrack(trackNumber: fallbackTrackNum, title: fileName);
  }

  Future<Album?> createAlbumFromFolder(String folderPath) async {
    try {
      // 1. Ordnernamen als Albumname verwenden
      String albumName = p.basename(folderPath);
      String artist = 'Unknown Artist';
      String genre = 'Unknown Genre';
      String year = 'Unknown Year';
      String medium = 'CD';
      bool isDigital = false;

      // 2. MP3-Dateien lesen
      List<File> mp3Files = await getMp3Files(folderPath);
      if (mp3Files.isEmpty) {
        throw Exception("Keine MP3-Dateien im ausgewählten Ordner gefunden.");
      }

      // 3. Track-Informationen extrahieren
      List<ExtractedTrack> extractedTracks = parseTrackInfo(mp3Files);

      // 4. Track-Objekte erstellen
      List<Track> parsedTracks = extractedTracks.map((et) {
        return Track(
          title: et.title,
          trackNumber: et.trackNumber,
        );
      }).toList();

      // 5. Neues Album-Objekt erstellen
      Album newAlbum = Album(
        id: const Uuid().v4(),
        name: albumName,
        artist: artist,
        genre: genre,
        year: year,
        medium: medium,
        digital: isDigital,
        tracks: parsedTracks,
      );

      return newAlbum;
    } catch (e) {
      LoggerService.error('Album creation from folder', e);
      return null;
    }
  }
}