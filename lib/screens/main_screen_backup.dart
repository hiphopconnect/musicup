import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/screens/add_album_screen.dart';
import 'package:music_up/screens/discogs_search_screen.dart';
import 'package:music_up/screens/edit_album_screen.dart';
import 'package:music_up/screens/settings_screen.dart';
import 'package:music_up/screens/wantlist_screen.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/widgets/app_layout.dart';
import 'package:music_up/widgets/counter_bar.dart';

class MainScreen extends StatefulWidget {
  final JsonService jsonService;
  final Function(ThemeMode)? onThemeChanged;

  const MainScreen({super.key, required this.jsonService, this.onThemeChanged});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  List<Album> _albums = [];
  List<Album> _filteredAlbums = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  // State variables for media count
  int vinylCount = 0;
  int cdCount = 0;
  int cassetteCount = 0;
  int digitalCount = 0;
  int digitalYesCount = 0;
  int digitalNoCount = 0;

  // Variable for search category
  String _searchCategory = 'Album'; // Default search by album

  // Filter variables for medium
  final Map<String, bool> _mediumFilters = {
    'Vinyl': true,
    'CD': true,
    'Cassette': true,
    'Digital': true,
  };

  // Filter variable for digital status
  String _digitalFilter = 'All'; // Options: 'All', 'Yes', 'No'

  // Variable for sort order
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
        _albums = albums.isNotEmpty ? albums : [];
        _sortAlbums(); // Sort album list
        _filteredAlbums = _albums;
        _isLoading = false;
        _updateCounts(); // Update counters
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

  // Method for sorting the album list
  void _sortAlbums() {
    _albums.sort((a, b) {
      int comparison = a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
      return _isAscending ? comparison : -comparison;
    });
  }

  // Method for sorting the filtered album list
  void _sortFilteredAlbums() {
    _filteredAlbums.sort((a, b) {
      int comparison = a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
      return _isAscending ? comparison : -comparison;
    });
  }

  void _updateCounts() {
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
        // Check medium filter
        if (!_mediumFilters[album.medium]!) {
          return false;
        }

        // Check digital status filter
        if (_digitalFilter != 'All') {
          if (_digitalFilter == 'Yes' && !album.digital) {
            return false;
          } else if (_digitalFilter == 'No' && album.digital) {
            return false;
          }
        }

        // Search based on search category
        switch (_searchCategory) {
          case 'Artist':
            return album.artist.toLowerCase().contains(query);
          case 'Song':
            return album.tracks
                .any((track) => track.title.toLowerCase().contains(query));
          case 'Album':
          default:
            return album.name.toLowerCase().contains(query);
        }
      }).toList();

      _sortFilteredAlbums(); // Sort filtered list
      _updateCounts(); // Update counters based on filtered albums
    });
  }

  // Method for deleting an album
  void _deleteAlbum(Album album) async {
    setState(() {
      _albums.removeWhere((a) => a.id == album.id);
      _sortAlbums(); // Sort album list
      _filterAlbums(); // Reapply filters
      _updateCounts(); // Update counters
    });
    await widget.jsonService.saveAlbums(_albums);
  }

  // Method for toggling sort order
  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      _sortAlbums();
      _sortFilteredAlbums();
    });

    // Show snackbar with current sort order
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isAscending ? 'Sort A-Z' : 'Sort Z-A'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Method for resetting medium filters
  void _resetMediumFilters() {
    setState(() {
      // Set all medium filters to true
      _mediumFilters.updateAll((key, value) => true);
      // Apply filters
      _filterAlbums();
    });

    // Show snackbar confirming medium filter reset
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medium filter was reset'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Open wantlist and reload collection after returning
  void _openWantlist() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WantlistScreen(
            configManager: widget.jsonService.configManager,
          ),
        ),
      );

      // WICHTIG: Egal was zurückkommt (true, Album, etc.) => Sammlung neu laden
      if (!mounted) return;
      if (result != null) {
        _loadAlbums();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening Wantlist: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Discogs-Suche: nur noch mit OAuth
  void _openDiscogsSearch() async {
    final cm = widget.jsonService.configManager;
    if (!cm.hasDiscogsOAuthTokens()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte zuerst OAuth in den Einstellungen abschließen.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiscogsSearchScreen(
            discogsToken: null, // Personal Token wird nicht mehr genutzt
            jsonService: widget.jsonService,
          ),
        ),
      );

      if (result != null && result is Album) {
        setState(() {
          _albums.add(result);
          _sortAlbums();
          _filterAlbums();
          _updateCounts();
        });
        await widget.jsonService.saveAlbums(_albums);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added "${result.name}" to collection!')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening Discogs Search: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: "MusicUp",
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
                _sortAlbums(); // Sort album list
                _filterAlbums(); // Reapply filters
                _updateCounts(); // Update counters
              });
              widget.jsonService.saveAlbums(_albums);
            }
          },
        ),
        // FUNCTIONAL: Wantlist Button
        IconButton(
          icon: const Icon(Icons.favorite_border),
          tooltip: 'Wantlist',
          onPressed: _openWantlist,
        ),
        // FUNCTIONAL: Discogs Search Button
        IconButton(
          icon: const Icon(Icons.search_outlined),
          tooltip: 'Search Discogs',
          onPressed: _openDiscogsSearch,
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(
                  jsonService: widget.jsonService,
                  onThemeChanged: widget.onThemeChanged,
                ),
              ),
            );

            // IMMER neu laden – unabhängig vom Rückgabewert.
            await widget.jsonService.configManager.loadConfig();
            _loadAlbums();
          },
        ),
      ],
      body: Column(
        children: [
          // Einheitliche Zählerleiste
          CounterBar(
            vinyl: vinylCount,
            cd: cdCount,
            cassette: cassetteCount,
            digitalMedium: digitalCount,
            // Medium == "Digital"
            digitalYes: digitalYesCount,
            // Flag digital == true
            digitalNo: digitalNoCount, // Flag digital == false
          ),
          // Filterbereich in wiederverwendbarer SectionCard
          ExpansionTile(
            title: const Text('Filter'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Medium filter and reset button in one row
                    Row(
                      children: [
                        // Expanded Wrap with FilterChips
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
                        // Reset button
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Medium filter reset',
                          onPressed: _resetMediumFilters,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Sort order control
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sort:'),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          icon: Icon(_isAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha),
                          label: Text(_isAscending ? 'A-Z' : 'Z-A'),
                          onPressed: _toggleSortOrder,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Digital status filter
                    Row(
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
                  ],
                ),
              ),
            ],
          ),

          // Search area
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
                      _filterAlbums(); // Apply filters after category change
                    });
                  },
                ),
                const SizedBox(width: 10),
                // Space between dropdown and search field
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
                                    if (editedAlbum != null &&
                                        editedAlbum is Album) {
                                      setState(() {
                                        int originalIndex = _albums.indexWhere(
                                            (alb) => alb.id == editedAlbum.id);
                                        if (originalIndex != -1) {
                                          _albums[originalIndex] = editedAlbum;
                                          _sortAlbums(); // Sort album list
                                        }
                                        _filterAlbums(); // Reapply filters
                                        _updateCounts(); // Update counters
                                      });
                                      await widget.jsonService
                                          .saveAlbums(_albums);
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
                                  // FIXED: Verwende sichere Track-Sortierung
                                  List<Track> sortedTracks =
                                      List.from(album.tracks)
                                        ..sort((a, b) => a.compareTo(b));

                                  return AlertDialog(
                                    title: Text(album.name),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Show album information
                                          ListTile(
                                            leading: const Icon(
                                                Icons.calendar_today),
                                            title: const Text("Year"),
                                            subtitle: Text(album.year),
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.album),
                                            title: const Text("Medium"),
                                            subtitle: Text(album.medium),
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.cloud),
                                            title: const Text("Digital"),
                                            subtitle: Text(
                                                album.digital ? "Yes" : "No"),
                                          ),
                                          const Divider(),
                                          // Show tracks
                                          if (sortedTracks.isEmpty)
                                            const ListTile(
                                              leading: Icon(Icons.info_outline),
                                              title:
                                                  Text("No tracks available"),
                                              subtitle: Text(
                                                  "This album has no tracklist"),
                                            )
                                          else
                                            ...sortedTracks.map((track) {
                                              return ListTile(
                                                leading: Text(
                                                  "Track ${track.getFormattedTrackNumber()}",
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                title: Text(track.title),
                                                dense: true,
                                              );
                                            }),
                                        ],
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
