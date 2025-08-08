// lib/screens/discogs_search_screen.dart

import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/discogs_service.dart';

class DiscogsSearchScreen extends StatefulWidget {
  final String? discogsToken;

  const DiscogsSearchScreen({super.key, required this.discogsToken});

  @override
  DiscogsSearchScreenState createState() => DiscogsSearchScreenState();
}

class DiscogsSearchScreenState extends State<DiscogsSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DiscogsSearchResult> _searchResults = [];
  bool _isLoading = false;
  bool _hasToken = false;

  late DiscogsService _discogsService;

  @override
  void initState() {
    super.initState();
    _hasToken = widget.discogsToken != null && widget.discogsToken!.isNotEmpty;
    if (_hasToken) {
      _discogsService = DiscogsService(widget.discogsToken!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchDiscogs() async {
    if (!_hasToken) {
      _showNoTokenMessage();
      return;
    }

    String query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter search terms')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<DiscogsSearchResult> results =
          await _discogsService.searchReleases(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: $e')),
      );
    }
  }

  void _showNoTokenMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please set your Discogs token in Settings first!'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // NEW: Show album details from search result
  void _showSearchResultDetails(DiscogsSearchResult result) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Load tracks
      List<Track> tracks = await _discogsService.getReleaseTracklist(result.id);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Show album details
      showDialog(
        context: context,
        builder: (BuildContext context) {
          List<Track> sortedTracks = List.from(tracks)
            ..sort((a, b) =>
                int.parse(a.trackNumber).compareTo(int.parse(b.trackNumber)));

          return AlertDialog(
            title: Text(result.title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Show album information
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Artist"),
                    subtitle: Text(result.artist),
                  ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text("Year"),
                    subtitle: Text(result.year),
                  ),
                  ListTile(
                    leading: const Icon(Icons.album),
                    title: const Text("Format"),
                    subtitle: Text(result.format),
                  ),
                  if (result.genre.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.music_note),
                      title: const Text("Genre"),
                      subtitle: Text(result.genre),
                    ),
                  if (sortedTracks.isNotEmpty) ...[
                    const Divider(),
                    Text(
                      "Tracks (${sortedTracks.length})",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Show tracks
                    ...sortedTracks.map((track) {
                      return ListTile(
                        leading: Text(
                          "Track ${track.getFormattedTrackNumber()}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        title: Text(track.title),
                        dense: true,
                      );
                    }),
                  ] else ...[
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text("No tracks available"),
                      subtitle:
                          Text("This release has no tracklist information"),
                    ),
                  ],
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
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load album details: $e')),
      );
    }
  }

  // Show confirmation dialog for adding to collection
  Future<void> _showAddToCollectionDialog(DiscogsSearchResult result) async {
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
                  Text('Adding: "${result.title}" by ${result.artist}'),
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
                    await _addToCollection(result, selectedMedium, isDigital);
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

  // Convert DiscogsSearchResult to Album with tracks
  Future<Album> _convertToAlbumWithTracks(
      DiscogsSearchResult result, String medium, bool digital) async {
    List<Track> tracks = [];

    // Load tracks from Discogs automatically
    try {
      tracks = await _discogsService.getReleaseTracklist(result.id);
    } catch (e) {
      print('Failed to load tracks: $e');
      // Continue without tracks if loading fails
    }

    return Album(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: result.title,
      artist: result.artist,
      genre: result.genre,
      year: result.year,
      medium: medium,
      // User selected medium
      digital: digital,
      // User selected digital status
      tracks: tracks, // Automatically loaded tracks
    );
  }

  // Add to collection with confirmation dialog
  Future<void> _addToCollection(
      DiscogsSearchResult result, String medium, bool digital) async {
    try {
      Album newAlbum = await _convertToAlbumWithTracks(result, medium, digital);

      if (!mounted) return;
      Navigator.pop(context, newAlbum);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Added "${result.title}" to collection with ${newAlbum.tracks.length} tracks!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to collection: $e')),
      );
    }
  }

  // Add to wantlist with tracks
  Future<void> _addToWantlist(DiscogsSearchResult result) async {
    if (!_hasToken) {
      _showNoTokenMessage();
      return;
    }

    try {
      // Add to Discogs wantlist
      await _discogsService.addToWantlist(result.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added "${result.title}" to Discogs wantlist!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to wantlist: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Discogs'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // Token Status Info
          if (!_hasToken)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              color: Colors.red[100],
              child: const Text(
                '⚠️ No Discogs token configured. Please set it in Settings.',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

          // Search Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search for artist, album, or song...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _searchDiscogs(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _hasToken ? _searchDiscogs : null,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),

          // Search Results
          Expanded(
            child: _searchResults.isEmpty && !_isLoading
                ? const Center(
                    child: Text(
                      'No results. Try searching for an artist or album.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          leading: result.imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    result.imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.album),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.album),
                                ),
                          title: Text(
                            result.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Artist: ${result.artist}'),
                              Text('Year: ${result.year}'),
                              Text('Format: ${result.format}'),
                              if (result.genre.isNotEmpty)
                                Text('Genre: ${result.genre}'),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Add to Collection Button
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                tooltip: 'Add to Collection',
                                onPressed: () =>
                                    _showAddToCollectionDialog(result),
                              ),
                              // Add to Wantlist Button
                              IconButton(
                                icon: const Icon(Icons.favorite_border),
                                tooltip: 'Add to Wantlist',
                                onPressed: _hasToken
                                    ? () => _addToWantlist(result)
                                    : null,
                              ),
                            ],
                          ),
                          // NEW: Tap to show details
                          onTap: () => _showSearchResultDetails(result),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// CORRECTED DiscogsSearchResult class - Fixed artist mapping!
class DiscogsSearchResult {
  final String id;
  final String title;
  final String artist;
  final String genre;
  final String year;
  final String format;
  final String imageUrl;

  DiscogsSearchResult({
    required this.id,
    required this.title,
    required this.artist,
    required this.genre,
    required this.year,
    required this.format,
    required this.imageUrl,
  });

  factory DiscogsSearchResult.fromJson(Map<String, dynamic> json) {
    // FIXED: Correct artist mapping
    String artist = 'Unknown Artist';

    // Try to get artist from multiple possible locations
    if (json.containsKey('artist') && json['artist'] != null) {
      artist = json['artist'].toString();
    } else if (json.containsKey('artists') && json['artists'] is List) {
      final List artists = json['artists'];
      if (artists.isNotEmpty && artists[0] is String) {
        artist = artists[0].toString();
      }
    }

    return DiscogsSearchResult(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unknown Title',
      artist: artist,
      // FIXED!
      genre: (json['genre'] is List && json['genre'].isNotEmpty)
          ? json['genre'][0].toString()
          : json['genre']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      format: (json['format'] is List && json['format'].isNotEmpty)
          ? json['format'][0].toString()
          : json['format']?.toString() ?? 'Unknown',
      imageUrl: json['thumb']?.toString() ?? '',
    );
  }
}
