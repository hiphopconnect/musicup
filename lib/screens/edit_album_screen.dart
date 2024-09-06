import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';

class EditAlbumScreen extends StatefulWidget {
  final Album album;

  EditAlbumScreen({required this.album});

  @override
  _EditAlbumScreenState createState() => _EditAlbumScreenState();
}

class _EditAlbumScreenState extends State<EditAlbumScreen> {
  late TextEditingController nameController;
  late TextEditingController artistController;
  late TextEditingController genreController;
  String? selectedMedium;
  bool? isDigital;
  String? selectedYear;
  List<String> years = [];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.album.name);
    artistController = TextEditingController(text: widget.album.artist);
    genreController = TextEditingController(text: widget.album.genre);
    selectedMedium = widget.album.medium;
    isDigital = widget.album.digital;
    selectedYear = widget.album.year;

    // Generating a list of years starting from the current year
    final currentYear = DateTime.now().year;
    years = List.generate(100, (index) => (currentYear - index).toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Album"),
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
                items: years.map<DropdownMenuItem<String>>((String value) {
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
                  if (selectedMedium == null || isDigital == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please select all fields")));
                  } else {
                    Album editedAlbum = Album(
                      id: widget.album.id,
                      name: nameController.text,
                      artist: artistController.text,
                      genre: genreController.text,
                      year: selectedYear!,
                      medium: selectedMedium!,
                      digital: isDigital!,
                      tracks: widget.album.tracks,
                    );
                    Navigator.pop(context, editedAlbum);
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
}
