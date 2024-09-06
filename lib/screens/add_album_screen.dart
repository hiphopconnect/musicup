import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:uuid/uuid.dart';

class AddAlbumScreen extends StatefulWidget {
  @override
  _AddAlbumScreenState createState() => _AddAlbumScreenState();
}

class _AddAlbumScreenState extends State<AddAlbumScreen> {
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
        title: Text("Add Album"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextFormField(
                controller: artistController,
                decoration: InputDecoration(labelText: "Artist"),
              ),
              TextFormField(
                controller: genreController,
                decoration: InputDecoration(labelText: "Genre"),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Year"),
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
                decoration: InputDecoration(labelText: "Medium"),
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
                decoration: InputDecoration(labelText: "Digital"),
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
                  _addTrack(); // Add track button
                },
                child: Text("Add Track"),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: TextFormField(
                        initialValue: tracks[index].title,
                        onChanged: (value) {
                          setState(() {
                            tracks[index].title = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Track ${index + 1}',
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
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
                        SnackBar(content: Text("Please select all fields")));
                  } else {
                    var uuid = Uuid();
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
                child: Text("Save Album"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTrack() {
    setState(() {
      tracks.add(Track(title: "Track ${tracks.length + 1}"));
    });
  }
}
