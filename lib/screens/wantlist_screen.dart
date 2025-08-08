// lib/screens/wantlist_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:music_up/models/album_model.dart';
import 'package:music_up/screens/add_wanted_album_screen.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/discogs_service.dart';
import 'package:music_up/services/json_service.dart';

class WantlistScreen extends StatefulWidget {
  final ConfigManager configManager;

  const WantlistScreen({super.key, required this.configManager});

  @override
  WantlistScreenState createState() => WantlistScreenState();
}

class WantlistScreenState extends State<WantlistScreen> {
  List<Album> _wantedAlbums = [];
  List<Album> _filteredWantlistAlbums = [];
  bool _isLoading = true;
  bool _hasDiscogsToken = false;
  DiscogsService? _discogsService;
  late JsonService _jsonService;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _jsonService = JsonService(widget.configManager);
    _searchController.addListener(_filterWantlist);
    _initializeService();
    _loadWantlist();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeService() {
    _hasDiscogsToken = widget.configManager.hasDiscogsToken();

    if (_hasDiscogsToken) {
      String token = widget.configManager.getDiscogsToken();
      _discogsService = DiscogsService(token);
    }
  }

  // ✅ DEBUG TOKEN COMPARISON FUNCTION
  Future<void> _debugCompareTokens() async {
    print('🔍 ====== TOKEN COMPARISON DEBUG ====== 🔍');

    // 1. Check welcher Token in der App verwendet wird
    String appToken = widget.configManager.getDiscogsToken();
    print('🔍 APP TOKEN: ${appToken.substring(0, 10)}...');
    print('🔍 APP TOKEN FULL: $appToken');

    // 2. Teste verschiedene URLs direkt
    final urls = [
      'https://api.discogs.com/oauth/identity',
      'https://api.discogs.com/users/me/wants',
      'https://api.discogs.com/users/me/wants?page=1&per_page=100',
      'https://api.discogs.com/users/hiphopconnected/wants?page=1&per_page=100',
    ];

    for (String url in urls) {
      try {
        print('🔍 TESTING: $url');

        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Discogs token=$appToken',
            'User-Agent':
                'MusicUp/1.3.1 +https://github.com/hiphopconnect/musicup',
          },
        );

        print('✅ STATUS: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data.containsKey('wants')) {
            final wants = data['wants'] ?? [];
            print('🎯 FOUND ${wants.length} WANTS!');
            if (wants.isNotEmpty) {
              print(
                  '🎵 FIRST WANT: ${wants[0]['basic_information']?['title']}');
            }
          } else if (data.containsKey('username')) {
            print('👤 USER: ${data['username']}');
          }
        } else {
          print('❌ ERROR BODY: ${response.body}');
        }
      } catch (e) {
        print('❌ EXCEPTION: $e');
      }

      await Future.delayed(const Duration(seconds: 1)); // Rate limit
    }

    print('🔍 ====== TOKEN COMPARISON END ====== 🔍');
  }

  // ✅ Load-Funktion MIT DEBUG für Discogs
  Future<void> _loadWantlist() async {
    setState(() => _isLoading = true);

    try {
      List<Album> albums = [];

      // 1. Lade offline Wantlist ZUERST
      List<Album> offlineWantlist = await _jsonService.loadWantlist();

      // 2. Lade Discogs Wantlist wenn Token verfügbar
      if (_hasDiscogsToken && _discogsService != null) {
        try {
          // ✅ TESTE TOKEN ZUERST
          print('🔍 DEBUG: Testing Discogs token...');
          bool tokenValid = await _discogsService!.testToken();
          print('🔍 DEBUG: Token valid: $tokenValid');

          if (!tokenValid) {
            throw Exception(
                'Invalid Discogs token. Please check token in Settings.');
          }

          // ✅ LADE USER INFO
          var userInfo = await _discogsService!.getUserInfo();
          print('🔍 DEBUG: User info: ${userInfo?['username']}');

          print('🔍 DEBUG: Loading Discogs wantlist...');
          List<Album> discogsWantlist =
              await _discogsService!.getWantlistAsAlbums();
          print(
              '✅ SUCCESS: Loaded ${discogsWantlist.length} Discogs wantlist items');

          // 3. Merge Lists und entferne Duplikate
          Map<String, Album> albumMap = {};

          // Erst offline Items hinzufügen
          for (Album album in offlineWantlist) {
            String key =
                '${album.artist.toLowerCase()}_${album.name.toLowerCase()}';
            albumMap[key] = album;
          }

          // Dann Discogs Items hinzufügen/überschreiben
          for (Album album in discogsWantlist) {
            String key =
                '${album.artist.toLowerCase()}_${album.name.toLowerCase()}';
            albumMap[key] = album; // Discogs-Daten haben Vorrang
          }

          albums = albumMap.values.toList();

          // 4. Speichere merged Wantlist offline
          await _jsonService.saveWantlist(albums);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '✅ Loaded ${discogsWantlist.length} items from Discogs + ${offlineWantlist.length} offline items'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          print('❌ ERROR loading Discogs wantlist: $e');

          // Bei Discogs-Fehler: Verwende nur offline Wantlist
          albums = offlineWantlist;

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '⚠️ Discogs error: $e\nUsing offline wantlist (${albums.length} items)'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } else {
        // 5. Kein Token: Verwende nur offline Wantlist
        albums = offlineWantlist;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'ℹ️ Configure Discogs token in Settings to sync online wantlist\nShowing ${albums.length} offline items'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }

      // 6. Update UI
      if (mounted) {
        setState(() {
          _wantedAlbums = albums;
          _filteredWantlistAlbums = albums;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ ERROR in _loadWantlist: $e');

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error loading wantlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Filter-Funktion für Wantlist-Suche
  void _filterWantlist() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredWantlistAlbums = _wantedAlbums.where((album) {
        return album.name.toLowerCase().contains(query) ||
            album.artist.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Refresh-Funktion
  Future<void> _refreshWantlist() async {
    await _loadWantlist();
  }

  // Show confirmation dialog for adding wantlist item to collection
  Future<void> _showAddToCollectionDialog(Album wantlistAlbum) async {
    String selectedMedium = 'Vinyl';
    bool isDigital = false;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add to Collection'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Adding: "${wantlistAlbum.name}" by ${wantlistAlbum.artist}'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedMedium,
                    decoration: const InputDecoration(
                      labelText: 'Which format do you have?',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Vinyl', 'CD', 'Cassette', 'Digital']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMedium = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Digital Available'),
                    subtitle: const Text('Do you also have it digitally?'),
                    value: isDigital,
                    onChanged: (bool value) {
                      setState(() {
                        isDigital = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await _addToCollectionAndRemoveFromWantlist(
                        wantlistAlbum, selectedMedium, isDigital);
                  },
                  child: const Text('Add to Collection'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Add to collection and remove from wantlist
  Future<void> _addToCollectionAndRemoveFromWantlist(
      Album wantlistAlbum, String medium, bool digital) async {
    try {
      // Create new album for collection with user's format preferences
      Album collectionAlbum = Album(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: wantlistAlbum.name,
        artist: wantlistAlbum.artist,
        genre: wantlistAlbum.genre,
        year: wantlistAlbum.year,
        medium: medium,
        digital: digital,
        tracks: wantlistAlbum.tracks,
      );

      // 1. Add to collection
      List<Album> currentCollection = await _jsonService.loadAlbums();
      currentCollection.add(collectionAlbum);
      await _jsonService.saveAlbums(currentCollection);

      // 2. Remove from wantlist
      setState(() {
        _wantedAlbums.removeWhere((album) =>
            album.name.toLowerCase() == wantlistAlbum.name.toLowerCase() &&
            album.artist.toLowerCase() == wantlistAlbum.artist.toLowerCase());
        _filteredWantlistAlbums = _wantedAlbums;
      });

      // 3. Save updated wantlist
      await _jsonService.saveWantlist(_wantedAlbums);

      // 4. Remove from Discogs wantlist (if connected)
      if (_hasDiscogsToken && _discogsService != null) {
        try {
          // TODO: Implement Discogs wantlist removal if API supports it
          // await _discogsService!.removeFromWantlist(wantlistAlbum);
        } catch (e) {
          // Silent error for Discogs removal
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('✅ "${wantlistAlbum.name}" added to collection as $medium'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error adding to collection: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Delete from wantlist
  Future<void> _deleteFromWantlist(Album album) async {
    try {
      setState(() {
        _wantedAlbums.removeWhere((a) => a.id == album.id);
        _filteredWantlistAlbums = _wantedAlbums;
      });

      await _jsonService.saveWantlist(_wantedAlbums);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Removed "${album.name}" from wantlist'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error removing from wantlist: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Wantlist'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading wantlist...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Wantlist (${_filteredWantlistAlbums.length})'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refreshWantlist,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Wantlist',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search wantlist...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Wantlist Items
          Expanded(
            child: _filteredWantlistAlbums.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.favorite_border,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No wantlist items found'),
                        const SizedBox(height: 8),
                        Text(
                          _hasDiscogsToken
                              ? 'Add items to your Discogs wantlist or configure token in Settings'
                              : 'Configure Discogs token in Settings to sync your wantlist',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredWantlistAlbums.length,
                    itemBuilder: (context, index) {
                      final album = _filteredWantlistAlbums[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(Icons.favorite, color: Colors.white),
                          ),
                          title: Text(
                            album.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(album.artist),
                              if (album.year.isNotEmpty)
                                Text('${album.year} • ${album.genre}'),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              switch (value) {
                                case 'add_collection':
                                  await _showAddToCollectionDialog(album);
                                  break;
                                case 'delete':
                                  await _deleteFromWantlist(album);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem<String>(
                                value: 'add_collection',
                                child: ListTile(
                                  leading: Icon(Icons.library_add),
                                  title: Text('Add to Collection'),
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: ListTile(
                                  leading:
                                      Icon(Icons.delete, color: Colors.red),
                                  title: Text('Remove from Wantlist'),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                List<Track> sortedTracks =
                                    List.from(album.tracks)
                                      ..sort((a, b) {
                                        // Sichere Konvertierung zu Integer
                                        int trackA =
                                            int.tryParse(a.trackNumber) ?? 0;
                                        int trackB =
                                            int.tryParse(b.trackNumber) ?? 0;
                                        return trackA.compareTo(trackB);
                                      });
                                return AlertDialog(
                                  title: Text(album.name),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Show album information
                                        ListTile(
                                          leading: const Icon(Icons.person),
                                          title: const Text("Artist"),
                                          subtitle: Text(album.artist),
                                        ),
                                        ListTile(
                                          leading:
                                              const Icon(Icons.calendar_today),
                                          title: const Text("Year"),
                                          subtitle: Text(album.year),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.album),
                                          title: const Text("Medium"),
                                          subtitle: Text(album.medium),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.music_note),
                                          title: const Text("Genre"),
                                          subtitle: Text(album.genre),
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
                                            title: Text("No tracks available"),
                                            subtitle: Text(
                                                "Tracks will be loaded from Discogs"),
                                          ),
                                        ...sortedTracks.map((track) {
                                          return ListTile(
                                            leading: Text(
                                                "Track ${track.getFormattedTrackNumber()}"),
                                            title: Text(track.title),
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // ✅ KORREKT PLATZIERTE DEBUG BUTTONS
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // ✅ DEBUG BUTTON
          if (_hasDiscogsToken && _discogsService != null)
            FloatingActionButton.small(
              heroTag: "debug",
              onPressed: () async {
                print('🔥 MANUAL DEBUG BUTTON PRESSED!');
                await _debugCompareTokens(); // ← NEUE FUNKTION!

                try {
                  final albums = await _discogsService!.getWantlistAsAlbums();
                  print('🎯 MANUAL TEST RESULT: ${albums.length} albums');

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Debug: Found ${albums.length} albums'),
                      backgroundColor: Colors.purple,
                    ),
                  );
                } catch (e) {
                  print('❌ MANUAL TEST ERROR: $e');
                }
              },
              backgroundColor: Colors.purple,
              child: const Icon(Icons.bug_report),
            ),
          const SizedBox(height: 8),

          // Original Add Button
          FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddWantedAlbumScreen(
                    jsonService: _jsonService,
                    configManager: widget.configManager,
                  ),
                ),
              );

              if (result == true) {
                await _refreshWantlist();
              }
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
