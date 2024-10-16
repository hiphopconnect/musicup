// lib/screens/edit_album_screen.dart

import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';

class EditAlbumScreen extends StatefulWidget {
  final Album album;

  const EditAlbumScreen({super.key, required this.album});

  @override
  EditAlbumScreenState createState() => EditAlbumScreenState();
}

class EditAlbumScreenState extends State<EditAlbumScreen> {
  late TextEditingController nameController;
  late TextEditingController artistController;
  late TextEditingController genreController;
  String? selectedMedium;
  bool? isDigital;
  String? selectedYear;
  List<String> years = [];
  final ScrollController _scrollController = ScrollController();

  // Kopie des Albums und der Tracks
  late Album editedAlbum;
  List<Track> tracks = [];
  List<TextEditingController> _trackTitleControllers = [];

  @override
  void initState() {
    super.initState();

    // Erstellen einer Kopie des Albums
    editedAlbum = Album(
      id: widget.album.id,
      name: widget.album.name,
      artist: widget.album.artist,
      genre: widget.album.genre,
      year: widget.album.year,
      medium: widget.album.medium,
      digital: widget.album.digital,
      tracks: widget.album.tracks.map((track) => Track(
        title: track.title,
        trackNumber: track.trackNumber,
      )).toList(),
    );

    nameController = TextEditingController(text: editedAlbum.name);
    artistController = TextEditingController(text: editedAlbum.artist);
    genreController = TextEditingController(text: editedAlbum.genre);
    selectedMedium = editedAlbum.medium;
    isDigital = editedAlbum.digital;
    selectedYear = editedAlbum.year;

    final currentYear = DateTime.now().year;
    years = List.generate(100, (index) => (currentYear - index).toString());

    tracks = editedAlbum.tracks;
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

  Future<bool> _onWillPop() async {
    bool shouldPop = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Änderungen speichern?'),
        content: const Text('Möchten Sie die Änderungen speichern, bevor Sie die Seite verlassen?'),
        actions: [
          TextButton(
            child: const Text('Abbrechen'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Nein'),
            onPressed: () {
              Navigator.of(context).pop(true);
              Navigator.pop(context, null); // Keine Änderungen gespeichert
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
    ) ??
        false;
    return shouldPop;
  }

  void _saveAlbum() {
    if (selectedMedium == null || isDigital == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select all fields")));
    } else {
      Album updatedAlbum = editedAlbum.copyWith(
        name: nameController.text,
        artist: artistController.text,
        genre: genreController.text,
        year: selectedYear!,
        medium: selectedMedium!,
        digital: isDigital!,
        tracks: tracks,
      );
      Navigator.pop(context, updatedAlbum);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Album"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Album Name"),
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
                  items: years.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Medium"),
                  value: selectedMedium,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMedium = newValue;
                    });
                  },
                  items: <String>{'Vinyl', 'CD', 'Cassette', 'Digital', 'Unknown'}
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
                  items: <String>['Yes', 'No'].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
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
                              track.title = value;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Track Title',
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_upward),
                                onPressed: index > 0
                                    ? () {
                                  setState(() {
                                    final temp = tracks[index];
                                    tracks[index] = tracks[index - 1];
                                    tracks[index - 1] = temp;
                                    // Tracknummern aktualisieren
                                    for (int i = 0; i < tracks.length; i++) {
                                      tracks[i].trackNumber = (i + 1).toString().padLeft(2, '0');
                                    }
                                    _updateTrackControllers();
                                  });
                                }
                                    : null,
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_downward),
                                onPressed: index < tracks.length - 1
                                    ? () {
                                  setState(() {
                                    final temp = tracks[index];
                                    tracks[index] = tracks[index + 1];
                                    tracks[index + 1] = temp;
                                    // Tracknummern aktualisieren
                                    for (int i = 0; i < tracks.length; i++) {
                                      tracks[i].trackNumber = (i + 1).toString().padLeft(2, '0');
                                    }
                                    _updateTrackControllers();
                                  });
                                }
                                    : null,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    tracks.removeAt(index);
                                    // Tracknummern aktualisieren
                                    for (int i = 0; i < tracks.length; i++) {
                                      tracks[i].trackNumber = (i + 1).toString().padLeft(2, '0');
                                    }
                                    _updateTrackControllers();
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      } else {
                        // "Add Track"-Button
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton.icon(
                            onPressed: _addTrack,
                            icon: const Icon(Icons.add),
                            label: const Text("Add Track"),
                          ),
                        );
                      }
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _saveAlbum,
                  child: const Text("Save Album"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Funktion zum Hinzufügen eines Tracks
  void _addTrack() {
    setState(() {
      int trackNumber = tracks.length + 1;
      String formattedTrackNumber = trackNumber.toString().padLeft(2, '0');
      tracks.add(Track(title: "", trackNumber: formattedTrackNumber));
      _updateTrackControllers();
    });

    // Scrollen Sie nach unten
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}
