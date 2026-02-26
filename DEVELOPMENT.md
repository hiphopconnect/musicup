# MusicUp - Development Guide

## Getting Started

### Prerequisites

- **Flutter SDK**: 3.10.0+
- **Dart SDK**: 3.0.0+
- **Platform-spezifisch**:
  - Android: Android Studio + Android SDK
  - iOS: Xcode (nur macOS)
  - Windows: Visual Studio 2022 mit C++ Tools
  - macOS: Xcode Command Line Tools
  - Linux: Standard-Entwicklungstools (`clang`, `cmake`, `ninja-build`, `libgtk-3-dev`)

### Setup

```bash
git clone https://github.com/hiphopconnect/musicup.git
cd musicup

flutter pub get

flutter config --enable-linux-desktop
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop

flutter doctor -v
```

Keine Code-Generierung noetig -- das Projekt verwendet kein `build_runner`.

## Project Structure

```
lib/
├── main.dart               # Entry Point, Service-Wiring
├── models/
│   └── album_model.dart    # Album, Track, DiscogsSearchResult
├── screens/
│   ├── main_screen.dart           # Hauptansicht mit Albumliste
│   ├── add_album_screen.dart      # Album hinzufuegen
│   ├── edit_album_screen.dart     # Album bearbeiten
│   ├── album_detail_screen.dart   # Album-Detailansicht
│   ├── discogs_search_screen.dart # Discogs-Suche
│   ├── wantlist_screen.dart       # Wantlist-Verwaltung
│   ├── add_wanted_album_screen.dart # Wantlist-Eintrag erstellen
│   └── settings_screen.dart       # Einstellungen
├── services/
│   ├── config_manager.dart        # SharedPreferences Wrapper
│   ├── json_service.dart          # File I/O (albums.json, wantlist.json)
│   ├── album_filter_service.dart  # Filter- und Sortierlogik
│   ├── album_edit_service.dart    # Bearbeitungslogik
│   ├── validation_service.dart    # Formularvalidierung
│   ├── auto_save_service.dart     # Entwurfsspeicherung
│   ├── discogs_service_unified.dart  # Discogs API Client
│   ├── discogs_oauth_service.dart    # OAuth-Authentifizierung
│   ├── discogs_album_service.dart    # Discogs-Album-Konvertierung
│   ├── wantlist_service.dart         # Wantlist-Operationen
│   ├── wantlist_sync_service.dart    # Wantlist-Discogs-Sync
│   ├── import_export_service.dart    # CSV/XML/JSON Import/Export
│   ├── folder_import_service.dart    # Ordner-Import
│   ├── pdf_export_service.dart       # PDF-Export (Sammlung + Wantlist)
│   ├── logger_service.dart           # Logging
│   ├── toast_service.dart            # Benutzerbenachrichtigungen
│   └── accessibility_service.dart    # Barrierefreiheit
├── theme/
│   ├── app_theme.dart         # Material Theme Definitionen
│   └── design_system.dart     # Design Tokens (Spacing, Farben)
└── widgets/                   # 22 wiederverwendbare UI-Komponenten
    ├── app_layout.dart        # App-Shell mit AppBar
    ├── album_list_widget.dart
    ├── album_form_widget.dart
    ├── album_filters_widget.dart
    ├── track_management_widget.dart
    ├── search_bar_widget.dart
    └── ...
```

## State Management

Das Projekt verwendet **StatefulWidget + setState**. Kein Riverpod, kein Provider-Package, kein Bloc.

### Pattern

```dart
class _MyScreenState extends State<MyScreen> {
  List<Album> _albums = [];
  bool _isLoading = true;

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await widget.jsonService.loadAlbums();
    setState(() {
      _albums = data;
      _isLoading = false;
    });
  }
}
```

### Service Injection

Services werden per Constructor an Screens uebergeben:

```dart
Navigator.push(context,
  MaterialPageRoute(builder: (_) => EditAlbumScreen(
    album: album,
    jsonService: widget.jsonService,
  )),
);
```

## Error Handling

Fehler werden direkt in den Screens per try/catch behandelt und via `SnackBar` dem Benutzer angezeigt:

```dart
try {
  await widget.jsonService.saveAlbums(albums);
} catch (e) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Fehler beim Speichern: $e')),
  );
}
```

Logging ueber `LoggerService`:

```dart
LoggerService.info('Albums loaded: ${albums.length} albums');
LoggerService.error('Failed to load albums', error);
```

## Testing

### Tests ausfuehren

```bash
flutter test                                      # Alle Tests
flutter test test/json_service_test.dart          # Einzelner Test
flutter test --coverage                           # Mit Coverage-Report
```

### Test schreiben

#### Unit Test (Service)

```dart
void main() {
  group('AlbumFilterService', () {
    late AlbumFilterService service;

    setUp(() {
      service = AlbumFilterService();
    });

    test('filters by medium', () {
      final albums = [
        Album(medium: 'Vinyl', ...),
        Album(medium: 'CD', ...),
      ];
      final result = service.filterAlbums(
        albums: albums,
        mediumFilters: {'Vinyl': true, 'CD': false},
      );
      expect(result.length, 1);
      expect(result.first.medium, 'Vinyl');
    });
  });
}
```

#### Widget Test (Screen)

```dart
void main() {
  testWidgets('MainScreen displays album list', (tester) async {
    final mockJsonService = MockJsonService();
    when(mockJsonService.loadAlbums()).thenAnswer((_) async => testAlbums);

    await tester.pumpWidget(MaterialApp(
      home: MainScreen(jsonService: mockJsonService),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Test Album'), findsOneWidget);
  });
}
```

### Vorhandene Tests

- **Model Tests**: `album_model_test.dart`
- **Service Tests**: `json_service_test.dart`, `album_filter_service_test.dart`, `config_manager_test.dart`, `validation_service_test.dart`, `auto_save_service_test.dart`, `discogs_service_test.dart`, `import_export_service_test.dart`, `logger_service_test.dart`, `wantlist_sync_service_test.dart`
- **Widget/Screen Tests**: `main_screen_test.dart`, `add_album_screen_test.dart`, `edit_album_screen_test.dart`, `album_form_widget_test.dart`, `album_list_widget_test.dart`
- **Integration Tests**: `integration_test.dart`

## Building

### Development

```bash
flutter run                # Standard-Plattform
flutter run -d linux       # Linux
flutter run -d android     # Android
```

### Release Builds

```bash
flutter build apk --release          # Android APK
flutter build appbundle --release    # Android App Bundle (Play Store)
flutter build linux --release        # Linux
flutter build windows --release      # Windows
flutter build macos --release        # macOS
flutter build ios --release          # iOS
```

### Build-Skripte

```bash
./scripts/create_apk.sh            # Android APK erstellen
./scripts/create_deb.sh            # Debian-Paket erstellen
./scripts/build_all_platforms.sh   # Alle Plattformen bauen
```

## Versionierung

### Version aktualisieren

```bash
./scripts/update_version.sh
```

Aktualisiert automatisch:
- `pubspec.yaml` (Version + Build-Nummer)
- `README.md` (Version-Badge)
- `android/app/build.gradle` (versionCode + versionName)
- `package/DEBIAN/control` (Debian-Version)
- `package/.../version.json` (Flutter-Assets)

### Automatische Build-Nummer

Der Pre-commit Hook in `.git/hooks/pre-commit` erhoeht die Build-Nummer in `pubspec.yaml` bei jedem Commit automatisch um 1.

## Code Quality

### Linting & Formatting

```bash
dart format lib/ test/
flutter analyze
dart fix --apply
```

### Dependencies

```bash
flutter pub get              # Dependencies installieren
flutter pub upgrade          # Dependencies aktualisieren
flutter pub outdated         # Veraltete Packages pruefen
```

### Aktuelle Dependencies (pubspec.yaml)

```yaml
dependencies:
  path_provider: ^2.1.1      # Dateisystem-Pfade
  file_picker: ^8.1.2        # Dateiauswahl-Dialog
  shared_preferences: ^2.2.2 # Key-Value Speicher
  uuid: ^4.5.0               # Unique IDs
  package_info_plus: ^8.1.1  # App-Versionsinformationen
  logger: ^1.4.0             # Logging
  url_launcher: ^6.3.0       # URLs oeffnen
  http: ^1.1.0               # HTTP Client (Discogs API)
  csv: ^6.0.0                # CSV Import/Export
  xml: ^6.1.0                # XML Import/Export
  crypto: ^3.0.3             # OAuth-Signaturen
  share_plus: ^10.0.2        # Teilen-Funktion

dev_dependencies:
  mockito: ^5.4.4            # Mocking fuer Tests
  build_runner: ^2.4.13      # Code-Generierung (Mockito)
  flutter_lints: ^5.0.0      # Lint-Regeln
  flutter_launcher_icons: ^0.13.1 # App-Icon-Generierung
```

## Debugging

```bash
flutter run --debug          # Debug-Modus
flutter run --verbose        # Ausfuehrliches Logging
flutter run --profile        # Performance-Profiling
flutter logs                 # Logs anzeigen
```

## Commit-Konventionen

```
feat: neue Funktion hinzufuegen
fix: Bug beheben
docs: Dokumentation aktualisieren
test: Tests hinzufuegen/aendern
refactor: Code umstrukturieren
style: Formatierung aendern
```
