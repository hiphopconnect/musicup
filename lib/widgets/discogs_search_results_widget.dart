// lib/widgets/discogs_search_results_widget.dart

import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/loading_widget.dart';
import 'package:music_up/widgets/animated_widgets.dart';

class DiscogsSearchResultsWidget extends StatelessWidget {
  final List<DiscogsSearchResult> results;
  final bool isLoading;
  final VoidCallback? onAddToCollection;
  final VoidCallback? onAddToWantlist;
  final VoidCallback? onShowDetails;
  final Function(DiscogsSearchResult)? onResultTap;
  final Function(DiscogsSearchResult)? onAddToCollectionTap;
  final Function(DiscogsSearchResult)? onAddToWantlistTap;

  const DiscogsSearchResultsWidget({
    super.key,
    required this.results,
    required this.isLoading,
    this.onAddToCollection,
    this.onAddToWantlist,
    this.onShowDetails,
    this.onResultTap,
    this.onAddToCollectionTap,
    this.onAddToWantlistTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (isLoading) {
      return LoadingWidget(message: l10n.searchRunning);
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 64, color: Colors.grey),
            const SizedBox(height: DS.md),
            Text(
              l10n.noResultsTrySearch,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(DS.md),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return FadeInListItem(
          index: index,
          child: _SearchResultCard(
            result: result,
            onTap: () => onResultTap?.call(result),
            onAddToCollection: () => onAddToCollectionTap?.call(result),
            onAddToWantlist: () => onAddToWantlistTap?.call(result),
          ),
        );
      },
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final DiscogsSearchResult result;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCollection;
  final VoidCallback? onAddToWantlist;

  const _SearchResultCard({
    required this.result,
    this.onTap,
    this.onAddToCollection,
    this.onAddToWantlist,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: DS.xs),
      child: ListTile(
        leading: _buildAlbumImage(),
        title: Text(
          result.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: _buildSubtitle(context),
        isThreeLine: true,
        trailing: _buildActionButtons(context),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAlbumImage() {
    if (result.imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: DS.rSm,
        child: Image.network(
          result.imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage();
          },
        ),
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: DS.rSm,
      ),
      child: const Icon(Icons.album),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.artistPrefix(result.artist)),
        Text(l10n.yearPrefix(result.year)),
        Text(l10n.formatPrefix(result.format)),
        if (result.genre.isNotEmpty)
          Text(l10n.genrePrefix(result.genre)),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          tooltip: l10n.addToCollection,
          onPressed: onAddToCollection,
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border),
          tooltip: l10n.addToWantlistTooltipShort,
          onPressed: onAddToWantlist,
        ),
      ],
    );
  }
}

class EmptySearchResultsWidget extends StatelessWidget {
  final String? message;
  final IconData icon;

  const EmptySearchResultsWidget({
    super.key,
    this.message,
    this.icon = Icons.search_off,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: DS.md),
          Text(
            message ?? l10n.noResultsFound,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
