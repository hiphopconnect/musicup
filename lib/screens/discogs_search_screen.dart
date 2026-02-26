// lib/screens/discogs_search_screen.dart

import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/theme/app_theme.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/discogs_album_service.dart';
import 'package:music_up/services/logger_service.dart';
import 'package:music_up/services/service_locator.dart';
import 'package:music_up/services/toast_service.dart';
import 'package:music_up/widgets/app_layout.dart';
import 'package:music_up/widgets/discogs_dialogs.dart';
import 'package:music_up/widgets/discogs_search_results_widget.dart';
import 'package:music_up/widgets/search_bar_widget.dart';
import 'package:music_up/screens/settings_screen.dart';
import 'package:music_up/widgets/section_card.dart';
import 'package:music_up/widgets/status_banner.dart';

class DiscogsSearchScreen extends StatefulWidget {
  const DiscogsSearchScreen({super.key});

  @override
  DiscogsSearchScreenState createState() => DiscogsSearchScreenState();
}

class DiscogsSearchScreenState extends State<DiscogsSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _releaseTitleController = TextEditingController();
  String? _selectedFormat;
  String? _selectedCountry;
  bool _filtersExpanded = false;

  List<DiscogsSearchResult> _searchResults = [];
  bool _isLoading = false;
  bool _hasAuth = false;

  DiscogsAlbumService? _albumService;

  static const _formatOptions = <String?>[
    null,
    'Vinyl',
    'CD',
    'Cassette',
    'File',
  ];

  static const _countryOptions = <String?>[
    null,
    'Germany',
    'US',
    'UK',
    'Japan',
    'Europe',
  ];

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _artistController.dispose();
    _releaseTitleController.dispose();
    super.dispose();
  }

  Future<void> _initServices() async {
    _albumService = DiscogsAlbumService(sl.discogsService, sl.jsonService);

    setState(() {
      _hasAuth = sl.discogsService.hasAuth;
    });
  }

  Future<void> _searchDiscogs() async {
    if (!sl.discogsService.hasAuth) {
      DiscogsDialogs.showNoTokenMessage(context);
      return;
    }

    final query = _searchController.text.trim();
    final artist = _artistController.text.trim();
    final releaseTitle = _releaseTitleController.text.trim();

    if (query.isEmpty &&
        artist.isEmpty &&
        releaseTitle.isEmpty &&
        _selectedFormat == null &&
        _selectedCountry == null) {
      DiscogsDialogs.showEmptyQueryMessage(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final rawResults = await sl.discogsService.searchReleases(
        query,
        artist: artist.isNotEmpty ? artist : null,
        releaseTitle: releaseTitle.isNotEmpty ? releaseTitle : null,
        format: _selectedFormat,
        country: _selectedCountry,
      );
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
        final l10n = AppLocalizations.of(context);
        ToastService.showSuccess(context, l10n.addedToCollection(result.title));
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ToastService.showError(context, l10n.errorGeneric('$e'));
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
        final l10n = AppLocalizations.of(context);
        ToastService.showSuccess(context, l10n.addedToWantlist(result.title));
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ToastService.showError(context, l10n.errorGeneric('$e'));
      }
    }
  }

  void _handleShowDetails(DiscogsSearchResult result) {
    DiscogsDialogs.showSearchResultDetails(context, result);
  }

  void _goToOAuthSetup() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppLayout(
      title: l10n.discogsSearch,
      appBarColor: AppTheme.oliveGreen, // Olive green
      body: Column(
        children: [
          if (!_hasAuth)
            StatusBanner.warning(
              l10n.oauthNotConfigured,
            ),

          SectionCard(
            title: l10n.search,
            child: Column(
              children: [
                SearchBarWidget(
                  controller: _searchController,
                  hintText: l10n.freeTextSearch,
                  onSearch: _searchDiscogs,
                  enabled: _hasAuth,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DS.md),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => setState(
                            () => _filtersExpanded = !_filtersExpanded),
                        child: Row(
                          children: [
                            Icon(
                              _filtersExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 20,
                            ),
                            const SizedBox(width: DS.xxs),
                            Text(
                              l10n.advancedFilters,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      if (_filtersExpanded) ...[
                        const SizedBox(height: DS.sm),
                        TextField(
                          controller: _artistController,
                          enabled: _hasAuth,
                          decoration: InputDecoration(
                            labelText: l10n.artist,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _searchDiscogs(),
                        ),
                        const SizedBox(height: DS.xs),
                        TextField(
                          controller: _releaseTitleController,
                          enabled: _hasAuth,
                          decoration: InputDecoration(
                            labelText: l10n.albumRelease,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _searchDiscogs(),
                        ),
                        const SizedBox(height: DS.xs),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String?>(
                                value: _selectedFormat,
                                decoration: InputDecoration(
                                  labelText: l10n.format,
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                ),
                                items: _formatOptions
                                    .map((f) => DropdownMenuItem<String?>(
                                          value: f,
                                          child: Text(f ?? l10n.all),
                                        ))
                                    .toList(),
                                onChanged: _hasAuth
                                    ? (val) =>
                                        setState(() => _selectedFormat = val)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: DS.xs),
                            Expanded(
                              child: DropdownButtonFormField<String?>(
                                value: _selectedCountry,
                                decoration: InputDecoration(
                                  labelText: l10n.pressCountry,
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                ),
                                items: _countryOptions
                                    .map((c) => DropdownMenuItem<String?>(
                                          value: c,
                                          child: Text(c ?? l10n.all),
                                        ))
                                    .toList(),
                                onChanged: _hasAuth
                                    ? (val) =>
                                        setState(() => _selectedCountry = val)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DS.sm),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _hasAuth ? _searchDiscogs : null,
                            child: Text(l10n.search),
                          ),
                        ),
                        const SizedBox(height: DS.xs),
                      ],
                    ],
                  ),
                ),
              ],
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
