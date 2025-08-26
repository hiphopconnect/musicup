// lib/screens/wantlist_screen.dart

import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/screens/add_wanted_album_screen.dart';
import 'package:music_up/screens/album_detail_screen.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/discogs_service_unified.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/services/logger_service.dart';
import 'package:music_up/services/wantlist_sync_service.dart';
import 'package:music_up/widgets/animated_widgets.dart';
import 'package:music_up/widgets/app_layout.dart';
import 'package:music_up/widgets/search_bar_widget.dart';
import 'package:music_up/widgets/section_card.dart';
import 'package:music_up/widgets/wantlist_dialogs.dart';
import 'package:music_up/widgets/wantlist_items_widget.dart';

class WantlistScreen extends StatefulWidget {
  final ConfigManager configManager;

  const WantlistScreen({super.key, required this.configManager});

  @override
  WantlistScreenState createState() => WantlistScreenState();
}

class WantlistScreenState extends State<WantlistScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  List<Album> _wantedAlbums = [];
  List<Album> _filteredWantlistAlbums = [];
  bool _isLoading = true;
  bool _hasDiscogsAuth = false;
  
  late JsonService _jsonService;
  late WantlistSyncService _syncService;
  DiscogsServiceUnified? _discogsService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _searchController.addListener(_filterWantlist);
    _loadWantlist();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeServices() {
    _jsonService = JsonService(widget.configManager);
    _discogsService = DiscogsServiceUnified(widget.configManager);
    _syncService = WantlistSyncService(_discogsService, _jsonService);
    _hasDiscogsAuth = _discogsService?.hasAuth ?? false;
  }

  void _filterWantlist() {
    final filtered = _syncService.filterWantlist(
      _wantedAlbums, 
      _searchController.text,
    );
    setState(() {
      _filteredWantlistAlbums = filtered;
    });
  }

  Future<void> _loadWantlist() async {
    setState(() => _isLoading = true);
    
    try {
      final albums = await _syncService.loadAndSyncWantlist();
      
      if (!mounted) return;
      setState(() {
        _wantedAlbums = albums;
        _filteredWantlistAlbums = albums;
        _isLoading = false;
      });
      
      LoggerService.info('Wantlist loaded', '${albums.length} items');
    } catch (e) {
      LoggerService.error('Wantlist load failed', e);
      if (!mounted) return;
      setState(() {
        _wantedAlbums = [];
        _filteredWantlistAlbums = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshWantlist() async {
    await _loadWantlist();
  }

  Future<void> _viewAlbum(Album album) async {
    await Navigator.push(
      context,
      SmoothPageRoute(
        page: AlbumDetailScreen(album: album),
        routeName: '/album-detail',
      ),
    );
  }

  Future<void> _addToCollection(Album wantlistAlbum) async {
    final confirmed = await WantlistDialogs.showAddToCollectionDialog(
      context, 
      wantlistAlbum,
    );
    
    if (confirmed != true) return;

    WantlistDialogs.showLoadingSnackbar(
      context, 
      'Wird zur Sammlung hinzugefügt...',
    );

    try {
      await _syncService.addToCollection(
        wantlistAlbum: wantlistAlbum,
        collectionJsonService: _jsonService,
      );

      if (!mounted) return;
      
      WantlistDialogs.showSuccessMessage(
        context,
        '"${wantlistAlbum.name}" zur Sammlung hinzugefügt und aus Wantlist entfernt',
      );

      // Reload wantlist to reflect changes
      await _loadWantlist();
    } catch (e) {
      if (!mounted) return;
      WantlistDialogs.showErrorMessage(context, e.toString());
    }
  }

  Future<void> _deleteFromWantlist(Album album) async {
    final confirmed = await WantlistDialogs.showDeleteConfirmationDialog(
      context,
      album,
    );

    if (confirmed != true) return;

    try {
      final success = await _syncService.deleteFromWantlist(album);

      if (!mounted) return;

      if (success) {
        final discogsInfo = _hasDiscogsAuth ? ' und aus Discogs' : '';
        WantlistDialogs.showSuccessMessage(
          context,
          '"${album.name}" aus Wunschliste$discogsInfo entfernt',
          backgroundColor: Colors.orange,
        );

        // Reload wantlist to reflect changes
        await _loadWantlist();
      } else {
        WantlistDialogs.showErrorMessage(
          context,
          'Album konnte nicht entfernt werden',
        );
      }
    } catch (e) {
      if (!mounted) return;
      WantlistDialogs.showErrorMessage(context, e.toString());
    }
  }

  Future<void> _addWantedAlbum() async {
    final result = await Navigator.push<bool>(
      context,
      SmoothPageRoute<bool>(
        page: AddWantedAlbumScreen(
          jsonService: _jsonService,
          configManager: widget.configManager,
        ),
        routeName: '/add-wanted-album',
      ),
    );

    if (result == true) {
      await _loadWantlist(); // Refresh if album was added
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Wunschliste (${_filteredWantlistAlbums.length})',
      appBarColor: const Color(0xFF556B2F), // Olive green
      actions: [
        IconButton(
          onPressed: _addWantedAlbum,
          icon: const Icon(Icons.add),
          tooltip: 'Album zur Wantlist hinzufügen',
        ),
        IconButton(
          onPressed: _refreshWantlist,
          icon: const Icon(Icons.refresh),
          tooltip: 'Wunschliste aktualisieren',
        ),
      ],
      body: Column(
        children: [
          // Auth Status Header
          WantlistHeader(hasDiscogsAuth: _hasDiscogsAuth),

          // Search Section
          SectionCard(
            title: 'Suche',
            child: SearchBarWidget(
              controller: _searchController,
              hintText: 'Wunschliste durchsuchen...',
              enabled: true,
            ),
          ),

          // Wantlist Items
          Expanded(
            child: WantlistItemsWidget(
              albums: _filteredWantlistAlbums,
              isLoading: _isLoading,
              hasDiscogsAuth: _hasDiscogsAuth,
              onViewAlbum: _viewAlbum,
              onAddToCollection: _addToCollection,
              onDeleteFromWantlist: _deleteFromWantlist,
            ),
          ),
        ],
      ),
    );
  }
}