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
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
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
                items: <String>['Yes', 'No'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: () {
                  _addTrack();
                },
                child: const Text("Add Track"),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
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
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedMedium == null || isDigital == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please select all fields")));
                  } else {
                    var uuid = const Uuid();
                    Album newAlbum = Album(
                      id: uuid.v4(),
                      name: nameController.text,
                      artist: artistController.text,
                      genre: genreController.text,
                      year: selectedYear!,
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

  void _addTrack() {
    setState(() {
      int trackNumber = tracks.length + 1;
      String formattedTrackNumber = trackNumber.toString().padLeft(2, '0');
      tracks.add(Track(title: "Track $formattedTrackNumber", trackNumber: formattedTrackNumber));
    });
  }
}
