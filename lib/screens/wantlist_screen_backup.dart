import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/screens/add_wanted_album_screen.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/discogs_service_unified.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/services/logger_service.dart';
import 'package:music_up/widgets/app_layout.dart';
import 'package:music_up/widgets/search_bar_widget.dart';
import 'package:music_up/widgets/section_card.dart';
import 'package:music_up/widgets/status_banner.dart';

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
  bool _hasDiscogsAuth = false;
  DiscogsServiceUnified? _discogsService;
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

  // Suchfilter für die Wunschliste (Listener in initState)
  void _filterWantlist() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filteredWantlistAlbums = _wantedAlbums.where((a) {
        return a.name.toLowerCase().contains(q) ||
            a.artist.toLowerCase().contains(q);
      }).toList();
    });
  }

  void _initializeService() {
    // Verwende DiscogsServiceUnified
    _discogsService = DiscogsServiceUnified(widget.configManager);
    _hasDiscogsAuth = _discogsService!.hasAuth;
  }

  // Pull-to-refresh bzw. AppBar-Refresh nutzt diese Methode
  Future<void> _refreshWantlist() async {
    await _loadWantlist();
  }

  Future<void> _loadWantlist() async {
    setState(() => _isLoading = true);
    try {
      final offline = await _jsonService.loadWantlist();
      List<Album> merged = List.of(offline);

      // Online-Sync nur, wenn OAuth vorhanden UND testToken==200
      if (_discogsService != null && _discogsService!.hasAuth) {
        try {
          final tokenValid = await _discogsService!.testAuthentication();

          if (tokenValid) {
            final online = await _discogsService!.getWantlist();

            // NEU: Online = Source of Truth
            merged = List.of(online);

            // Nur bei tatsächlicher Änderung persistieren
            bool listsEqualByIds(List<Album> a, List<Album> b) {
              if (a.length != b.length) return false;
              final sa = a.map((x) => x.id).toSet();
              final sb = b.map((x) => x.id).toSet();
              return sa.containsAll(sb) && sb.containsAll(sa);
            }

            if (!listsEqualByIds(offline, merged)) {
              LoggerService.data('Wantlist sync', merged.length, 'items saved');
              await _jsonService.saveWantlist(merged);
            }
          } else {
            LoggerService.warning('Wantlist sync', 'Auth invalid - using offline only');
          }
        } catch (e) {
          LoggerService.error('Wantlist sync', e);
          // Continue with offline data on error
        }
      } else {
      }

      if (!mounted) return;
      setState(() {
        _wantedAlbums = merged;
        _filteredWantlistAlbums = merged;
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.error('Wantlist load', e);
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Laden der Wunschliste: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _extractReleaseId(Album a) {
    const prefix = 'want_rel_';
    if (a.id.startsWith(prefix)) {
      return a.id.substring(prefix.length);
    }
    return null;
  }

  // Tracks nur bei Bedarf laden; nicht persistieren (Songs sind "nicht so wichtig")
  Future<List<Track>> _ensureTracksLoaded(Album album) async {
    if (album.tracks.isNotEmpty) return album.tracks;
    if (!_hasDiscogsAuth || _discogsService == null) return album.tracks;

    final releaseId = _extractReleaseId(album);
    if (releaseId == null || releaseId.isEmpty) return album.tracks;

    // Ladeindikator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final tracks = await _discogsService!.getReleaseTracklist(releaseId);
      if (!mounted) return album.tracks;

      setState(() {
        final i = _wantedAlbums.indexWhere((a) => a.id == album.id);
        if (i != -1) {
          _wantedAlbums[i] = _wantedAlbums[i].copyWith(tracks: tracks);
        }
        final j = _filteredWantlistAlbums.indexWhere((a) => a.id == album.id);
        if (j != -1) {
          _filteredWantlistAlbums[j] =
              _filteredWantlistAlbums[j].copyWith(tracks: tracks);
        }
      });

      return tracks;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Laden der Tracks: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return album.tracks;
    } finally {
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _showAddToCollectionDialog(Album wantlistAlbum) async {
    String selectedMedium = 'Vinyl';
    bool isDigital = false;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Zur Sammlung hinzufügen'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      'Hinzufügen: "${wantlistAlbum.name}" von ${wantlistAlbum.artist}'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedMedium,
                    decoration: const InputDecoration(
                      labelText: 'Welches Medium hast du?',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Vinyl', 'CD', 'Cassette', 'Digital']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => selectedMedium = v ?? 'Vinyl'),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Digital verfügbar'),
                    subtitle: const Text('Besitzt du es zusätzlich digital?'),
                    value: isDigital,
                    onChanged: (v) => setState(() => isDigital = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Abbrechen'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await _addToCollectionAndRemoveFromWantlist(
                      wantlistAlbum,
                      selectedMedium,
                      isDigital,
                    );
                  },
                  child: const Text('Hinzufügen'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addToCollectionAndRemoveFromWantlist(
      Album wantlistAlbum, String medium, bool digital) async {
    try {

      // 1) Tracks für dieses Release sicherstellen (jetzt laden, falls leer)
      List<Track> tracks =
          List.from(wantlistAlbum.tracks); // WICHTIG: Kopie erstellen
      final releaseId = _extractReleaseId(wantlistAlbum);


      // Tracks laden wenn leer und Release-ID vorhanden
      if (tracks.isEmpty &&
          _hasDiscogsAuth &&
          _discogsService != null &&
          releaseId != null &&
          releaseId.isNotEmpty) {
        try {
          tracks = await _discogsService!.getReleaseTracklist(releaseId);
        } catch (e) {
          LoggerService.error('Track loading', e, releaseId);
          tracks = [];
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Konnte Tracks nicht laden: $e'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }

      // 2) Album mit den KORREKT GELADENEN Tracks in die lokale Sammlung eintragen
      final collectionAlbum = Album(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: wantlistAlbum.name,
        artist: wantlistAlbum.artist,
        genre: wantlistAlbum.genre,
        year: wantlistAlbum.year,
        medium: medium,
        digital: digital,
        tracks: tracks, // FIXED: Verwende die geladenen tracks!
      );


      final current = await _jsonService.loadAlbums();
      current.add(collectionAlbum);
      await _jsonService.saveAlbums(current);

      LoggerService.success('Album added to collection', '${wantlistAlbum.name} with ${collectionAlbum.tracks.length} tracks');

      // 3) Bei Discogs aus Wantlist entfernen (falls möglich)
      bool discogsRemovalSuccessful = false;
      if (_hasDiscogsAuth &&
          _discogsService != null &&
          _discogsService!.hasWriteAccess &&
          releaseId != null &&
          releaseId.isNotEmpty) {
        try {
          await _discogsService!.removeFromWantlist(releaseId);
          discogsRemovalSuccessful = true;
        } catch (e) {
          LoggerService.error('Remove from Discogs wantlist', e, releaseId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Konnte bei Discogs nicht entfernen: $e (lokal entfernt)'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
      }

      // 4) Lokal aus Wantlist entfernen und persistieren
      setState(() {
        _wantedAlbums.removeWhere((a) =>
            a.name.toLowerCase() == wantlistAlbum.name.toLowerCase() &&
            a.artist.toLowerCase() == wantlistAlbum.artist.toLowerCase());
        _filteredWantlistAlbums = _wantedAlbums.where((a) {
          final q = _searchController.text.toLowerCase();
          return a.name.toLowerCase().contains(q) ||
              a.artist.toLowerCase().contains(q);
        }).toList();
      });
      await _jsonService.saveWantlist(_wantedAlbums);


      if (!mounted) return;

      final trackInfo = tracks.isEmpty ? '' : ' (${tracks.length} Tracks)';
      final discogsInfo =
          discogsRemovalSuccessful ? ' und aus Discogs-Wantlist entfernt' : '';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '"${wantlistAlbum.name}" als $medium hinzugefügt$trackInfo$discogsInfo'),
          backgroundColor: Colors.green,
        ),
      );

      // 5) Hauptliste informieren: Sammlung neu laden
      Navigator.of(context).pop(true);
    } catch (e) {
      LoggerService.error('Add to collection', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Hinzufügen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteFromWantlist(Album album) async {
    try {

      // Versuche zuerst bei Discogs zu löschen, wenn Release-ID bekannt
      final releaseId = _extractReleaseId(album);

      bool discogsRemovalSuccessful = false;
      if (_hasDiscogsAuth &&
          _discogsService != null &&
          _discogsService!.hasWriteAccess &&
          releaseId != null &&
          releaseId.isNotEmpty) {
        try {
          await _discogsService!.removeFromWantlist(releaseId);
          discogsRemovalSuccessful = true;
        } catch (e) {
          LoggerService.error('Remove from Discogs', e, releaseId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Entfernen bei Discogs fehlgeschlagen: $e - Wird trotzdem lokal entfernt'),
                backgroundColor: Colors.red,
              ),
            );
          }
          // Weiter mit lokaler Entfernung auch wenn Discogs fehlschlägt
        }
      } else {
      }

      // Lokal entfernen und speichern
      setState(() {
        _wantedAlbums.removeWhere((a) => a.id == album.id);
        _filteredWantlistAlbums = _wantedAlbums.where((a) {
          final q = _searchController.text.toLowerCase();
          return a.name.toLowerCase().contains(q) ||
              a.artist.toLowerCase().contains(q);
        }).toList();
      });
      await _jsonService.saveWantlist(_wantedAlbums);

      LoggerService.success('Removed from wantlist', album.name);

      if (!mounted) return;

      final discogsInfo = discogsRemovalSuccessful ? ' und aus Discogs' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('"${album.name}" aus Wunschliste$discogsInfo entfernt'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      LoggerService.error('Delete from wantlist', e, album.name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Entfernen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AppLayout(
        title: 'Wunschliste',
        appBarColor: Colors.green,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Wunschliste wird geladen...'),
            ],
          ),
        ),
      );
    }

    return AppLayout(
      title: 'Wunschliste (${_filteredWantlistAlbums.length})',
      appBarColor: Colors.green,
      actions: [
        IconButton(
          onPressed: _refreshWantlist,
          icon: const Icon(Icons.refresh),
          tooltip: 'Wunschliste aktualisieren',
        ),
      ],
      body: Column(
        children: [
          if (!_hasDiscogsAuth)
            StatusBanner.warning(
              'Bitte OAuth in den Einstellungen konfigurieren, um die Wunschliste zu synchronisieren',
            ),
          SectionCard(
            title: 'Suche',
            child: SearchBarWidget(
              controller: _searchController,
              hintText: 'Wunschliste durchsuchen...',
              enabled: true,
            ),
          ),
          Expanded(
            child: _filteredWantlistAlbums.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.favorite_border,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('Keine Einträge in der Wunschliste'),
                        const SizedBox(height: 8),
                        Text(
                          _hasDiscogsAuth
                              ? 'Füge Einträge zu deiner Discogs-Wunschliste hinzu'
                              : 'Bitte OAuth in den Einstellungen konfigurieren',
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
                            itemBuilder: (context) => const [
                              PopupMenuItem<String>(
                                value: 'add_collection',
                                child: ListTile(
                                  leading: Icon(Icons.library_add),
                                  title: Text('Zur Sammlung'),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: ListTile(
                                  leading:
                                      Icon(Icons.delete, color: Colors.red),
                                  title: Text('Entfernen'),
                                ),
                              ),
                            ],
                          ),
                          onTap: () async {
                            final tracks = await _ensureTracksLoaded(album);
                            if (!mounted) return;

                            // FIXED: Verwende sichere Track-Sortierung
                            final sorted = List<Track>.from(tracks)
                              ..sort((a, b) => a.compareTo(b));

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(album.name),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
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
                                        if (sorted.isEmpty)
                                          const ListTile(
                                            leading: Icon(Icons.info_outline),
                                            title:
                                                Text("Keine Tracks vorhanden"),
                                            subtitle: Text(
                                                "Trackliste ist nicht verfügbar"),
                                          )
                                        else
                                          ...sorted.map((track) => ListTile(
                                                leading: Text(
                                                  "Track ${track.getFormattedTrackNumber()}",
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                title: Text(track.title),
                                                dense: true,
                                              )),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text("Schließen"),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
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
      floatingActionButton: FloatingActionButton(
        heroTag: "add",
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
          if (!mounted) return;
          if (result == true) {
            await _refreshWantlist();
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
