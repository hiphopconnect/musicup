import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/screens/add_album_screen.dart';
import 'package:music_up/screens/edit_album_screen.dart';

class MainScreen extends StatefulWidget {
  final JsonService jsonService;

  MainScreen({required this.jsonService});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Album> _albums = [];
  List<Album> _filteredAlbums = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

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
      setState(() {
        _albums = albums;
        _filteredAlbums = albums;
        _isLoading = false;
      });
    } catch (e) {
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
        return album.name.toLowerCase().contains(query) ||
            album.artist.toLowerCase().contains(query);
      }).toList();
    });
  }

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
        title: Text("MusicUp"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final newAlbum = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddAlbumScreen()),
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
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredAlbums.isEmpty
                ? Center(child: Text('No albums found'))
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
                        icon: Icon(Icons.edit),
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
                            await widget.jsonService
                                .saveAlbums(_albums);
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
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
                        return AlertDialog(
                          title: Text(album.name),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: album.tracks.map((track) {
                              return ListTile(
                                title: Text(track.title),
                              );
                            }).toList(),
                          ),
                          actions: [
                            TextButton(
                              child: Text("Close"),
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
