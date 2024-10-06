// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/screens/add_album_screen.dart';
import 'package:music_up/screens/edit_album_screen.dart';
import 'package:music_up/screens/settings_screen.dart'; // Importiere die SettingsScreen

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

  // Zustandsvariablen für die Medienanzahl
  int vinylCount = 0;
  int cdCount = 0;
  int cassetteCount = 0;
  int digitalCount = 0;
  int digitalYesCount = 0;
  int digitalNoCount = 0;

  // Variable für die Suchkategorie
  String _searchCategory = 'Album'; // Standardmäßig wird nach Album gesucht

  // Filtervariablen für Medium
  final Map<String, bool> _mediumFilters = {
    'Vinyl': true,
    'CD': true,
    'Cassette': true,
    'Digital': true,
  };

  // Filtervariable für Digital-Status
  String _digitalFilter = 'All'; // Optionen: 'Alle', 'Ja', 'Nein'

  // Variable für Sortierreihenfolge
  bool _isAscending = true; // true = A-Z, false = Z-A

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
        _sortAlbums(); // Albenliste sortieren
        _filteredAlbums = _albums;
        _isLoading = false;
        _updateCounts(); // Zähler aktualisieren
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error when loading the albums: $e')),
      );
    }
  }

  // Methode zum Sortieren der Albenliste
  void _sortAlbums() {
    _albums.sort((a, b) {
      int comparison = a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
      return _isAscending ? comparison : -comparison;
    });
  }

  // Methode zum Sortieren der gefilterten Albenliste
  void _sortFilteredAlbums() {
    _filteredAlbums.sort((a, b) {
      int comparison = a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
      return _isAscending ? comparison : -comparison;
    });
  }

  void _updateCounts() {
    // Wenn du die Zähler basierend auf den gefilterten Alben anzeigen möchtest, verwende _filteredAlbums
    // List<Album> albumsToCount = _filteredAlbums;
    // Wenn du die Zähler basierend auf allen Alben anzeigen möchtest, verwende _albums
    List<Album> albumsToCount = _albums;

    vinylCount = 0;
    cdCount = 0;
    cassetteCount = 0;
    digitalCount = 0;
    digitalYesCount = 0;
    digitalNoCount = 0;

    for (final album in albumsToCount) {
      switch (album.medium.toLowerCase()) {
        case 'vinyl':
          vinylCount++;
          break;
        case 'cd':
          cdCount++;
          break;
        case 'cassette':
          cassetteCount++;
          break;
        case 'digital':
          digitalCount++;
          break;
        default:
        // Unbekannte Medien ignorieren oder behandeln
          break;
      }

      if (album.digital) {
        digitalYesCount++;
      } else {
        digitalNoCount++;
      }
    }
  }

  void _filterAlbums() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredAlbums = _albums.where((album) {
        // Überprüfe Medium-Filter
        if (!_mediumFilters[album.medium]!) {
          return false;
        }

        // Überprüfe Digital-Status-Filter
        if (_digitalFilter != 'All') {
          if (_digitalFilter == 'Yes' && !album.digital) {
            return false;
          } else if (_digitalFilter == 'No' && album.digital) {
            return false;
          }
        }

        // Suche basierend auf der Suchkategorie
        switch (_searchCategory) {
          case 'Artist':
            return album.artist.toLowerCase().contains(query);
          case 'Song':
            return album.tracks.any((track) => track.title.toLowerCase().contains(query));
          case 'Album':
          default:
            return album.name.toLowerCase().contains(query);
        }
      }).toList();

      _sortFilteredAlbums(); // Gefilterte Liste sortieren
      _updateCounts(); // Zähler aktualisieren basierend auf gefilterten Alben
    });
  }

  // Methode zum Löschen eines Albums
  void _deleteAlbum(Album album) async {
    setState(() {
      _albums.removeWhere((a) => a.id == album.id);
      _sortAlbums(); // Albenliste sortieren
      _filterAlbums(); // Filter erneut anwenden
      _updateCounts(); // Zähler aktualisieren
    });
    await widget.jsonService.saveAlbums(_albums);
  }

  // Methode zum Umschalten der Sortierreihenfolge
  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      _sortAlbums();
      _sortFilteredAlbums();
    });

    // Zeige eine Snackbar mit der aktuellen Sortierreihenfolge
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isAscending ? 'Sort A-Z' : 'Sort Z-A'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Methode zum Zurücksetzen der Medium-Filter
  void _resetMediumFilters() {
    setState(() {
      // Setze alle Medium-Filter auf true
      _mediumFilters.updateAll((key, value) => true);
      // Wende die Filter an
      _filterAlbums();
    });

    // Zeige eine Snackbar, die das Zurücksetzen der Medium-Filter bestätigt
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medium filter was reset'),
        duration: Duration(seconds: 2),
      ),
    );
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
                  _sortAlbums(); // Albenliste sortieren
                  _filterAlbums(); // Filter erneut anwenden
                  _updateCounts(); // Zähler aktualisieren
                });
                widget.jsonService.saveAlbums(_albums);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort_by_alpha),
            tooltip: _isAscending ? 'Sort Z-A' : 'Sort A-Z',
            onPressed: _toggleSortOrder,
          ),
          // Entferne die Reset-Schaltfläche aus der AppBar
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
                  _loadAlbums(); // Alben nach dem Ändern der Einstellungen neu laden
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Anzeige der Anzahl der Medien und Digitalstatus
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  'Vinyl: $vinylCount  CD: $cdCount  Cassette: $cassetteCount  Digital: $digitalCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12.0),
                ),
                Text(
                  'Digital Yes: $digitalYesCount  Digital No: $digitalNoCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12.0),
                ),
              ],
            ),
          ),
          // Filterbereich
          ExpansionTile(
            title: const Text('Filter'),
            children: [
              // Medium-Filter und Reset-Schaltfläche in einer Zeile
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    // Expanded Wrap mit den FilterChips
                    Expanded(
                      child: Wrap(
                        spacing: 10.0,
                        children: _mediumFilters.keys.map((String key) {
                          return FilterChip(
                            label: Text(key),
                            selected: _mediumFilters[key]!,
                            onSelected: (bool value) {
                              setState(() {
                                _mediumFilters[key] = value;
                                _filterAlbums();
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    // Reset-Schaltfläche
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Medium filter reset',
                      onPressed: _resetMediumFilters,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Digital-Status-Filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Digital:'),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _digitalFilter,
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All')),
                        DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                        DropdownMenuItem(value: 'No', child: Text('No')),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _digitalFilter = newValue!;
                          _filterAlbums();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Suchbereich
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Dropdown für die Suchkategorie
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
                      _filterAlbums(); // Filter nach Änderung der Kategorie anwenden
                    });
                  },
                ),
                const SizedBox(width: 10), // Abstand zwischen Dropdown und Suchfeld
                // Suchfeld
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
                              int originalIndex = _albums.indexWhere((alb) => alb.id == editedAlbum.id);
                              if (originalIndex != -1) {
                                _albums[originalIndex] = editedAlbum;
                                _sortAlbums(); // Albenliste sortieren
                              }
                              _filterAlbums(); // Filter erneut anwenden
                              _updateCounts(); // Zähler aktualisieren
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
                                  leading: Text("Track ${track.getFormattedTrackNumber()}"),
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
