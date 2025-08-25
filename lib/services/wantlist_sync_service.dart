// lib/services/wantlist_sync_service.dart

import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/discogs_service_unified.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/services/logger_service.dart';

class WantlistSyncService {
  final DiscogsServiceUnified? _discogsService;
  final JsonService _jsonService;

  WantlistSyncService(this._discogsService, this._jsonService);

  Future<List<Album>> loadAndSyncWantlist() async {
    try {
      final offline = await _jsonService.loadWantlist();
      List<Album> merged = List.of(offline);

      // Online-Sync nur, wenn OAuth vorhanden UND testToken==200
      if (_discogsService != null && _discogsService!.hasAuth) {
        try {
          final tokenValid = await _discogsService!.testAuthentication();

          if (tokenValid) {
            final online = await _discogsService!.getWantlist();

            // Online = Source of Truth
            merged = List.of(online);

            // Nur bei tatsächlicher Änderung persistieren
            if (!_listsEqualByIds(offline, merged)) {
              LoggerService.data('Wantlist sync', merged.length, 'items saved');
              await _jsonService.saveWantlist(merged);
            }
          } else {
            LoggerService.warning('Wantlist sync', 'Auth invalid - using offline only');
          }
        } catch (e) {
          LoggerService.error('Wantlist sync', e);
          // Continue with offline data on error
        }
      }

      return merged;
    } catch (e) {
      LoggerService.error('Wantlist load failed', e);
      return [];
    }
  }

  Future<bool> deleteFromWantlist(Album album) async {
    try {
      // Try to remove from Discogs first (if authenticated)
      if (_discogsService != null && _discogsService!.hasAuth) {
        try {
          await _discogsService!.removeFromWantlist(album.id);
          LoggerService.info('Discogs wantlist remove', album.name);
        } catch (e) {
          LoggerService.warning('Discogs wantlist remove failed', e.toString());
        }
      }

      // Remove from local wantlist
      final currentWantlist = await _jsonService.loadWantlist();
      final originalLength = currentWantlist.length;
      currentWantlist.removeWhere((a) => a.id == album.id);
      
      if (currentWantlist.length < originalLength) {
        await _jsonService.saveWantlist(currentWantlist);
        LoggerService.info('Local wantlist remove', album.name);
        return true;
      }
      
      return false;
    } catch (e) {
      LoggerService.error('Wantlist delete failed', e);
      rethrow;
    }
  }

  Future<bool> addToCollection({
    required Album wantlistAlbum,
    required JsonService collectionJsonService,
  }) async {
    try {
      // Ensure tracks are loaded
      final albumWithTracks = await _ensureTracksLoaded(wantlistAlbum);
      
      // Add to collection
      final collection = await collectionJsonService.loadAlbums();
      
      // Check for duplicates
      final duplicate = collection.any((existing) => 
          existing.name.toLowerCase() == albumWithTracks.name.toLowerCase() &&
          existing.artist.toLowerCase() == albumWithTracks.artist.toLowerCase());
      
      if (duplicate) {
        throw Exception('Album bereits in Sammlung vorhanden');
      }
      
      collection.add(albumWithTracks);
      await collectionJsonService.saveAlbums(collection);
      
      // Remove from wantlist
      await deleteFromWantlist(wantlistAlbum);
      
      LoggerService.info('Wantlist to collection', 
          '${albumWithTracks.name} moved to collection');
      return true;
    } catch (e) {
      LoggerService.error('Wantlist to collection failed', e);
      rethrow;
    }
  }

  Future<Album> _ensureTracksLoaded(Album album) async {
    // If tracks are already present and not empty, return as-is
    if (album.tracks.isNotEmpty) {
      return album;
    }

    // Try to load tracks from Discogs if authenticated
    if (_discogsService != null && _discogsService!.hasAuth) {
      try {
        final tracks = await _discogsService!.getReleaseTracklist(album.id);
        if (tracks.isNotEmpty) {
          return album.copyWith(tracks: tracks);
        }
      } catch (e) {
        LoggerService.warning('Track loading failed', e.toString());
      }
    }

    // Fallback: Create a default track
    final fallbackTrack = Track(trackNumber: '01', title: album.name);
    return album.copyWith(tracks: [fallbackTrack]);
  }

  List<Album> filterWantlist(List<Album> albums, String searchQuery) {
    if (searchQuery.isEmpty) return albums;
    
    final query = searchQuery.toLowerCase();
    return albums.where((album) {
      return album.name.toLowerCase().contains(query) ||
             album.artist.toLowerCase().contains(query);
    }).toList();
  }

  bool _listsEqualByIds(List<Album> a, List<Album> b) {
    if (a.length != b.length) return false;
    final sa = a.map((x) => x.id).toSet();
    final sb = b.map((x) => x.id).toSet();
    return sa.containsAll(sb) && sb.containsAll(sa);
  }
}