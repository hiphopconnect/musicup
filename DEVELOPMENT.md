# MusicUp - Development Guide

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.10.0+
- **Dart SDK**: 3.0.0+
- **Platform-specific tools**:
  - Android: Android Studio + Android SDK
  - iOS: Xcode (macOS only)
  - Windows: Visual Studio 2022 with C++ tools
  - macOS: Xcode Command Line Tools
  - Linux: Standard development tools

### Initial Setup

```bash
# Clone the repository
git clone https://github.com/hiphopconnect/musicup.git
cd musicup

# Install dependencies
flutter pub get

# Generate code (Riverpod providers, etc.)
dart run build_runner build

# Enable desktop platforms
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop

# Verify setup
flutter doctor -v
```

## 🏗️ Project Structure

### Core Architecture

```
lib/
├── core/                    # Clean architecture core
│   ├── error/
│   │   └── error_handler.dart         # Centralized error handling
│   ├── platform/
│   │   └── platform_service.dart      # Platform-specific services
│   ├── providers/
│   │   └── theme_provider.dart        # Riverpod providers
│   ├── repositories/
│   │   └── album_repository.dart      # Repository interfaces
│   ├── responsive/
│   │   └── responsive_layout.dart     # Responsive design system
│   └── services/
│       └── unified_album_service.dart # Consolidated business logic
├── models/
│   └── album_model.dart               # Data models
├── screens/
│   ├── main_screen.dart               # Legacy main screen
│   ├── responsive_main_screen.dart    # Modern responsive screen
│   ├── add_album_screen.dart
│   ├── edit_album_screen.dart
│   ├── settings_screen.dart
│   └── wantlist_screen.dart
├── services/                          # Legacy services (being phased out)
├── theme/
│   ├── app_theme.dart                 # App theming
│   └── design_system.dart             # Design tokens
├── widgets/                           # Reusable components
└── main.dart                          # App entry point
```

## 🔄 State Management with Riverpod

### Creating Providers

```dart
// 1. Add riverpod_annotation dependency
// 2. Create provider file
@riverpod
class DataNotifier extends _$DataNotifier {
  @override
  List<Data> build() => [];
  
  void addData(Data data) {
    state = [...state, data];
  }
}

// 3. Generate code
// dart run build_runner build
```

### Using Providers in Widgets

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataNotifierProvider);
    
    return Column(
      children: [
        Text('Count: ${data.length}'),
        ElevatedButton(
          onPressed: () => ref.read(dataNotifierProvider.notifier).addData(newData),
          child: Text('Add Data'),
        ),
      ],
    );
  }
}
```

## 📱 Responsive Design

### Adding Responsive Layouts

```dart
// Use ResponsiveLayout widget
ResponsiveLayout(
  mobile: MobileWidget(),
  tablet: TabletWidget(),
  desktop: DesktopWidget(),
)

// Use ResponsiveValue for dynamic values
final padding = ResponsiveValue<double>(
  mobile: 16.0,
  tablet: 24.0,
  desktop: 32.0,
).getValue(context);
```

### Platform-Specific Adaptations

```dart
// Get platform-appropriate styling
final padding = PlatformAdaptive.getPlatformPadding(context);
final borderRadius = PlatformAdaptive.getPlatformBorderRadius();
final elevation = PlatformAdaptive.getPlatformElevation();

// Platform detection
if (ResponsiveLayout.isDesktop) {
  // Desktop-specific code
} else {
  // Mobile-specific code
}
```

## ⚠️ Error Handling

### Using Centralized Error Handler

```dart
try {
  await riskyOperation();
} catch (error, stackTrace) {
  // Centralized error handling
  AppErrorHandler.handle(
    error,
    stackTrace,
    context: 'MyWidget.riskyOperation',
    level: ErrorLevel.error,
  );
  
  // Or use specific handlers
  throw AppErrorHandler.handleNetworkError(error, context: 'API Call');
}
```

### Creating Custom Exceptions

```dart
throw AppException.validation(
  message: 'Invalid input data',
  context: 'FormValidation',
);
```

## 🧪 Testing

### Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/core/services/unified_album_service_test.dart

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Writing Tests

#### Unit Tests

```dart
void main() {
  group('UnifiedAlbumService', () {
    late UnifiedAlbumService service;
    late MockJsonService mockJsonService;
    
    setUp(() {
      mockJsonService = MockJsonService();
      service = UnifiedAlbumService(jsonService: mockJsonService);
    });
    
    test('should return albums', () async {
      // Arrange
      final expectedAlbums = [Album(id: '1', title: 'Test')];
      when(mockJsonService.loadAlbums()).thenAnswer((_) async => expectedAlbums);
      
      // Act
      final result = await service.getAlbums();
      
      // Assert
      expect(result, equals(expectedAlbums));
    });
  });
}
```

#### Widget Tests

```dart
void main() {
  testWidgets('ResponsiveLayout displays correct widget for screen size', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(400, 800)),
          child: ResponsiveLayout(
            mobile: Text('Mobile'),
            tablet: Text('Tablet'),
          ),
        ),
      ),
    );
    
    expect(find.text('Mobile'), findsOneWidget);
    expect(find.text('Tablet'), findsNothing);
  });
}
```

## 🏗️ Building & Deployment

### Development Builds

```bash
# Debug builds for development
flutter run                    # Default platform
flutter run -d windows         # Windows
flutter run -d macos          # macOS
flutter run -d linux          # Linux
flutter run -d android        # Android
flutter run -d ios            # iOS
```

### Release Builds

```bash
# Single platform
flutter build apk --release               # Android APK
flutter build appbundle --release         # Android App Bundle
flutter build ios --release               # iOS
flutter build windows --release           # Windows
flutter build macos --release             # macOS
flutter build linux --release             # Linux

# All platforms
./build_all_platforms.sh
```

### Build Outputs

```
releases/v{VERSION}/
├── musicup-v{VERSION}-android-arm64.apk
├── musicup-v{VERSION}-android-arm.apk
├── musicup-v{VERSION}-android-x64.apk
├── musicup-v{VERSION}-playstore.aab
├── windows/                    # Windows executable + DLLs
├── macos/MusicUp.app          # macOS app bundle
├── linux/                     # Linux executable + resources
├── musicup-v{VERSION}-linux.tar.gz
├── music-up_*.deb             # Debian package
└── SHA256SUMS                 # Checksums
```

## 🔧 Code Quality

### Linting & Formatting

```bash
# Format code
dart format lib/ test/

# Analyze code
flutter analyze

# Fix common issues
dart fix --apply
```

### Pre-commit Hooks

```bash
# Install pre-commit hooks (if using)
git hooks install

# Manual quality check
dart format --set-exit-if-changed lib/ test/
flutter analyze --fatal-infos
flutter test
```

### Code Generation

```bash
# Generate Riverpod providers, JSON serialization, etc.
dart run build_runner build

# Watch for changes during development
dart run build_runner watch

# Clean and rebuild
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

## 🐛 Debugging

### Debug Mode

```bash
# Run with debugging
flutter run --debug

# Enable verbose logging
flutter run --verbose

# Profile mode for performance testing
flutter run --profile
```

### Platform-Specific Debugging

#### Android

```bash
# View logs
flutter logs
adb logcat

# Install debug APK
flutter install --debug
```

#### iOS (macOS only)

```bash
# Open iOS Simulator
open -a Simulator

# View device logs
flutter logs
xcrun simctl spawn booted log stream
```

#### Desktop

```bash
# Run with console output
flutter run -d windows --verbose
flutter run -d macos --verbose
flutter run -d linux --verbose
```

## 📦 Dependencies

### Adding Dependencies

```bash
# Add regular dependency
flutter pub add package_name

# Add dev dependency
flutter pub add --dev package_name

# Update dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated
```

### Key Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.9      # State management
  riverpod_annotation: ^2.3.3   # Code generation
  window_manager: ^0.3.7        # Desktop window management
  system_tray: ^2.0.3           # System tray support
  logger: ^2.0.1                # Logging
  
dev_dependencies:
  riverpod_generator: ^2.3.9    # Riverpod code generation
  build_runner: ^2.4.13        # Code generation runner
  mockito: ^5.4.4               # Mocking for tests
```

## 🔄 Migration Guide

### From Legacy to Modern Architecture

1. **Replace setState with Riverpod**:
   ```dart
   // Old
   setState(() { _data = newData; });
   
   // New
   ref.read(dataNotifierProvider.notifier).updateData(newData);
   ```

2. **Replace direct service calls with repositories**:
   ```dart
   // Old
   final albums = await jsonService.loadAlbums();
   
   // New
   final albums = await ref.read(albumRepositoryProvider).getAlbums();
   ```

3. **Replace manual error handling**:
   ```dart
   // Old
   try { ... } catch (e) { print('Error: $e'); }
   
   // New
   try { ... } catch (e, s) { AppErrorHandler.handle(e, s, context: 'Operation'); }
   ```

## 🚀 Performance Optimization

### General Guidelines

- Use `const` constructors where possible
- Implement proper `dispose()` methods
- Use `AutomaticKeepAliveClientMixin` for expensive widgets
- Optimize list rendering with `ListView.builder`
- Cache expensive computations

### Platform-Specific Optimizations

#### Desktop

```dart
// Window management
await windowManager.setSize(Size(1200, 800));
await windowManager.setMinimumSize(Size(800, 600));

// System tray integration
await systemTray.initSystemTray(iconPath: 'assets/icon.png');
```

#### Mobile

```dart
// Memory optimization
SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

// Battery optimization
WidgetsBinding.instance.addObserver(lifecycleObserver);
```

## 📝 Contributing

### Development Workflow

1. **Feature Branch**: Create feature/fix branches from `main`
2. **Code**: Implement changes following architecture guidelines
3. **Test**: Write/update tests, ensure coverage
4. **Quality**: Run linting, formatting, analysis
5. **PR**: Create pull request with description
6. **Review**: Address feedback, update as needed
7. **Merge**: Squash and merge when approved

### Commit Messages

```bash
feat: add responsive desktop layout
fix: resolve memory leak in album loading
docs: update architecture documentation
test: add unit tests for album service
refactor: consolidate album services
style: format code according to dart conventions
```

## 🔧 Troubleshooting

### Common Issues

#### Build Failures

```bash
# Clean and rebuild
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build

# Platform-specific issues
flutter doctor -v
```

#### State Management Issues

```bash
# Regenerate providers
dart run build_runner build --delete-conflicting-outputs

# Check provider dependencies
flutter packages pub deps
```

#### Platform Support

```bash
# Enable desktop support
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop

# Verify platform support
flutter doctor -v
```

## 📚 Resources

### Documentation

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### Tools

- **IDE**: VS Code with Flutter/Dart extensions
- **Debugging**: Flutter Inspector, Dart DevTools
- **Testing**: Flutter Test, Mockito
- **CI/CD**: GitHub Actions (planned)

### Community

- [Flutter Community](https://flutter.dev/community)
- [Riverpod Discord](https://discord.gg/Bbumvej)
- Project Issues: [GitHub Issues](https://github.com/hiphopconnect/musicup/issues)