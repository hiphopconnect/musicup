# MusicUp - Architecture Documentation

## 🏗️ Architecture Overview

MusicUp follows a **Clean Architecture** pattern with **Riverpod** state management, designed for cross-platform deployment (Android, iOS, Windows, macOS, Linux).

```
lib/
├── core/                    # Framework-agnostic business logic
│   ├── error/               # Centralized error handling
│   ├── platform/            # Platform-specific services
│   ├── providers/           # Riverpod providers
│   ├── repositories/        # Repository interfaces
│   ├── responsive/          # Responsive design system
│   └── services/            # Core business services
├── models/                  # Data models
├── screens/                 # UI screens (feature-based)
├── services/                # Legacy services (being migrated)
├── theme/                   # App theming
└── widgets/                 # Reusable UI components
```

## 🔄 State Management

### Riverpod Providers

We use **Riverpod** for modern, type-safe state management:

```dart
// Theme management
@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() => configManager.getThemeMode();
  
  Future<void> updateTheme(ThemeMode mode) async {
    await configManager.setThemeMode(mode);
    state = mode;
  }
}

// Usage in widgets
final themeMode = ref.watch(themeNotifierProvider);
```

### Key Providers

- **ThemeNotifier**: Theme mode management
- **AlbumNotifier**: Album collection state
- **ConfigManager**: App configuration
- **PlatformService**: Platform-specific functionality

## 📱 Responsive Design

### Breakpoints

```dart
class ResponsiveBreakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;
}
```

### Layout Adaptation

```dart
ResponsiveLayout(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
)
```

### Platform-Specific UI

- **Mobile (Android/iOS)**: Bottom/Tab navigation
- **Tablet**: Rail navigation
- **Desktop**: Sidebar navigation with system tray support

## 🏪 Repository Pattern

### Album Repository

```dart
abstract class AlbumRepository {
  Future<List<Album>> getAlbums();
  Future<void> saveAlbum(Album album);
  Future<void> updateAlbum(Album album);
  Future<void> deleteAlbum(String id);
  Future<List<Album>> searchAlbums(String query);
  Future<AlbumStats> getAlbumStats();
}
```

### Implementation

```dart
class UnifiedAlbumService implements AlbumRepository {
  // Consolidates:
  // - JSON storage operations
  // - Validation logic
  // - Import/Export functionality
  // - Search and filtering
}
```

## ⚠️ Error Handling

### Centralized Error Management

```dart
class AppErrorHandler {
  static void handle(
    Object error,
    StackTrace? stackTrace, {
    String? context,
    ErrorLevel level = ErrorLevel.error,
  });
}
```

### Error Types

- **AppException.network**: Network-related errors
- **AppException.storage**: Local storage errors
- **AppException.validation**: Data validation errors
- **AppException.unknown**: Unexpected errors

### Usage

```dart
try {
  await albumService.saveAlbum(album);
} catch (error) {
  throw AppErrorHandler.handleStorageError(
    error,
    context: 'MainScreen.saveAlbum',
  );
}
```

## 🔧 Services Architecture

### Core Services (New)

1. **UnifiedAlbumService**: Album CRUD operations
2. **PlatformService**: Platform-specific functionality
3. **ConfigManager**: App configuration
4. **ValidationService**: Data validation
5. **LoggerService**: Centralized logging

### Legacy Services (Being Phased Out)

- Multiple specialized services consolidated into fewer, more focused services
- Migrating from direct service injection to repository pattern

## 🚀 Platform Support

### Desktop Features

- **Window Management**: Resizing, minimizing, positioning
- **System Tray**: Background operation with context menu
- **Auto-Updates**: Automatic update checking
- **Native Shortcuts**: Keyboard shortcuts per platform

### Mobile Features

- **Responsive Navigation**: Bottom nav (Android) / Tab bar (iOS)
- **Platform Theming**: Material (Android) / Cupertino hints (iOS)
- **Deep Linking**: URL scheme support
- **Background Tasks**: Limited background processing

### Platform-Specific Optimizations

```dart
// Platform detection
PlatformType platform = ResponsiveLayout.getCurrentPlatform();

// Platform-specific UI
EdgeInsets padding = PlatformAdaptive.getPlatformPadding(context);
BorderRadius radius = PlatformAdaptive.getPlatformBorderRadius();
```

## 📊 Data Flow

```
UI Layer (Screens/Widgets)
    ↓
State Management (Riverpod Providers)
    ↓
Repository Layer (Album Repository)
    ↓
Service Layer (Unified Services)
    ↓
Data Layer (JSON Files / External APIs)
```

## 🧪 Testing Strategy

### Test Coverage Goals

- **Unit Tests**: 80%+ coverage for business logic
- **Widget Tests**: Critical UI components
- **Integration Tests**: End-to-end workflows
- **Golden Tests**: UI regression testing

### Test Structure

```
test/
├── core/
│   ├── services/         # Service unit tests
│   ├── repositories/     # Repository tests
│   └── responsive/       # Responsive layout tests
├── widgets/              # Widget tests
├── screens/              # Screen tests
└── integration/          # E2E tests
```

## 🔄 Migration Path

### From Legacy to Modern Architecture

1. **Phase 1**: Riverpod integration ✅
2. **Phase 2**: Service consolidation ✅
3. **Phase 3**: Repository pattern ✅
4. **Phase 4**: Error handling ✅
5. **Phase 5**: Responsive design ✅
6. **Phase 6**: Test coverage improvement ✅

### Breaking Changes

- State management moved from setState to Riverpod
- Service injection replaced with repository pattern
- Manual theming replaced with provider-based theming

## 📦 Build & Deployment

### Multi-Platform Builds

```bash
./build_all_platforms.sh
```

Builds for:
- Android (APK + AAB)
- iOS (requires macOS)
- Windows (MSI installer)
- macOS (DMG package)
- Linux (DEB + AppImage)

### CI/CD Pipeline

1. **Code Quality**: Linting, formatting, analysis
2. **Testing**: Unit, widget, integration tests
3. **Building**: Multi-platform builds
4. **Deployment**: Platform-specific stores/repositories

## 🔧 Development Guidelines

### Code Style

- Follow Dart/Flutter conventions
- Use `dart format` and `flutter analyze`
- Implement proper error handling
- Write comprehensive tests

### Architecture Principles

- **Single Responsibility**: Each class has one reason to change
- **Dependency Inversion**: Depend on abstractions, not concretions
- **Open/Closed**: Open for extension, closed for modification
- **Interface Segregation**: Many specific interfaces vs. one general

### Performance Considerations

- Lazy loading for large lists
- Image caching for album artwork
- Debounced search queries
- Pagination for large datasets
- Platform-appropriate animations

## 🔍 Monitoring & Analytics

### Logging

```dart
LoggerService.logInfo('User action performed');
LoggerService.logError('Error occurred', error);
```

### Error Tracking

- Development: Console logging
- Production: Crash reporting integration ready
- User Feedback: In-app error reporting

### Performance Monitoring

- Flutter Inspector for development
- Platform-specific profiling tools
- Memory usage monitoring
- App startup time tracking

## 🚀 Future Enhancements

### Planned Features

1. **Cloud Sync**: Cross-device synchronization
2. **Advanced Search**: Full-text search with indexing
3. **Social Features**: Sharing collections, recommendations
4. **AI Integration**: Smart categorization, duplicate detection
5. **Offline Support**: Full offline-first architecture

### Technical Debt

- Complete migration from legacy services
- Implement proper dependency injection container
- Add comprehensive error recovery mechanisms
- Improve test coverage to 90%+
- Add performance benchmarking