// test/album_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/models/album_model.dart';

void main() {
  // -- Album Tests --

  group('Album.fromMap', () {
    test('creates Album correctly from valid map data', () {
      final map = {
        'id': 'abc-123',
        'name': 'Illmatic',
        'artist': 'Nas',
        'genre': 'Hip-Hop',
        'year': '1994',
        'medium': 'Vinyl',
        'digital': true,
        'tracks': [
          {'title': 'N.Y. State of Mind', 'trackNumber': '1'},
          {'title': 'Life\'s a Bitch', 'trackNumber': '2'},
        ],
      };

      final album = Album.fromMap(map);

      expect(album.id, 'abc-123');
      expect(album.name, 'Illmatic');
      expect(album.artist, 'Nas');
      expect(album.genre, 'Hip-Hop');
      expect(album.year, '1994');
      expect(album.medium, 'Vinyl');
      expect(album.digital, true);
      expect(album.tracks.length, 2);
      expect(album.tracks[0].title, 'N.Y. State of Mind');
      expect(album.tracks[1].trackNumber, '2');
    });

    test('handles null tracks list gracefully', () {
      final map = {
        'id': 'abc-123',
        'name': 'Illmatic',
        'artist': 'Nas',
        'genre': 'Hip-Hop',
        'year': '1994',
        'medium': 'Vinyl',
        'digital': false,
        'tracks': null,
      };

      final album = Album.fromMap(map);

      expect(album.tracks, isEmpty);
    });

    test('handles missing tracks key by defaulting to empty list', () {
      final map = {
        'id': 'abc-123',
        'name': 'Illmatic',
        'artist': 'Nas',
        'genre': 'Hip-Hop',
      };

      final album = Album.fromMap(map);

      expect(album.tracks, isEmpty);
    });

    test('applies defaults for missing optional fields', () {
      final map = {
        'id': 'abc-123',
        'name': 'Illmatic',
        'artist': 'Nas',
        'genre': 'Hip-Hop',
      };

      final album = Album.fromMap(map);

      expect(album.year, 'Unknown');
      expect(album.medium, 'Unknown');
      expect(album.digital, false);
    });
  });

  group('Album.toMap', () {
    test('roundtrip: toMap then fromMap produces equal album', () {
      final original = Album(
        id: 'xyz-789',
        name: 'Ready to Die',
        artist: 'The Notorious B.I.G.',
        genre: 'Hip-Hop',
        year: '1994',
        medium: 'CD',
        digital: false,
        tracks: [
          const Track(title: 'Intro', trackNumber: '1'),
          const Track(title: 'Things Done Changed', trackNumber: '2'),
        ],
      );

      final map = original.toMap();
      final restored = Album.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.artist, original.artist);
      expect(restored.genre, original.genre);
      expect(restored.year, original.year);
      expect(restored.medium, original.medium);
      expect(restored.digital, original.digital);
      expect(restored.tracks.length, original.tracks.length);
      expect(restored.tracks[0], original.tracks[0]);
      expect(restored.tracks[1], original.tracks[1]);
    });

    test('toMap includes all fields in the output', () {
      final album = Album(
        id: '1',
        name: 'Test',
        artist: 'Artist',
        genre: 'Rock',
        year: '2020',
        medium: 'Vinyl',
        digital: true,
        tracks: [],
      );

      final map = album.toMap();

      expect(map.containsKey('id'), true);
      expect(map.containsKey('name'), true);
      expect(map.containsKey('artist'), true);
      expect(map.containsKey('genre'), true);
      expect(map.containsKey('year'), true);
      expect(map.containsKey('medium'), true);
      expect(map.containsKey('digital'), true);
      expect(map.containsKey('tracks'), true);
      expect(map['tracks'], isA<List>());
    });
  });

  group('Album.copyWith', () {
    late Album base;

    setUp(() {
      base = Album(
        id: 'orig-id',
        name: 'Original Name',
        artist: 'Original Artist',
        genre: 'Jazz',
        year: '1960',
        medium: 'Vinyl',
        digital: false,
        tracks: [const Track(title: 'Track 1', trackNumber: '1')],
      );
    });

    test('partial override only changes specified fields', () {
      final updated = base.copyWith(name: 'New Name', digital: true);

      expect(updated.name, 'New Name');
      expect(updated.digital, true);
      // Unchanged fields remain the same
      expect(updated.id, base.id);
      expect(updated.artist, base.artist);
      expect(updated.genre, base.genre);
      expect(updated.year, base.year);
      expect(updated.medium, base.medium);
      expect(updated.tracks, base.tracks);
    });

    test('full override replaces all fields', () {
      final newTracks = [const Track(title: 'Replaced', trackNumber: '99')];
      final updated = base.copyWith(
        id: 'new-id',
        name: 'New',
        artist: 'New Artist',
        genre: 'Electronic',
        year: '2025',
        medium: 'Digital',
        digital: true,
        tracks: newTracks,
      );

      expect(updated.id, 'new-id');
      expect(updated.name, 'New');
      expect(updated.artist, 'New Artist');
      expect(updated.genre, 'Electronic');
      expect(updated.year, '2025');
      expect(updated.medium, 'Digital');
      expect(updated.digital, true);
      expect(updated.tracks, newTracks);
    });

    test('copyWith with no arguments returns equivalent album', () {
      final copy = base.copyWith();

      expect(copy, equals(base));
      expect(copy.tracks, base.tracks);
    });
  });

  group('Album == and hashCode', () {
    test('two albums with identical fields are equal', () {
      final a = Album(
        id: '1',
        name: 'A',
        artist: 'B',
        genre: 'C',
        year: '2000',
        medium: 'CD',
        digital: false,
        tracks: [],
      );
      final b = Album(
        id: '1',
        name: 'A',
        artist: 'B',
        genre: 'C',
        year: '2000',
        medium: 'CD',
        digital: false,
        tracks: [],
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('albums with different ids are not equal', () {
      final a = Album(
        id: '1',
        name: 'A',
        artist: 'B',
        genre: 'C',
        year: '2000',
        medium: 'CD',
        digital: false,
        tracks: [],
      );
      final b = Album(
        id: '2',
        name: 'A',
        artist: 'B',
        genre: 'C',
        year: '2000',
        medium: 'CD',
        digital: false,
        tracks: [],
      );

      expect(a, isNot(equals(b)));
    });

    test('albums with different names are not equal', () {
      final a = Album(
        id: '1',
        name: 'Alpha',
        artist: 'B',
        genre: 'C',
        year: '2000',
        medium: 'CD',
        digital: false,
        tracks: [],
      );
      final b = Album(
        id: '1',
        name: 'Beta',
        artist: 'B',
        genre: 'C',
        year: '2000',
        medium: 'CD',
        digital: false,
        tracks: [],
      );

      expect(a, isNot(equals(b)));
    });

    test('equality ignores track list differences (by design)', () {
      final a = Album(
        id: '1',
        name: 'A',
        artist: 'B',
        genre: 'C',
        year: '2000',
        medium: 'CD',
        digital: false,
        tracks: [const Track(title: 'X', trackNumber: '1')],
      );
      final b = Album(
        id: '1',
        name: 'A',
        artist: 'B',
        genre: 'C',
        year: '2000',
        medium: 'CD',
        digital: false,
        tracks: [],
      );

      expect(a, equals(b),
          reason: 'Album equality does not compare tracks');
    });

    test('album is not equal to a non-Album object', () {
      final album = Album(
        id: '1',
        name: 'A',
        artist: 'B',
        genre: 'C',
        year: '2000',
        medium: 'CD',
        digital: false,
        tracks: [],
      );

      // ignore: unrelated_type_equality_checks
      expect(album == 'not an album', false);
    });
  });

  // -- Track Tests --

  group('Track.fromMap', () {
    test('creates Track from valid map', () {
      final map = {'title': 'So What', 'trackNumber': '1'};

      final track = Track.fromMap(map);

      expect(track.title, 'So What');
      expect(track.trackNumber, '1');
    });

    test('applies default title when missing', () {
      final map = {'trackNumber': '3'};

      final track = Track.fromMap(map);

      expect(track.title, 'Unknown');
    });

    test('applies default trackNumber when missing', () {
      final map = {'title': 'Freddie Freeloader'};

      final track = Track.fromMap(map);

      expect(track.trackNumber, '00');
    });

    test('applies all defaults for empty map', () {
      final track = Track.fromMap({});

      expect(track.title, 'Unknown');
      expect(track.trackNumber, '00');
    });

    test('applies defaults when values are null', () {
      final map = {'title': null, 'trackNumber': null};

      final track = Track.fromMap(map);

      expect(track.title, 'Unknown');
      expect(track.trackNumber, '00');
    });
  });

  group('Track.toMap', () {
    test('roundtrip: toMap then fromMap produces equal track', () {
      const original = Track(title: 'Blue in Green', trackNumber: '3');

      final map = original.toMap();
      final restored = Track.fromMap(map);

      expect(restored, equals(original));
    });

    test('toMap output contains correct keys and values', () {
      const track = Track(title: 'All Blues', trackNumber: '4');

      final map = track.toMap();

      expect(map, {'title': 'All Blues', 'trackNumber': '4'});
    });
  });

  group('Track immutability', () {
    test('Track fields are final and set via constructor', () {
      const track = Track(title: 'Flamenco Sketches', trackNumber: '5');

      expect(track.title, 'Flamenco Sketches');
      expect(track.trackNumber, '5');

      // The const constructor proves immutability: if Track fields were not
      // final, Dart would not allow const construction.
      const same = Track(title: 'Flamenco Sketches', trackNumber: '5');
      expect(identical(track, same), true,
          reason: 'Const tracks with same values should be identical');
    });
  });

  group('Track.getNumericSortOrder', () {
    test('simple integer string "1" returns 1', () {
      const track = Track(title: 't', trackNumber: '1');
      expect(track.getNumericSortOrder(), 1);
    });

    test('zero-padded integer string "01" returns 1', () {
      const track = Track(title: 't', trackNumber: '01');
      expect(track.getNumericSortOrder(), 1);
    });

    test('larger number "12" returns 12', () {
      const track = Track(title: 't', trackNumber: '12');
      expect(track.getNumericSortOrder(), 12);
    });

    test('alphanumeric "A1" returns 101 (A=100 + 1)', () {
      const track = Track(title: 't', trackNumber: 'A1');
      expect(track.getNumericSortOrder(), 101);
    });

    test('alphanumeric "B2" returns 202 (B=200 + 2)', () {
      const track = Track(title: 't', trackNumber: 'B2');
      expect(track.getNumericSortOrder(), 202);
    });

    test('alphanumeric lowercase "a3" returns 103 (A=100 + 3)', () {
      const track = Track(title: 't', trackNumber: 'a3');
      expect(track.getNumericSortOrder(), 103);
    });

    test('alphanumeric "C10" returns 310 (C=300 + 10)', () {
      const track = Track(title: 't', trackNumber: 'C10');
      expect(track.getNumericSortOrder(), 310);
    });

    test('decimal "1.1" returns 11 (1*10 + 1)', () {
      const track = Track(title: 't', trackNumber: '1.1');
      expect(track.getNumericSortOrder(), 11);
    });

    test('decimal "2.3" returns 23 (2*10 + 3)', () {
      const track = Track(title: 't', trackNumber: '2.3');
      expect(track.getNumericSortOrder(), 23);
    });

    test('empty string returns 0', () {
      const track = Track(title: 't', trackNumber: '');
      expect(track.getNumericSortOrder(), 0);
    });

    test('mixed text with number "Track 5" extracts 5', () {
      const track = Track(title: 't', trackNumber: 'Track 5');
      expect(track.getNumericSortOrder(), 5);
    });

    test('mixed text "Side-B-3" extracts first number 3', () {
      const track = Track(title: 't', trackNumber: 'Side-B-3');
      expect(track.getNumericSortOrder(), 3);
    });

    test('pure alphabetic string falls back to hashCode-based value', () {
      const track = Track(title: 't', trackNumber: 'Intro');
      final result = track.getNumericSortOrder();
      // Should be a non-negative number derived from hashCode % 10000
      expect(result, greaterThanOrEqualTo(0));
      expect(result, lessThan(10000));
    });

    test('ordering: A-side tracks sort before B-side tracks', () {
      const a1 = Track(title: 't', trackNumber: 'A1');
      const a2 = Track(title: 't', trackNumber: 'A2');
      const b1 = Track(title: 't', trackNumber: 'B1');

      expect(a1.getNumericSortOrder(), lessThan(a2.getNumericSortOrder()));
      expect(a2.getNumericSortOrder(), lessThan(b1.getNumericSortOrder()));
    });
  });

  group('Track.compareTo', () {
    test('track with lower number sorts before higher', () {
      const first = Track(title: 't', trackNumber: '1');
      const second = Track(title: 't', trackNumber: '2');

      expect(first.compareTo(second), lessThan(0));
    });

    test('tracks with same number return 0', () {
      const a = Track(title: 'X', trackNumber: '5');
      const b = Track(title: 'Y', trackNumber: '5');

      expect(a.compareTo(b), 0);
    });

    test('track with higher number sorts after lower', () {
      const first = Track(title: 't', trackNumber: '10');
      const second = Track(title: 't', trackNumber: '3');

      expect(first.compareTo(second), greaterThan(0));
    });

    test('compareTo works correctly across format types', () {
      const simple = Track(title: 't', trackNumber: '1');
      const alpha = Track(title: 't', trackNumber: 'A1');

      // simple "1" = 1, alpha "A1" = 101
      expect(simple.compareTo(alpha), lessThan(0));
    });

    test('sorting a list of tracks produces correct order', () {
      final tracks = [
        const Track(title: 'Third', trackNumber: '3'),
        const Track(title: 'First', trackNumber: '1'),
        const Track(title: 'Second', trackNumber: '2'),
      ];

      tracks.sort((a, b) => a.compareTo(b));

      expect(tracks[0].title, 'First');
      expect(tracks[1].title, 'Second');
      expect(tracks[2].title, 'Third');
    });
  });

  group('Track == and hashCode', () {
    test('identical tracks are equal', () {
      const a = Track(title: 'Test', trackNumber: '1');
      const b = Track(title: 'Test', trackNumber: '1');

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('tracks with different titles are not equal', () {
      const a = Track(title: 'Alpha', trackNumber: '1');
      const b = Track(title: 'Beta', trackNumber: '1');

      expect(a, isNot(equals(b)));
    });

    test('tracks with different trackNumbers are not equal', () {
      const a = Track(title: 'Same', trackNumber: '1');
      const b = Track(title: 'Same', trackNumber: '2');

      expect(a, isNot(equals(b)));
    });

    test('track is not equal to a non-Track object', () {
      const track = Track(title: 'X', trackNumber: '1');
      // ignore: unrelated_type_equality_checks
      expect(track == 'not a track', false);
    });

    test('equal tracks can be used as Set/Map keys', () {
      const a = Track(title: 'T', trackNumber: '1');
      const b = Track(title: 'T', trackNumber: '1');

      final trackSet = <Track>{a};
      trackSet.add(b);
      expect(trackSet.length, 1);
    });
  });

  // -- DiscogsSearchResult Tests --

  group('DiscogsSearchResult.fromJson', () {
    test('creates result from full data with explicit artist', () {
      final json = {
        'id': 12345,
        'title': 'Some Album Title',
        'artist': 'Miles Davis',
        'genre': ['Jazz', 'Fusion'],
        'year': '1970',
        'format': ['Vinyl', 'LP'],
        'thumb': 'https://example.com/thumb.jpg',
      };

      final result = DiscogsSearchResult.fromJson(json);

      expect(result.id, '12345');
      expect(result.title, 'Some Album Title');
      expect(result.artist, 'Miles Davis');
      expect(result.genre, 'Jazz');
      expect(result.year, '1970');
      expect(result.format, 'Vinyl');
      expect(result.imageUrl, 'https://example.com/thumb.jpg');
    });

    test('parses "Artist - Title" format from title field', () {
      final json = {
        'id': 999,
        'title': 'Kendrick Lamar - good kid, m.A.A.d city',
      };

      final result = DiscogsSearchResult.fromJson(json);

      // Without an explicit artist field, artist is parsed from title
      expect(result.artist, 'Kendrick Lamar');
      expect(result.title, 'good kid, m.A.A.d city');
    });

    test('explicit artist field overrides parsed artist from title', () {
      final json = {
        'id': 100,
        'title': 'Wrong Artist - Album Name',
        'artist': 'Correct Artist',
      };

      final result = DiscogsSearchResult.fromJson(json);

      expect(result.artist, 'Correct Artist');
      expect(result.title, 'Album Name');
    });

    test('handles title with multiple dashes correctly', () {
      final json = {
        'id': 200,
        'title': 'Artist Name - Part One - Remastered',
      };

      final result = DiscogsSearchResult.fromJson(json);

      expect(result.artist, 'Artist Name');
      expect(result.title, 'Part One - Remastered');
    });

    test('handles missing fields with defaults', () {
      final json = <String, dynamic>{
        'id': null,
      };

      final result = DiscogsSearchResult.fromJson(json);

      expect(result.id, '');
      expect(result.title, 'Unknown Title');
      expect(result.artist, 'Unknown Artist');
      expect(result.genre, '');
      expect(result.year, '');
      expect(result.format, 'Unknown');
      expect(result.imageUrl, '');
    });

    test('handles completely empty map', () {
      final result = DiscogsSearchResult.fromJson({});

      expect(result.id, '');
      expect(result.title, 'Unknown Title');
      expect(result.artist, 'Unknown Artist');
    });

    test('genre as a single string is used directly', () {
      final json = {
        'id': 1,
        'title': 'Test',
        'genre': 'Rock',
      };

      final result = DiscogsSearchResult.fromJson(json);
      expect(result.genre, 'Rock');
    });

    test('genre as a list uses the first element', () {
      final json = {
        'id': 1,
        'title': 'Test',
        'genre': ['Electronic', 'Ambient'],
      };

      final result = DiscogsSearchResult.fromJson(json);
      expect(result.genre, 'Electronic');
    });

    test('format as a single string is used directly', () {
      final json = {
        'id': 1,
        'title': 'Test',
        'format': 'CD',
      };

      final result = DiscogsSearchResult.fromJson(json);
      expect(result.format, 'CD');
    });

    test('format as a list uses the first element', () {
      final json = {
        'id': 1,
        'title': 'Test',
        'format': ['Vinyl', '12"', 'Album'],
      };

      final result = DiscogsSearchResult.fromJson(json);
      expect(result.format, 'Vinyl');
    });

    test('integer id is converted to string', () {
      final json = {
        'id': 42,
        'title': 'Test',
      };

      final result = DiscogsSearchResult.fromJson(json);
      expect(result.id, '42');
    });
  });

  group('DiscogsSearchResult == and hashCode', () {
    test('equal results with same id, title, artist are equal', () {
      final a = DiscogsSearchResult(
        id: '1',
        title: 'Album',
        artist: 'Artist',
        genre: 'Rock',
        year: '2020',
        format: 'CD',
        imageUrl: 'http://a.com/img.jpg',
      );
      final b = DiscogsSearchResult(
        id: '1',
        title: 'Album',
        artist: 'Artist',
        genre: 'Jazz',
        year: '1999',
        format: 'Vinyl',
        imageUrl: 'http://b.com/other.jpg',
      );

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('results with different ids are not equal', () {
      final a = DiscogsSearchResult(
        id: '1',
        title: 'Album',
        artist: 'Artist',
        genre: '',
        year: '',
        format: '',
        imageUrl: '',
      );
      final b = DiscogsSearchResult(
        id: '2',
        title: 'Album',
        artist: 'Artist',
        genre: '',
        year: '',
        format: '',
        imageUrl: '',
      );

      expect(a, isNot(equals(b)));
    });

    test('results with different titles are not equal', () {
      final a = DiscogsSearchResult(
        id: '1',
        title: 'Album A',
        artist: 'Artist',
        genre: '',
        year: '',
        format: '',
        imageUrl: '',
      );
      final b = DiscogsSearchResult(
        id: '1',
        title: 'Album B',
        artist: 'Artist',
        genre: '',
        year: '',
        format: '',
        imageUrl: '',
      );

      expect(a, isNot(equals(b)));
    });

    test('results with different artists are not equal', () {
      final a = DiscogsSearchResult(
        id: '1',
        title: 'Album',
        artist: 'Artist A',
        genre: '',
        year: '',
        format: '',
        imageUrl: '',
      );
      final b = DiscogsSearchResult(
        id: '1',
        title: 'Album',
        artist: 'Artist B',
        genre: '',
        year: '',
        format: '',
        imageUrl: '',
      );

      expect(a, isNot(equals(b)));
    });

    test('result is not equal to a non-DiscogsSearchResult object', () {
      final result = DiscogsSearchResult(
        id: '1',
        title: 'T',
        artist: 'A',
        genre: '',
        year: '',
        format: '',
        imageUrl: '',
      );

      // ignore: unrelated_type_equality_checks
      expect(result == 'not a result', false);
    });

    test('equal results work correctly as Set elements', () {
      final a = DiscogsSearchResult(
        id: '1',
        title: 'Album',
        artist: 'Artist',
        genre: 'Rock',
        year: '2020',
        format: 'CD',
        imageUrl: '',
      );
      final b = DiscogsSearchResult(
        id: '1',
        title: 'Album',
        artist: 'Artist',
        genre: 'Jazz',
        year: '1980',
        format: 'Vinyl',
        imageUrl: '',
      );

      final set = {a, b};
      expect(set.length, 1);
    });
  });
}
