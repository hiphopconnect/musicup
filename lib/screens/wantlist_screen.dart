// lib/screens/wantlist_screen.dart

import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/screens/add_wanted_album_screen.dart';
import 'package:music_up/screens/album_detail_screen.dart';
import 'package:music_up/services/logger_service.dart';
import 'package:music_up/services/service_locator.dart';
import 'package:music_up/services/pdf_export_service.dart';
import 'package:music_up/theme/app_theme.dart';
import 'package:music_up/services/wantlist_sync_service.dart';
import 'package:music_up/widgets/animated_widgets.dart';
import 'package:music_up/widgets/app_layout.dart';
import 'package:music_up/widgets/search_bar_widget.dart';
import 'package:music_up/widgets/section_card.dart';
import 'package:music_up/widgets/wantlist_dialogs.dart';
import 'package:music_up/widgets/wantlist_items_widget.dart';

class WantlistScreen extends StatefulWidget {
  const WantlistScreen({super.key});

  @override
  WantlistScreenState createState() => WantlistScreenState();
}

class WantlistScreenState extends State<WantlistScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Album> _wantedAlbums = [];
  List<Album> _filteredWantlistAlbums = [];
  bool _isLoading = true;
  bool _hasDiscogsAuth = false;
  bool _isSortAscending = true;

  late WantlistSyncService _syncService;

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
    _syncService = WantlistSyncService(sl.discogsService, sl.jsonService);
    _hasDiscogsAuth = sl.discogsService.hasAuth;
  }

  void _filterWantlist() {
    final filtered = _syncService.filterWantlist(
      _wantedAlbums,
      _searchController.text,
    );
    setState(() {
      _filteredWantlistAlbums = filtered;
      _applySorting();
    });
  }

  void _applySorting() {
    _filteredWantlistAlbums.sort((a, b) {
      final cmp = a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
      return _isSortAscending ? cmp : -cmp;
    });
  }

  void _toggleSort() {
    setState(() {
      _isSortAscending = !_isSortAscending;
      _applySorting();
    });
  }

  Future<void> _exportWantlistPdf() async {
    final l10n = AppLocalizations.of(context);

    if (_filteredWantlistAlbums.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.wantlistEmpty)),
      );
      return;
    }

    try {
      final path = await PdfExportService.exportAsPdf(
        albums: _filteredWantlistAlbums,
        title: 'MusicUp Wunschliste',
        fileName: 'wunschliste.pdf',
        dialogTitle: 'Wunschliste als PDF speichern',
      );
      if (!mounted) return;
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pdfSaved(path))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pdfExportFailed('$e'))),
      );
    }
  }

  Future<void> _loadWantlist() async {
    setState(() => _isLoading = true);

    try {
      final albums = await _syncService.loadAndSyncWantlist();

      if (!mounted) return;
      setState(() {
        _wantedAlbums = albums;
        _filteredWantlistAlbums = List<Album>.from(albums);
        _applySorting();
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
    final l10n = AppLocalizations.of(context);

    final confirmed = await WantlistDialogs.showAddToCollectionDialog(
      context,
      wantlistAlbum,
    );

    if (confirmed != true) return;

    if (!mounted) return;
    WantlistDialogs.showLoadingSnackbar(
      context,
      l10n.addingToCollection,
    );

    try {
      await _syncService.addToCollection(
        wantlistAlbum: wantlistAlbum,
        collectionJsonService: sl.jsonService,
      );

      if (!mounted) return;

      WantlistDialogs.showSuccessMessage(
        context,
        l10n.albumMovedToCollection(wantlistAlbum.name),
      );

      // Reload wantlist to reflect changes
      await _loadWantlist();
    } catch (e) {
      if (!mounted) return;
      WantlistDialogs.showErrorMessage(context, e.toString());
    }
  }

  Future<void> _deleteFromWantlist(Album album) async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await WantlistDialogs.showDeleteConfirmationDialog(
      context,
      album,
    );

    if (confirmed != true) return;

    try {
      final success = await _syncService.deleteFromWantlist(album);

      if (!mounted) return;

      if (success) {
        final message = _hasDiscogsAuth
            ? l10n.albumRemovedFromWantlistAndDiscogs(album.name)
            : l10n.albumRemovedFromWantlist(album.name);
        WantlistDialogs.showSuccessMessage(
          context,
          message,
          backgroundColor: Colors.orange,
        );

        // Reload wantlist to reflect changes
        await _loadWantlist();
      } else {
        WantlistDialogs.showErrorMessage(
          context,
          l10n.albumCouldNotBeRemoved,
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
        page: const AddWantedAlbumScreen(),
        routeName: '/add-wanted-album',
      ),
    );

    if (result == true) {
      await _loadWantlist(); // Refresh if album was added
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppLayout(
      title: l10n.wantlistTitle(_filteredWantlistAlbums.length),
      appBarColor: AppTheme.oliveGreen, // Olive green
      actions: [
        IconButton(
          onPressed: _exportWantlistPdf,
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: l10n.exportAsPdf,
        ),
        IconButton(
          onPressed: _toggleSort,
          icon: const Icon(Icons.sort_by_alpha),
          tooltip: _isSortAscending ? l10n.sortAZ : l10n.sortZA,
        ),
        IconButton(
          onPressed: _addWantedAlbum,
          icon: const Icon(Icons.add),
          tooltip: l10n.addToWantlistTooltip,
        ),
        IconButton(
          onPressed: _refreshWantlist,
          icon: const Icon(Icons.refresh),
          tooltip: l10n.refreshWantlist,
        ),
      ],
      body: Column(
        children: [
          // Auth Status Header
          WantlistHeader(hasDiscogsAuth: _hasDiscogsAuth),

          // Search Section
          SectionCard(
            title: l10n.search,
            child: SearchBarWidget(
              controller: _searchController,
              hintText: l10n.searchWantlist,
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
