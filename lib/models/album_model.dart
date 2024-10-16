// lib/models/album_model.dart

class Album {
  final String id;
  final String name;
  final String artist;
  final String genre;
  final String year;
  final String medium;
  final bool digital;
  final List<Track> tracks;

  Album({
    required this.id,
    required this.name,
    required this.artist,
    required this.genre,
    required this.year,
    required this.medium,
    required this.digital,
    required this.tracks,
  });

  factory Album.fromMap(Map<String, dynamic> json) {
    var tracksFromJson = json['tracks'] as List;
    List<Track> tracksList = tracksFromJson.map((i) => Track.fromMap(i)).toList();

    return Album(
      id: json['id'],
      name: json['name'],
      artist: json['artist'],
      genre: json['genre'],
      year: json['year'] ?? 'Unknown',
      medium: json['medium'] ?? 'Unknown',
      digital: json['digital'] ?? false,
      tracks: tracksList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'artist': artist,
      'genre': genre,
      'year': year,
      'medium': medium,
      'digital': digital,
      'tracks': tracks.map((track) => track.toMap()).toList(),
    };
  }

  // Hinzugefügte copyWith-Methode
  Album copyWith({
    String? id,
    String? name,
    String? artist,
    String? genre,
    String? year,
    String? medium,
    bool? digital,
    List<Track>? tracks,
  }) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      medium: medium ?? this.medium,
      digital: digital ?? this.digital,
      tracks: tracks ?? this.tracks,
    );
  }
}

class Track {
  String title;
  String trackNumber;

  Track({required this.title, required this.trackNumber});

  factory Track.fromMap(Map<String, dynamic> json) {
    return Track(
      title: json['title'] ?? 'Unknown',
      trackNumber: json['trackNumber'] ?? '00',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'trackNumber': trackNumber,
    };
  }

  String getFormattedTrackNumber() {
    return trackNumber.padLeft(2, '0');
  }
}
