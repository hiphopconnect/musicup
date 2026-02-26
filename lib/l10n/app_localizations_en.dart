// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search...';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get unknown => 'Unknown';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get confirm => 'Confirm';

  @override
  String get all => 'All';

  @override
  String get settings => 'Settings';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get resetSettingsConfirm => 'Reset all settings to defaults?';

  @override
  String get settingsReset => 'Settings reset';

  @override
  String errorLoadingSettings(String error) {
    return 'Error loading settings: $error';
  }

  @override
  String errorResetting(String error) {
    return 'Error resetting: $error';
  }

  @override
  String get filePaths => 'File Paths';

  @override
  String get collectionJsonFile => 'Collection JSON File';

  @override
  String get wantlistJsonFile => 'Wantlist JSON File';

  @override
  String get noFileSelected => 'No file selected';

  @override
  String get browse => 'Browse';

  @override
  String get collectionPathUpdated => 'Collection path updated';

  @override
  String get wantlistPathUpdated => 'Wantlist path updated';

  @override
  String errorFileSelection(String error) {
    return 'Error selecting file: $error';
  }

  @override
  String get discogsIntegration => 'Discogs Integration';

  @override
  String get importExport => 'Import / Export';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeLight => 'Light';

  @override
  String get themeLightDesc => 'Always use light theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeDarkDesc => 'Always use dark theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeSystemDesc => 'Use system setting';

  @override
  String get advanced => 'Advanced';

  @override
  String get logLevel => 'Log Level';

  @override
  String get logLevelDebug => 'All messages (Debug)';

  @override
  String get logLevelInfo => 'Info and above';

  @override
  String get logLevelWarning => 'Warnings and errors only';

  @override
  String get logLevelError => 'Errors only';

  @override
  String logFilesInfo(int count, String size) {
    return '$count files, current: $size';
  }

  @override
  String get aboutMusicUp => 'About MusicUp';

  @override
  String get help => 'Help';

  @override
  String get helpSubtitle => 'Documentation and user guide';

  @override
  String get startTour => 'Start Tour';

  @override
  String get startTourSubtitle => 'Interactive introduction to the app';

  @override
  String get version => 'Version';

  @override
  String get license => 'License';

  @override
  String get proprietarySoftware => 'Proprietary Software';

  @override
  String get developer => 'Developer';

  @override
  String get contact => 'Contact';

  @override
  String get reportProblem => 'Report Problem';

  @override
  String get reportProblemSubtitle => 'Send email to support';

  @override
  String get sendLogs => 'Send Logs';

  @override
  String get sendLogsDefault => 'Share log files';

  @override
  String get repository => 'Repository';

  @override
  String get language => 'Language';

  @override
  String get musicUpCollection => 'MusicUp Collection';

  @override
  String get addAlbumTooltip => 'Add album';

  @override
  String get openWantlist => 'Open Wantlist';

  @override
  String get searchDiscogs => 'Search Discogs';

  @override
  String albumDeletedSuccess(String name) {
    return '\"$name\" deleted';
  }

  @override
  String errorDeleting(String error) {
    return 'Error deleting: $error';
  }

  @override
  String get deleteAlbum => 'Delete Album';

  @override
  String deleteAlbumConfirm(String name) {
    return 'Do you really want to delete \"$name\"?';
  }

  @override
  String get tourCollectionTitle => 'Your Collection';

  @override
  String get tourCollectionDesc =>
      'Here you can see all albums in your collection at a glance.';

  @override
  String get tourSearchTitle => 'Search';

  @override
  String get tourSearchDesc => 'Search your albums by name, artist or genre.';

  @override
  String get tourFilterTitle => 'Filter';

  @override
  String get tourFilterDesc =>
      'Filter by medium (Vinyl, CD, ...) and other criteria.';

  @override
  String get tourAddAlbumTitle => 'Add Album';

  @override
  String get tourAddAlbumDesc => 'Add a new album to your collection.';

  @override
  String get tourSettingsTitle => 'Settings';

  @override
  String get tourSettingsDesc =>
      'Here you\'ll find settings, import/export and the Discogs connection.';

  @override
  String get addNewAlbum => 'Add New Album';

  @override
  String get importFromFolder => 'Import from folder';

  @override
  String get saveAlbum => 'Save Album';

  @override
  String get draftFound => 'Draft Found';

  @override
  String get draftFoundMessage =>
      'A saved draft was found. Do you want to load it?';

  @override
  String get loadDraft => 'Yes, load';

  @override
  String get draftLoaded => 'Draft loaded';

  @override
  String get saveChangesQuestion => 'Save changes?';

  @override
  String get saveChangesBeforeLeaving =>
      'Do you want to save the new album before leaving?';

  @override
  String get dontSave => 'Don\'t save';

  @override
  String get saveAndLeave => 'Save & Leave';

  @override
  String tracksImported(int count, String name) {
    return '$count tracks imported from \"$name\"';
  }

  @override
  String errorImporting(String error) {
    return 'Error importing: $error';
  }

  @override
  String get trackWithTitleRequired =>
      'At least one track with a title is required';

  @override
  String albumAddedSuccess(String name) {
    return 'Album \"$name\" added successfully';
  }

  @override
  String get editAlbum => 'Edit Album';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get unsavedChanges => 'Unsaved Changes';

  @override
  String get unsavedChangesMessage =>
      'You have unsaved changes. Do you want to discard them?';

  @override
  String get continueEditing => 'Continue Editing';

  @override
  String get discardChanges => 'Discard Changes';

  @override
  String get validationError => 'Validation Error';

  @override
  String get tracksLoading => 'Loading tracks...';

  @override
  String get albumInformation => 'Album Information';

  @override
  String get year => 'Year';

  @override
  String get medium => 'Medium';

  @override
  String get digitalAvailable => 'Available digitally';

  @override
  String get genre => 'Genre';

  @override
  String get trackList => 'Track List';

  @override
  String trackListCount(int count) {
    return 'Track List ($count Tracks)';
  }

  @override
  String get noTracksAvailable => 'No tracks available';

  @override
  String wantlistTitle(int count) {
    return 'Wantlist ($count)';
  }

  @override
  String get wantlistEmpty => 'Wantlist is empty';

  @override
  String pdfSaved(String path) {
    return 'PDF saved: $path';
  }

  @override
  String pdfExportFailed(String error) {
    return 'PDF export failed: $error';
  }

  @override
  String get exportAsPdf => 'Export as PDF';

  @override
  String get exportCollectionAsPdf => 'Export collection as PDF';

  @override
  String get collectionEmpty => 'No albums to export';

  @override
  String get sortAZ => 'Sort: A-Z';

  @override
  String get sortZA => 'Sort: Z-A';

  @override
  String get addToWantlistTooltip => 'Add album to Wantlist';

  @override
  String get refreshWantlist => 'Refresh Wantlist';

  @override
  String get searchWantlist => 'Search wantlist...';

  @override
  String get addingToCollection => 'Adding to collection...';

  @override
  String albumMovedToCollection(String name) {
    return '\"$name\" added to collection and removed from Wantlist';
  }

  @override
  String albumRemovedFromWantlist(String name) {
    return '\"$name\" removed from Wantlist';
  }

  @override
  String albumRemovedFromWantlistAndDiscogs(String name) {
    return '\"$name\" removed from Wantlist and from Discogs';
  }

  @override
  String get albumCouldNotBeRemoved => 'Album could not be removed';

  @override
  String get addToWantlistTitle => 'Add to Wantlist';

  @override
  String get savingToWantlist => 'Saving to wantlist...';

  @override
  String get wantlistInfoBanner =>
      'Albums you\'d like to acquire in the future';

  @override
  String albumAddedToWantlist(String name) {
    return '\"$name\" added to Wantlist';
  }

  @override
  String get saving => 'Saving...';

  @override
  String get addToWantlistButton => 'Add to Wantlist';

  @override
  String get discogsSearch => 'Discogs Search';

  @override
  String get oauthNotConfigured =>
      'OAuth not configured. Please set up in settings.';

  @override
  String get freeTextSearch => 'Free text search...';

  @override
  String get advancedFilters => 'Advanced Filters';

  @override
  String get artist => 'Artist';

  @override
  String get albumRelease => 'Album / Release';

  @override
  String get format => 'Format';

  @override
  String get pressCountry => 'Press Country';

  @override
  String addedToCollection(String title) {
    return '\"$title\" added to collection';
  }

  @override
  String addedToWantlist(String title) {
    return '\"$title\" added to Wantlist';
  }

  @override
  String get welcomeTitle => 'Welcome to MusicUp';

  @override
  String get welcomeBody =>
      'Manage your music collection. Vinyl, CD, Cassette or Digital -- all in one place.';

  @override
  String get letsGo => 'Let\'s go';

  @override
  String get collectionFile => 'Collection File';

  @override
  String get collectionAutoSaved =>
      'Your collection is automatically saved in the app directory.';

  @override
  String get collectionChooseLocation =>
      'Choose the location for your collection file (albums.json).';

  @override
  String get selectFile => 'Select file';

  @override
  String get selectOtherFile => 'Select other file';

  @override
  String get selectCollectionFile => 'Select collection file';

  @override
  String get discogsOptionalBody =>
      'Optional: Connect your Discogs account to search albums and sync your wantlist.';

  @override
  String get discogsConnected => 'Discogs connected';

  @override
  String get setupLater => 'Set up later';

  @override
  String get allReady => 'All ready!';

  @override
  String get collection => 'Collection';

  @override
  String get configured => 'Configured';

  @override
  String get standard => 'Default';

  @override
  String get discogs => 'Discogs';

  @override
  String get connected => 'Connected';

  @override
  String get notConfigured => 'Not configured';

  @override
  String get startApp => 'Start App';

  @override
  String get albumName => 'Album Name';

  @override
  String get albumNameRequired => 'Album Name *';

  @override
  String get artistRequired => 'Artist *';

  @override
  String get genreOptional => 'Genre (optional)';

  @override
  String get albumDetails => 'Album Details';

  @override
  String get selectYear => 'Select year';

  @override
  String get selectMedium => 'Select medium';

  @override
  String get digitalAvailableQuestion => 'Is this album available digitally?';

  @override
  String get pleaseEnterAlbumName => 'Please enter an album name';

  @override
  String get pleaseEnterArtist => 'Please enter an artist';

  @override
  String get formatSettings => 'Format Settings';

  @override
  String get pleaseEnterAlbumNameShort => 'Please enter album name';

  @override
  String get pleaseEnterArtistShort => 'Please enter artist name';

  @override
  String get yearOptional => 'Year (optional)';

  @override
  String pleaseEnterValidYear(int maxYear) {
    return 'Please enter a valid year (1900-$maxYear)';
  }

  @override
  String trackListTitle(int count) {
    return 'Track List ($count Tracks)';
  }

  @override
  String get addTrack => 'Add Track';

  @override
  String get removeTrack => 'Remove Track';

  @override
  String get noTracksAdded => 'No tracks added yet';

  @override
  String get noAlbumsFound => 'No albums found';

  @override
  String get addFirstAlbum => 'Add your first album';

  @override
  String get wantlistLoading => 'Loading wantlist...';

  @override
  String get noWantlistEntries => 'No entries in wantlist';

  @override
  String get addToDiscogsWantlist => 'Add entries to your Discogs wantlist';

  @override
  String get configureOAuthFirst => 'Please configure OAuth in settings';

  @override
  String artistPrefix(String artist) {
    return 'Artist: $artist';
  }

  @override
  String yearPrefix(String year) {
    return 'Year: $year';
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
  String get addToCollection => 'Add to collection';

  @override
  String get removeFromWantlist => 'Remove from Wantlist';

  @override
  String get discogsOAuthConfigured =>
      'Discogs OAuth configured - Wantlist is syncing';

  @override
  String get oauthNotConfiguredLong =>
      'OAuth not configured. Please set up in settings to sync the Wantlist.';

  @override
  String get whatHappens => 'What happens:';

  @override
  String get whatHappensBody =>
      'Album will be added to your collection\nAlbum will be removed from Wantlist\nTrack information will be loaded';

  @override
  String get removeFromWantlistTitle => 'Remove from Wantlist';

  @override
  String removeFromWantlistConfirm(String name) {
    return 'Do you really want to remove \"$name\" from the Wantlist?';
  }

  @override
  String get note => 'Note:';

  @override
  String get removeFromWantlistNote =>
      'The album will be removed from both the local wantlist and your Discogs wantlist (if configured).';

  @override
  String get addToCollectionDiscogsBody =>
      'This album will be added to your collection. Track information will be loaded from Discogs.';

  @override
  String get oauthRequired => 'OAuth Required';

  @override
  String oauthRequiredBody(String title) {
    return 'To add \"$title\" to the Wantlist, you need OAuth authentication.';
  }

  @override
  String get oauthSetupQuestion => 'Do you want to set up OAuth in settings?';

  @override
  String get later => 'Later';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get pleaseConfigureOAuth => 'Please set up OAuth in settings.';

  @override
  String get pleaseEnterSearchTerms => 'Please enter search terms';

  @override
  String searchFailed(String error) {
    return 'Search failed: $error';
  }

  @override
  String get noResultsTrySearch =>
      'No results. Try searching for an artist or album.';

  @override
  String get searchRunning => 'Searching...';

  @override
  String get noResultsFound => 'No results found.';

  @override
  String get addToWantlistTooltipShort => 'Add to Wantlist';

  @override
  String get importCollection => 'Import Collection';

  @override
  String get importCollectionSubtitle => 'Import JSON, CSV or XML';

  @override
  String get exportCollection => 'Export Collection';

  @override
  String get exportCollectionSubtitle => 'Export as JSON, CSV or XML';

  @override
  String get importFormatTitle => 'Select Import Format';

  @override
  String get exportFormatTitle => 'Select Export Format';

  @override
  String get standardFormat => 'Standard MusicUp Format';

  @override
  String get tableData => 'Table data';

  @override
  String get structuredData => 'Structured data';

  @override
  String get forSpreadsheet => 'For Excel/Calc';

  @override
  String albumsImportedWithSkipped(int count, int skipped) {
    return '$count albums imported ($skipped duplicates skipped)';
  }

  @override
  String albumsImported(int count) {
    return '$count albums imported';
  }

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get noAlbumsToExport => 'No albums to export';

  @override
  String albumsExported(int count, String path) {
    return '$count albums exported to\n$path';
  }

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get supportedFormats => 'Supported formats: JSON, CSV, XML';

  @override
  String get pleaseEnterConsumerKeySecret =>
      'Please enter Consumer Key and Secret';

  @override
  String get consumerCredentialsSaved => 'Consumer credentials saved';

  @override
  String get pleaseFirstSaveConsumerKey =>
      'Please save Consumer Key/Secret first';

  @override
  String get browserOpenedVerifier =>
      'Browser opened. Enter verifier after authorization.';

  @override
  String couldNotOpenUrl(String url) {
    return 'Could not open URL: $url';
  }

  @override
  String get pleaseEnterVerifierCode => 'Please enter verifier code';

  @override
  String get invalidAccessTokenResponse =>
      'Invalid access token response received';

  @override
  String get oauthCompleted => 'OAuth completed successfully';

  @override
  String get noInternetConnection =>
      'No internet connection or network access for MusicUp not allowed. Please check network permissions in system settings.';

  @override
  String get connectionToDiscogsFailed =>
      'Connection to Discogs failed. Please check internet connection.';

  @override
  String oauthFailed(String error) {
    return 'OAuth failed: $error';
  }

  @override
  String get discogsConnectionSuccessful => 'Discogs connection successful';

  @override
  String get discogsConnectionFailed => 'Discogs connection failed';

  @override
  String get oauthTokensRemoved => 'OAuth tokens removed';

  @override
  String get discogsOAuthWriteAccess => 'Discogs OAuth (for write access)';

  @override
  String get verifierCodeLabel => 'Verifier code (after authorization)';

  @override
  String get oauthConfigured => 'OAuth configured';

  @override
  String get removeOAuth => 'Remove OAuth';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get oauth => 'OAuth';

  @override
  String get filterAndSort => 'Filter and Sort';

  @override
  String get mediumFilter => 'Medium filter:';

  @override
  String get resetFilters => 'Reset filters';

  @override
  String get sorting => 'Sort:';

  @override
  String get digitalLabel => 'Digital:';

  @override
  String get artistCategory => 'Artist';

  @override
  String get titleCategory => 'Title';

  @override
  String get skipTour => 'Skip';

  @override
  String get nextStep => 'Next';

  @override
  String get finishTour => 'Done';

  @override
  String screenLabel(String title) {
    return 'Screen: $title';
  }

  @override
  String titleLabel(String title) {
    return 'Title: $title';
  }

  @override
  String get actionButton => 'Action button';

  @override
  String get validationAlbumNameRequired => 'Album name is required';

  @override
  String get validationAlbumNameTooLong =>
      'Album name must be at most 200 characters';

  @override
  String get validationArtistRequired => 'Artist name is required';

  @override
  String get validationArtistTooLong =>
      'Artist name must be at most 200 characters';

  @override
  String get validationGenreTooLong => 'Genre must be at most 100 characters';

  @override
  String get validationYearFormat => 'Year must be a number or \"Unknown\"';

  @override
  String get validationYearTooOld => 'Year too old (before 1800)';

  @override
  String get validationYearTooFuture => 'Year too far in the future';

  @override
  String get validationInvalidMedium => 'Invalid medium selected';

  @override
  String get validationTrackNameRequired => 'Track name is required';

  @override
  String get validationTrackNameTooLong =>
      'Track name must be at most 150 characters';

  @override
  String get validationTimeFormat => 'Format: MM:SS (e.g. 3:45)';

  @override
  String get validationInvalidTimeFormat => 'Invalid time format';

  @override
  String get validationMinutesRange => 'Minutes must be between 0-99';

  @override
  String get validationSecondsRange => 'Seconds must be between 0-59';

  @override
  String get editValidationAlbumNameRequired => 'Album name is required';

  @override
  String get editValidationArtistRequired => 'Artist is required';

  @override
  String get editValidationMediumRequired => 'Medium must be selected';

  @override
  String get editValidationDigitalRequired => 'Digital status must be selected';

  @override
  String get editValidationTrackRequired => 'At least one track is required';

  @override
  String editValidationTrackTitleRequired(int index) {
    return 'Track $index needs a title';
  }

  @override
  String get helpShortDescription =>
      'Music collection manager for Linux and Android';

  @override
  String get helpSectionDescription => 'DESCRIPTION';

  @override
  String get helpDescriptionBody =>
      'MusicUp manages your music collection on Linux and Android. Albums can be created manually, imported from folder structures, or searched and added via the Discogs database.';

  @override
  String get helpSectionCollection => 'MANAGE COLLECTION';

  @override
  String get helpCollectionBody =>
      'Create albums with name, artist, genre, year, medium and tracks.\nEdit existing albums and use detail view.\nDuplicate detection on import and manual creation.\nAdvanced search and filter by medium, genre, year.\nSort by various criteria.\nExport collection as PDF (sorted by artist).';

  @override
  String get helpSectionDiscogs => 'DISCOGS INTEGRATION';

  @override
  String get helpDiscogsBody =>
      'Set up OAuth 1.0a authentication in settings.\nSearch albums in the Discogs database and import with metadata.\nSynchronize complete Discogs collection.\nAutomatic API rate limiting.';

  @override
  String get helpSectionImportExport => 'IMPORT/EXPORT';

  @override
  String get helpImportExportBody =>
      'JSON (recommended): Complete data with tracks and metadata.\nCSV: Spreadsheet compatible, with optional track support.\nXML: Structured format for data exchange.\nFolder import: Automatic detection from music folders (format: \"01 - Tracktitle.mp3\").';

  @override
  String get helpSectionWantlist => 'WANTLIST';

  @override
  String get helpWantlistBody =>
      'Dedicated screen for desired albums.\nOnline/offline synchronization with Discogs.\nMove albums from wantlist to collection.\nIntelligent conflict detection during sync.\nExport wantlist as PDF.';

  @override
  String get helpSectionFilePaths => 'FILE PATHS';

  @override
  String get helpFilePathsBody =>
      'Configuration:   ~/.config/music_up/\nCollection:      Configurable in settings\nWantlist:        Configurable in settings\nLogs:            See Settings > Send Logs';

  @override
  String get helpSectionOptions => 'OPTIONS';

  @override
  String get helpOptionsBody =>
      '-h, --help       Show help and exit\n-v, --version    Show version and exit';

  @override
  String get helpSectionAuthor => 'AUTHOR';

  @override
  String get helpSectionBugReport => 'REPORT BUGS';

  @override
  String get helpBugReportBody =>
      'Bug reports and feature requests via email to:\nnobo_code@posteo.de\n\nSource code: https://github.com/hiphopconnect/musicup';
}
