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
    List<Track> tracksList =
        tracksFromJson.map((i) => Track.fromMap(i)).toList();

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

  /// Extrahiert eine numerische Sortierungsreihenfolge aus der Track-Nummer
  /// Unterstützt Formate wie: "1", "01", "A1", "B2", "1.1", etc.
  int getNumericSortOrder() {
    if (trackNumber.isEmpty) return 0;

    try {
      // Versuche direktes Parsen für einfache Zahlen
      final directParse = int.tryParse(trackNumber);
      if (directParse != null) return directParse;

      // Behandle alphanumerische Formate (A1, B2, etc.)
      final alphaNumericMatch =
          RegExp(r'^([A-Za-z])(\d+)$').firstMatch(trackNumber);
      if (alphaNumericMatch != null) {
        final letter = alphaNumericMatch.group(1)!.toUpperCase();
        final number = int.parse(alphaNumericMatch.group(2)!);

        // Konvertiere Buchstaben zu Zahlen: A=100, B=200, C=300, etc.
        final letterValue =
            (letter.codeUnitAt(0) - 'A'.codeUnitAt(0) + 1) * 100;
        return letterValue + number;
      }

      // Behandle Dezimalzahlen (1.1, 1.2, etc.)
      final decimalMatch = RegExp(r'^(\d+)\.(\d+)$').firstMatch(trackNumber);
      if (decimalMatch != null) {
        final mainNumber = int.parse(decimalMatch.group(1)!);
        final subNumber = int.parse(decimalMatch.group(2)!);
        return (mainNumber * 10) + subNumber;
      }

      // Extrahiere erste Zahl aus gemischtem Text
      final numberMatch = RegExp(r'\d+').firstMatch(trackNumber);
      if (numberMatch != null) {
        return int.parse(numberMatch.group(0)!);
      }

      // Fallback: verwende Hash des Strings
      return trackNumber.hashCode.abs() % 10000;
    } catch (e) {
      // Absolute Fallback-Position
      return 9999;
    }
  }

  /// Vergleicht Tracks für Sortierung
  int compareTo(Track other) {
    return getNumericSortOrder().compareTo(other.getNumericSortOrder());
  }
}

class DiscogsSearchResult {
  final String id;
  final String title;
  final String artist;
  final String genre;
  final String year;
  final String format;
  final String imageUrl;

  DiscogsSearchResult({
    required this.id,
    required this.title,
    required this.artist,
    required this.genre,
    required this.year,
    required this.format,
    required this.imageUrl,
  });

  factory DiscogsSearchResult.fromJson(Map<String, dynamic> json) {
    String title = json['title']?.toString() ?? 'Unknown Title';
    String artist = 'Unknown Artist';

    // Extract artist from title if format is "Artist - Title"
    if (title.contains(' - ')) {
      final parts = title.split(' - ');
      if (parts.length >= 2) {
        artist = parts[0].trim();
        title = parts.sublist(1).join(' - ').trim();
      }
    }

    // Override with explicit artist field if available
    if (json['artist'] != null && json['artist'].toString().isNotEmpty) {
      artist = json['artist'].toString();
    }

    // Fallback: try to extract from title again if still "Unknown Artist"
    if (artist == 'Unknown Artist' && title.contains(' - ')) {
      final parts = title.split(' - ');
      if (parts.length >= 2) {
        artist = parts[0].trim();
        title = parts.sublist(1).join(' - ').trim();
      }
    }

    return DiscogsSearchResult(
      id: json['id']?.toString() ?? '',
      title: title,
      artist: artist,
      genre: (json['genre'] is List && json['genre'].isNotEmpty)
          ? json['genre'][0].toString()
          : json['genre']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      format: (json['format'] is List && json['format'].isNotEmpty)
          ? json['format'][0].toString()
          : json['format']?.toString() ?? 'Unknown',
      imageUrl: json['thumb']?.toString() ?? '',
    );
  }
}
