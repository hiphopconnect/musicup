// lib/screens/add_album_screen.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/app_layout.dart';
import 'package:music_up/widgets/section_card.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Model für extrahierte Track-Informationen
class ExtractedTrack {
  final String trackNumber;
  final String title;

  ExtractedTrack({required this.trackNumber, required this.title});
}

class AddAlbumScreen extends StatefulWidget {
  const AddAlbumScreen({super.key});

  @override
  AddAlbumScreenState createState() => AddAlbumScreenState();
}

class AddAlbumScreenState extends State<AddAlbumScreen> {
  final nameController = TextEditingController();
  final artistController = TextEditingController();
  final genreController = TextEditingController();
  String? selectedYear;
  String? selectedMedium;
  bool? isDigital;
  List<Track> tracks = [];
  final int currentYear = DateTime.now().year;
  List<TextEditingController> _trackTitleControllers = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeTrackControllers();
  }

  void _initializeTrackControllers() {
    _trackTitleControllers = tracks.map((track) {
      return TextEditingController(text: track.title);
    }).toList();
  }

  void _updateTrackControllers() {
    for (var controller in _trackTitleControllers) {
      controller.dispose();
    }
    _trackTitleControllers = tracks.map((track) {
      return TextEditingController(text: track.title);
    }).toList();
  }

  @override
  void dispose() {
    nameController.dispose();
    artistController.dispose();
    genreController.dispose();
    _scrollController.dispose();
    for (var controller in _trackTitleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// WillPopScope-Logik: Den Benutzer fragen, ob er Änderungen vor dem Verlassen speichern möchte
  Future<bool> _onWillPop() async {
    bool? shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Änderungen speichern?'),
        content: const Text(
            'Möchten Sie das neue Album vor dem Verlassen der Seite speichern?'),
        actions: [
          TextButton(
            child: const Text('Abbrechen'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Nein'),
            onPressed: () {
              Navigator.of(context).pop(true);
              Navigator.pop(
                  context, null); // Keine Änderungen werden gespeichert
            },
          ),
          TextButton(
            child: const Text('Ja'),
            onPressed: () {
              Navigator.of(context).pop(true);
              _saveAlbum();
            },
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  /// Funktion zum Auswählen eines Ordners
  Future<String?> _selectFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    return selectedDirectory;
  }

  /// Funktion zum Lesen von MP3-Dateien aus einem Ordner
  Future<List<File>> _getMp3Files(String directoryPath) async {
    Directory dir = Directory(directoryPath);
    if (!await dir.exists()) {
      throw Exception("Der ausgewählte Ordner existiert nicht.");
    }

    List<FileSystemEntity> entities = dir.listSync();
    List<File> mp3Files = entities
        .whereType<File>()
        .where((file) => p.extension(file.path).toLowerCase() == '.mp3')
        .toList();

    return mp3Files;
  }

  /// IMPROVED: Enhanced track info parsing with better format detection
  List<ExtractedTrack> _parseTrackInfo(List<File> mp3Files) {
    List<ExtractedTrack> extractedTracks = [];

    // Sort files by name to ensure proper order
    mp3Files.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

    for (int i = 0; i < mp3Files.length; i++) {
      var file = mp3Files[i];
      String fileName = p.basenameWithoutExtension(file.path);

      ExtractedTrack? track = _extractTrackFromFilename(fileName, i + 1);
      if (track != null) {
        extractedTracks.add(track);
      }
    }

    return extractedTracks;
  }

  /// IMPROVED: Smart track extraction from filename with multiple format support
  ExtractedTrack? _extractTrackFromFilename(
      String fileName, int fallbackNumber) {
    // Pattern 1: "01 - Song Title" or "1 - Song Title"
    final dashPattern = RegExp(r'^(\d+)\s*-\s*(.+)$');
    final dashMatch = dashPattern.firstMatch(fileName);
    if (dashMatch != null) {
      final trackNum = dashMatch.group(1)!.padLeft(2, '0');
      final title = dashMatch.group(2)!.trim();
      return ExtractedTrack(trackNumber: trackNum, title: title);
    }

    // Pattern 2: "01. Song Title" or "1. Song Title"
    final dotPattern = RegExp(r'^(\d+)\.\s*(.+)$');
    final dotMatch = dotPattern.firstMatch(fileName);
    if (dotMatch != null) {
      final trackNum = dotMatch.group(1)!.padLeft(2, '0');
      final title = dotMatch.group(2)!.trim();
      return ExtractedTrack(trackNumber: trackNum, title: title);
    }

    // Pattern 3: "A1 Song Title" or "B2 Song Title" (Vinyl format)
    final vinylPattern = RegExp(r'^([A-Za-z])(\d+)\s+(.+)$');
    final vinylMatch = vinylPattern.firstMatch(fileName);
    if (vinylMatch != null) {
      final letter = vinylMatch.group(1)!.toUpperCase();
      final number = vinylMatch.group(2)!;
      final title = vinylMatch.group(3)!.trim();
      return ExtractedTrack(trackNumber: '$letter$number', title: title);
    }

    // Pattern 4: "Track 01 - Song Title"
    final trackPattern =
        RegExp(r'^(?:Track\s+)?(\d+)\s*[-.]?\s*(.+)$', caseSensitive: false);
    final trackMatch = trackPattern.firstMatch(fileName);
    if (trackMatch != null) {
      final trackNum = trackMatch.group(1)!.padLeft(2, '0');
      final title = trackMatch.group(2)!.trim();
      if (title.isNotEmpty) {
        return ExtractedTrack(trackNumber: trackNum, title: title);
      }
    }

    // Pattern 5: Just numbers at start "01Song Title" or "1Song Title"
    final numOnlyPattern = RegExp(r'^(\d+)(.+)$');
    final numOnlyMatch = numOnlyPattern.firstMatch(fileName);
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

  /// Funktion zum Erstellen eines neuen Albums aus einem Ordner
  Future<Album?> _createAlbumFromFolder(String folderPath) async {
    try {
      // 1. Ordnernamen als Albumname verwenden
      String albumName = p.basename(folderPath);
      String artist =
          'Unknown Artist'; // Optional: kann später angepasst werden
      String genre = 'Unknown Genre'; // Optional: kann später angepasst werden
      String year = 'Unknown Year'; // Optional: kann später angepasst werden
      String medium = 'CD'; // Standardmedium
      bool isDigital = false; // Standard: nicht digital

      // 2. MP3-Dateien lesen
      List<File> mp3Files = await _getMp3Files(folderPath);
      if (mp3Files.isEmpty) {
        throw Exception("Keine MP3-Dateien im ausgewählten Ordner gefunden.");
      }

      // 3. Track-Informationen extrahieren mit verbesserter Logik
      List<ExtractedTrack> extractedTracks = _parseTrackInfo(mp3Files);

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
      // In der Produktion echtes Logging verwenden
      debugPrint("Fehler beim Erstellen des Albums: $e");
      return null;
    }
  }

  /// Funktion zum Hinzufügen eines Albums aus einem Ordner
  Future<void> _addAlbumFromFolder() async {
    String? folderPath = await _selectFolder();
    if (folderPath == null) return;

    Album? newAlbum = await _createAlbumFromFolder(folderPath);
    if (newAlbum != null) {
      if (!mounted) return;
      setState(() {
        // Albumname aus Ordner
        nameController.text = newAlbum.name;
        // Optional andere Felder vorausfüllen, wenn gewünscht
        tracks = newAlbum.tracks;
        selectedYear = newAlbum.year;
        selectedMedium = newAlbum.medium;
        isDigital = true;
        _updateTrackControllers();
      });

      // Bestätigung für den Benutzer anzeigen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Album automatisch hinzugefügt mit ${tracks.length} Tracks. Bitte Daten überprüfen.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Album konnte nicht erstellt werden.")),
      );
    }
  }

  /// IMPROVED: Reorder tracks with proper track number updating
  void _reorderTracks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final Track item = tracks.removeAt(oldIndex);
      tracks.insert(newIndex, item);

      // Update all track numbers to maintain sequential order
      _updateAllTrackNumbers();
      _updateTrackControllers();
    });
  }

  /// IMPROVED: Update track numbers while preserving alphanumeric format if present
  void _updateAllTrackNumbers() {
    for (int i = 0; i < tracks.length; i++) {
      final currentTrackNumber = tracks[i].trackNumber;

      // Check if current track has alphanumeric format (A1, B2, etc.)
      if (RegExp(r'^[A-Za-z]\d+$').hasMatch(currentTrackNumber)) {
        // Preserve letter prefix, update number
        final letter = currentTrackNumber.substring(0, 1).toUpperCase();
        final newNumber = (i + 1).toString();
        tracks[i].trackNumber = '$letter$newNumber';
      } else {
        // Use simple numeric format
        tracks[i].trackNumber = (i + 1).toString().padLeft(2, '0');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: AppLayout(
        title: "Album hinzufügen",
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Album aus Ordner hinzufügen',
            onPressed: _addAlbumFromFolder,
          ),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(DS.md),
          child: Form(
            child: Column(
              children: [
                // Album-Informationen Sektion
                SectionCard(
                  title: "Album-Informationen",
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Album-Titel",
                          prefixIcon: Icon(Icons.album),
                        ),
                      ),
                      const SizedBox(height: DS.md),
                      TextFormField(
                        controller: artistController,
                        decoration: const InputDecoration(
                          labelText: "Künstler",
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: DS.md),
                      TextFormField(
                        controller: genreController,
                        decoration: const InputDecoration(
                          labelText: "Genre",
                          prefixIcon: Icon(Icons.music_note),
                        ),
                      ),
                    ],
                  ),
                ),

                // Format-Einstellungen Sektion
                SectionCard(
                  title: "Format-Einstellungen",
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Jahr",
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        value: selectedYear,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedYear = newValue;
                          });
                        },
                        items: [
                          const DropdownMenuItem<String>(
                            value: 'Unknown Year',
                            child: Text('Unbekanntes Jahr'),
                          ),
                          ...List.generate(
                            100,
                            (index) => (currentYear - index).toString(),
                          ).map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: DS.md),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Medium",
                          prefixIcon: Icon(Icons.storage),
                        ),
                        value: selectedMedium,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedMedium = newValue;
                          });
                        },
                        items: <String>['Vinyl', 'CD', 'Cassette', 'Digital']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: DS.md),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: "Digital",
                          prefixIcon: Icon(Icons.cloud),
                        ),
                        value: isDigital != null
                            ? (isDigital! ? "Ja" : "Nein")
                            : null,
                        onChanged: (String? newValue) {
                          setState(() {
                            isDigital = newValue == "Ja" ? true : false;
                          });
                        },
                        items: <String>['Ja', 'Nein']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Tracks Sektion - IMPROVED with drag-and-drop and better sorting
                SectionCard(
                  title: "Tracks (${tracks.length})",
                  child: Column(
                    children: [
                      SizedBox(
                        height: 300,
                        child: ReorderableListView.builder(
                          scrollController: _scrollController,
                          itemCount: tracks.length + 1,
                          onReorder: _reorderTracks,
                          itemBuilder: (context, index) {
                            if (index < tracks.length) {
                              final track = tracks[index];
                              return Card(
                                key: ValueKey(
                                    'track_${track.trackNumber}_$index'),
                                margin: const EdgeInsets.only(bottom: DS.xs),
                                child: ListTile(
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.drag_handle,
                                          color: Colors.grey[600]),
                                      const SizedBox(width: 8),
                                      CircleAvatar(
                                        radius: 16,
                                        child: Text(
                                          track.trackNumber,
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: TextFormField(
                                    controller: _trackTitleControllers[index],
                                    onChanged: (value) {
                                      setState(() {
                                        track.title = value;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Track-Titel',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        tracks.removeAt(index);
                                        _updateAllTrackNumbers();
                                        _updateTrackControllers();
                                      });
                                    },
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                key: const ValueKey('add_track_button'),
                                padding:
                                    const EdgeInsets.symmetric(vertical: DS.xs),
                                child: ElevatedButton.icon(
                                  onPressed: _addTrack,
                                  icon: const Icon(Icons.add),
                                  label: const Text("Track hinzufügen"),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: DS.lg),

                // Speichern Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveAlbum,
                    icon: const Icon(Icons.save),
                    label: const Text("Album speichern"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(DS.md),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// IMPROVED: Add track with smart track number assignment
  void _addTrack() {
    setState(() {
      // Determine the next track number based on existing tracks
      String nextTrackNumber;

      if (tracks.isEmpty) {
        nextTrackNumber = '01';
      } else {
        final lastTrack = tracks.last;
        final lastTrackNumber = lastTrack.trackNumber;

        // Check if we have alphanumeric format
        final alphaNumMatch =
            RegExp(r'^([A-Za-z])(\d+)$').firstMatch(lastTrackNumber);
        if (alphaNumMatch != null) {
          // Continue alphanumeric sequence
          final letter = alphaNumMatch.group(1)!;
          final number = int.parse(alphaNumMatch.group(2)!);
          nextTrackNumber = '$letter${number + 1}';
        } else {
          // Use simple numeric increment
          final trackCount = tracks.length + 1;
          nextTrackNumber = trackCount.toString().padLeft(2, '0');
        }
      }

      tracks.add(Track(title: "", trackNumber: nextTrackNumber));
      _updateTrackControllers();
    });

    // Scroll to the new track
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: DS.normal,
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Angepasste _saveAlbum Funktion zum Speichern eines spezifischen Albums
  void _saveAlbum([Album? prefilledAlbum]) {
    if (selectedMedium == null || isDigital == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bitte alle Felder ausfüllen")),
      );
      return;
    }

    var uuid = const Uuid();
    Album newAlbum = prefilledAlbum ??
        Album(
          id: uuid.v4(),
          name: nameController.text,
          artist: artistController.text,
          genre: genreController.text,
          year: selectedYear ?? 'Unbekannt',
          medium: selectedMedium!,
          digital: isDigital!,
          tracks: tracks,
        );
    Navigator.pop(context, newAlbum);
  }
}
