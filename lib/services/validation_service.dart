// lib/services/validation_service.dart

/// Service fuer Form-Validierung.
/// Returns keys instead of localized strings - UI layer translates via validation_translations.dart
class ValidationService {

  /// Validiert Album-Name (PFLICHT)
  static String? validateAlbumName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'albumNameRequired';
    }
    if (value.trim().length > 200) {
      return 'albumNameTooLong';
    }
    return null;
  }

  /// Validiert Kuenstler-Name (PFLICHT)
  static String? validateArtistName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'artistRequired';
    }
    if (value.trim().length > 200) {
      return 'artistTooLong';
    }
    return null;
  }

  /// Validiert Genre
  static String? validateGenre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length > 100) {
      return 'genreTooLong';
    }
    return null;
  }

  /// Validiert Jahr (sehr flexibel)
  static String? validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final normalizedValue = value.trim().toLowerCase();
    if (['unknown', 'unbekannt', 'nan', 'n/a', '?', '-'].contains(normalizedValue)) {
      return null;
    }

    final year = int.tryParse(value.trim());
    if (year == null) {
      return 'yearFormat';
    }

    final currentYear = DateTime.now().year;
    if (year < 1800) {
      return 'yearTooOld';
    }
    if (year > currentYear + 5) {
      return 'yearTooFuture';
    }

    return null;
  }

  /// Validiert Medium-Auswahl (OPTIONAL)
  static String? validateMedium(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final validMediums = ['CD', 'Vinyl', 'Cassette', 'Digital', 'Unknown'];
    if (!validMediums.contains(value)) {
      return 'invalidMedium';
    }

    return null;
  }

  /// Validiert Track-Name
  static String? validateTrackName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'trackNameRequired';
    }
    if (value.trim().length > 150) {
      return 'trackNameTooLong';
    }
    return null;
  }

  /// Validiert Track-Dauer (optional)
  static String? validateTrackDuration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final durationRegex = RegExp(r'^\d{1,2}:\d{2}$');
    if (!durationRegex.hasMatch(value.trim())) {
      return 'timeFormat';
    }

    final parts = value.trim().split(':');
    final minutes = int.tryParse(parts[0]);
    final seconds = int.tryParse(parts[1]);

    if (minutes == null || seconds == null) {
      return 'invalidTimeFormat';
    }

    if (minutes < 0 || minutes > 99) {
      return 'minutesRange';
    }

    if (seconds < 0 || seconds > 59) {
      return 'secondsRange';
    }

    return null;
  }

  /// Prueft ob Formular-Eingaben gueltig sind (Album & Kuenstler sind Pflicht)
  static bool isAlbumFormValid({
    required String albumName,
    required String artistName,
    required String genre,
    required String year,
    required String? selectedMedium,
  }) {
    return validateAlbumName(albumName) == null &&
           validateArtistName(artistName) == null &&
           validateGenre(genre) == null &&
           validateYear(year) == null &&
           validateMedium(selectedMedium) == null;
  }

  /// Zaehlt Validierungs-Fehler (Album & Kuenstler sind Pflicht)
  static int countValidationErrors({
    required String albumName,
    required String artistName,
    required String genre,
    required String year,
    required String? selectedMedium,
  }) {
    int errors = 0;

    if (validateAlbumName(albumName) != null) errors++;
    if (validateArtistName(artistName) != null) errors++;
    if (validateGenre(genre) != null) errors++;
    if (validateYear(year) != null) errors++;
    if (validateMedium(selectedMedium) != null) errors++;

    return errors;
  }

  /// Bereinigt leere Felder zu Standard-Werten
  static String getAlbumNameOrDefault(String? value) {
    return (value == null || value.trim().isEmpty) ? 'Unknown Title' : value.trim();
  }

  static String getArtistNameOrDefault(String? value) {
    return (value == null || value.trim().isEmpty) ? 'Unknown Artist' : value.trim();
  }

  static String getGenreOrDefault(String? value) {
    return (value == null || value.trim().isEmpty) ? 'Unknown Genre' : value.trim();
  }

  static String getYearOrDefault(String? value) {
    if (value == null || value.trim().isEmpty) return 'Unknown';

    final normalizedValue = value.trim().toLowerCase();
    if (['nan', 'n/a', '?', '-'].contains(normalizedValue)) {
      return 'Unknown';
    }

    return value.trim();
  }

  static String getMediumOrDefault(String? value) {
    return (value == null || value.trim().isEmpty) ? 'Unknown' : value.trim();
  }

  static bool getDigitalOrDefault(bool? value) {
    return value ?? false;
  }

  /// Bereinigt Eingabe-Text (trim + sanitize)
  static String sanitizeInput(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
