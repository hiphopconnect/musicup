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
}

class Track {
  String title;

  Track({required this.title});

  factory Track.fromMap(Map<String, dynamic> json) {
    return Track(
      title: json['title'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
    };
  }
}

