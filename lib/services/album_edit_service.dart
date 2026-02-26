// lib/services/album_edit_service.dart

import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/logger_service.dart';

class AlbumEditService {
  Album createEditableCopy(Album original) {
    return Album(
      id: original.id,
      name: original.name,
      artist: original.artist,
      genre: original.genre,
      year: original.year,
      medium: original.medium,
      digital: original.digital,
      tracks: original.tracks
          .map((track) => Track(
                title: track.title,
                trackNumber: track.trackNumber,
              ))
          .toList(),
    );
  }

  Album updateAlbumFromForm({
    required Album originalAlbum,
    required String name,
    required String artist,
    required String genre,
    required String? selectedYear,
    required String? selectedMedium,
    required bool? isDigital,
    required List<Track> tracks,
  }) {
    final cleanTracks = tracks.where((t) => t.title.trim().isNotEmpty).toList();

    final updatedAlbum = Album(
      id: originalAlbum.id,
      name: name.trim(),
      artist: artist.trim(),
      genre: genre.trim().isEmpty ? 'Unknown' : genre.trim(),
      year: selectedYear ?? 'Unknown',
      medium: selectedMedium ?? 'Unknown',
      digital: isDigital ?? false,
      tracks: cleanTracks,
    );

    LoggerService.info('Album updated', '${updatedAlbum.name} by ${updatedAlbum.artist}');
    return updatedAlbum;
  }

  bool hasChanges({
    required Album original,
    required String name,
    required String artist,
    required String genre,
    required String? selectedYear,
    required String? selectedMedium,
    required bool? isDigital,
    required List<Track> tracks,
  }) {
    if (original.name != name.trim() ||
        original.artist != artist.trim() ||
        original.genre != (genre.trim().isEmpty ? 'Unknown' : genre.trim()) ||
        original.year != (selectedYear ?? 'Unknown') ||
        original.medium != (selectedMedium ?? 'Unknown') ||
        original.digital != (isDigital ?? false)) {
      return true;
    }

    if (original.tracks.length != tracks.length) {
      return true;
    }

    for (int i = 0; i < original.tracks.length; i++) {
      final originalTrack = original.tracks[i];
      final currentTrack = tracks[i];

      if (originalTrack.title != currentTrack.title ||
          originalTrack.trackNumber != currentTrack.trackNumber) {
        return true;
      }
    }

    return false;
  }

  /// Returns keys instead of localized strings.
  /// UI layer translates via validation_translations.dart
  List<String> validateAlbumEdit({
    required String name,
    required String artist,
    required String? selectedMedium,
    required bool? isDigital,
    required List<Track> tracks,
  }) {
    List<String> errors = [];

    if (name.trim().isEmpty) {
      errors.add('editAlbumNameRequired');
    }

    if (artist.trim().isEmpty) {
      errors.add('editArtistRequired');
    }

    if (selectedMedium == null) {
      errors.add('editMediumRequired');
    }

    if (isDigital == null) {
      errors.add('editDigitalRequired');
    }

    if (tracks.isEmpty) {
      errors.add('editTrackRequired');
    }

    for (int i = 0; i < tracks.length; i++) {
      if (tracks[i].title.trim().isEmpty) {
        errors.add('editTrackTitleRequired:${i + 1}');
      }
    }

    return errors;
  }
}
