// lib/screens/add_album_screen.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Model for extracted track information
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

  /// WillPopScope logic: ask the user if they want to save changes before leaving
  Future<bool> _onWillPop() async {
    bool? shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save changes?'),
        content: const Text(
            'Do you want to save the new album before leaving the page?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop(true);
              Navigator.pop(context, null); // No changes are saved
            },
          ),
          TextButton(
            child: const Text('Yes'),
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

  /// Function to select a folder
  Future<String?> _selectFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    return selectedDirectory;
  }

  /// Function to read MP3 files from a folder
  Future<List<File>> _getMp3Files(String directoryPath) async {
    Directory dir = Directory(directoryPath);
    if (!await dir.exists()) {
      throw Exception("The selected folder does not exist.");
    }

    List<FileSystemEntity> entities = dir.listSync();
    List<File> mp3Files = entities
        .whereType<File>()
        .where((file) => p.extension(file.path).toLowerCase() == '.mp3')
        .toList();

    return mp3Files;
  }

  /// Function to parse filenames
  List<ExtractedTrack> _parseTrackInfo(List<File> mp3Files) {
    List<ExtractedTrack> extractedTracks = [];

    for (var file in mp3Files) {
      String fileName = p.basenameWithoutExtension(file.path);
      // Example: "01 - Song Title"
      List<String> parts = fileName.split(' - ');

      if (parts.length >= 2) {
        String trackNumber = parts[0].trim();
        String title = parts.sublist(1).join(' - ').trim();
        extractedTracks
            .add(ExtractedTrack(trackNumber: trackNumber, title: title));
      } else {
        // Fallback if the format doesn't match
        extractedTracks.add(ExtractedTrack(trackNumber: '00', title: fileName));
      }
    }

    return extractedTracks;
  }

  /// Function to create a new album from a folder
  Future<Album?> _createAlbumFromFolder(String folderPath) async {
    try {
      // 1. Use folder name as album name
      String albumName = p.basename(folderPath);
      String artist = 'Unknown Artist'; // Optional: can be adjusted later
      String genre = 'Unknown Genre'; // Optional: can be adjusted later
      String year = 'Unknown Year'; // Optional: can be adjusted later
      String medium = 'CD'; // Default medium
      bool isDigital = false; // Default to not digital

      // 2. Read MP3 files
      List<File> mp3Files = await _getMp3Files(folderPath);
      if (mp3Files.isEmpty) {
        throw Exception("No MP3 files found in the selected folder.");
      }

      // 3. Extract track information
      List<ExtractedTrack> extractedTracks = _parseTrackInfo(mp3Files);

      // 4. Create Track objects
      List<Track> parsedTracks = extractedTracks.map((et) {
        return Track(
          title: et.title,
          trackNumber: et.trackNumber,
        );
      }).toList();

      // 5. Create a new Album object
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
      // In production, use proper logging
      debugPrint("Error creating album: $e");
      return null;
    }
  }

  /// Function to add an album from a folder
  Future<void> _addAlbumFromFolder() async {
    String? folderPath = await _selectFolder();
    if (folderPath == null) return;

    Album? newAlbum = await _createAlbumFromFolder(folderPath);
    if (newAlbum != null) {
      if (!mounted) return;
      setState(() {
        // Album name from folder
        nameController.text = newAlbum.name;
        // Optionally prefill other fields if desired
        tracks = newAlbum.tracks;
        selectedYear = newAlbum.year;
        selectedMedium = newAlbum.medium;
        isDigital = true;
        _updateTrackControllers();
      });

      // Show a confirmation to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Album automatically added. Please check the data.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Album could not be created.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add Album"),
          actions: [
            IconButton(
              icon: const Icon(Icons.folder_open),
              tooltip: 'Add album from folder',
              onPressed: _addAlbumFromFolder,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Album Title"),
                ),
                TextFormField(
                  controller: artistController,
                  decoration: const InputDecoration(labelText: "Artist"),
                ),
                TextFormField(
                  controller: genreController,
                  decoration: const InputDecoration(labelText: "Genre"),
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Year"),
                  value: selectedYear,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedYear = newValue;
                    });
                  },
                  items: [
                    const DropdownMenuItem<String>(
                      value: 'Unknown Year',
                      child: Text('Unknown Year'),
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
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Medium"),
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
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Digital"),
                  value: isDigital != null ? (isDigital! ? "Yes" : "No") : null,
                  onChanged: (String? newValue) {
                    setState(() {
                      isDigital = newValue == "Yes" ? true : false;
                    });
                  },
                  items: <String>['Yes', 'No']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: tracks.length + 1,
                    itemBuilder: (context, index) {
                      if (index < tracks.length) {
                        final track = tracks[index];
                        return ListTile(
                          leading: Text('Track ${track.trackNumber}'),
                          title: TextFormField(
                            controller: _trackTitleControllers[index],
                            onChanged: (value) {
                              setState(() {
                                track.title = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Track title',
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                tracks.removeAt(index);
                                _updateTrackControllers();
                              });
                            },
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton.icon(
                            onPressed: _addTrack,
                            icon: const Icon(Icons.add),
                            label: const Text("Add track"),
                          ),
                        );
                      }
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _saveAlbum,
                  child: const Text("Save album"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Function to add a track
  void _addTrack() {
    setState(() {
      int trackNumber = tracks.length + 1;
      String formattedTrackNumber = trackNumber.toString().padLeft(2, '0');
      tracks.add(Track(title: "", trackNumber: formattedTrackNumber));
      _updateTrackControllers();
    });

    // Scroll down to the newly added track
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Adapted _saveAlbum function to save a specific album
  void _saveAlbum([Album? prefilledAlbum]) {
    if (selectedMedium == null || isDigital == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
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
          year: selectedYear ?? 'Unknown',
          medium: selectedMedium!,
          digital: isDigital!,
          tracks: tracks,
        );
    Navigator.pop(context, newAlbum);
  }
}
