import 'package:music_up/l10n/app_localizations.dart';

class HelpSection {
  final String title;
  final String body;

  const HelpSection(this.title, this.body);
}

class HelpContent {
  static const String appName = 'MusicUp';
  static const String synopsis = 'musicup [OPTIONEN]';

  static String shortDescription(AppLocalizations l10n) => l10n.helpShortDescription;

  static List<HelpSection> sections(AppLocalizations l10n) => [
    HelpSection(l10n.helpSectionDescription, l10n.helpDescriptionBody),
    HelpSection(l10n.helpSectionCollection, l10n.helpCollectionBody),
    HelpSection(l10n.helpSectionDiscogs, l10n.helpDiscogsBody),
    HelpSection(l10n.helpSectionImportExport, l10n.helpImportExportBody),
    HelpSection(l10n.helpSectionWantlist, l10n.helpWantlistBody),
    HelpSection(l10n.helpSectionFilePaths, l10n.helpFilePathsBody),
    HelpSection(l10n.helpSectionOptions, l10n.helpOptionsBody),
    HelpSection(l10n.helpSectionAuthor, 'Michael Milke (Nobo)\nE-Mail: nobo_code@posteo.de'),
    HelpSection(l10n.helpSectionBugReport, l10n.helpBugReportBody),
  ];

  /// German-only fallback for CLI tools (generate_manpage.dart)
  /// that cannot access Flutter's localization system.
  static const String shortDescriptionDe = 'Musiksammlungs-Manager fuer Linux und Android';

  static const List<HelpSection> sectionsDe = [
    HelpSection(
      'BESCHREIBUNG',
      'MusicUp verwaltet deine Musiksammlung auf Linux und Android. '
          'Alben lassen sich manuell anlegen, aus Ordnerstrukturen importieren '
          'oder ueber die Discogs-Datenbank suchen und hinzufuegen.',
    ),
    HelpSection(
      'SAMMLUNG VERWALTEN',
      'Alben anlegen mit Name, Kuenstler, Genre, Jahr, Medium und Tracks.\n'
          'Bestehende Alben bearbeiten und Detailansicht nutzen.\n'
          'Duplikaterkennung beim Import und manuellen Anlegen.\n'
          'Erweiterte Suche und Filter nach Medium, Genre, Jahr.\n'
          'Sortierung nach verschiedenen Kriterien.\n'
          'Sammlung als PDF exportieren (sortiert nach Kuenstler).',
    ),
    HelpSection(
      'DISCOGS INTEGRATION',
      'OAuth 1.0a Authentifizierung in den Einstellungen einrichten.\n'
          'Alben in der Discogs-Datenbank suchen und mit Metadaten importieren.\n'
          'Komplette Discogs-Sammlung synchronisieren.\n'
          'Automatisches API-Rate-Limiting.',
    ),
    HelpSection(
      'IMPORT/EXPORT',
      'JSON (empfohlen): Vollstaendige Daten mit Tracks und Metadaten.\n'
          'CSV: Tabellenkompatibel, mit optionaler Track-Unterstuetzung.\n'
          'XML: Strukturiertes Format fuer Datenaustausch.\n'
          'Ordner-Import: Automatische Erkennung aus Musikordnern '
          '(Format: "01 - Tracktitel.mp3").',
    ),
    HelpSection(
      'WANTLIST',
      'Eigener Bildschirm fuer gewuenschte Alben.\n'
          'Online/Offline-Synchronisation mit Discogs.\n'
          'Alben von der Wantlist in die Sammlung uebernehmen.\n'
          'Intelligente Konflikterkennung beim Synchronisieren.\n'
          'Wunschliste als PDF exportieren.',
    ),
    HelpSection(
      'DATEIPFADE',
      'Konfiguration:   ~/.config/music_up/\n'
          'Sammlung:        Konfigurierbar in Einstellungen\n'
          'Wantlist:        Konfigurierbar in Einstellungen\n'
          'Logs:            Siehe Einstellungen > Logs senden',
    ),
    HelpSection(
      'OPTIONEN',
      '-h, --help       Hilfe anzeigen und beenden\n'
          '-v, --version    Version anzeigen und beenden',
    ),
    HelpSection(
      'AUTOR',
      'Michael Milke (Nobo)\n'
          'E-Mail: nobo_code@posteo.de',
    ),
    HelpSection(
      'FEHLER MELDEN',
      'Fehler und Verbesserungsvorschlaege per E-Mail an:\n'
          'nobo_code@posteo.de\n\n'
          'Quellcode: https://github.com/hiphopconnect/musicup',
    ),
  ];
}
