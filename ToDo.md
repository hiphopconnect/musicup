# MusicUp - ToDo

## ~~LoggingSystem~~ (erledigt)

- ~~LoggerService ausbauen (File-Logging, Log-Levels, Log-Rotation)~~
- ~~LoggerService konsistent in allen Services und Screens verwenden~~

## ~~Hilfe-System~~ (erledigt)

- ~~**Man Page**: Linux Man Page im troff-Format (`man musicup`), installiert nach `/usr/share/man/man1/`~~
- ~~**--help Flag**: CLI-Hilfe beim Start aus dem Terminal (`musicup --help`)~~
- ~~**In-App Hilfe-Button**: Hilfe-Seite oder Dialog in der App~~
- ~~Alle drei aus einer gemeinsamen Quelle generieren damit es wartbar bleibt~~

## ~~Setup-Wizard~~ (erledigt)

- ~~Ersteinrichtungs-Assistent beim ersten App-Start (Dateipfade, Discogs-Token konfigurieren)~~
- ~~Guided Tour / Feature-Walkthrough: Tooltips die von Funktion zu Funktion fuehren und erklaeren~~

## ~~ServiceLocator Refactoring~~ (erledigt)

- ~~Einfacher ServiceLocator statt Prop Drilling (kein externes Package)~~
- ~~Services nur einmal in main.dart erstellen~~
- ~~Inkonsistente Service-Instanziierung in Screens bereinigen~~

## ~~Tour in Settings~~ (erledigt)

- ~~unter settings sollte man nochmal die tour oder den wizard starten können.~~

## ~~Wunschliste als PDF exportieren~~ (erledigt)

- ~~Wunschliste als PDF exportieren um sie Freunden zu schicken~~
- ~~Sortierung nach Kuenstler (A-Z / Z-A) in der Wantlist-UI~~

## ~~Verwendete Pakete, Abhängigkeiten die Installiert werden müssen, und deren Lizenzen Abgleichen zur

Verwendung~~ (erledigt, siehe THIRD_PARTY_LICENSES)

## Vorlagen Ordner mit Tools erstellen Versions Update, Manual, help

## Bilder nachladen irgendwo her? bzw. hinzufügen? Auf jeden Fall als Funktion die man hin und zufügt.

## Einschraenken von dem was man eingeben kann? Weil sonst absturz?

### Crash-Schwere (6)

- [x] V1: `Album.fromMap()` crasht bei null-Feldern (`id`, `name`, `artist`, `genre` ohne Defaults)
- [x] V2: Edit-Form Year-Dropdown crasht wenn Album-Jahr nicht in generierter Liste (z.B. "Unknown", vor 1926)
- [x] V3: Edit-Form Medium-Dropdown crasht wenn Medium nicht in Set (z.B. "Kassette" vs "Cassette")
- [x] V4: XML-Import `.first` crasht bei fehlenden Elementen (ID, Name, Artist etc.)
- [x] V5: "Kassette" vs "Cassette" Mismatch zwischen ValidationService und Form-Widgets
- [x] V6: CSV-Import stuerzt bei fehlerhaften Zeilen ab (row.length < 7 nicht abgefangen)

### Datenkorruption (6)

- [x] V7: Importierte Daten werden nicht getrimmt (fuehrende/folgende Leerzeichen)
- [x] V8: Doppelte Album-IDs beim Import moeglich (Merge ohne Deduplizierung)
- [x] V9: Track-Nummern ohne Bereichspruefung beim Import
- [x] V10: AddAlbumScreen validiert leere Track-Titel nicht vor dem Speichern
- [x] V11: Import umgeht ValidationService komplett (keine Feldvalidierung)
- [x] V12: CSV Digital-Feld case-sensitiv ("Yes" vs "yes" vs "JA")

### Kosmetik (4)

- [x] V13: Jahr-Bereich inkonsistent (Add-Form: ab 1950, Edit-Form: 100 Jahre, ValidationService: ab 1800)
- [x] V14: Track-Titel-Laenge nicht begrenzt im TrackManagementWidget
- [x] V15: Genre-Feld ohne Laengenbegrenzung im UI (nur ValidationService prueft 100 Zeichen)
- [x] V16: Album-/Kuenstler-Name ohne Laengenbegrenzung im UI (nur ValidationService prueft 200 Zeichen)

## ~~Macht Logging in Tests Sinn?~~ (erledigt, nein - Tests haben eigene Assertions)

## ~~Haben wir für den User einen Test ob die Discogs Verbindung klappt? Also ein Alive?~~ (erledigt)

## Ist das Projekt Best Practice? Was sollte man noch anpassen?

### Kritisch

- [x] C1: Hardcoded Colors durch `AppTheme.*` Konstanten ersetzt (14 Dateien)
- [x] C2: Linter-Regeln aktiviert (`prefer_single_quotes`, `always_use_package_imports`, etc.)
- [x] C3: HTTP Client injizierbar (`http.Client` per Konstruktor in beide Discogs-Services)
- [x] C4: `Track` Model immutable (`final` Felder)

### Wichtig

- [x] I1: User-Agent Version auf 2.2.0 aktualisiert
- [x] I2: JSON-Parsing dedupliziert (`albumFromJson` Helper in `JsonService`)
- [x] I3: Leerer `setState()` in `add_album_screen.dart` entfernt
- [x] I4: Relative Imports in `settings_screen.dart` durch Package-Imports ersetzt
- [x] I5: Unsafe Cast `json['tracks'] as List` durch `as List? ?? []` abgesichert
- [x] I6: Test-Abdeckung erweitert (174 -> 392 Tests, neue Tests fuer album_model, config_manager,
  discogs_service_unified, validation_service)
- [x] I7: RadioListTile-Duplizierung in `settings_screen.dart` durch `_onThemeModeChanged` behoben

### Nice-to-have

- [x] N1: Named Route `/settings` entfernt, einheitlich push-basiert
- [x] N2: Design System erweitert (Font-Sizes, Icon-Sizes, `rXs`, `xxl` Spacing)
- [x] N3: `==`/`hashCode` auf `Album`, `Track`, `DiscogsSearchResult` implementiert
- [x] N4: Englische UI-Strings auf Deutsch uebersetzt (Settings, Filter, Suche, Import/Export)
- [x] N5: Redundante `_createHeaders` entfernt, direkt `_createOAuthHeaders` verwendet
- [x] N6: `saveConfig()` als `@Deprecated` markiert
- [x] N7: Leeren `migrateConfigIfNeeded()` Placeholder entfernt
- [x] N8: OAuth-Service Caching implementiert (nur bei Token-Aenderung neu erstellt)
- [x] N9: Dead Code in `validateTrackName` entfernt

## ~~Haben wir eine Suche in der Wantlist?~~ (erledigt, SearchBarWidget vorhanden)

## ~~Software 2 Sprachig machen Deutsch und Englisch~~ (erledigt)

- ~~flutter_localizations + intl Infrastruktur (l10n.yaml, ARB-Dateien)~~
- ~~~250 Keys in app_de.arb (Deutsch) und app_en.arb (Englisch)~~
- ~~Sprach-Auswahl in Einstellungen (Deutsch/English), persistiert via SharedPreferences~~
- ~~Alle ~119 hartcodierten deutschen Strings in ~27 Dateien (Screens + Widgets) migriert~~
- ~~ValidationService gibt Keys zurueck, UI uebersetzt via validation_translations.dart~~
- ~~Import/Export-Formate (CSV-Header, XML-Tags, JSON-Keys, Medium-Werte) bleiben Englisch~~
- ~~Alle 392 Tests aktualisiert und bestanden~~

## Online Service / Premium Funktion, um Wantlist und Albums zu syncronisieren.

## Liste schreiben von dingen die eine Software sein sollte.

# DRY, KISS, Best practice, ist es sicher? kann man falsche sachen eingeben?

## CI/CD PipeLine ? 