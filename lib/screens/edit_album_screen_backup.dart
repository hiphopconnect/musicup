// lib/screens/edit_album_screen.dart

import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/app_layout.dart';
import 'package:music_up/widgets/section_card.dart';

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

  // Copy of the album and tracks
  late Album editedAlbum;
  List<Track> tracks = [];
  List<TextEditingController> _trackTitleControllers = [];

  @override
  void initState() {
    super.initState();

    // Create a copy of the album
    editedAlbum = Album(
      id: widget.album.id,
      name: widget.album.name,
      artist: widget.album.artist,
      genre: widget.album.genre,
      year: widget.album.year,
      medium: widget.album.medium,
      digital: widget.album.digital,
      tracks: widget.album.tracks
          .map((track) => Track(
                title: track.title,
                trackNumber: track.trackNumber,
              ))
          .toList(),
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
    bool shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Save changes?'),
            content: const Text(
                'Do you want to save changes before leaving the page?'),
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

  void _saveAlbum() {
    if (selectedMedium == null || isDigital == null || selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select all fields")),
      );
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
        title: "Album bearbeiten",
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAlbum,
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
                          labelText: "Album-Name",
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
                        items:
                            years.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
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
                        items: <String>{
                          'Vinyl',
                          'CD',
                          'Cassette',
                          'Digital',
                          'Unknown'
                        }.map<DropdownMenuItem<String>>((String value) {
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

                // Tracks Sektion - IMPROVED with better sorting and drag-and-drop
                SectionCard(
                  title: "Tracks (${tracks.length})",
                  child: Column(
                    children: [
                      SizedBox(
                        height: 400,
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
                                      track.title = value;
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
                              // "Track hinzufügen" Button
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

  // IMPROVED: Add track with smart track number assignment
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
}
