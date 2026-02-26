// lib/widgets/wantlist_items_widget.dart

import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/theme/app_theme.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/loading_widget.dart';
import 'package:music_up/widgets/animated_widgets.dart';

class WantlistItemsWidget extends StatelessWidget {
  final List<Album> albums;
  final bool isLoading;
  final bool hasDiscogsAuth;
  final Function(Album) onViewAlbum;
  final Function(Album) onAddToCollection;
  final Function(Album) onDeleteFromWantlist;

  const WantlistItemsWidget({
    super.key,
    required this.albums,
    required this.isLoading,
    required this.hasDiscogsAuth,
    required this.onViewAlbum,
    required this.onAddToCollection,
    required this.onDeleteFromWantlist,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (isLoading) {
      return LoadingWidget(message: l10n.wantlistLoading);
    }

    if (albums.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            const SizedBox(height: DS.md),
            Text(l10n.noWantlistEntries),
            const SizedBox(height: DS.xs),
            Text(
              hasDiscogsAuth
                  ? l10n.addToDiscogsWantlist
                  : l10n.configureOAuthFirst,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return FadeInListItem(
          index: index,
          child: WantlistItemCard(
            album: album,
            onTap: () => onViewAlbum(album),
            onAddToCollection: () => onAddToCollection(album),
            onDelete: () => onDeleteFromWantlist(album),
          ),
        );
      },
    );
  }
}

class WantlistItemCard extends StatelessWidget {
  final Album album;
  final VoidCallback onTap;
  final VoidCallback onAddToCollection;
  final VoidCallback onDelete;

  const WantlistItemCard({
    super.key,
    required this.album,
    required this.onTap,
    required this.onAddToCollection,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: DS.md, vertical: DS.xs),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(
          backgroundColor: AppTheme.oliveGreen, // Olive green
          child: Icon(Icons.favorite, color: Colors.white),
        ),
        title: Text(
          album.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.artistPrefix(album.artist)),
            Wrap(
              spacing: DS.xs,
              children: [
                _buildInfoChip(l10n.yearPrefix(album.year), AppTheme.oliveGreen),
                _buildInfoChip(l10n.mediumPrefix(album.medium), AppTheme.darkGreen),
                if (album.genre.isNotEmpty)
                  _buildInfoChip(l10n.genrePrefix(album.genre), AppTheme.charcoal),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: AppTheme.darkGreen, // Dark green
              onPressed: onAddToCollection,
              tooltip: l10n.addToCollection,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: onDelete,
              tooltip: l10n.removeFromWantlist,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: DS.xs),
      child: Chip(
        label: Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
        backgroundColor: color.withValues(alpha: 0.1),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class WantlistHeader extends StatelessWidget {
  final bool hasDiscogsAuth;

  const WantlistHeader({
    super.key,
    required this.hasDiscogsAuth,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (hasDiscogsAuth) {
      return Container(
        margin: const EdgeInsets.all(DS.sm),
        padding: const EdgeInsets.all(DS.md),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(DS.xs),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: DS.sm),
            Expanded(
              child: Text(
                l10n.discogsOAuthConfigured,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(DS.sm),
      padding: const EdgeInsets.all(DS.md),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(DS.xs),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_outlined, color: Colors.orange),
          const SizedBox(width: DS.sm),
          Expanded(
            child: Text(
              l10n.oauthNotConfiguredLong,
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
