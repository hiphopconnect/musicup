import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:uuid/uuid.dart';

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
  final currentYear = DateTime.now().year;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    nameController.dispose();
    artistController.dispose();
    genreController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
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
            onPressed: () => Navigator.of(context).pop(true),
          ),
          TextButton(
            child: const Text('Ja'),
            onPressed: () {
              _saveAlbum();
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    ) ??
        false;
  }

  void _saveAlbum() {
    if (selectedMedium == null || isDigital == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select all fields")),
      );
    } else {
      var uuid = const Uuid();
      Album newAlbum = Album(
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add Album"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              children: [
                // Album Titel
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Album title"),
                ),
                // Artist
                TextFormField(
                  controller: artistController,
                  decoration: const InputDecoration(labelText: "Artist"),
                ),
                // Genre
                TextFormField(
                  controller: genreController,
                  decoration: const InputDecoration(labelText: "Genre"),
                ),
                // Year Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Year"),
                  value: selectedYear,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedYear = newValue;
                    });
                  },
                  items: List.generate(
                    100,
                        (index) => (currentYear - index).toString(),
                  ).map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                // Medium Dropdown
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
                // Digital Dropdown
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
                // Expanded ListView für Tracks und "Add Track"-Button
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: tracks.length + 1, // +1 für den "Add Track"-Button
                    itemBuilder: (context, index) {
                      if (index < tracks.length) {
                        // Track-Item
                        return ListTile(
                          leading: Text('Track ${tracks[index].trackNumber}'),
                          title: TextFormField(
                            initialValue: tracks[index].title,
                            onChanged: (value) {
                              setState(() {
                                tracks[index].title = value;
                              });
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
                // Save Album Button
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

  void _addTrack() {
    setState(() {
      int trackNumber = tracks.length + 1;
      String formattedTrackNumber = trackNumber.toString().padLeft(2, '0');
      tracks.add(Track(title: "", trackNumber: formattedTrackNumber));
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
