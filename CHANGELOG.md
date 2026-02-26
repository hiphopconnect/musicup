# MusicUp Changelog

All notable changes to MusicUp will be documented in this file.

## [3.0.0] - 2026-02-26 - Production Release

### Added
- **Localization**: Full German and English language support (l10n with flutter_localizations)
- **PDF Export**: Export collection and wantlist as PDF (sorted by artist, with artist/album/medium columns)
- **Help System**: In-app help screen with documentation and user guide
- **Setup Wizard**: First-launch wizard for initial configuration
- **Interactive Tour**: Guided tour overlay introducing app features
- **Service Locator**: Centralized service management replacing manual dependency injection
- **Wantlist Search**: Search and filter functionality for the wantlist screen
- **THIRD_PARTY_LICENSES**: Complete third-party license documentation
- **Man Page**: Unix man page for Linux package (musicup.1)

### Changed
- **Architecture**: Removed obsolete core/ layer (error_handler, platform_service, responsive_layout, album_repository, unified_album_service)
- **Project Structure**: Build scripts moved to scripts/, deb output to releases/linux/
- **PDF Service**: Unified PdfExportService for both collection and wantlist (no code duplication)
- **Documentation**: Updated README, ARCHITECTURE, DEVELOPMENT to reflect current state

### Fixed
- **PDF Export**: TooManyPagesException for collections with 700+ albums (maxPages increased)
- **use_build_context_synchronously** warning in main_screen.dart
- **equal_elements_in_set** warning in album_model_test.dart
- **dead_code** warnings in discogs_service_unified_test.dart (3 occurrences)

### Removed
- Unused app_info_widget.dart and responsive_widgets.dart
- Obsolete responsive_main_screen.dart
- Entire lib/core/ directory (replaced by simpler service architecture)

## [2.2.0] - 2025-02-19 - Wantlist Release

### Added
- Wantlist management with dedicated screen
- Online/Offline synchronization with Discogs wantlist
- Move albums from wantlist to collection
- Smart merge and conflict detection during sync

### Changed
- Updated version management and build scripts

## [2.1.2] - 2025-01-28 - Commercial Release

### Added
- Store-ready preparation for commercial distribution
- Privacy Policy and Terms of Service
- Professional store assets and screenshots
- Enhanced export with multiple format support (JSON, CSV, XML)
- Cross-platform testing on all 5 target platforms

### Improved
- Performance: Optimized album loading and filtering
- Stability: Enhanced error handling and data validation
- UI: Refined interface for better user experience
- Responsiveness: Better adaptation to different screen sizes

### Technical
- Build system: Automated builds for all platforms
- Dependencies: Updated to stable, long-term supported versions
- Testing: Comprehensive test suite for core functionality
- Documentation: Complete developer and user documentation

## [2.0.0] - Major Release

### Added
- Complete UI redesign
- Discogs integration with OAuth 1.0a authentication
- Multi-format import/export (JSON, CSV, XML)
- Enhanced search and filter functionality

### Changed
- Migrated to modern Flutter architecture
- Improved data storage format
- Enhanced user experience

## [1.3.1] - Folder Import

### Added
- Folder import: Automatic track detection from music folders
- Track format: "01 - Tracktitle.mp3"

## [1.0.0] - Initial Release

### Added
- Basic album collection management
- Local data storage with JSON
- Simple export functionality
- Cross-platform support (Linux, Android)
