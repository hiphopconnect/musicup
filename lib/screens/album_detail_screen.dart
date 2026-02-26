// lib/screens/album_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/screens/edit_album_screen.dart';
import 'package:music_up/services/logger_service.dart';
import 'package:music_up/services/service_locator.dart';
import 'package:music_up/theme/app_theme.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/app_layout.dart';

class AlbumDetailScreen extends StatefulWidget {
  final Album album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  Album? _albumWithTracks;
  bool _isLoadingTracks = false;

  @override
  void initState() {
    super.initState();
    _loadTracksIfNeeded();
  }

  Future<void> _loadTracksIfNeeded() async {
    if (widget.album.tracks.isNotEmpty) {
      _albumWithTracks = widget.album;
      return;
    }

    setState(() => _isLoadingTracks = true);

    try {
      final albumWithTracks = await sl.jsonService.loadAlbumWithTracks(widget.album.id);
      if (mounted) {
        setState(() {
          _albumWithTracks = albumWithTracks ?? widget.album;
          _isLoadingTracks = false;
        });
      }
    } catch (e) {
      LoggerService.error('Track loading', e, 'AlbumDetailScreen');
      if (mounted) {
        setState(() {
          _albumWithTracks = widget.album;
          _isLoadingTracks = false;
        });
      }
    }
  }

  Album get album => _albumWithTracks ?? widget.album;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppLayout(
      title: widget.album.name,
      appBarColor: AppTheme.charcoal, // Charcoal
      actions: [
        IconButton(
          onPressed: () => _editAlbum(context),
          icon: const Icon(Icons.edit),
          tooltip: l10n.editAlbum,
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
        iconColor = AppTheme.darkGreen; // Dark green
        break;
      case 'CD':
        iconData = Icons.album;
        iconColor = AppTheme.oliveGreen; // Olive green
        break;
      case 'Cassette':
        iconData = Icons.library_music;
        iconColor = AppTheme.charcoal; // Charcoal
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
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DS.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.albumInformation,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: DS.md),
            _buildInfoRow(l10n.year, album.year),
            _buildInfoRow(l10n.medium, album.medium),
            _buildInfoRow(l10n.digitalAvailable, album.digital ? l10n.yes : l10n.no),
            if (album.genre.isNotEmpty) _buildInfoRow(l10n.genre, album.genre),
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
    final l10n = AppLocalizations.of(context);
    if (_isLoadingTracks) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(DS.md),
          child: Column(
            children: [
              Text(
                l10n.trackList,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: DS.md),
              const CircularProgressIndicator(),
              const SizedBox(height: DS.sm),
              Text(
                l10n.tracksLoading,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    if (album.tracks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(DS.md),
          child: Column(
            children: [
              Text(
                l10n.trackList,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: DS.md),
              Text(
                l10n.noTracksAvailable,
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
              l10n.trackListCount(album.tracks.length),
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
