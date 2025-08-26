// lib/services/wantlist_service.dart

import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/services/logger_service.dart';

class WantlistService {
  final JsonService _jsonService;

  WantlistService(this._jsonService);

  Future<Album> createWantedAlbum({
    required String name,
    required String artist,
    required String genre,
    required String year,
    required String medium,
    required bool digital,
  }) async {
    final album = Album(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      artist: artist.trim(),
      genre: genre.trim().isEmpty ? 'Unknown' : genre.trim(),
      year: year.trim().isEmpty ? 'Unknown' : year.trim(),
      medium: medium,
      digital: digital,
      tracks: [], // Wantlist albums don't need tracks initially
    );

    return album;
  }

  Future<bool> addToWantlist(Album album) async {
    try {
      List<Album> currentWantlist = await _jsonService.loadWantlist();
      
      // Check if album already exists in wantlist
      bool alreadyExists = currentWantlist.any((existing) => 
          existing.name.toLowerCase() == album.name.toLowerCase() &&
          existing.artist.toLowerCase() == album.artist.toLowerCase());
      
      if (alreadyExists) {
        throw Exception('Album bereits in Wantlist vorhanden');
      }

      currentWantlist.add(album);
      await _jsonService.saveWantlist(currentWantlist);
      
      LoggerService.info('Wantlist add', '${album.name} by ${album.artist}');
      return true;
    } catch (e) {
      LoggerService.error('Wantlist add failed', e, '${album.name} by ${album.artist}');
      rethrow;
    }
  }

  Future<List<Album>> getWantlist() async {
    try {
      return await _jsonService.loadWantlist();
    } catch (e) {
      LoggerService.error('Wantlist load failed', e);
      return [];
    }
  }

  Future<bool> removeFromWantlist(String albumId) async {
    try {
      List<Album> currentWantlist = await _jsonService.loadWantlist();
      final initialLength = currentWantlist.length;
      
      currentWantlist.removeWhere((album) => album.id == albumId);
      
      if (currentWantlist.length == initialLength) {
        return false; // Nothing was removed
      }
      
      await _jsonService.saveWantlist(currentWantlist);
      LoggerService.info('Wantlist remove', 'Album removed from wantlist');
      return true;
    } catch (e) {
      LoggerService.error('Wantlist remove failed', e);
      return false;
    }
  }
}