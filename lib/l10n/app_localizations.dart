import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// Button: Cancel
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// Button: OK
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get ok;

  /// Yes
  ///
  /// In de, this message translates to:
  /// **'Ja'**
  String get yes;

  /// No
  ///
  /// In de, this message translates to:
  /// **'Nein'**
  String get no;

  /// Button: Save
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// Button: Delete
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// Button/Tooltip: Edit
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get edit;

  /// Button: Close
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get close;

  /// Button: Search
  ///
  /// In de, this message translates to:
  /// **'Suchen'**
  String get search;

  /// Search field hint text
  ///
  /// In de, this message translates to:
  /// **'Suchen...'**
  String get searchHint;

  /// Loading indicator text
  ///
  /// In de, this message translates to:
  /// **'Laden...'**
  String get loading;

  /// Error label
  ///
  /// In de, this message translates to:
  /// **'Fehler'**
  String get error;

  /// Generic error message
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String errorGeneric(String error);

  /// Unknown value
  ///
  /// In de, this message translates to:
  /// **'Unbekannt'**
  String get unknown;

  /// Button: Add
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get add;

  /// Button: Remove
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get remove;

  /// Button: Confirm
  ///
  /// In de, this message translates to:
  /// **'Bestätigen'**
  String get confirm;

  /// Filter: All
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get all;

  /// Settings screen title
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// Reset settings dialog title / tooltip
  ///
  /// In de, this message translates to:
  /// **'Einstellungen zurücksetzen'**
  String get resetSettings;

  /// Reset settings confirmation message
  ///
  /// In de, this message translates to:
  /// **'Sollen alle Einstellungen auf Standard zurückgesetzt werden?'**
  String get resetSettingsConfirm;

  /// SnackBar: Settings reset successfully
  ///
  /// In de, this message translates to:
  /// **'Einstellungen zurückgesetzt'**
  String get settingsReset;

  /// Error loading settings
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Einstellungen: {error}'**
  String errorLoadingSettings(String error);

  /// Error resetting settings
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Zurücksetzen: {error}'**
  String errorResetting(String error);

  /// Section title: File Paths
  ///
  /// In de, this message translates to:
  /// **'Dateipfade'**
  String get filePaths;

  /// Label: Collection JSON file
  ///
  /// In de, this message translates to:
  /// **'Collection JSON-Datei'**
  String get collectionJsonFile;

  /// Label: Wantlist JSON file
  ///
  /// In de, this message translates to:
  /// **'Wantlist JSON-Datei'**
  String get wantlistJsonFile;

  /// Hint: No file selected
  ///
  /// In de, this message translates to:
  /// **'Keine Datei ausgewählt'**
  String get noFileSelected;

  /// Button: Browse for file
  ///
  /// In de, this message translates to:
  /// **'Durchsuchen'**
  String get browse;

  /// SnackBar: Collection path updated
  ///
  /// In de, this message translates to:
  /// **'Sammlungspfad aktualisiert'**
  String get collectionPathUpdated;

  /// SnackBar: Wantlist path updated
  ///
  /// In de, this message translates to:
  /// **'Wantlist-Pfad aktualisiert'**
  String get wantlistPathUpdated;

  /// Error selecting file
  ///
  /// In de, this message translates to:
  /// **'Fehler bei Dateiauswahl: {error}'**
  String errorFileSelection(String error);

  /// Section title: Discogs Integration
  ///
  /// In de, this message translates to:
  /// **'Discogs Integration'**
  String get discogsIntegration;

  /// Section title / button: Import/Export
  ///
  /// In de, this message translates to:
  /// **'Import / Export'**
  String get importExport;

  /// Section title: Appearance
  ///
  /// In de, this message translates to:
  /// **'Erscheinungsbild'**
  String get appearance;

  /// Theme: Light
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get themeLight;

  /// Theme light description
  ///
  /// In de, this message translates to:
  /// **'Immer helles Design verwenden'**
  String get themeLightDesc;

  /// Theme: Dark
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get themeDark;

  /// Theme dark description
  ///
  /// In de, this message translates to:
  /// **'Immer dunkles Design verwenden'**
  String get themeDarkDesc;

  /// Theme: System
  ///
  /// In de, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// Theme system description
  ///
  /// In de, this message translates to:
  /// **'Systemeinstellung verwenden'**
  String get themeSystemDesc;

  /// Section title: Advanced
  ///
  /// In de, this message translates to:
  /// **'Erweitert'**
  String get advanced;

  /// Label: Log level
  ///
  /// In de, this message translates to:
  /// **'Log-Level'**
  String get logLevel;

  /// Log level: Debug
  ///
  /// In de, this message translates to:
  /// **'Alle Meldungen (Debug)'**
  String get logLevelDebug;

  /// Log level: Info
  ///
  /// In de, this message translates to:
  /// **'Info und höher'**
  String get logLevelInfo;

  /// Log level: Warning
  ///
  /// In de, this message translates to:
  /// **'Nur Warnungen und Fehler'**
  String get logLevelWarning;

  /// Log level: Error
  ///
  /// In de, this message translates to:
  /// **'Nur Fehler'**
  String get logLevelError;

  /// Log files info
  ///
  /// In de, this message translates to:
  /// **'{count} Dateien, aktuelle: {size}'**
  String logFilesInfo(int count, String size);

  /// Section title: About MusicUp
  ///
  /// In de, this message translates to:
  /// **'Über MusicUp'**
  String get aboutMusicUp;

  /// Help screen title
  ///
  /// In de, this message translates to:
  /// **'Hilfe'**
  String get help;

  /// Help subtitle
  ///
  /// In de, this message translates to:
  /// **'Dokumentation und Bedienungsanleitung'**
  String get helpSubtitle;

  /// Start tour button
  ///
  /// In de, this message translates to:
  /// **'Tour starten'**
  String get startTour;

  /// Start tour subtitle
  ///
  /// In de, this message translates to:
  /// **'Interaktive Einführung in die App'**
  String get startTourSubtitle;

  /// Label: Version
  ///
  /// In de, this message translates to:
  /// **'Version'**
  String get version;

  /// Label: License
  ///
  /// In de, this message translates to:
  /// **'Lizenz'**
  String get license;

  /// License type
  ///
  /// In de, this message translates to:
  /// **'Proprietäre Software'**
  String get proprietarySoftware;

  /// Label: Developer
  ///
  /// In de, this message translates to:
  /// **'Entwickler'**
  String get developer;

  /// Label: Contact
  ///
  /// In de, this message translates to:
  /// **'Kontakt'**
  String get contact;

  /// Report problem title
  ///
  /// In de, this message translates to:
  /// **'Problem melden'**
  String get reportProblem;

  /// Report problem subtitle
  ///
  /// In de, this message translates to:
  /// **'E-Mail an Support senden'**
  String get reportProblemSubtitle;

  /// Send logs title
  ///
  /// In de, this message translates to:
  /// **'Logs senden'**
  String get sendLogs;

  /// Send logs default subtitle
  ///
  /// In de, this message translates to:
  /// **'Log-Dateien teilen'**
  String get sendLogsDefault;

  /// Label: Repository
  ///
  /// In de, this message translates to:
  /// **'Repository'**
  String get repository;

  /// Section title: Language
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get language;

  /// Main screen title
  ///
  /// In de, this message translates to:
  /// **'MusicUp Collection'**
  String get musicUpCollection;

  /// Tooltip: Add album
  ///
  /// In de, this message translates to:
  /// **'Album hinzufügen'**
  String get addAlbumTooltip;

  /// Tooltip: Open wantlist
  ///
  /// In de, this message translates to:
  /// **'Wantlist öffnen'**
  String get openWantlist;

  /// Tooltip: Search Discogs
  ///
  /// In de, this message translates to:
  /// **'Discogs durchsuchen'**
  String get searchDiscogs;

  /// SnackBar: Album deleted
  ///
  /// In de, this message translates to:
  /// **'\"{name}\" gelöscht'**
  String albumDeletedSuccess(String name);

  /// Error deleting album
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Löschen: {error}'**
  String errorDeleting(String error);

  /// Dialog title: Delete album
  ///
  /// In de, this message translates to:
  /// **'Album löschen'**
  String get deleteAlbum;

  /// Delete confirmation
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie \"{name}\" wirklich löschen?'**
  String deleteAlbumConfirm(String name);

  /// Tour step: Collection title
  ///
  /// In de, this message translates to:
  /// **'Deine Sammlung'**
  String get tourCollectionTitle;

  /// Tour step: Collection description
  ///
  /// In de, this message translates to:
  /// **'Hier siehst du alle Alben deiner Sammlung auf einen Blick.'**
  String get tourCollectionDesc;

  /// Tour step: Search title
  ///
  /// In de, this message translates to:
  /// **'Suche'**
  String get tourSearchTitle;

  /// Tour step: Search description
  ///
  /// In de, this message translates to:
  /// **'Durchsuche deine Alben nach Name, Künstler oder Genre.'**
  String get tourSearchDesc;

  /// Tour step: Filter title
  ///
  /// In de, this message translates to:
  /// **'Filter'**
  String get tourFilterTitle;

  /// Tour step: Filter description
  ///
  /// In de, this message translates to:
  /// **'Filtere nach Medium (Vinyl, CD, ...) und weiteren Kriterien.'**
  String get tourFilterDesc;

  /// Tour step: Add album title
  ///
  /// In de, this message translates to:
  /// **'Album hinzufügen'**
  String get tourAddAlbumTitle;

  /// Tour step: Add album description
  ///
  /// In de, this message translates to:
  /// **'Füge ein neues Album zu deiner Sammlung hinzu.'**
  String get tourAddAlbumDesc;

  /// Tour step: Settings title
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get tourSettingsTitle;

  /// Tour step: Settings description
  ///
  /// In de, this message translates to:
  /// **'Hier findest du Einstellungen, Import/Export und die Discogs-Anbindung.'**
  String get tourSettingsDesc;

  /// Screen title: Add new album
  ///
  /// In de, this message translates to:
  /// **'Neues Album hinzufügen'**
  String get addNewAlbum;

  /// Tooltip: Import from folder
  ///
  /// In de, this message translates to:
  /// **'Aus Ordner importieren'**
  String get importFromFolder;

  /// Button/Tooltip: Save album
  ///
  /// In de, this message translates to:
  /// **'Album speichern'**
  String get saveAlbum;

  /// Dialog title: Draft found
  ///
  /// In de, this message translates to:
  /// **'Entwurf gefunden'**
  String get draftFound;

  /// Draft found dialog message
  ///
  /// In de, this message translates to:
  /// **'Es wurde ein gespeicherter Entwurf gefunden. Möchten Sie ihn laden?'**
  String get draftFoundMessage;

  /// Button: Load draft
  ///
  /// In de, this message translates to:
  /// **'Ja, laden'**
  String get loadDraft;

  /// SnackBar: Draft loaded
  ///
  /// In de, this message translates to:
  /// **'Entwurf geladen'**
  String get draftLoaded;

  /// Dialog title: Save changes?
  ///
  /// In de, this message translates to:
  /// **'Änderungen speichern?'**
  String get saveChangesQuestion;

  /// Save changes dialog message
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie das neue Album vor dem Verlassen der Seite speichern?'**
  String get saveChangesBeforeLeaving;

  /// Button: Don't save
  ///
  /// In de, this message translates to:
  /// **'Nicht speichern'**
  String get dontSave;

  /// Button: Save and leave
  ///
  /// In de, this message translates to:
  /// **'Speichern & Verlassen'**
  String get saveAndLeave;

  /// SnackBar: Tracks imported from folder
  ///
  /// In de, this message translates to:
  /// **'{count} Tracks aus \"{name}\" importiert'**
  String tracksImported(int count, String name);

  /// Error importing
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Importieren: {error}'**
  String errorImporting(String error);

  /// Validation: At least one track with title required
  ///
  /// In de, this message translates to:
  /// **'Mindestens ein Track mit Titel ist erforderlich'**
  String get trackWithTitleRequired;

  /// SnackBar: Album added
  ///
  /// In de, this message translates to:
  /// **'Album \"{name}\" erfolgreich hinzugefügt'**
  String albumAddedSuccess(String name);

  /// Screen title / tooltip: Edit album
  ///
  /// In de, this message translates to:
  /// **'Album bearbeiten'**
  String get editAlbum;

  /// Button/Tooltip: Save changes
  ///
  /// In de, this message translates to:
  /// **'Änderungen speichern'**
  String get saveChanges;

  /// Dialog title: Unsaved changes
  ///
  /// In de, this message translates to:
  /// **'Ungespeicherte Änderungen'**
  String get unsavedChanges;

  /// Unsaved changes dialog message
  ///
  /// In de, this message translates to:
  /// **'Sie haben ungespeicherte Änderungen. Möchten Sie diese verwerfen?'**
  String get unsavedChangesMessage;

  /// Button: Continue editing
  ///
  /// In de, this message translates to:
  /// **'Bearbeitung fortsetzen'**
  String get continueEditing;

  /// Button: Discard changes
  ///
  /// In de, this message translates to:
  /// **'Änderungen verwerfen'**
  String get discardChanges;

  /// Dialog title: Validation error
  ///
  /// In de, this message translates to:
  /// **'Validierungsfehler'**
  String get validationError;

  /// Loading text: Tracks loading
  ///
  /// In de, this message translates to:
  /// **'Tracks werden geladen...'**
  String get tracksLoading;

  /// Section title: Album information
  ///
  /// In de, this message translates to:
  /// **'Album-Informationen'**
  String get albumInformation;

  /// Label: Year
  ///
  /// In de, this message translates to:
  /// **'Jahr'**
  String get year;

  /// Label: Medium
  ///
  /// In de, this message translates to:
  /// **'Medium'**
  String get medium;

  /// Label: Digitally available
  ///
  /// In de, this message translates to:
  /// **'Digital verfügbar'**
  String get digitalAvailable;

  /// Label: Genre
  ///
  /// In de, this message translates to:
  /// **'Genre'**
  String get genre;

  /// Section title: Track list
  ///
  /// In de, this message translates to:
  /// **'Trackliste'**
  String get trackList;

  /// Track list with count
  ///
  /// In de, this message translates to:
  /// **'Trackliste ({count} Tracks)'**
  String trackListCount(int count);

  /// Empty state: No tracks available
  ///
  /// In de, this message translates to:
  /// **'Keine Tracks verfügbar'**
  String get noTracksAvailable;

  /// Wantlist screen title
  ///
  /// In de, this message translates to:
  /// **'Wunschliste ({count})'**
  String wantlistTitle(int count);

  /// SnackBar: Wantlist is empty
  ///
  /// In de, this message translates to:
  /// **'Wunschliste ist leer'**
  String get wantlistEmpty;

  /// SnackBar: PDF saved
  ///
  /// In de, this message translates to:
  /// **'PDF gespeichert: {path}'**
  String pdfSaved(String path);

  /// SnackBar: PDF export failed
  ///
  /// In de, this message translates to:
  /// **'PDF-Export fehlgeschlagen: {error}'**
  String pdfExportFailed(String error);

  /// Tooltip: Export as PDF
  ///
  /// In de, this message translates to:
  /// **'Als PDF exportieren'**
  String get exportAsPdf;

  /// Tooltip: Export collection as PDF
  ///
  /// In de, this message translates to:
  /// **'Sammlung als PDF exportieren'**
  String get exportCollectionAsPdf;

  /// SnackBar: No albums to export as PDF
  ///
  /// In de, this message translates to:
  /// **'Keine Alben zum Exportieren'**
  String get collectionEmpty;

  /// Tooltip: Sort A-Z
  ///
  /// In de, this message translates to:
  /// **'Sortierung: A-Z'**
  String get sortAZ;

  /// Tooltip: Sort Z-A
  ///
  /// In de, this message translates to:
  /// **'Sortierung: Z-A'**
  String get sortZA;

  /// Tooltip: Add album to wantlist
  ///
  /// In de, this message translates to:
  /// **'Album zur Wantlist hinzufügen'**
  String get addToWantlistTooltip;

  /// Tooltip: Refresh wantlist
  ///
  /// In de, this message translates to:
  /// **'Wunschliste aktualisieren'**
  String get refreshWantlist;

  /// Hint: Search wantlist
  ///
  /// In de, this message translates to:
  /// **'Wunschliste durchsuchen...'**
  String get searchWantlist;

  /// SnackBar: Adding to collection
  ///
  /// In de, this message translates to:
  /// **'Wird zur Sammlung hinzugefügt...'**
  String get addingToCollection;

  /// SnackBar: Album moved to collection
  ///
  /// In de, this message translates to:
  /// **'\"{name}\" zur Sammlung hinzugefügt und aus Wantlist entfernt'**
  String albumMovedToCollection(String name);

  /// SnackBar: Album removed from wantlist
  ///
  /// In de, this message translates to:
  /// **'\"{name}\" aus Wunschliste entfernt'**
  String albumRemovedFromWantlist(String name);

  /// SnackBar: Album removed from wantlist and Discogs
  ///
  /// In de, this message translates to:
  /// **'\"{name}\" aus Wunschliste und aus Discogs entfernt'**
  String albumRemovedFromWantlistAndDiscogs(String name);

  /// SnackBar: Album could not be removed
  ///
  /// In de, this message translates to:
  /// **'Album konnte nicht entfernt werden'**
  String get albumCouldNotBeRemoved;

  /// Screen title: Add to wantlist
  ///
  /// In de, this message translates to:
  /// **'Zur Wantlist hinzufügen'**
  String get addToWantlistTitle;

  /// Loading text: Saving to wantlist
  ///
  /// In de, this message translates to:
  /// **'Speichere zur Wantlist...'**
  String get savingToWantlist;

  /// Info banner in add wanted album screen
  ///
  /// In de, this message translates to:
  /// **'Alben, die Sie in Zukunft erwerben möchten'**
  String get wantlistInfoBanner;

  /// SnackBar: Album added to wantlist
  ///
  /// In de, this message translates to:
  /// **'\"{name}\" zur Wantlist hinzugefügt'**
  String albumAddedToWantlist(String name);

  /// Button: Saving...
  ///
  /// In de, this message translates to:
  /// **'Speichere...'**
  String get saving;

  /// Button: Add to wantlist
  ///
  /// In de, this message translates to:
  /// **'Zur Wantlist hinzufügen'**
  String get addToWantlistButton;

  /// Screen title: Discogs Search
  ///
  /// In de, this message translates to:
  /// **'Discogs Suche'**
  String get discogsSearch;

  /// Warning: OAuth not configured
  ///
  /// In de, this message translates to:
  /// **'OAuth nicht konfiguriert. Bitte in den Einstellungen einrichten.'**
  String get oauthNotConfigured;

  /// Hint: Free text search
  ///
  /// In de, this message translates to:
  /// **'Freitextsuche...'**
  String get freeTextSearch;

  /// Label: Advanced filters
  ///
  /// In de, this message translates to:
  /// **'Erweiterte Filter'**
  String get advancedFilters;

  /// Label: Artist
  ///
  /// In de, this message translates to:
  /// **'Künstler'**
  String get artist;

  /// Label: Album / Release
  ///
  /// In de, this message translates to:
  /// **'Album / Release'**
  String get albumRelease;

  /// Label: Format
  ///
  /// In de, this message translates to:
  /// **'Format'**
  String get format;

  /// Label: Press country
  ///
  /// In de, this message translates to:
  /// **'Pressland'**
  String get pressCountry;

  /// SnackBar: Added to collection
  ///
  /// In de, this message translates to:
  /// **'\"{title}\" zur Sammlung hinzugefügt'**
  String addedToCollection(String title);

  /// SnackBar: Added to wantlist
  ///
  /// In de, this message translates to:
  /// **'\"{title}\" zur Wantlist hinzugefügt'**
  String addedToWantlist(String title);

  /// Setup wizard: Welcome title
  ///
  /// In de, this message translates to:
  /// **'Willkommen bei MusicUp'**
  String get welcomeTitle;

  /// Setup wizard: Welcome body
  ///
  /// In de, this message translates to:
  /// **'Verwalte deine Musiksammlung. Vinyl, CD, Kassette oder Digital -- alles an einem Ort.'**
  String get welcomeBody;

  /// Button: Let's go
  ///
  /// In de, this message translates to:
  /// **'Los geht\'s'**
  String get letsGo;

  /// Setup wizard: Collection file title
  ///
  /// In de, this message translates to:
  /// **'Sammlungsdatei'**
  String get collectionFile;

  /// Setup wizard: Auto-save info (mobile)
  ///
  /// In de, this message translates to:
  /// **'Deine Sammlung wird automatisch im App-Verzeichnis gespeichert.'**
  String get collectionAutoSaved;

  /// Setup wizard: Choose location (desktop)
  ///
  /// In de, this message translates to:
  /// **'Wähle den Speicherort für deine Sammlungsdatei (albums.json).'**
  String get collectionChooseLocation;

  /// Button: Select file
  ///
  /// In de, this message translates to:
  /// **'Datei auswählen'**
  String get selectFile;

  /// Button: Select other file
  ///
  /// In de, this message translates to:
  /// **'Andere Datei wählen'**
  String get selectOtherFile;

  /// File picker title
  ///
  /// In de, this message translates to:
  /// **'Sammlungsdatei auswählen'**
  String get selectCollectionFile;

  /// Setup wizard: Discogs optional description
  ///
  /// In de, this message translates to:
  /// **'Optional: Verbinde dein Discogs-Konto, um Alben zu suchen und deine Wantlist zu synchronisieren.'**
  String get discogsOptionalBody;

  /// Status: Discogs connected
  ///
  /// In de, this message translates to:
  /// **'Discogs verbunden'**
  String get discogsConnected;

  /// Button: Set up later
  ///
  /// In de, this message translates to:
  /// **'Später einrichten'**
  String get setupLater;

  /// Setup wizard: All ready title
  ///
  /// In de, this message translates to:
  /// **'Alles bereit!'**
  String get allReady;

  /// Label: Collection
  ///
  /// In de, this message translates to:
  /// **'Sammlung'**
  String get collection;

  /// Status: Configured
  ///
  /// In de, this message translates to:
  /// **'Konfiguriert'**
  String get configured;

  /// Status: Default/Standard
  ///
  /// In de, this message translates to:
  /// **'Standard'**
  String get standard;

  /// Label: Discogs
  ///
  /// In de, this message translates to:
  /// **'Discogs'**
  String get discogs;

  /// Status: Connected
  ///
  /// In de, this message translates to:
  /// **'Verbunden'**
  String get connected;

  /// Status: Not configured
  ///
  /// In de, this message translates to:
  /// **'Nicht eingerichtet'**
  String get notConfigured;

  /// Button: Start app
  ///
  /// In de, this message translates to:
  /// **'App starten'**
  String get startApp;

  /// Label: Album name
  ///
  /// In de, this message translates to:
  /// **'Album-Name'**
  String get albumName;

  /// Label: Album name (required)
  ///
  /// In de, this message translates to:
  /// **'Album-Name *'**
  String get albumNameRequired;

  /// Label: Artist (required)
  ///
  /// In de, this message translates to:
  /// **'Künstler *'**
  String get artistRequired;

  /// Label: Genre (optional)
  ///
  /// In de, this message translates to:
  /// **'Genre (optional)'**
  String get genreOptional;

  /// Section title: Album details
  ///
  /// In de, this message translates to:
  /// **'Album-Details'**
  String get albumDetails;

  /// Dropdown hint: Select year
  ///
  /// In de, this message translates to:
  /// **'Jahr auswählen'**
  String get selectYear;

  /// Dropdown hint: Select medium
  ///
  /// In de, this message translates to:
  /// **'Medium auswählen'**
  String get selectMedium;

  /// Switch subtitle: Is album digitally available?
  ///
  /// In de, this message translates to:
  /// **'Ist dieses Album digital verfügbar?'**
  String get digitalAvailableQuestion;

  /// Validation: Please enter album name
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie einen Album-Namen ein'**
  String get pleaseEnterAlbumName;

  /// Validation: Please enter artist
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie einen Künstler ein'**
  String get pleaseEnterArtist;

  /// Section title: Format settings
  ///
  /// In de, this message translates to:
  /// **'Format-Einstellungen'**
  String get formatSettings;

  /// Validation: Please enter album name (short)
  ///
  /// In de, this message translates to:
  /// **'Bitte Album-Name eingeben'**
  String get pleaseEnterAlbumNameShort;

  /// Validation: Please enter artist name (short)
  ///
  /// In de, this message translates to:
  /// **'Bitte Künstler-Name eingeben'**
  String get pleaseEnterArtistShort;

  /// Label: Year (optional)
  ///
  /// In de, this message translates to:
  /// **'Jahr (optional)'**
  String get yearOptional;

  /// Validation: Please enter valid year
  ///
  /// In de, this message translates to:
  /// **'Bitte gültiges Jahr eingeben (1900-{maxYear})'**
  String pleaseEnterValidYear(int maxYear);

  /// Section title: Track list with count
  ///
  /// In de, this message translates to:
  /// **'Track-Liste ({count} Tracks)'**
  String trackListTitle(int count);

  /// Button: Add track
  ///
  /// In de, this message translates to:
  /// **'Track hinzufügen'**
  String get addTrack;

  /// Tooltip: Remove track
  ///
  /// In de, this message translates to:
  /// **'Track entfernen'**
  String get removeTrack;

  /// Empty state: No tracks added yet
  ///
  /// In de, this message translates to:
  /// **'Noch keine Tracks hinzugefügt'**
  String get noTracksAdded;

  /// Empty state: No albums found
  ///
  /// In de, this message translates to:
  /// **'Keine Alben gefunden'**
  String get noAlbumsFound;

  /// Empty state: Add your first album
  ///
  /// In de, this message translates to:
  /// **'Fügen Sie Ihr erstes Album hinzu'**
  String get addFirstAlbum;

  /// Loading: Wantlist loading
  ///
  /// In de, this message translates to:
  /// **'Wantlist wird geladen...'**
  String get wantlistLoading;

  /// Empty state: No wantlist entries
  ///
  /// In de, this message translates to:
  /// **'Keine Einträge in der Wantlist'**
  String get noWantlistEntries;

  /// Empty state hint: Add to Discogs wantlist
  ///
  /// In de, this message translates to:
  /// **'Füge Einträge zu deiner Discogs-Wantlist hinzu'**
  String get addToDiscogsWantlist;

  /// Hint: Configure OAuth first
  ///
  /// In de, this message translates to:
  /// **'Bitte OAuth in den Einstellungen konfigurieren'**
  String get configureOAuthFirst;

  /// Artist with prefix
  ///
  /// In de, this message translates to:
  /// **'Künstler: {artist}'**
  String artistPrefix(String artist);

  /// Year with prefix
  ///
  /// In de, this message translates to:
  /// **'Jahr: {year}'**
  String yearPrefix(String year);

  /// Medium with prefix
  ///
  /// In de, this message translates to:
  /// **'Medium: {medium}'**
  String mediumPrefix(String medium);

  /// Genre with prefix
  ///
  /// In de, this message translates to:
  /// **'Genre: {genre}'**
  String genrePrefix(String genre);

  /// Format with prefix
  ///
  /// In de, this message translates to:
  /// **'Format: {format}'**
  String formatPrefix(String format);

  /// Button/Tooltip: Add to collection
  ///
  /// In de, this message translates to:
  /// **'Zur Sammlung hinzufügen'**
  String get addToCollection;

  /// Button/Tooltip: Remove from wantlist
  ///
  /// In de, this message translates to:
  /// **'Aus Wantlist entfernen'**
  String get removeFromWantlist;

  /// Status: Discogs OAuth configured
  ///
  /// In de, this message translates to:
  /// **'Discogs OAuth konfiguriert - Wantlist wird synchronisiert'**
  String get discogsOAuthConfigured;

  /// Warning: OAuth not configured (long)
  ///
  /// In de, this message translates to:
  /// **'OAuth nicht konfiguriert. Bitte in den Einstellungen einrichten, um die Wantlist zu synchronisieren.'**
  String get oauthNotConfiguredLong;

  /// Info label: What happens
  ///
  /// In de, this message translates to:
  /// **'Was passiert:'**
  String get whatHappens;

  /// Info body: What happens when adding to collection
  ///
  /// In de, this message translates to:
  /// **'Album wird zu Ihrer Sammlung hinzugefügt\nAlbum wird aus der Wantlist entfernt\nTrack-Informationen werden geladen'**
  String get whatHappensBody;

  /// Dialog title: Remove from wantlist
  ///
  /// In de, this message translates to:
  /// **'Aus Wantlist entfernen'**
  String get removeFromWantlistTitle;

  /// Remove from wantlist confirmation
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie \"{name}\" wirklich aus der Wantlist entfernen?'**
  String removeFromWantlistConfirm(String name);

  /// Label: Note
  ///
  /// In de, this message translates to:
  /// **'Hinweis:'**
  String get note;

  /// Note about removing from wantlist
  ///
  /// In de, this message translates to:
  /// **'Das Album wird sowohl aus der lokalen Wantlist als auch aus Ihrer Discogs-Wantlist entfernt (falls konfiguriert).'**
  String get removeFromWantlistNote;

  /// Dialog body: Add to collection from Discogs
  ///
  /// In de, this message translates to:
  /// **'Dieses Album wird zu Ihrer Sammlung hinzugefügt. Track-Informationen werden von Discogs geladen.'**
  String get addToCollectionDiscogsBody;

  /// Dialog title: OAuth required
  ///
  /// In de, this message translates to:
  /// **'OAuth erforderlich'**
  String get oauthRequired;

  /// OAuth required dialog body
  ///
  /// In de, this message translates to:
  /// **'Um \"{title}\" zur Wantlist hinzuzufügen, benötigen Sie OAuth-Authentifizierung.'**
  String oauthRequiredBody(String title);

  /// OAuth setup question
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie OAuth in den Einstellungen einrichten?'**
  String get oauthSetupQuestion;

  /// Button: Later
  ///
  /// In de, this message translates to:
  /// **'Später'**
  String get later;

  /// Button: Go to settings
  ///
  /// In de, this message translates to:
  /// **'Zu Einstellungen'**
  String get goToSettings;

  /// SnackBar: Please configure OAuth
  ///
  /// In de, this message translates to:
  /// **'Bitte OAuth in den Einstellungen einrichten.'**
  String get pleaseConfigureOAuth;

  /// SnackBar: Please enter search terms
  ///
  /// In de, this message translates to:
  /// **'Bitte Suchbegriffe eingeben'**
  String get pleaseEnterSearchTerms;

  /// SnackBar: Search failed
  ///
  /// In de, this message translates to:
  /// **'Suche fehlgeschlagen: {error}'**
  String searchFailed(String error);

  /// Empty state: No results, try searching
  ///
  /// In de, this message translates to:
  /// **'Keine Ergebnisse. Versuchen Sie nach einem Künstler oder Album zu suchen.'**
  String get noResultsTrySearch;

  /// Loading: Search running
  ///
  /// In de, this message translates to:
  /// **'Suche läuft...'**
  String get searchRunning;

  /// Empty state: No results found
  ///
  /// In de, this message translates to:
  /// **'Keine Ergebnisse gefunden.'**
  String get noResultsFound;

  /// Tooltip: Add to wantlist (short)
  ///
  /// In de, this message translates to:
  /// **'Zur Wantlist hinzufügen'**
  String get addToWantlistTooltipShort;

  /// List tile: Import collection
  ///
  /// In de, this message translates to:
  /// **'Sammlung importieren'**
  String get importCollection;

  /// Import collection subtitle
  ///
  /// In de, this message translates to:
  /// **'JSON, CSV oder XML importieren'**
  String get importCollectionSubtitle;

  /// List tile: Export collection
  ///
  /// In de, this message translates to:
  /// **'Sammlung exportieren'**
  String get exportCollection;

  /// Export collection subtitle
  ///
  /// In de, this message translates to:
  /// **'Als JSON, CSV oder XML exportieren'**
  String get exportCollectionSubtitle;

  /// Dialog title: Select import format
  ///
  /// In de, this message translates to:
  /// **'Import Format wählen'**
  String get importFormatTitle;

  /// Dialog title: Select export format
  ///
  /// In de, this message translates to:
  /// **'Export Format wählen'**
  String get exportFormatTitle;

  /// Format: Standard MusicUp format
  ///
  /// In de, this message translates to:
  /// **'Standard MusicUp Format'**
  String get standardFormat;

  /// Format: Table data
  ///
  /// In de, this message translates to:
  /// **'Tabellendaten'**
  String get tableData;

  /// Format: Structured data
  ///
  /// In de, this message translates to:
  /// **'Strukturierte Daten'**
  String get structuredData;

  /// Format: For spreadsheets
  ///
  /// In de, this message translates to:
  /// **'Für Excel/Calc'**
  String get forSpreadsheet;

  /// SnackBar: Albums imported with skipped
  ///
  /// In de, this message translates to:
  /// **'{count} Alben importiert ({skipped} Duplikate übersprungen)'**
  String albumsImportedWithSkipped(int count, int skipped);

  /// SnackBar: Albums imported
  ///
  /// In de, this message translates to:
  /// **'{count} Alben importiert'**
  String albumsImported(int count);

  /// SnackBar: Import failed
  ///
  /// In de, this message translates to:
  /// **'Import fehlgeschlagen: {error}'**
  String importFailed(String error);

  /// SnackBar: No albums to export
  ///
  /// In de, this message translates to:
  /// **'Keine Alben zum Exportieren vorhanden'**
  String get noAlbumsToExport;

  /// SnackBar: Albums exported
  ///
  /// In de, this message translates to:
  /// **'{count} Alben exportiert nach\n{path}'**
  String albumsExported(int count, String path);

  /// SnackBar: Export failed
  ///
  /// In de, this message translates to:
  /// **'Export fehlgeschlagen: {error}'**
  String exportFailed(String error);

  /// Info text: Supported formats
  ///
  /// In de, this message translates to:
  /// **'Unterstützte Formate: JSON, CSV, XML'**
  String get supportedFormats;

  /// SnackBar: Enter consumer key/secret
  ///
  /// In de, this message translates to:
  /// **'Bitte Consumer Key und Secret eingeben'**
  String get pleaseEnterConsumerKeySecret;

  /// SnackBar: Consumer credentials saved
  ///
  /// In de, this message translates to:
  /// **'Consumer-Zugangsdaten gespeichert'**
  String get consumerCredentialsSaved;

  /// SnackBar: Save consumer key first
  ///
  /// In de, this message translates to:
  /// **'Bitte zuerst Consumer Key/Secret speichern'**
  String get pleaseFirstSaveConsumerKey;

  /// SnackBar: Browser opened
  ///
  /// In de, this message translates to:
  /// **'Browser geöffnet. Nach Autorisierung Verifier eingeben.'**
  String get browserOpenedVerifier;

  /// SnackBar: Could not open URL
  ///
  /// In de, this message translates to:
  /// **'Konnte URL nicht öffnen: {url}'**
  String couldNotOpenUrl(String url);

  /// SnackBar: Enter verifier code
  ///
  /// In de, this message translates to:
  /// **'Bitte Verifier-Code eingeben'**
  String get pleaseEnterVerifierCode;

  /// SnackBar: Invalid access token response
  ///
  /// In de, this message translates to:
  /// **'Ungültige Access-Token-Antwort erhalten'**
  String get invalidAccessTokenResponse;

  /// SnackBar: OAuth completed
  ///
  /// In de, this message translates to:
  /// **'OAuth erfolgreich abgeschlossen'**
  String get oauthCompleted;

  /// Error: No internet connection
  ///
  /// In de, this message translates to:
  /// **'Keine Internetverbindung oder Netzwerkzugriff für MusicUp nicht erlaubt. Bitte Netzwerkberechtigung in den Systemeinstellungen prüfen.'**
  String get noInternetConnection;

  /// Error: Connection to Discogs failed
  ///
  /// In de, this message translates to:
  /// **'Verbindung zu Discogs fehlgeschlagen. Bitte Internetverbindung prüfen.'**
  String get connectionToDiscogsFailed;

  /// SnackBar: OAuth failed
  ///
  /// In de, this message translates to:
  /// **'OAuth fehlgeschlagen: {error}'**
  String oauthFailed(String error);

  /// SnackBar: Discogs connection successful
  ///
  /// In de, this message translates to:
  /// **'Discogs-Verbindung erfolgreich'**
  String get discogsConnectionSuccessful;

  /// SnackBar: Discogs connection failed
  ///
  /// In de, this message translates to:
  /// **'Discogs-Verbindung fehlgeschlagen'**
  String get discogsConnectionFailed;

  /// SnackBar: OAuth tokens removed
  ///
  /// In de, this message translates to:
  /// **'OAuth-Tokens entfernt'**
  String get oauthTokensRemoved;

  /// Label: Discogs OAuth for write access
  ///
  /// In de, this message translates to:
  /// **'Discogs OAuth (für Schreibzugriff)'**
  String get discogsOAuthWriteAccess;

  /// Label: Verifier code
  ///
  /// In de, this message translates to:
  /// **'Verifier-Code (nach Autorisierung)'**
  String get verifierCodeLabel;

  /// Status: OAuth configured
  ///
  /// In de, this message translates to:
  /// **'OAuth konfiguriert'**
  String get oauthConfigured;

  /// Button: Remove OAuth
  ///
  /// In de, this message translates to:
  /// **'OAuth entfernen'**
  String get removeOAuth;

  /// Button: Test connection
  ///
  /// In de, this message translates to:
  /// **'Verbindung testen'**
  String get testConnection;

  /// Button: OAuth
  ///
  /// In de, this message translates to:
  /// **'OAuth'**
  String get oauth;

  /// Section title: Filter and sort
  ///
  /// In de, this message translates to:
  /// **'Filter und Sortierung'**
  String get filterAndSort;

  /// Label: Medium filter
  ///
  /// In de, this message translates to:
  /// **'Medium-Filter:'**
  String get mediumFilter;

  /// Button: Reset filters
  ///
  /// In de, this message translates to:
  /// **'Filter zurücksetzen'**
  String get resetFilters;

  /// Label: Sorting
  ///
  /// In de, this message translates to:
  /// **'Sortierung:'**
  String get sorting;

  /// Label: Digital
  ///
  /// In de, this message translates to:
  /// **'Digital:'**
  String get digitalLabel;

  /// Search category: Artist
  ///
  /// In de, this message translates to:
  /// **'Künstler'**
  String get artistCategory;

  /// Search category: Title
  ///
  /// In de, this message translates to:
  /// **'Titel'**
  String get titleCategory;

  /// Button: Skip tour
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get skipTour;

  /// Button: Next
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get nextStep;

  /// Button: Done/Finish
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get finishTour;

  /// Accessibility: Screen label
  ///
  /// In de, this message translates to:
  /// **'Bildschirm: {title}'**
  String screenLabel(String title);

  /// Accessibility: Title label
  ///
  /// In de, this message translates to:
  /// **'Titel: {title}'**
  String titleLabel(String title);

  /// Accessibility: Action button
  ///
  /// In de, this message translates to:
  /// **'Aktions-Button'**
  String get actionButton;

  /// Validation: Album name required
  ///
  /// In de, this message translates to:
  /// **'Album-Name ist erforderlich'**
  String get validationAlbumNameRequired;

  /// Validation: Album name too long
  ///
  /// In de, this message translates to:
  /// **'Album-Name darf maximal 200 Zeichen lang sein'**
  String get validationAlbumNameTooLong;

  /// Validation: Artist name required
  ///
  /// In de, this message translates to:
  /// **'Künstler-Name ist erforderlich'**
  String get validationArtistRequired;

  /// Validation: Artist name too long
  ///
  /// In de, this message translates to:
  /// **'Künstler-Name darf maximal 200 Zeichen lang sein'**
  String get validationArtistTooLong;

  /// Validation: Genre too long
  ///
  /// In de, this message translates to:
  /// **'Genre darf maximal 100 Zeichen lang sein'**
  String get validationGenreTooLong;

  /// Validation: Year format
  ///
  /// In de, this message translates to:
  /// **'Jahr muss eine Zahl sein oder \"Unknown\"'**
  String get validationYearFormat;

  /// Validation: Year too old
  ///
  /// In de, this message translates to:
  /// **'Jahr zu alt (vor 1800)'**
  String get validationYearTooOld;

  /// Validation: Year too far in future
  ///
  /// In de, this message translates to:
  /// **'Jahr zu weit in der Zukunft'**
  String get validationYearTooFuture;

  /// Validation: Invalid medium
  ///
  /// In de, this message translates to:
  /// **'Ungültiges Medium ausgewählt'**
  String get validationInvalidMedium;

  /// Validation: Track name required
  ///
  /// In de, this message translates to:
  /// **'Track-Name ist erforderlich'**
  String get validationTrackNameRequired;

  /// Validation: Track name too long
  ///
  /// In de, this message translates to:
  /// **'Track-Name darf maximal 150 Zeichen lang sein'**
  String get validationTrackNameTooLong;

  /// Validation: Time format
  ///
  /// In de, this message translates to:
  /// **'Format: MM:SS (z.B. 3:45)'**
  String get validationTimeFormat;

  /// Validation: Invalid time format
  ///
  /// In de, this message translates to:
  /// **'Ungültiges Zeitformat'**
  String get validationInvalidTimeFormat;

  /// Validation: Minutes range
  ///
  /// In de, this message translates to:
  /// **'Minuten müssen zwischen 0-99 liegen'**
  String get validationMinutesRange;

  /// Validation: Seconds range
  ///
  /// In de, this message translates to:
  /// **'Sekunden müssen zwischen 0-59 liegen'**
  String get validationSecondsRange;

  /// Edit validation: Album name required
  ///
  /// In de, this message translates to:
  /// **'Album-Name ist erforderlich'**
  String get editValidationAlbumNameRequired;

  /// Edit validation: Artist required
  ///
  /// In de, this message translates to:
  /// **'Künstler ist erforderlich'**
  String get editValidationArtistRequired;

  /// Edit validation: Medium required
  ///
  /// In de, this message translates to:
  /// **'Medium muss ausgewählt werden'**
  String get editValidationMediumRequired;

  /// Edit validation: Digital status required
  ///
  /// In de, this message translates to:
  /// **'Digital-Status muss ausgewählt werden'**
  String get editValidationDigitalRequired;

  /// Edit validation: Track required
  ///
  /// In de, this message translates to:
  /// **'Mindestens ein Track ist erforderlich'**
  String get editValidationTrackRequired;

  /// Edit validation: Track title required
  ///
  /// In de, this message translates to:
  /// **'Track {index} benötigt einen Titel'**
  String editValidationTrackTitleRequired(int index);

  /// Help: Short description
  ///
  /// In de, this message translates to:
  /// **'Musiksammlungs-Manager für Linux und Android'**
  String get helpShortDescription;

  /// Help section title
  ///
  /// In de, this message translates to:
  /// **'BESCHREIBUNG'**
  String get helpSectionDescription;

  /// Help section body
  ///
  /// In de, this message translates to:
  /// **'MusicUp verwaltet deine Musiksammlung auf Linux und Android. Alben lassen sich manuell anlegen, aus Ordnerstrukturen importieren oder über die Discogs-Datenbank suchen und hinzufügen.'**
  String get helpDescriptionBody;

  /// Help section title
  ///
  /// In de, this message translates to:
  /// **'SAMMLUNG VERWALTEN'**
  String get helpSectionCollection;

  /// Help section body
  ///
  /// In de, this message translates to:
  /// **'Alben anlegen mit Name, Künstler, Genre, Jahr, Medium und Tracks.\nBestehende Alben bearbeiten und Detailansicht nutzen.\nDuplikaterkennung beim Import und manuellen Anlegen.\nErweiterte Suche und Filter nach Medium, Genre, Jahr.\nSortierung nach verschiedenen Kriterien.\nSammlung als PDF exportieren (sortiert nach Künstler).'**
  String get helpCollectionBody;

  /// Help section title
  ///
  /// In de, this message translates to:
  /// **'DISCOGS INTEGRATION'**
  String get helpSectionDiscogs;

  /// Help section body
  ///
  /// In de, this message translates to:
  /// **'OAuth 1.0a Authentifizierung in den Einstellungen einrichten.\nAlben in der Discogs-Datenbank suchen und mit Metadaten importieren.\nKomplette Discogs-Sammlung synchronisieren.\nAutomatisches API-Rate-Limiting.'**
  String get helpDiscogsBody;

  /// Help section title
  ///
  /// In de, this message translates to:
  /// **'IMPORT/EXPORT'**
  String get helpSectionImportExport;

  /// Help section body
  ///
  /// In de, this message translates to:
  /// **'JSON (empfohlen): Vollständige Daten mit Tracks und Metadaten.\nCSV: Tabellenkompatibel, mit optionaler Track-Unterstützung.\nXML: Strukturiertes Format für Datenaustausch.\nOrdner-Import: Automatische Erkennung aus Musikordnern (Format: \"01 - Tracktitel.mp3\").'**
  String get helpImportExportBody;

  /// Help section title
  ///
  /// In de, this message translates to:
  /// **'WANTLIST'**
  String get helpSectionWantlist;

  /// Help section body
  ///
  /// In de, this message translates to:
  /// **'Eigener Bildschirm für gewünschte Alben.\nOnline/Offline-Synchronisation mit Discogs.\nAlben von der Wantlist in die Sammlung übernehmen.\nIntelligente Konflikterkennung beim Synchronisieren.\nWunschliste als PDF exportieren.'**
  String get helpWantlistBody;

  /// Help section title
  ///
  /// In de, this message translates to:
  /// **'DATEIPFADE'**
  String get helpSectionFilePaths;

  /// Help section body
  ///
  /// In de, this message translates to:
  /// **'Konfiguration:   ~/.config/music_up/\nSammlung:        Konfigurierbar in Einstellungen\nWantlist:        Konfigurierbar in Einstellungen\nLogs:            Siehe Einstellungen > Logs senden'**
  String get helpFilePathsBody;

  /// Help section title
  ///
  /// In de, this message translates to:
  /// **'OPTIONEN'**
  String get helpSectionOptions;

  /// Help section body
  ///
  /// In de, this message translates to:
  /// **'-h, --help       Hilfe anzeigen und beenden\n-v, --version    Version anzeigen und beenden'**
  String get helpOptionsBody;

  /// Help section title
  ///
  /// In de, this message translates to:
  /// **'AUTOR'**
  String get helpSectionAuthor;

  /// Help section title
  ///
  /// In de, this message translates to:
  /// **'FEHLER MELDEN'**
  String get helpSectionBugReport;

  /// Help section body
  ///
  /// In de, this message translates to:
  /// **'Fehler und Verbesserungsvorschläge per E-Mail an:\nnobo_code@posteo.de\n\nQuellcode: https://github.com/hiphopconnect/musicup'**
  String get helpBugReportBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
