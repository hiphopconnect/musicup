import 'dart:convert';
import 'dart:io';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/config_manager.dart';

class JsonService {
  final ConfigManager configManager;

  JsonService(this.configManager);

  // Lädt Alben aus einer JSON-Datei
  Future<List<Album>> loadAlbums() async {
    String? jsonPath = await configManager.getJsonPath();
    if (jsonPath == null || jsonPath.isEmpty) {
      throw Exception('No JSON path set');
    }

    File file = File(jsonPath);
    if (!await file.exists()) {
      throw Exception('JSON file not found');
    }

    String contents = await file.readAsString();
    List<dynamic> jsonData = json.decode(contents);
    return jsonData.map((item) => Album.fromMap(item as Map<String, dynamic>)).toList();
  }

  // Speichert Alben in der JSON-Datei mit Formatierung
  Future<void> saveAlbums(List<Album> albums) async {
    String? jsonPath = await configManager.getJsonPath();
    if (jsonPath == null || jsonPath.isEmpty) {
      throw Exception('No JSON path set');
    }

    File file = File(jsonPath);
    String jsonString = JsonEncoder.withIndent('  ').convert(albums.map((album) => album.toMap()).toList());
    await file.writeAsString(jsonString);
  }

  // Exportiert Alben als JSON
  Future<void> exportJson(String exportPath) async {
    List<Album> albums = await loadAlbums();
    String jsonString = JsonEncoder.withIndent('  ').convert(albums.map((album) => album.toMap()).toList());
    File file = File(exportPath);
    await file.writeAsString(jsonString);
  }

  // Exportiert Alben als XML (dieses Beispiel ist einfach und nicht für komplexe XML-Strukturen geeignet)
  Future<void> exportXml(String exportPath) async {
    List<Album> albums = await loadAlbums();
    StringBuffer xmlString = StringBuffer();
    xmlString.writeln('<albums>');
    for (Album album in albums) {
      xmlString.writeln('  <album>');
      xmlString.writeln('    <id>${album.id}</id>');
      xmlString.writeln('    <name>${album.name}</name>');
      xmlString.writeln('    <artist>${album.artist}</artist>');
      xmlString.writeln('    <genre>${album.genre}</genre>');
      xmlString.writeln('    <year>${album.year}</year>');
      xmlString.writeln('    <medium>${album.medium}</medium>');
      xmlString.writeln('    <digital>${album.digital}</digital>');
      xmlString.writeln('    <tracks>');
      for (Track track in album.tracks) {
        xmlString.writeln('      <track>');
        xmlString.writeln('        <title>${track.title}</title>');
        xmlString.writeln('      </track>');
      }
      xmlString.writeln('    </tracks>');
      xmlString.writeln('  </album>');
    }
    xmlString.writeln('</albums>');

    File file = File(exportPath);
    await file.writeAsString(xmlString.toString());
  }

  // Exportiert Alben als CSV
  Future<void> exportCsv(String exportPath) async {
    List<Album> albums = await loadAlbums();
    StringBuffer csvString = StringBuffer();
    csvString.writeln('id,name,artist,genre,year,medium,digital,tracks');

    for (Album album in albums) {
      List<String> trackTitles = album.tracks.map((track) => track.title).toList();
      String tracks = trackTitles.join(', ');
      csvString.writeln('${album.id},${album.name},${album.artist},${album.genre},${album.year},${album.medium},${album.digital},$tracks');
    }

    File file = File(exportPath);
    await file.writeAsString(csvString.toString());
  }

  // Importiert Alben aus einer JSON-Datei und sorgt für eindeutige IDs
  Future<void> importAlbums(String filePath) async {
    File file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Import file not found');
    }

    String contents = await file.readAsString();
    List<dynamic> jsonData = json.decode(contents);

    List<Album> importedAlbums = jsonData.map((item) {
      Map<String, dynamic> albumData = item as Map<String, dynamic>;
      albumData['id'] = DateTime.now().millisecondsSinceEpoch.toString();  // Neue eindeutige ID
      return Album.fromMap(albumData);
    }).toList();

    List<Album> existingAlbums = await loadAlbums();
    existingAlbums.addAll(importedAlbums);

    await saveAlbums(existingAlbums); // Speichern der aktualisierten Alben
  }
}
