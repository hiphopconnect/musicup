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

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.album.name);
    artistController = TextEditingController(text: widget.album.artist);
    genreController = TextEditingController(text: widget.album.genre);
    selectedMedium = widget.album.medium;
    isDigital = widget.album.digital;
    selectedYear = widget.album.year;

    final currentYear = DateTime.now().year;
    years = List.generate(100, (index) => (currentYear - index).toString());

    // Sort tracks by trackNumber to ensure correct order
    widget.album.tracks.sort((a, b) => int.parse(a.trackNumber).compareTo(int.parse(b.trackNumber)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                items: <String>{'Vinyl', 'CD', 'Cassette', 'Digital', 'Unknown'}  // Ensure unique values
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
              // Add the "Add Track" button like in AddAlbumScreen
              ElevatedButton(
                onPressed: () {
                  _addTrack();
                },
                child: const Text("Add Track"),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.album.tracks.length,
                  itemBuilder: (context, index) {
                    final track = widget.album.tracks[index];
                    return ListTile(
                      leading: Text("Track ${track.trackNumber}"),
                      title: TextFormField(
                        initialValue: track.title,
                        onChanged: (value) {
                          setState(() {
                            track.title = value;
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
                            widget.album.tracks.removeAt(index);
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
                child: const Text("Save Album"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to add a track
  void _addTrack() {
    setState(() {
      int trackNumber = widget.album.tracks.length + 1;
      String formattedTrackNumber = trackNumber.toString().padLeft(2, '0');
      widget.album.tracks.add(Track(title: "Track $formattedTrackNumber", trackNumber: formattedTrackNumber));
    });
  }
}
