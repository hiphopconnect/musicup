import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/discogs_service_unified.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/services/logger_service.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/app_layout.dart';
import 'package:music_up/widgets/search_bar_widget.dart';
import 'package:music_up/widgets/section_card.dart';
import 'package:music_up/widgets/status_banner.dart';

class DiscogsSearchScreen extends StatefulWidget {
  final String? discogsToken; // nicht mehr genutzt (Personal Token entfernt)
  final JsonService jsonService;

  const DiscogsSearchScreen({
    super.key,
    required this.discogsToken,
    required this.jsonService,
  });

  @override
  DiscogsSearchScreenState createState() => DiscogsSearchScreenState();
}

class DiscogsSearchScreenState extends State<DiscogsSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DiscogsSearchResult> _searchResults = [];
  bool _isLoading = false;
  bool _hasAuth = false;

  DiscogsServiceUnified? _discogsService;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    _discogsService = DiscogsServiceUnified(widget.jsonService.configManager);
    setState(() {
      _hasAuth = _discogsService!.hasAuth; // nur OAuth
    });

  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchDiscogs() async {
    if (_discogsService == null || !_discogsService!.hasAuth) {
      _showNoTokenMessage();
      return;
    }

    final query = _searchController.text.trim();
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
      final rawResults = await _discogsService!.searchReleases(query);
      final results =
          rawResults.map((json) => DiscogsSearchResult.fromJson(json)).toList();
      LoggerService.data('Search completed', results.length, 'results');

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.error('Discogs search', e, query);
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
        content: Text('Bitte OAuth in den Einstellungen einrichten.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSearchResultDetails(DiscogsSearchResult result) async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final tracks = await _discogsService!.getReleaseTracklist(result.id);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      showDialog(
        context: context,
        builder: (BuildContext context) {
          final sortedTracks = List<Track>.from(tracks)
            ..sort((a, b) => a.compareTo(b));

          return AlertDialog(
            title: Text(result.title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  const Divider(),
                  if (sortedTracks.isEmpty)
                    const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text("No tracks available"),
                      subtitle:
                          Text("This release has no tracklist information"),
                    )
                  else
                    ...sortedTracks.map(
                      (track) => ListTile(
                        leading: Text(
                          "Track ${track.getFormattedTrackNumber()}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        title: Text(track.title),
                        dense: true,
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Close"),
                onPressed: () => Navigator.of(context).pop(),
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
                  const SizedBox(height: DS.md),
                  DropdownButtonFormField<String>(
                    value: selectedMedium,
                    decoration: const InputDecoration(
                      labelText: 'Which format do you have?',
                      border: OutlineInputBorder(),
                    ),
                    items: const ['Vinyl', 'CD', 'Cassette', 'Digital']
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedMedium = newValue ?? 'Vinyl';
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Digital Available'),
                    subtitle: const Text('Do you also have it digitally?'),
                    value: isDigital,
                    onChanged: (value) => setState(() => isDigital = value),
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

  Future<Album> _convertToAlbumWithTracks(
      DiscogsSearchResult result, String medium, bool digital) async {
    List<Track> tracks = [];

    try {
      tracks = await _discogsService!.getReleaseTracklist(result.id);
    } catch (e) {
      LoggerService.error('Track loading for collection', e, result.title);
    }

    return Album(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: result.title,
      artist: result.artist,
      genre: result.genre,
      year: result.year,
      medium: medium,
      digital: digital,
      tracks: tracks,
    );
  }

  Future<void> _addToCollection(
      DiscogsSearchResult result, String medium, bool digital) async {
    try {
      final newAlbum = await _convertToAlbumWithTracks(result, medium, digital);
      if (!mounted) return;
      Navigator.pop(context, newAlbum);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Added "${result.title}" to collection with ${newAlbum.tracks.length} tracks!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to collection: $e')),
      );
    }
  }

  Future<void> _addToWantlist(DiscogsSearchResult result) async {
    if (_discogsService == null || !_discogsService!.hasWriteAccess) {
      _showOAuthNeededDialog(result);
      return;
    }

    try {

      final tokenValid = await _discogsService!.testAuthentication();
      if (!tokenValid) {
        throw Exception('OAuth Token ungültig. Bitte erneut authentifizieren.');
      }

      await _discogsService!.addToWantlist(result.id);

      try {
        final current = await widget.jsonService.loadWantlist();
        final exists = current.any((a) =>
            a.name.toLowerCase() == result.title.toLowerCase() &&
            a.artist.toLowerCase() == result.artist.toLowerCase());

        if (!exists) {
          current.add(Album(
            id: 'want_rel_${result.id}',
            name: result.title,
            artist: result.artist,
            genre: result.genre,
            year: result.year,
            medium: result.format,
            digital: false,
            tracks: const [],
          ));
          await widget.jsonService.saveWantlist(current);
          LoggerService.success('Added to wantlist', result.title);
        }
      } catch (e) {
        LoggerService.error('Local wantlist save', e, result.title);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('"${result.title}" zur Discogs-Wantlist hinzugefügt!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      if (e.toString().contains('403') ||
          e.toString().contains('Schreibzugriff') ||
          e.toString().contains('Owner-Authentifizierung')) {
        _showOAuthNeededDialog(result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showOAuthNeededDialog(DiscogsSearchResult result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('OAuth benötigt'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Für das Hinzufügen zur Wantlist ist OAuth erforderlich.'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Lokal hinzufügen'),
              onPressed: () {
                Navigator.of(context).pop();
                _addToLocalWantlist(result);
              },
            ),
            ElevatedButton(
              child: const Text('OAuth einrichten'),
              onPressed: () {
                Navigator.of(context).pop();
                _goToOAuthSetup();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addToLocalWantlist(DiscogsSearchResult result) async {
    final album = Album(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      name: result.title,
      artist: result.artist,
      genre: result.genre,
      year: result.year,
      medium: result.format,
      digital: false,
      tracks: [],
    );

    try {
      final current = await widget.jsonService.loadWantlist();
      final exists = current.any((a) =>
          a.name.toLowerCase() == album.name.toLowerCase() &&
          a.artist.toLowerCase() == album.artist.toLowerCase());

      if (!exists) {
        current.add(album);
        await widget.jsonService.saveWantlist(current);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '📱 "${result.title}" ${exists ? "war schon in der lokalen Wantlist" : "zur lokalen Wantlist hinzugefügt"}'),
          backgroundColor: exists ? Colors.blueGrey : Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Konnte lokal nicht hinzufügen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _goToOAuthSetup() {
    Navigator.of(context).pushNamed('/settings');
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Discogs durchsuchen',
      appBarColor: Colors.orange,
      body: Column(
        children: [
          if (!_hasAuth)
            StatusBanner.warning(
              'OAuth nicht konfiguriert. Bitte in den Einstellungen einrichten.',
            ),
          SectionCard(
            title: 'Suche',
            child: SearchBarWidget(
              controller: _searchController,
              hintText: 'Nach Künstler, Album oder Song suchen...',
              onSearch: _searchDiscogs,
              enabled: _hasAuth,
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(DS.lg),
              child: CircularProgressIndicator(),
            ),
          Expanded(
            child: _searchResults.isEmpty && !_isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey),
                        SizedBox(height: DS.md),
                        Text(
                          'Keine Ergebnisse. Versuchen Sie nach einem Künstler oder Album zu suchen.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(DS.md),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: DS.xs),
                        child: ListTile(
                          leading: result.imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: DS.rSm,
                                  child: Image.network(
                                    result.imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: DS.rSm,
                                        ),
                                        child: const Icon(Icons.album),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: DS.rSm,
                                  ),
                                  child: const Icon(Icons.album),
                                ),
                          title: Text(
                            result.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Künstler: ${result.artist}'),
                              Text('Jahr: ${result.year}'),
                              Text('Format: ${result.format}'),
                              if (result.genre.isNotEmpty)
                                Text('Genre: ${result.genre}'),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                tooltip: 'Zur Sammlung hinzufügen',
                                onPressed: () =>
                                    _showAddToCollectionDialog(result),
                              ),
                              IconButton(
                                icon: const Icon(Icons.favorite_border),
                                tooltip: 'Zur Wantlist hinzufügen',
                                onPressed: () => _addToWantlist(result),
                              ),
                            ],
                          ),
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
    String artist = 'Unknown Artist';
    String title = json['title']?.toString() ?? 'Unknown Title';

    // Try to get artist from various fields
    if (json.containsKey('artist') && json['artist'] != null) {
      artist = json['artist'].toString();
    } else if (json.containsKey('artists') && json['artists'] is List) {
      final List artists = json['artists'];
      if (artists.isNotEmpty && artists[0] is String) {
        artist = artists[0].toString();
      }
    }

    // If artist is still unknown, try to parse from title "Artist - Album"
    if (artist == 'Unknown Artist' && title.contains(' - ')) {
      final parts = title.split(' - ');
      if (parts.length >= 2) {
        artist = parts[0].trim();
        title = parts.sublist(1).join(' - ').trim();
      }
    }

    return DiscogsSearchResult(
      id: json['id']?.toString() ?? '',
      title: title,
      artist: artist,
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
