// test/album_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:music_up/models/album_model.dart';

void main() {
  test('Album serialization and deserialization', () {
    Album album = Album(
      id: '1',
      name: 'Test Album',
      artist: 'Test Artist',
      genre: 'Genre',
      year: '2021',
      medium: 'CD',
      digital: false,
      tracks: [
        Track(title: 'Track 1', trackNumber: '1'),
        Track(title: 'Track 2', trackNumber: '2'),
      ],
    );

    Map<String, dynamic> albumMap = album.toMap();
    Album newAlbum = Album.fromMap(albumMap);

    expect(newAlbum.name, album.name);
    expect(newAlbum.tracks.length, album.tracks.length);
  });
}
