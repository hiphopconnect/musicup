// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/screens/add_album_screen.dart';
import 'package:music_up/screens/discogs_search_screen.dart';
import 'package:music_up/screens/album_detail_screen.dart';
import 'package:music_up/screens/edit_album_screen.dart';
import 'package:music_up/screens/settings_screen.dart';
import 'package:music_up/screens/wantlist_screen.dart';
import 'package:music_up/services/album_filter_service.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/services/logger_service.dart';
import 'package:music_up/widgets/album_filters_widget.dart';
import 'package:music_up/widgets/album_list_widget.dart';
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
  final AlbumFilterService _filterService = AlbumFilterService();
  final TextEditingController _searchController = TextEditingController();

  List<Album> _albums = [];
  List<Album> _filteredAlbums = [];
  bool _isLoading = true;
  
  // Filter state
  String _searchCategory = 'Album';
  Map<String, bool> _mediumFilters = {};
  String _digitalFilter = 'All';
  bool _isAscending = true;

  // Counts for counter bar
  Map<String, int> _counts = {};

  @override
  void initState() {
    super.initState();
    _mediumFilters = _filterService.getDefaultMediumFilters();
    _loadAlbums();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAlbums() async {
    try {
      setState(() => _isLoading = true);
      
      List<Album> albums = await widget.jsonService.loadAlbums();
      
      if (!mounted) return;
      setState(() {
        _albums = albums;
        _applyFiltersAndSort();
        _isLoading = false;
      });
      
      LoggerService.info('Albums loaded', '${albums.length} albums');
    } catch (e) {
      LoggerService.error('Album loading failed', e);
      if (!mounted) return;
      setState(() {
        _albums = [];
        _filteredAlbums = [];
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    // Filter albums
    List<Album> filtered = _filterService.filterAlbums(
      albums: _albums,
      searchQuery: _searchController.text,
      searchCategory: _searchCategory,
      mediumFilters: _mediumFilters,
      digitalFilter: _digitalFilter,
    );

    // Sort albums
    filtered = _filterService.sortAlbums(
      albums: filtered,
      isAscending: _isAscending,
    );

    // Calculate counts
    _counts = _filterService.calculateAlbumCounts(_albums);

    setState(() {
      _filteredAlbums = filtered;
    });
  }

  void _onMediumFilterChanged(String medium, bool selected) {
    setState(() {
      _mediumFilters[medium] = selected;
      _applyFiltersAndSort();
    });
  }

  void _onDigitalFilterChanged(String filter) {
    setState(() {
      _digitalFilter = filter;
      _applyFiltersAndSort();
    });
  }

  void _onSearchCategoryChanged(String category) {
    setState(() {
      _searchCategory = category;
      _applyFiltersAndSort();
    });
  }

  void _toggleSortOrder() {
    setState(() {
      _isAscending = !_isAscending;
      _applyFiltersAndSort();
    });
  }

  void _resetFilters() {
    setState(() {
      _mediumFilters = _filterService.getDefaultMediumFilters();
      _digitalFilter = 'All';
      _searchController.clear();
      _applyFiltersAndSort();
    });
  }

  Future<void> _deleteAlbum(Album album) async {
    final confirmed = await _showDeleteConfirmationDialog(album);
    if (confirmed != true) return;

    try {
      _albums.removeWhere((a) => a.id == album.id);
      await widget.jsonService.saveAlbums(_albums);
      _applyFiltersAndSort();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${album.name} gelöscht')),
        );
      }
      
      LoggerService.info('Album deleted', album.name);
    } catch (e) {
      LoggerService.error('Album deletion failed', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Löschen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(Album album) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Album löschen'),
          content: Text('Möchten Sie "${album.name}" wirklich löschen?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Löschen'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _viewAlbum(Album album) async {
    final editedAlbum = await Navigator.push<Album>(
      context,
      MaterialPageRoute(
        builder: (context) => AlbumDetailScreen(
          album: album,
          jsonService: widget.jsonService,
        ),
      ),
    );

    if (editedAlbum != null) {
      final index = _albums.indexWhere((a) => a.id == album.id);
      if (index != -1) {
        _albums[index] = editedAlbum;
        await widget.jsonService.saveAlbums(_albums);
        _applyFiltersAndSort();
      }
    }
  }

  Future<void> _editAlbum(Album album) async {
    final editedAlbum = await Navigator.push<Album>(
      context,
      MaterialPageRoute(
        builder: (context) => EditAlbumScreen(album: album, jsonService: widget.jsonService),
      ),
    );

    if (editedAlbum != null) {
      final index = _albums.indexWhere((a) => a.id == album.id);
      if (index != -1) {
        _albums[index] = editedAlbum;
        await widget.jsonService.saveAlbums(_albums);
        _applyFiltersAndSort();
      }
    }
  }

  Future<void> _addAlbum() async {
    final newAlbum = await Navigator.push<Album>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddAlbumScreen(),
      ),
    );

    if (newAlbum != null) {
      _albums.add(newAlbum);
      await widget.jsonService.saveAlbums(_albums);
      _applyFiltersAndSort();
    }
  }

  Future<void> _openWantlist() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WantlistScreen(
          configManager: widget.jsonService.configManager,
        ),
      ),
    );
    _loadAlbums(); // Reload in case wantlist items were moved to collection
  }

  Future<void> _openDiscogsSearch() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiscogsSearchScreen(
          discogsToken: null,
          jsonService: widget.jsonService,
        ),
      ),
    );
    _loadAlbums(); // Reload in case items were added from Discogs
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          jsonService: widget.jsonService,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
    
    // Reload config and albums
    await widget.jsonService.configManager.loadConfig();
    _loadAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'MusicUp Collection',
      appBarColor: const Color(0xFF2E4F2E), // Dark green
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _addAlbum,
          tooltip: 'Album hinzufügen',
        ),
        IconButton(
          icon: const Icon(Icons.favorite),
          onPressed: _openWantlist,
          tooltip: 'Wantlist öffnen',
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _openDiscogsSearch,
          tooltip: 'Discogs durchsuchen',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _openSettings,
          tooltip: 'Einstellungen',
        ),
      ],
      body: Column(
        children: [
          // Counter Bar
          CounterBar(
            vinyl: _counts['vinyl'] ?? 0,
            cd: _counts['cd'] ?? 0,
            cassette: _counts['cassette'] ?? 0,
            digitalMedium: _counts['digital'] ?? 0,
            digitalYes: _counts['digitalYes'] ?? 0,
            digitalNo: _counts['digitalNo'] ?? 0,
          ),

          // Filter Controls
          AlbumFiltersWidget(
            mediumFilters: _mediumFilters,
            digitalFilter: _digitalFilter,
            isAscending: _isAscending,
            onMediumFilterChanged: _onMediumFilterChanged,
            onDigitalFilterChanged: _onDigitalFilterChanged,
            onToggleSortOrder: _toggleSortOrder,
            onResetFilters: _resetFilters,
          ),

          // Search Bar
          AlbumSearchWidget(
            searchController: _searchController,
            searchCategory: _searchCategory,
            onSearchCategoryChanged: _onSearchCategoryChanged,
          ),

          // Albums List (takes remaining space)
          Expanded(
            child: AlbumListWidget(
              albums: _filteredAlbums,
              isLoading: _isLoading,
              onViewAlbum: _viewAlbum,
              onEditAlbum: _editAlbum,
              onDeleteAlbum: _deleteAlbum,
            ),
          ),
        ],
      ),
    );
  }
}