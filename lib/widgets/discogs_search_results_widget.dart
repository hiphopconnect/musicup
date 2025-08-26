// lib/widgets/discogs_search_results_widget.dart

import 'package:flutter/material.dart';
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
    if (isLoading) {
      return const LoadingWidget(message: 'Suche läuft...');
    }

    if (results.isEmpty) {
      return const Center(
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
        subtitle: _buildSubtitle(),
        isThreeLine: true,
        trailing: _buildActionButtons(),
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

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Künstler: ${result.artist}'),
        Text('Jahr: ${result.year}'),
        Text('Format: ${result.format}'),
        if (result.genre.isNotEmpty)
          Text('Genre: ${result.genre}'),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'Zur Sammlung hinzufügen',
          onPressed: onAddToCollection,
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border),
          tooltip: 'Zur Wantlist hinzufügen',
          onPressed: onAddToWantlist,
        ),
      ],
    );
  }
}

class EmptySearchResultsWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptySearchResultsWidget({
    super.key,
    this.message = 'Keine Ergebnisse gefunden.',
    this.icon = Icons.search_off,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: DS.md),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}