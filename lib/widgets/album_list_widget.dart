// lib/widgets/album_list_widget.dart

import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/loading_widget.dart';
import 'package:music_up/widgets/animated_widgets.dart';
import 'package:music_up/widgets/responsive_widgets.dart';
import 'package:music_up/services/accessibility_service.dart';

class AlbumListWidget extends StatelessWidget {
  final List<Album> albums;
  final bool isLoading;
  final Function(Album) onViewAlbum;
  final Function(Album) onEditAlbum;
  final Function(Album) onDeleteAlbum;

  const AlbumListWidget({
    super.key,
    required this.albums,
    required this.isLoading,
    required this.onViewAlbum,
    required this.onEditAlbum,
    required this.onDeleteAlbum,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SkeletonLoadingList(itemCount: 6);
    }

    if (albums.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.album, size: 64, color: Colors.grey),
            SizedBox(height: DS.md),
            Text(
              'Keine Alben gefunden',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: DS.xs),
            Text(
              'Fügen Sie Ihr erstes Album hinzu',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: albums.length,
      itemExtent: 80.0, // Fixed height für bessere Performance
      cacheExtent: 400.0, // Weniger Items im Cache
      itemBuilder: (context, index) {
        final album = albums[index];
        return AlbumListTile(
          album: album,
          onTap: () => onViewAlbum(album),
          onEdit: () => onEditAlbum(album),
          onDelete: () => onDeleteAlbum(album),
        );
      },
    );
  }

}

class AlbumListTile extends StatelessWidget {
  final Album album;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AlbumListTile({
    super.key,
    required this.album,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: DS.sm, vertical: DS.xs),
      color: const Color(0xFF2C2C2C), // Charcoal background
      child: ListTile(
        onTap: onTap,
        leading: _buildSimpleIcon(),
        title: Text(
          album.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          album.artist,
          style: TextStyle(color: Colors.grey[300]),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
              onPressed: onEdit,
              tooltip: 'Bearbeiten',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white70, size: 20),
              onPressed: onDelete,
              tooltip: 'Löschen',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleIcon() {
    final IconData iconData;
    final Color iconColor;

    switch (album.medium) {
      case 'Vinyl':
        iconData = Icons.album;
        iconColor = const Color(0xFF2E4F2E);
        break;
      case 'CD':
        iconData = Icons.album;
        iconColor = const Color(0xFF556B2F);
        break;
      case 'Cassette':
        iconData = Icons.library_music;
        iconColor = const Color(0xFF2C2C2C);
        break;
      case 'Digital':
        iconData = Icons.cloud;
        iconColor = Colors.grey;
        break;
      default:
        iconData = Icons.music_note;
        iconColor = Colors.grey;
    }

    return Icon(iconData, color: iconColor, size: 24);
  }
}

