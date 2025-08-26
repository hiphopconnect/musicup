// lib/services/validation_service.dart

/// Service für Form-Validierung ohne Design-Änderungen
class ValidationService {
  
  /// Validiert Album-Name (PFLICHT)
  static String? validateAlbumName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Album-Name ist erforderlich';
    }
    if (value.trim().length > 200) {
      return 'Album-Name darf maximal 200 Zeichen lang sein';
    }
    return null;
  }

  /// Validiert Künstler-Name (PFLICHT)  
  static String? validateArtistName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Künstler-Name ist erforderlich';
    }
    if (value.trim().length > 200) {
      return 'Künstler-Name darf maximal 200 Zeichen lang sein';
    }
    return null;
  }

  /// Validiert Genre
  static String? validateGenre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Leer ist OK, wird zu "Unknown Genre"
    }
    if (value.trim().length > 100) {
      return 'Genre darf maximal 100 Zeichen lang sein';
    }
    return null;
  }

  /// Validiert Jahr (sehr flexibel)
  static String? validateYear(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Leer ist OK, wird zu "Unknown"
    }
    
    // Spezielle Werte erlauben
    final normalizedValue = value.trim().toLowerCase();
    if (['unknown', 'unbekannt', 'nan', 'n/a', '?', '-'].contains(normalizedValue)) {
      return null;
    }
    
    final year = int.tryParse(value.trim());
    if (year == null) {
      return 'Jahr muss eine Zahl sein oder "Unknown"';
    }
    
    final currentYear = DateTime.now().year;
    if (year < 1800) {
      return 'Jahr zu alt (vor 1800)';
    }
    if (year > currentYear + 5) {
      return 'Jahr zu weit in der Zukunft';
    }
    
    return null;
  }

  /// Validiert Medium-Auswahl (OPTIONAL)
  static String? validateMedium(String? value) {
    // Medium ist jetzt optional
    if (value == null || value.trim().isEmpty) {
      return null; // OK, wird zu "Unknown"
    }
    
    final validMediums = ['CD', 'Vinyl', 'Kassette', 'Digital'];
    if (!validMediums.contains(value)) {
      return 'Ungültiges Medium ausgewählt';
    }
    
    return null;
  }

  /// Validiert Track-Name
  static String? validateTrackName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Track-Name ist erforderlich';
    }
    if (value.trim().length < 1) {
      return 'Track-Name darf nicht leer sein';
    }
    if (value.trim().length > 150) {
      return 'Track-Name darf maximal 150 Zeichen lang sein';
    }
    return null;
  }

  /// Validiert Track-Dauer (optional)
  static String? validateTrackDuration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Duration ist optional
    }
    
    // Format: MM:SS oder M:SS
    final durationRegex = RegExp(r'^\d{1,2}:\d{2}$');
    if (!durationRegex.hasMatch(value.trim())) {
      return 'Format: MM:SS (z.B. 3:45)';
    }
    
    final parts = value.trim().split(':');
    final minutes = int.tryParse(parts[0]);
    final seconds = int.tryParse(parts[1]);
    
    if (minutes == null || seconds == null) {
      return 'Ungültiges Zeitformat';
    }
    
    if (minutes < 0 || minutes > 99) {
      return 'Minuten müssen zwischen 0-99 liegen';
    }
    
    if (seconds < 0 || seconds > 59) {
      return 'Sekunden müssen zwischen 0-59 liegen';
    }
    
    return null;
  }

  /// Prüft ob Formular-Eingaben gültig sind (Album & Künstler sind Pflicht)
  static bool isAlbumFormValid({
    required String albumName,
    required String artistName,
    required String genre,
    required String year,
    required String? selectedMedium,
  }) {
    // Album-Name und Künstler sind Pflicht, Rest ist optional
    return validateAlbumName(albumName) == null &&
           validateArtistName(artistName) == null &&
           validateGenre(genre) == null &&
           validateYear(year) == null &&
           validateMedium(selectedMedium) == null;
  }

  /// Zählt Validierungs-Fehler (Album & Künstler sind Pflicht)
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
    return value ?? false; // Default: nicht digital
  }

  /// Bereinigt Eingabe-Text (trim + sanitize)
  static String sanitizeInput(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}