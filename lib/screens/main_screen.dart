import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/screens/add_album_screen.dart';
import 'package:music_up/screens/edit_album_screen.dart';
import 'package:music_up/screens/settings_screen.dart';  // Importiere die SettingsScreen

class MainScreen extends StatefulWidget {
  final JsonService jsonService;

  const MainScreen({super.key, required this.jsonService});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  List<Album> _albums = [];
  List<Album> _filteredAlbums = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  // New variable for search category
  String _searchCategory = 'Album';  // Default search category is Album

  @override
  void initState() {
    super.initState();
    _loadAlbums();
    _searchController.addListener(_filterAlbums);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAlbums() async {
    try {
      List<Album> albums = await widget.jsonService.loadAlbums();

      if (!mounted) return;
      setState(() {
        _albums = albums;
        _filteredAlbums = albums;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading albums: $e')),
      );
    }
  }

  void _filterAlbums() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredAlbums = _albums.where((album) {
        switch (_searchCategory) {
          case 'Artist':
          // Search only by artist name
            return album.artist.toLowerCase().contains(query);
          case 'Song':
          // Search only by song titles
            return album.tracks.any((track) => track.title.toLowerCase().contains(query));
          case 'Album':
          default:
          // Default case: Search by album name
            return album.name.toLowerCase().contains(query);
        }
      }).toList();
    });
  }

  // Define the missing _deleteAlbum method
  void _deleteAlbum(Album album) async {
    setState(() {
      _albums.remove(album);
      _filteredAlbums.remove(album);
    });
    await widget.jsonService.saveAlbums(_albums);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MusicUp"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final newAlbum = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddAlbumScreen()),
              );
              if (newAlbum != null && newAlbum is Album) {
                setState(() {
                  _albums.add(newAlbum);
                  _filteredAlbums.add(newAlbum);
                });
                widget.jsonService.saveAlbums(_albums);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(jsonService: widget.jsonService),
                ),
              ).then((value) {
                if (value == true) {
                  _loadAlbums();  // Alben nach dem Ändern der Einstellungen neu laden
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Dropdown for search category
                DropdownButton<String>(
                  value: _searchCategory,
                  items: const [
                    DropdownMenuItem(value: 'Album', child: Text('Album')),
                    DropdownMenuItem(value: 'Artist', child: Text('Artist')),
                    DropdownMenuItem(value: 'Song', child: Text('Song')),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _searchCategory = newValue!;
                      _filterAlbums(); // Apply filter after changing category
                    });
                  },
                ),
                const SizedBox(width: 10),  // Add some space between dropdown and search field
                // Search field
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Search...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAlbums.isEmpty
                ? const Center(child: Text('No albums found'))
                : ListView.builder(
              itemCount: _filteredAlbums.length,
              itemBuilder: (context, index) {
                final album = _filteredAlbums[index];
                return ListTile(
                  title: Text(album.name),
                  subtitle: Text(album.artist),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final editedAlbum = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditAlbumScreen(
                                album: album,
                              ),
                            ),
                          );
                          if (editedAlbum != null && editedAlbum is Album) {
                            setState(() {
                              _albums[index] = editedAlbum;
                              _filteredAlbums[index] = editedAlbum;
                            });
                            await widget.jsonService.saveAlbums(_albums);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteAlbum(album);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        List<Track> sortedTracks = List.from(album.tracks)
                          ..sort((a, b) => int.parse(a.trackNumber).compareTo(int.parse(b.trackNumber)));
                        return AlertDialog(
                          title: Text(album.name),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: sortedTracks.map((track) {
                                return ListTile(
                                  leading: Text("Track ${track.trackNumber.padLeft(2, '0')}"),
                                  title: Text(track.title),
                                );
                              }).toList(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: const Text("Close"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
