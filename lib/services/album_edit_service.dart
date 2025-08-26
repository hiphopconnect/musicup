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
    final updatedAlbum = Album(
      id: originalAlbum.id,
      name: name.trim(),
      artist: artist.trim(),
      genre: genre.trim().isEmpty ? 'Unknown' : genre.trim(),
      year: selectedYear ?? 'Unknown',
      medium: selectedMedium ?? 'Unknown',
      digital: isDigital ?? false,
      tracks: tracks,
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
    // Check basic album info
    if (original.name != name.trim() ||
        original.artist != artist.trim() ||
        original.genre != (genre.trim().isEmpty ? 'Unknown' : genre.trim()) ||
        original.year != (selectedYear ?? 'Unknown') ||
        original.medium != (selectedMedium ?? 'Unknown') ||
        original.digital != (isDigital ?? false)) {
      return true;
    }

    // Check tracks count
    if (original.tracks.length != tracks.length) {
      return true;
    }

    // Check individual tracks
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

  List<String> validateAlbumEdit({
    required String name,
    required String artist,
    required String? selectedMedium,
    required bool? isDigital,
    required List<Track> tracks,
  }) {
    List<String> errors = [];

    if (name.trim().isEmpty) {
      errors.add('Album-Name ist erforderlich');
    }

    if (artist.trim().isEmpty) {
      errors.add('Künstler ist erforderlich');
    }

    if (selectedMedium == null) {
      errors.add('Medium muss ausgewählt werden');
    }

    if (isDigital == null) {
      errors.add('Digital-Status muss ausgewählt werden');
    }

    if (tracks.isEmpty) {
      errors.add('Mindestens ein Track ist erforderlich');
    }

    // Check for empty track titles
    for (int i = 0; i < tracks.length; i++) {
      if (tracks[i].title.trim().isEmpty) {
        errors.add('Track ${i + 1} benötigt einen Titel');
      }
    }

    return errors;
  }
}