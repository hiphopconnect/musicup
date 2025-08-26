// lib/screens/discogs_search_screen.dart

import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/discogs_album_service.dart';
import 'package:music_up/services/discogs_service_unified.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/services/logger_service.dart';
import 'package:music_up/services/toast_service.dart';
import 'package:music_up/widgets/app_layout.dart';
import 'package:music_up/widgets/discogs_dialogs.dart';
import 'package:music_up/widgets/discogs_search_results_widget.dart';
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
  DiscogsAlbumService? _albumService;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initServices() async {
    _discogsService = DiscogsServiceUnified(widget.jsonService.configManager);
    _albumService = DiscogsAlbumService(_discogsService!, widget.jsonService);
    
    setState(() {
      _hasAuth = _discogsService!.hasAuth;
    });
  }

  Future<void> _searchDiscogs() async {
    if (_discogsService == null || !_discogsService!.hasAuth) {
      DiscogsDialogs.showNoTokenMessage(context);
      return;
    }

    final query = _searchController.text.trim();
    if (query.isEmpty) {
      DiscogsDialogs.showEmptyQueryMessage(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final rawResults = await _discogsService!.searchReleases(query);
      final results = rawResults
          .map((json) => DiscogsSearchResult.fromJson(json))
          .toList();
      
      LoggerService.data('Search completed', results.length, 'results');

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.error('Discogs search', e, query);
      setState(() => _isLoading = false);
      
      if (mounted) {
        DiscogsDialogs.showSearchErrorMessage(context, e.toString());
      }
    }
  }

  Future<void> _handleAddToCollection(DiscogsSearchResult result) async {
    final confirmed = await DiscogsDialogs.showAddToCollectionDialog(context, result);
    if (confirmed != true) return;

    try {
      await _albumService!.addToCollection(result);
      
      if (mounted) {
        ToastService.showSuccess(context, '"${result.title}" zur Sammlung hinzugefügt');
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'Fehler: $e');
      }
    }
  }

  Future<void> _handleAddToWantlist(DiscogsSearchResult result) async {
    if (!_hasAuth) {
      DiscogsDialogs.showOAuthNeededDialog(
        context,
        result,
        _goToOAuthSetup,
      );
      return;
    }

    try {
      await _albumService!.addToWantlist(result);
      
      if (mounted) {
        ToastService.showSuccess(context, '"${result.title}" zur Wantlist hinzugefügt');
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, 'Fehler: $e');
      }
    }
  }

  void _handleShowDetails(DiscogsSearchResult result) {
    DiscogsDialogs.showSearchResultDetails(context, result);
  }

  void _goToOAuthSetup() {
    Navigator.of(context).pushNamed('/settings');
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Discogs Suche',
      appBarColor: const Color(0xFF556B2F), // Olive green
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

          Expanded(
            child: DiscogsSearchResultsWidget(
              results: _searchResults,
              isLoading: _isLoading,
              onResultTap: _handleShowDetails,
              onAddToCollectionTap: _handleAddToCollection,
              onAddToWantlistTap: _handleAddToWantlist,
            ),
          ),
        ],
      ),
    );
  }
}