# MusicUp - Architecture Documentation

## Architecture Overview

MusicUp uses a **pragmatic Service-based architecture** with **StatefulWidget + setState** for state management. Services are created in `main.dart` and passed via constructor injection through the widget tree.

```
lib/
├── main.dart                # App entry point, service wiring
├── models/                  # Data models (Album, Track, DiscogsSearchResult)
├── screens/                 # StatefulWidget screens (8 screens)
├── services/                # Stateless service classes (15 services)
├── theme/                   # App theming and design tokens
└── widgets/                 # Reusable UI components (22 widgets)
```

## Data Flow

```
User Input
    |
Screen (StatefulWidget)
    | setState()
Service Layer (stateless classes)
    |
Data Layer (JSON files / Discogs API / SharedPreferences)
```

Kein Repository Pattern, keine Provider, keine Abstraktionsschichten zwischen Screen und Service.

## Service Architecture

### Service-Kategorien

| Kategorie | Services | Aufgabe |
|-----------|----------|---------|
| **Konfiguration** | ConfigManager | SharedPreferences Wrapper |
| **Datenzugriff** | JsonService | File I/O (albums.json, wantlist.json) |
| **Externe API** | DiscogsServiceUnified, DiscogsOAuthService, DiscogsAlbumService | Discogs API |
| **Business Logic** | AlbumFilterService, AlbumEditService, WantlistSyncService, WantlistService | Kernoperationen |
| **Formulare** | ValidationService, AutoSaveService | Validierung und Entwurfsspeicherung |
| **Import/Export** | ImportExportService, FolderImportService | CSV/XML/JSON Import/Export |
| **PDF-Export** | PdfExportService | PDF-Generierung fuer Sammlung und Wantlist |
| **Utilities** | LoggerService, ToastService, AccessibilityService | Querschnittsfunktionen |

### Dependency Wiring (main.dart)

```dart
main()
  -> ConfigManager()            // SharedPreferences laden
  -> JsonService(configManager) // File I/O mit Config-Pfaden
  -> MyApp(configManager, jsonService)
       -> MainScreen(jsonService, onThemeChanged)
       -> SettingsScreen(jsonService, onThemeChanged)
```

Services werden per **Constructor Injection** weitergegeben. Einige Screens erstellen zusaetzliche Services lokal in `initState()`:

```dart
// Beispiel: DiscogsSearchScreen
void initState() {
  _discogsService = DiscogsServiceUnified(token: widget.discogsToken);
  _albumService = DiscogsAlbumService();
}
```

### Service-Eigenschaften

- **Stateless**: Services halten keinen eigenen State
- **Keine Streams**: Keine reaktiven Patterns (StreamController etc.)
- **Async via Future<T>**: Alle I/O-Operationen sind Future-basiert
- **Testbar**: Mockbar via Constructor Injection (Mockito)

## State Management

### Pattern: StatefulWidget + setState

Jeder Screen verwaltet seinen eigenen State lokal:

```dart
class _MainScreenState extends State<MainScreen> {
  List<Album> _albums = [];
  List<Album> _filteredAlbums = [];
  bool _isLoading = true;

  Future<void> _loadAlbums() async {
    setState(() => _isLoading = true);
    final albums = await widget.jsonService.loadAlbums();
    setState(() {
      _albums = albums;
      _applyFiltersAndSort();
      _isLoading = false;
    });
  }
}
```

### State Lifting

Parent-Widgets verwalten State und reichen Daten + Callbacks an Children:

```
MainScreen (State: albums, filters, loading)
    |
    +-- AlbumFiltersWidget (onFilterChanged callback)
    +-- AlbumListWidget (albums list, onEdit/onDelete callbacks)
```

### Cross-Screen Communication

Screens geben Ergebnisse via `Navigator.pop(context, result)` zurueck:

```dart
final result = await Navigator.push(context,
  MaterialPageRoute(builder: (_) => EditAlbumScreen(...)));
if (result == true) {
  _loadAlbums(); // Daten neu laden
}
```

## Models

Zentrale Datenmodelle in `lib/models/album_model.dart`:

- **Album**: Hauptmodell mit Titel, Artist, Tracks, Medium, etc.
- **Track**: Einzelner Track mit Titel und Dauer
- **DiscogsSearchResult**: Ergebnis der Discogs-API-Suche

## Testing

### Struktur

```
test/
├── album_model_test.dart           # Model Unit Tests
├── album_filter_service_test.dart  # Service Unit Tests
├── config_manager_test.dart
├── json_service_test.dart
├── validation_service_test.dart
├── auto_save_service_test.dart
├── discogs_service_test.dart
├── import_export_service_test.dart
├── logger_service_test.dart
├── wantlist_sync_service_test.dart
├── add_album_screen_test.dart      # Screen Widget Tests
├── edit_album_screen_test.dart
├── main_screen_test.dart
├── album_form_widget_test.dart     # Widget Tests
├── album_list_widget_test.dart
└── integration_test.dart           # Integration Tests
```

### Test-Ansatz

- **Unit Tests**: Services via Mockito testen (Constructor Injection)
- **Widget Tests**: Screens mit gemockten Services
- **Integration Tests**: End-to-End Workflows

```bash
flutter test                                    # Alle Tests
flutter test test/json_service_test.dart        # Einzelner Test
flutter test --coverage                         # Mit Coverage
```

## Build & Deployment

### Build-Skripte

| Skript | Zielplattform |
|--------|---------------|
| `scripts/create_apk.sh` | Android APK |
| `scripts/create_deb.sh` | Linux .deb Paket |
| `scripts/create_exe.sh` | Windows |
| `scripts/create_ios.sh` | iOS |
| `scripts/create_macos.sh` | macOS |
| `scripts/build_all_platforms.sh` | Alle Plattformen |
| `scripts/update_version.sh` | Versionsnummer aktualisieren |

### Versionierung

- Version in `pubspec.yaml` (z.B. `2.2.0+11`)
- `update_version.sh` aktualisiert: pubspec.yaml, README.md, Android build.gradle, DEBIAN/control, version.json
- Pre-commit Hook erhoeht Build-Nummer automatisch

## Known Limitations

### Prop Drilling

`jsonService` und `onThemeChanged` werden manuell durch den Widget-Tree gereicht. Bei tieferen Hierarchien wird das unuebersichtlich.

### Inkonsistente Service-Instanziierung

Manche Screens erstellen eigene Service-Instanzen in `initState()` statt sie von oben zu erhalten. Das fuehrt zu mehreren Instanzen desselben Services.

### Manuelles Cross-Screen State

Aenderungen in einem Screen (z.B. Album bearbeiten) erfordern manuelles Neuladen im vorherigen Screen. Es gibt keinen automatischen Synchronisationsmechanismus.

### Moegliche Verbesserung

Ein einfacher ServiceLocator (ohne externe Packages) wuerde alle drei Probleme loesen, ohne die Architektur wesentlich zu verkomplizieren.
