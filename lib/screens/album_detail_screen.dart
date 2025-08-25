// lib/screens/album_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/screens/edit_album_screen.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/app_layout.dart';

class AlbumDetailScreen extends StatelessWidget {
  final Album album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: album.name,
      appBarColor: const Color(0xFF2C2C2C), // Charcoal
      actions: [
        IconButton(
          onPressed: () => _editAlbum(context),
          icon: const Icon(Icons.edit),
          tooltip: 'Album bearbeiten',
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DS.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAlbumHeader(),
            const SizedBox(height: DS.lg),
            _buildAlbumInfo(),
            const SizedBox(height: DS.lg),
            _buildTracksList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(DS.lg),
        child: Row(
          children: [
            _buildAlbumIcon(),
            const SizedBox(width: DS.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: DS.xs),
                  Text(
                    album.artist,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
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
      radius: 30,
      backgroundColor: iconColor.withValues(alpha: 0.2),
      child: Icon(iconData, color: iconColor, size: 30),
    );
  }

  Widget _buildAlbumInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DS.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Album-Informationen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: DS.md),
            _buildInfoRow('Jahr', album.year),
            _buildInfoRow('Medium', album.medium),
            _buildInfoRow('Digital verfügbar', album.digital ? 'Ja' : 'Nein'),
            if (album.genre.isNotEmpty) _buildInfoRow('Genre', album.genre),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DS.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildTracksList() {
    if (album.tracks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(DS.md),
          child: Column(
            children: [
              const Text(
                'Trackliste',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: DS.md),
              Text(
                'Keine Tracks verfügbar',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DS.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trackliste (${album.tracks.length} Tracks)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: DS.md),
            ...album.tracks.map((track) => _buildTrackTile(track)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackTile(Track track) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DS.xs),
      child: Row(
        children: [
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              track.trackNumber,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(width: DS.sm),
          Expanded(
            child: Text(track.title),
          ),
        ],
      ),
    );
  }

  Future<void> _editAlbum(BuildContext context) async {
    final editedAlbum = await Navigator.push<Album>(
      context,
      MaterialPageRoute(
        builder: (context) => EditAlbumScreen(album: album),
      ),
    );

    if (editedAlbum != null && context.mounted) {
      // Return edited album to parent screen
      Navigator.of(context).pop(editedAlbum);
    }
  }
}