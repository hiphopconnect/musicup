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
  List<TextEditingController> _trackTitleControllers = [];
  final ScrollController _scrollController =
      ScrollController(); // ScrollController hinzugefügt

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
    _scrollController.dispose(); // ScrollController dispose
    for (var controller in _trackTitleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Die WillPopScope-Logik, die den Nutzer fragt, ob er speichern möchte
  Future<bool> _onWillPop() async {
    bool shouldPop = await showDialog<bool>(
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
                  Navigator.pop(context, null); // No changes saved
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
        ) ??
        false;
    return shouldPop;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // WillPopScope eingefügt
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
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Album title"),
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
                  items: <String>['Yes', 'No']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    // ScrollController für ListView hinzugefügt
                    itemCount: tracks.length + 1,
                    itemBuilder: (context, index) {
                      if (index < tracks.length) {
                        return ListTile(
                          leading: Text('Track ${tracks[index].trackNumber}'),
                          title: TextFormField(
                            controller: _trackTitleControllers[index],
                            onChanged: (value) {
                              setState(() {
                                tracks[index].title = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Track Title', // Label bleibt oben
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

  void _addTrack() {
    setState(() {
      int trackNumber = tracks.length + 1;
      String formattedTrackNumber = trackNumber.toString().padLeft(2, '0');
      tracks.add(Track(title: "", trackNumber: formattedTrackNumber));
      _updateTrackControllers();
    });

    // Scroll nach unten zum neu hinzugefügten Track
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
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
}
