// lib/widgets/album_list_widget.dart

import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/theme/design_system.dart';

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
      return const Center(child: CircularProgressIndicator());
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
        leading: _buildAlbumIcon(),
        title: Text(
          album.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          album.artist,
          style: TextStyle(color: Colors.grey[300]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white70),
              onPressed: onEdit,
              tooltip: 'Album bearbeiten',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white70),
              onPressed: onDelete,
              tooltip: 'Album löschen',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumIcon() {
    IconData iconData;
    Color iconColor;

    switch (album.medium) {
      case 'Vinyl':
        iconData = Icons.album;
        iconColor = const Color(0xFF2E4F2E); // Dark green
        break;
      case 'CD':
        iconData = Icons.album;
        iconColor = const Color(0xFF556B2F); // Olive green
        break;
      case 'Cassette':
        iconData = Icons.library_music;
        iconColor = const Color(0xFF2C2C2C); // Charcoal
        break;
      case 'Digital':
        iconData = Icons.cloud;
        iconColor = Colors.grey[600]!;
        break;
      default:
        iconData = Icons.music_note;
        iconColor = Colors.grey[500]!;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withValues(alpha: 0.2),
      child: Icon(iconData, color: iconColor),
    );
  }

}