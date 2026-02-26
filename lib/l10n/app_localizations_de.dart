// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get cancel => 'Abbrechen';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get close => 'Schließen';

  @override
  String get search => 'Suchen';

  @override
  String get searchHint => 'Suchen...';

  @override
  String get loading => 'Laden...';

  @override
  String get error => 'Fehler';

  @override
  String errorGeneric(String error) {
    return 'Fehler: $error';
  }

  @override
  String get unknown => 'Unbekannt';

  @override
  String get add => 'Hinzufügen';

  @override
  String get remove => 'Entfernen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get all => 'Alle';

  @override
  String get settings => 'Einstellungen';

  @override
  String get resetSettings => 'Einstellungen zurücksetzen';

  @override
  String get resetSettingsConfirm =>
      'Sollen alle Einstellungen auf Standard zurückgesetzt werden?';

  @override
  String get settingsReset => 'Einstellungen zurückgesetzt';

  @override
  String errorLoadingSettings(String error) {
    return 'Fehler beim Laden der Einstellungen: $error';
  }

  @override
  String errorResetting(String error) {
    return 'Fehler beim Zurücksetzen: $error';
  }

  @override
  String get filePaths => 'Dateipfade';

  @override
  String get collectionJsonFile => 'Collection JSON-Datei';

  @override
  String get wantlistJsonFile => 'Wantlist JSON-Datei';

  @override
  String get noFileSelected => 'Keine Datei ausgewählt';

  @override
  String get browse => 'Durchsuchen';

  @override
  String get collectionPathUpdated => 'Sammlungspfad aktualisiert';

  @override
  String get wantlistPathUpdated => 'Wantlist-Pfad aktualisiert';

  @override
  String errorFileSelection(String error) {
    return 'Fehler bei Dateiauswahl: $error';
  }

  @override
  String get discogsIntegration => 'Discogs Integration';

  @override
  String get importExport => 'Import / Export';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeLightDesc => 'Immer helles Design verwenden';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeDarkDesc => 'Immer dunkles Design verwenden';

  @override
  String get themeSystem => 'System';

  @override
  String get themeSystemDesc => 'Systemeinstellung verwenden';

  @override
  String get advanced => 'Erweitert';

  @override
  String get logLevel => 'Log-Level';

  @override
  String get logLevelDebug => 'Alle Meldungen (Debug)';

  @override
  String get logLevelInfo => 'Info und höher';

  @override
  String get logLevelWarning => 'Nur Warnungen und Fehler';

  @override
  String get logLevelError => 'Nur Fehler';

  @override
  String logFilesInfo(int count, String size) {
    return '$count Dateien, aktuelle: $size';
  }

  @override
  String get aboutMusicUp => 'Über MusicUp';

  @override
  String get help => 'Hilfe';

  @override
  String get helpSubtitle => 'Dokumentation und Bedienungsanleitung';

  @override
  String get startTour => 'Tour starten';

  @override
  String get startTourSubtitle => 'Interaktive Einführung in die App';

  @override
  String get version => 'Version';

  @override
  String get license => 'Lizenz';

  @override
  String get proprietarySoftware => 'Proprietäre Software';

  @override
  String get developer => 'Entwickler';

  @override
  String get contact => 'Kontakt';

  @override
  String get reportProblem => 'Problem melden';

  @override
  String get reportProblemSubtitle => 'E-Mail an Support senden';

  @override
  String get sendLogs => 'Logs senden';

  @override
  String get sendLogsDefault => 'Log-Dateien teilen';

  @override
  String get repository => 'Repository';

  @override
  String get language => 'Sprache';

  @override
  String get musicUpCollection => 'MusicUp Collection';

  @override
  String get addAlbumTooltip => 'Album hinzufügen';

  @override
  String get openWantlist => 'Wantlist öffnen';

  @override
  String get searchDiscogs => 'Discogs durchsuchen';

  @override
  String albumDeletedSuccess(String name) {
    return '\"$name\" gelöscht';
  }

  @override
  String errorDeleting(String error) {
    return 'Fehler beim Löschen: $error';
  }

  @override
  String get deleteAlbum => 'Album löschen';

  @override
  String deleteAlbumConfirm(String name) {
    return 'Möchten Sie \"$name\" wirklich löschen?';
  }

  @override
  String get tourCollectionTitle => 'Deine Sammlung';

  @override
  String get tourCollectionDesc =>
      'Hier siehst du alle Alben deiner Sammlung auf einen Blick.';

  @override
  String get tourSearchTitle => 'Suche';

  @override
  String get tourSearchDesc =>
      'Durchsuche deine Alben nach Name, Künstler oder Genre.';

  @override
  String get tourFilterTitle => 'Filter';

  @override
  String get tourFilterDesc =>
      'Filtere nach Medium (Vinyl, CD, ...) und weiteren Kriterien.';

  @override
  String get tourAddAlbumTitle => 'Album hinzufügen';

  @override
  String get tourAddAlbumDesc =>
      'Füge ein neues Album zu deiner Sammlung hinzu.';

  @override
  String get tourSettingsTitle => 'Einstellungen';

  @override
  String get tourSettingsDesc =>
      'Hier findest du Einstellungen, Import/Export und die Discogs-Anbindung.';

  @override
  String get addNewAlbum => 'Neues Album hinzufügen';

  @override
  String get importFromFolder => 'Aus Ordner importieren';

  @override
  String get saveAlbum => 'Album speichern';

  @override
  String get draftFound => 'Entwurf gefunden';

  @override
  String get draftFoundMessage =>
      'Es wurde ein gespeicherter Entwurf gefunden. Möchten Sie ihn laden?';

  @override
  String get loadDraft => 'Ja, laden';

  @override
  String get draftLoaded => 'Entwurf geladen';

  @override
  String get saveChangesQuestion => 'Änderungen speichern?';

  @override
  String get saveChangesBeforeLeaving =>
      'Möchten Sie das neue Album vor dem Verlassen der Seite speichern?';

  @override
  String get dontSave => 'Nicht speichern';

  @override
  String get saveAndLeave => 'Speichern & Verlassen';

  @override
  String tracksImported(int count, String name) {
    return '$count Tracks aus \"$name\" importiert';
  }

  @override
  String errorImporting(String error) {
    return 'Fehler beim Importieren: $error';
  }

  @override
  String get trackWithTitleRequired =>
      'Mindestens ein Track mit Titel ist erforderlich';

  @override
  String albumAddedSuccess(String name) {
    return 'Album \"$name\" erfolgreich hinzugefügt';
  }

  @override
  String get editAlbum => 'Album bearbeiten';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get unsavedChanges => 'Ungespeicherte Änderungen';

  @override
  String get unsavedChangesMessage =>
      'Sie haben ungespeicherte Änderungen. Möchten Sie diese verwerfen?';

  @override
  String get continueEditing => 'Bearbeitung fortsetzen';

  @override
  String get discardChanges => 'Änderungen verwerfen';

  @override
  String get validationError => 'Validierungsfehler';

  @override
  String get tracksLoading => 'Tracks werden geladen...';

  @override
  String get albumInformation => 'Album-Informationen';

  @override
  String get year => 'Jahr';

  @override
  String get medium => 'Medium';

  @override
  String get digitalAvailable => 'Digital verfügbar';

  @override
  String get genre => 'Genre';

  @override
  String get trackList => 'Trackliste';

  @override
  String trackListCount(int count) {
    return 'Trackliste ($count Tracks)';
  }

  @override
  String get noTracksAvailable => 'Keine Tracks verfügbar';

  @override
  String wantlistTitle(int count) {
    return 'Wunschliste ($count)';
  }

  @override
  String get wantlistEmpty => 'Wunschliste ist leer';

  @override
  String pdfSaved(String path) {
    return 'PDF gespeichert: $path';
  }

  @override
  String pdfExportFailed(String error) {
    return 'PDF-Export fehlgeschlagen: $error';
  }

  @override
  String get exportAsPdf => 'Als PDF exportieren';

  @override
  String get exportCollectionAsPdf => 'Sammlung als PDF exportieren';

  @override
  String get collectionEmpty => 'Keine Alben zum Exportieren';

  @override
  String get sortAZ => 'Sortierung: A-Z';

  @override
  String get sortZA => 'Sortierung: Z-A';

  @override
  String get addToWantlistTooltip => 'Album zur Wantlist hinzufügen';

  @override
  String get refreshWantlist => 'Wunschliste aktualisieren';

  @override
  String get searchWantlist => 'Wunschliste durchsuchen...';

  @override
  String get addingToCollection => 'Wird zur Sammlung hinzugefügt...';

  @override
  String albumMovedToCollection(String name) {
    return '\"$name\" zur Sammlung hinzugefügt und aus Wantlist entfernt';
  }

  @override
  String albumRemovedFromWantlist(String name) {
    return '\"$name\" aus Wunschliste entfernt';
  }

  @override
  String albumRemovedFromWantlistAndDiscogs(String name) {
    return '\"$name\" aus Wunschliste und aus Discogs entfernt';
  }

  @override
  String get albumCouldNotBeRemoved => 'Album konnte nicht entfernt werden';

  @override
  String get addToWantlistTitle => 'Zur Wantlist hinzufügen';

  @override
  String get savingToWantlist => 'Speichere zur Wantlist...';

  @override
  String get wantlistInfoBanner => 'Alben, die Sie in Zukunft erwerben möchten';

  @override
  String albumAddedToWantlist(String name) {
    return '\"$name\" zur Wantlist hinzugefügt';
  }

  @override
  String get saving => 'Speichere...';

  @override
  String get addToWantlistButton => 'Zur Wantlist hinzufügen';

  @override
  String get discogsSearch => 'Discogs Suche';

  @override
  String get oauthNotConfigured =>
      'OAuth nicht konfiguriert. Bitte in den Einstellungen einrichten.';

  @override
  String get freeTextSearch => 'Freitextsuche...';

  @override
  String get advancedFilters => 'Erweiterte Filter';

  @override
  String get artist => 'Künstler';

  @override
  String get albumRelease => 'Album / Release';

  @override
  String get format => 'Format';

  @override
  String get pressCountry => 'Pressland';

  @override
  String addedToCollection(String title) {
    return '\"$title\" zur Sammlung hinzugefügt';
  }

  @override
  String addedToWantlist(String title) {
    return '\"$title\" zur Wantlist hinzugefügt';
  }

  @override
  String get welcomeTitle => 'Willkommen bei MusicUp';

  @override
  String get welcomeBody =>
      'Verwalte deine Musiksammlung. Vinyl, CD, Kassette oder Digital -- alles an einem Ort.';

  @override
  String get letsGo => 'Los geht\'s';

  @override
  String get collectionFile => 'Sammlungsdatei';

  @override
  String get collectionAutoSaved =>
      'Deine Sammlung wird automatisch im App-Verzeichnis gespeichert.';

  @override
  String get collectionChooseLocation =>
      'Wähle den Speicherort für deine Sammlungsdatei (albums.json).';

  @override
  String get selectFile => 'Datei auswählen';

  @override
  String get selectOtherFile => 'Andere Datei wählen';

  @override
  String get selectCollectionFile => 'Sammlungsdatei auswählen';

  @override
  String get discogsOptionalBody =>
      'Optional: Verbinde dein Discogs-Konto, um Alben zu suchen und deine Wantlist zu synchronisieren.';

  @override
  String get discogsConnected => 'Discogs verbunden';

  @override
  String get setupLater => 'Später einrichten';

  @override
  String get allReady => 'Alles bereit!';

  @override
  String get collection => 'Sammlung';

  @override
  String get configured => 'Konfiguriert';

  @override
  String get standard => 'Standard';

  @override
  String get discogs => 'Discogs';

  @override
  String get connected => 'Verbunden';

  @override
  String get notConfigured => 'Nicht eingerichtet';

  @override
  String get startApp => 'App starten';

  @override
  String get albumName => 'Album-Name';

  @override
  String get albumNameRequired => 'Album-Name *';

  @override
  String get artistRequired => 'Künstler *';

  @override
  String get genreOptional => 'Genre (optional)';

  @override
  String get albumDetails => 'Album-Details';

  @override
  String get selectYear => 'Jahr auswählen';

  @override
  String get selectMedium => 'Medium auswählen';

  @override
  String get digitalAvailableQuestion => 'Ist dieses Album digital verfügbar?';

  @override
  String get pleaseEnterAlbumName => 'Bitte geben Sie einen Album-Namen ein';

  @override
  String get pleaseEnterArtist => 'Bitte geben Sie einen Künstler ein';

  @override
  String get formatSettings => 'Format-Einstellungen';

  @override
  String get pleaseEnterAlbumNameShort => 'Bitte Album-Name eingeben';

  @override
  String get pleaseEnterArtistShort => 'Bitte Künstler-Name eingeben';

  @override
  String get yearOptional => 'Jahr (optional)';

  @override
  String pleaseEnterValidYear(int maxYear) {
    return 'Bitte gültiges Jahr eingeben (1900-$maxYear)';
  }

  @override
  String trackListTitle(int count) {
    return 'Track-Liste ($count Tracks)';
  }

  @override
  String get addTrack => 'Track hinzufügen';

  @override
  String get removeTrack => 'Track entfernen';

  @override
  String get noTracksAdded => 'Noch keine Tracks hinzugefügt';

  @override
  String get noAlbumsFound => 'Keine Alben gefunden';

  @override
  String get addFirstAlbum => 'Fügen Sie Ihr erstes Album hinzu';

  @override
  String get wantlistLoading => 'Wantlist wird geladen...';

  @override
  String get noWantlistEntries => 'Keine Einträge in der Wantlist';

  @override
  String get addToDiscogsWantlist =>
      'Füge Einträge zu deiner Discogs-Wantlist hinzu';

  @override
  String get configureOAuthFirst =>
      'Bitte OAuth in den Einstellungen konfigurieren';

  @override
  String artistPrefix(String artist) {
    return 'Künstler: $artist';
  }

  @override
  String yearPrefix(String year) {
    return 'Jahr: $year';
  }

  @override
  String mediumPrefix(String medium) {
    return 'Medium: $medium';
  }

  @override
  String genrePrefix(String genre) {
    return 'Genre: $genre';
  }

  @override
  String formatPrefix(String format) {
    return 'Format: $format';
  }

  @override
  String get addToCollection => 'Zur Sammlung hinzufügen';

  @override
  String get removeFromWantlist => 'Aus Wantlist entfernen';

  @override
  String get discogsOAuthConfigured =>
      'Discogs OAuth konfiguriert - Wantlist wird synchronisiert';

  @override
  String get oauthNotConfiguredLong =>
      'OAuth nicht konfiguriert. Bitte in den Einstellungen einrichten, um die Wantlist zu synchronisieren.';

  @override
  String get whatHappens => 'Was passiert:';

  @override
  String get whatHappensBody =>
      'Album wird zu Ihrer Sammlung hinzugefügt\nAlbum wird aus der Wantlist entfernt\nTrack-Informationen werden geladen';

  @override
  String get removeFromWantlistTitle => 'Aus Wantlist entfernen';

  @override
  String removeFromWantlistConfirm(String name) {
    return 'Möchten Sie \"$name\" wirklich aus der Wantlist entfernen?';
  }

  @override
  String get note => 'Hinweis:';

  @override
  String get removeFromWantlistNote =>
      'Das Album wird sowohl aus der lokalen Wantlist als auch aus Ihrer Discogs-Wantlist entfernt (falls konfiguriert).';

  @override
  String get addToCollectionDiscogsBody =>
      'Dieses Album wird zu Ihrer Sammlung hinzugefügt. Track-Informationen werden von Discogs geladen.';

  @override
  String get oauthRequired => 'OAuth erforderlich';

  @override
  String oauthRequiredBody(String title) {
    return 'Um \"$title\" zur Wantlist hinzuzufügen, benötigen Sie OAuth-Authentifizierung.';
  }

  @override
  String get oauthSetupQuestion =>
      'Möchten Sie OAuth in den Einstellungen einrichten?';

  @override
  String get later => 'Später';

  @override
  String get goToSettings => 'Zu Einstellungen';

  @override
  String get pleaseConfigureOAuth =>
      'Bitte OAuth in den Einstellungen einrichten.';

  @override
  String get pleaseEnterSearchTerms => 'Bitte Suchbegriffe eingeben';

  @override
  String searchFailed(String error) {
    return 'Suche fehlgeschlagen: $error';
  }

  @override
  String get noResultsTrySearch =>
      'Keine Ergebnisse. Versuchen Sie nach einem Künstler oder Album zu suchen.';

  @override
  String get searchRunning => 'Suche läuft...';

  @override
  String get noResultsFound => 'Keine Ergebnisse gefunden.';

  @override
  String get addToWantlistTooltipShort => 'Zur Wantlist hinzufügen';

  @override
  String get importCollection => 'Sammlung importieren';

  @override
  String get importCollectionSubtitle => 'JSON, CSV oder XML importieren';

  @override
  String get exportCollection => 'Sammlung exportieren';

  @override
  String get exportCollectionSubtitle => 'Als JSON, CSV oder XML exportieren';

  @override
  String get importFormatTitle => 'Import Format wählen';

  @override
  String get exportFormatTitle => 'Export Format wählen';

  @override
  String get standardFormat => 'Standard MusicUp Format';

  @override
  String get tableData => 'Tabellendaten';

  @override
  String get structuredData => 'Strukturierte Daten';

  @override
  String get forSpreadsheet => 'Für Excel/Calc';

  @override
  String albumsImportedWithSkipped(int count, int skipped) {
    return '$count Alben importiert ($skipped Duplikate übersprungen)';
  }

  @override
  String albumsImported(int count) {
    return '$count Alben importiert';
  }

  @override
  String importFailed(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get noAlbumsToExport => 'Keine Alben zum Exportieren vorhanden';

  @override
  String albumsExported(int count, String path) {
    return '$count Alben exportiert nach\n$path';
  }

  @override
  String exportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get supportedFormats => 'Unterstützte Formate: JSON, CSV, XML';

  @override
  String get pleaseEnterConsumerKeySecret =>
      'Bitte Consumer Key und Secret eingeben';

  @override
  String get consumerCredentialsSaved => 'Consumer-Zugangsdaten gespeichert';

  @override
  String get pleaseFirstSaveConsumerKey =>
      'Bitte zuerst Consumer Key/Secret speichern';

  @override
  String get browserOpenedVerifier =>
      'Browser geöffnet. Nach Autorisierung Verifier eingeben.';

  @override
  String couldNotOpenUrl(String url) {
    return 'Konnte URL nicht öffnen: $url';
  }

  @override
  String get pleaseEnterVerifierCode => 'Bitte Verifier-Code eingeben';

  @override
  String get invalidAccessTokenResponse =>
      'Ungültige Access-Token-Antwort erhalten';

  @override
  String get oauthCompleted => 'OAuth erfolgreich abgeschlossen';

  @override
  String get noInternetConnection =>
      'Keine Internetverbindung oder Netzwerkzugriff für MusicUp nicht erlaubt. Bitte Netzwerkberechtigung in den Systemeinstellungen prüfen.';

  @override
  String get connectionToDiscogsFailed =>
      'Verbindung zu Discogs fehlgeschlagen. Bitte Internetverbindung prüfen.';

  @override
  String oauthFailed(String error) {
    return 'OAuth fehlgeschlagen: $error';
  }

  @override
  String get discogsConnectionSuccessful => 'Discogs-Verbindung erfolgreich';

  @override
  String get discogsConnectionFailed => 'Discogs-Verbindung fehlgeschlagen';

  @override
  String get oauthTokensRemoved => 'OAuth-Tokens entfernt';

  @override
  String get discogsOAuthWriteAccess => 'Discogs OAuth (für Schreibzugriff)';

  @override
  String get verifierCodeLabel => 'Verifier-Code (nach Autorisierung)';

  @override
  String get oauthConfigured => 'OAuth konfiguriert';

  @override
  String get removeOAuth => 'OAuth entfernen';

  @override
  String get testConnection => 'Verbindung testen';

  @override
  String get oauth => 'OAuth';

  @override
  String get filterAndSort => 'Filter und Sortierung';

  @override
  String get mediumFilter => 'Medium-Filter:';

  @override
  String get resetFilters => 'Filter zurücksetzen';

  @override
  String get sorting => 'Sortierung:';

  @override
  String get digitalLabel => 'Digital:';

  @override
  String get artistCategory => 'Künstler';

  @override
  String get titleCategory => 'Titel';

  @override
  String get skipTour => 'Überspringen';

  @override
  String get nextStep => 'Weiter';

  @override
  String get finishTour => 'Fertig';

  @override
  String screenLabel(String title) {
    return 'Bildschirm: $title';
  }

  @override
  String titleLabel(String title) {
    return 'Titel: $title';
  }

  @override
  String get actionButton => 'Aktions-Button';

  @override
  String get validationAlbumNameRequired => 'Album-Name ist erforderlich';

  @override
  String get validationAlbumNameTooLong =>
      'Album-Name darf maximal 200 Zeichen lang sein';

  @override
  String get validationArtistRequired => 'Künstler-Name ist erforderlich';

  @override
  String get validationArtistTooLong =>
      'Künstler-Name darf maximal 200 Zeichen lang sein';

  @override
  String get validationGenreTooLong =>
      'Genre darf maximal 100 Zeichen lang sein';

  @override
  String get validationYearFormat =>
      'Jahr muss eine Zahl sein oder \"Unknown\"';

  @override
  String get validationYearTooOld => 'Jahr zu alt (vor 1800)';

  @override
  String get validationYearTooFuture => 'Jahr zu weit in der Zukunft';

  @override
  String get validationInvalidMedium => 'Ungültiges Medium ausgewählt';

  @override
  String get validationTrackNameRequired => 'Track-Name ist erforderlich';

  @override
  String get validationTrackNameTooLong =>
      'Track-Name darf maximal 150 Zeichen lang sein';

  @override
  String get validationTimeFormat => 'Format: MM:SS (z.B. 3:45)';

  @override
  String get validationInvalidTimeFormat => 'Ungültiges Zeitformat';

  @override
  String get validationMinutesRange => 'Minuten müssen zwischen 0-99 liegen';

  @override
  String get validationSecondsRange => 'Sekunden müssen zwischen 0-59 liegen';

  @override
  String get editValidationAlbumNameRequired => 'Album-Name ist erforderlich';

  @override
  String get editValidationArtistRequired => 'Künstler ist erforderlich';

  @override
  String get editValidationMediumRequired => 'Medium muss ausgewählt werden';

  @override
  String get editValidationDigitalRequired =>
      'Digital-Status muss ausgewählt werden';

  @override
  String get editValidationTrackRequired =>
      'Mindestens ein Track ist erforderlich';

  @override
  String editValidationTrackTitleRequired(int index) {
    return 'Track $index benötigt einen Titel';
  }

  @override
  String get helpShortDescription =>
      'Musiksammlungs-Manager für Linux und Android';

  @override
  String get helpSectionDescription => 'BESCHREIBUNG';

  @override
  String get helpDescriptionBody =>
      'MusicUp verwaltet deine Musiksammlung auf Linux und Android. Alben lassen sich manuell anlegen, aus Ordnerstrukturen importieren oder über die Discogs-Datenbank suchen und hinzufügen.';

  @override
  String get helpSectionCollection => 'SAMMLUNG VERWALTEN';

  @override
  String get helpCollectionBody =>
      'Alben anlegen mit Name, Künstler, Genre, Jahr, Medium und Tracks.\nBestehende Alben bearbeiten und Detailansicht nutzen.\nDuplikaterkennung beim Import und manuellen Anlegen.\nErweiterte Suche und Filter nach Medium, Genre, Jahr.\nSortierung nach verschiedenen Kriterien.\nSammlung als PDF exportieren (sortiert nach Künstler).';

  @override
  String get helpSectionDiscogs => 'DISCOGS INTEGRATION';

  @override
  String get helpDiscogsBody =>
      'OAuth 1.0a Authentifizierung in den Einstellungen einrichten.\nAlben in der Discogs-Datenbank suchen und mit Metadaten importieren.\nKomplette Discogs-Sammlung synchronisieren.\nAutomatisches API-Rate-Limiting.';

  @override
  String get helpSectionImportExport => 'IMPORT/EXPORT';

  @override
  String get helpImportExportBody =>
      'JSON (empfohlen): Vollständige Daten mit Tracks und Metadaten.\nCSV: Tabellenkompatibel, mit optionaler Track-Unterstützung.\nXML: Strukturiertes Format für Datenaustausch.\nOrdner-Import: Automatische Erkennung aus Musikordnern (Format: \"01 - Tracktitel.mp3\").';

  @override
  String get helpSectionWantlist => 'WANTLIST';

  @override
  String get helpWantlistBody =>
      'Eigener Bildschirm für gewünschte Alben.\nOnline/Offline-Synchronisation mit Discogs.\nAlben von der Wantlist in die Sammlung übernehmen.\nIntelligente Konflikterkennung beim Synchronisieren.\nWunschliste als PDF exportieren.';

  @override
  String get helpSectionFilePaths => 'DATEIPFADE';

  @override
  String get helpFilePathsBody =>
      'Konfiguration:   ~/.config/music_up/\nSammlung:        Konfigurierbar in Einstellungen\nWantlist:        Konfigurierbar in Einstellungen\nLogs:            Siehe Einstellungen > Logs senden';

  @override
  String get helpSectionOptions => 'OPTIONEN';

  @override
  String get helpOptionsBody =>
      '-h, --help       Hilfe anzeigen und beenden\n-v, --version    Version anzeigen und beenden';

  @override
  String get helpSectionAuthor => 'AUTOR';

  @override
  String get helpSectionBugReport => 'FEHLER MELDEN';

  @override
  String get helpBugReportBody =>
      'Fehler und Verbesserungsvorschläge per E-Mail an:\nnobo_code@posteo.de\n\nQuellcode: https://github.com/hiphopconnect/musicup';
}
