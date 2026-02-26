// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/screens/add_album_screen.dart';
import 'package:music_up/screens/discogs_search_screen.dart';
import 'package:music_up/screens/album_detail_screen.dart';
import 'package:music_up/screens/edit_album_screen.dart';
import 'package:music_up/screens/settings_screen.dart';
import 'package:music_up/screens/wantlist_screen.dart';
import 'package:music_up/services/album_filter_service.dart';
import 'package:music_up/services/pdf_export_service.dart';
import 'package:music_up/services/logger_service.dart';
import 'package:music_up/services/service_locator.dart';
import 'package:music_up/services/tour_service.dart';
import 'package:music_up/theme/app_theme.dart';
import 'package:music_up/widgets/album_filters_widget.dart';
import 'package:music_up/widgets/album_list_widget.dart';
import 'package:music_up/widgets/app_layout.dart';
import 'package:music_up/widgets/counter_bar.dart';
import 'package:music_up/widgets/tour_overlay.dart';

class MainScreen extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;
  final Function(Locale)? onLocaleChanged;
  final bool startTour;

  const MainScreen({super.key, this.onThemeChanged, this.onLocaleChanged, this.startTour = false});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final AlbumFilterService _filterService = AlbumFilterService();
  final TextEditingController _searchController = TextEditingController();
  final TourService _tourService = TourService();

  // GlobalKeys fuer die Tour-Ziele
  final GlobalKey _albumListKey = GlobalKey();
  final GlobalKey _searchBarKey = GlobalKey();
  final GlobalKey _filterKey = GlobalKey();
  final GlobalKey _addButtonKey = GlobalKey();
  final GlobalKey _settingsButtonKey = GlobalKey();

  List<Album> _albums = [];
  List<Album> _filteredAlbums = [];
  bool _isLoading = true;
  bool _tourConfigured = false;

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
    _tourService.addListener(_onTourChanged);
    if (widget.startTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tourService.start();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_tourConfigured) {
      _tourConfigured = true;
      _configureTour(context);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tourService.removeListener(_onTourChanged);
    _tourService.dispose();
    super.dispose();
  }

  void _configureTour(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _tourService.configure([
      TourStep(
        title: l10n.tourCollectionTitle,
        description: l10n.tourCollectionDesc,
        targetKey: _albumListKey,
      ),
      TourStep(
        title: l10n.tourSearchTitle,
        description: l10n.tourSearchDesc,
        targetKey: _searchBarKey,
      ),
      TourStep(
        title: l10n.tourFilterTitle,
        description: l10n.tourFilterDesc,
        targetKey: _filterKey,
      ),
      TourStep(
        title: l10n.tourAddAlbumTitle,
        description: l10n.tourAddAlbumDesc,
        targetKey: _addButtonKey,
      ),
      TourStep(
        title: l10n.tourSettingsTitle,
        description: l10n.tourSettingsDesc,
        targetKey: _settingsButtonKey,
      ),
    ]);
  }

  void _onTourChanged() {
    if (!_tourService.isActive && _tourService.currentStep == -1) {
      sl.configManager.setTourCompleted();
    }
  }

  void startTour() {
    _tourService.start();
  }

  Future<void> _loadAlbums() async {
    try {
      setState(() => _isLoading = true);

      List<Album> albums = await sl.jsonService.loadAlbums();

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
    final l10n = AppLocalizations.of(context);
    final confirmed = await _showDeleteConfirmationDialog(album);
    if (confirmed != true) return;

    try {
      _albums.removeWhere((a) => a.id == album.id);
      await sl.jsonService.saveAlbums(_albums);
      _applyFiltersAndSort();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.albumDeletedSuccess(album.name))),
        );
      }

      LoggerService.info('Album deleted', album.name);
    } catch (e) {
      LoggerService.error('Album deletion failed', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorDeleting('$e')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog(Album album) async {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteAlbum),
          content: Text(l10n.deleteAlbumConfirm(album.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.delete),
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
        builder: (context) => AlbumDetailScreen(album: album),
      ),
    );

    if (editedAlbum != null) {
      final index = _albums.indexWhere((a) => a.id == album.id);
      if (index != -1) {
        _albums[index] = editedAlbum;
        await sl.jsonService.saveAlbums(_albums);
        _applyFiltersAndSort();
      }
    }
  }

  Future<void> _editAlbum(Album album) async {
    final editedAlbum = await Navigator.push<Album>(
      context,
      MaterialPageRoute(
        builder: (context) => EditAlbumScreen(album: album),
      ),
    );

    if (editedAlbum != null) {
      final index = _albums.indexWhere((a) => a.id == album.id);
      if (index != -1) {
        _albums[index] = editedAlbum;
        await sl.jsonService.saveAlbums(_albums);
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
      await sl.jsonService.saveAlbums(_albums);
      _applyFiltersAndSort();
    }
  }

  Future<void> _openWantlist() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WantlistScreen(),
      ),
    );
    _loadAlbums(); // Reload in case wantlist items were moved to collection
  }

  Future<void> _openDiscogsSearch() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DiscogsSearchScreen(),
      ),
    );
    _loadAlbums(); // Reload in case items were added from Discogs
  }

  Future<void> _exportCollectionPdf() async {
    final l10n = AppLocalizations.of(context);

    if (_filteredAlbums.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.collectionEmpty)),
      );
      return;
    }

    try {
      final path = await PdfExportService.exportAsPdf(
        albums: _filteredAlbums,
        title: 'MusicUp Sammlung',
        fileName: 'sammlung.pdf',
        dialogTitle: 'Sammlung als PDF speichern',
      );
      if (path != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pdfSaved(path))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pdfExportFailed('$e')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          onThemeChanged: widget.onThemeChanged,
          onLocaleChanged: widget.onLocaleChanged,
        ),
      ),
    );

    // Reload config and albums
    await sl.configManager.loadConfig();
    _loadAlbums();

    if (result == 'startTour') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tourService.start();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppLayout(
      title: l10n.musicUpCollection,
      appBarColor: AppTheme.darkGreen, // Dark green
      actions: [
        IconButton(
          key: _addButtonKey,
          icon: const Icon(Icons.add),
          onPressed: _addAlbum,
          tooltip: l10n.addAlbumTooltip,
        ),
        IconButton(
          icon: const Icon(Icons.favorite),
          onPressed: _openWantlist,
          tooltip: l10n.openWantlist,
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _openDiscogsSearch,
          tooltip: l10n.searchDiscogs,
        ),
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          onPressed: _exportCollectionPdf,
          tooltip: l10n.exportCollectionAsPdf,
        ),
        IconButton(
          key: _settingsButtonKey,
          icon: const Icon(Icons.settings),
          onPressed: _openSettings,
          tooltip: l10n.settings,
        ),
      ],
      body: Stack(
        children: [
          Column(
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
                key: _filterKey,
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
                key: _searchBarKey,
                searchController: _searchController,
                searchCategory: _searchCategory,
                onSearchCategoryChanged: _onSearchCategoryChanged,
              ),

              // Albums List (takes remaining space)
              Expanded(
                child: AlbumListWidget(
                  key: _albumListKey,
                  albums: _filteredAlbums,
                  isLoading: _isLoading,
                  onViewAlbum: _viewAlbum,
                  onEditAlbum: _editAlbum,
                  onDeleteAlbum: _deleteAlbum,
                ),
              ),
            ],
          ),

          // Tour Overlay
          TourOverlay(tourService: _tourService),
        ],
      ),
    );
  }
}
