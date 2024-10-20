// lib/screens/add_album_screen.dart

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

  @override
  void dispose() {
    nameController.dispose();
    artistController.dispose();
    genreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                items: <String>['Yes', 'No']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              // Expanded ListView für Tracks und "Add Track"-Button
              Expanded(
                child: ListView.builder(
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
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              tracks.removeAt(index);
                              // Aktualisiere die Track-Nummern nach dem Entfernen
                              for (int i = 0; i < tracks.length; i++) {
                                tracks[i].trackNumber =
                                    (i + 1).toString().padLeft(2, '0');
                                tracks[i].title =
                                    'Track ${tracks[i].trackNumber}';
                              }
                            });
                          },
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
                onPressed: () {
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
                },
                child: const Text("Save Album"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Test
  void _addTrack() {
    setState(() {
      int trackNumber = tracks.length + 1;
      String formattedTrackNumber = trackNumber.toString().padLeft(2, '0');
      tracks.add(Track(
          title: "Track $formattedTrackNumber",
          trackNumber: formattedTrackNumber));
    });
  }
}
