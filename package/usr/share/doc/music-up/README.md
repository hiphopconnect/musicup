# MusicUp

![Flutter](https://img.shields.io/badge/Flutter-v3.32.7-blue.svg)
![Dart](https://img.shields.io/badge/Dart-v3.8.1-blue.svg)
![Version](https://img.shields.io/badge/Version-v2.0.1-blue.svg)
![License](https://img.shields.io/badge/License-Proprietary-red.svg)
![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Android-green.svg)
![Discogs](https://img.shields.io/badge/Discogs-API%20Integration-orange.svg)
![Portfolio](https://img.shields.io/badge/Portfolio-Project-yellow.svg)
![Status](https://img.shields.io/badge/Status-Active%20Development-brightgreen.svg)

**MusicUp** is a Flutter-based application designed to help users manage their extensive music collections efficiently.
Whether you're a music enthusiast organizing your CDs and vinyls or an artist managing your discography, MusicUp offers
a seamless experience for importing, exporting, and maintaining your album data.

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Installation](#installation)
- [Packaging for Debian](#packaging-for-debian)
- [Usage](#usage)
- [Testing](#testing)
- [Motivation](#motivation)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Features

### Core Collection Management
- **Add Albums:** Easily add new albums with details such as name, artist, genre, year, medium, and digital availability
- **Edit Albums:** Modify existing album information to keep your collection up-to-date
- **Album Details:** View comprehensive album information including track listings and metadata
- **Duplicate Prevention:** Automatically avoids adding duplicate albums during import and manual entry

### Advanced Import Features
- **Folder Import:** Starting from version 1.3.1, fetch song information from folder structures. Press the folder button in the Add Album section and select a folder. The album name is extracted from the folder name, and MP3 files must be formatted as '01 - Tracktitle.mp3' for automatic track detection
- **Multi-Format Import/Export:** Support for importing and exporting album data in JSON, CSV, and XML formats
- **Batch Operations:** Import multiple albums at once while maintaining data integrity

### Discogs Integration
- **OAuth Authentication:** Secure OAuth 1.0a authentication with Discogs API
- **Album Search:** Search the Discogs database for album information and automatically populate fields
- **Discogs Collection Sync:** Import albums directly from your Discogs collection
- **API Rate Limiting:** Intelligent handling of Discogs API rate limits to ensure uninterrupted service

### Wantlist Management
- **Wantlist Screen:** Dedicated interface for managing albums you want to acquire
- **Online/Offline Sync:** Synchronize your wantlist with Discogs while maintaining offline functionality
- **Add to Collection:** Seamlessly move albums from wantlist to your main collection
- **Smart Merging:** Intelligent conflict resolution when syncing online and offline wantlist data

### Search & Organization
- **Advanced Search:** Quickly find albums using comprehensive search functionality
- **Filter Options:** Filter by medium (CD, Vinyl, Digital), genre, year, and digital availability
- **Real-time Search:** Instant search results as you type
- **Album Sorting:** Organize your collection with intelligent sorting options

### User Experience
- **Modern UI:** Clean, intuitive Material Design interface with consistent theming
- **Auto-Save:** Automatic form data preservation to prevent data loss
- **Toast Notifications:** Clear feedback for all user actions
- **Accessibility Support:** Full accessibility features for inclusive usage
- **Settings Management:** Comprehensive configuration options and preferences

## Screenshots

<img src="screenshots/main_screen.png" alt="Main Screen" width="400"/>

*Main Screen displaying a list of albums.*

<img src="screenshots/add_album.png" alt="Add Album" width="400"/>

*Add Album screen with form fields.*

<img src="screenshots/export_options.png" alt="Export Options" width="400"/>

*Exporting albums in different formats.*

## Installation

### Prerequisites

- **Flutter SDK:** Ensure you have Flutter installed. Follow
  the [official installation guide](https://flutter.dev/docs/get-started/install) if you haven't set it up yet.
- **Dart SDK:** Comes bundled with Flutter.
- **Git:** To clone the repository.

### Steps

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/hiphopconnect/music_up.git
   cd music_up
   ```

2. **Install Dependencies:**

   ```bash
   flutter pub get
   ```

3. **Run the App:**

   ```bash
   flutter run
   ```

## Packaging for Debian

To create a `.deb` package for **MusicUp**, ensure you have all dependencies installed, then follow these steps:

1. Make the script executable:

   ```bash
   chmod +x create_deb.sh
   ```

2. Run the script to build the Debian package:

   ```bash
   ./create_deb.sh
   ```

This will generate a `.deb` package, which you can install on any Debian-based system.

## Usage

Once installed, **MusicUp** can be launched from your system's application menu. The application provides:

### Getting Started
1. **Main Collection:** Start by adding albums manually or importing from various formats
2. **Discogs Integration:** Configure OAuth authentication in settings for enhanced features
3. **Wantlist Management:** Use the dedicated wantlist screen to track desired albums
4. **Search & Discovery:** Use the Discogs search to find and add albums with complete metadata

### Key Workflows
- **Manual Entry:** Add albums with comprehensive details and track information
- **Folder Import:** Automatically extract album and track data from organized music folders
- **Discogs Search:** Find albums in the Discogs database and import with full metadata
- **Collection Sync:** Keep your local collection synchronized with your Discogs profile
- **Data Management:** Export your collection for backup or sharing in multiple formats

## Import/Export File Formats

**MusicUp** supports importing and exporting your collection in multiple standardized formats:

### 📄 **JSON Format** (Recommended)
The native format with full feature support including tracks and metadata:

```json
[
  {
    "id": "unique_album_id",
    "name": "Album Name",
    "artist": "Artist Name",
    "genre": "Rock",
    "year": "2024",
    "medium": "Vinyl",
    "digital": true,
    "tracks": [
      {
        "trackNumber": "01",
        "title": "Song Title"
      },
      {
        "trackNumber": "02", 
        "title": "Another Song"
      }
    ]
  }
]
```

### 📊 **CSV Format** 
Spreadsheet-compatible format supporting both basic and detailed album information:

#### **Basic CSV Format:**
```csv
name,artist,genre,year,medium,digital
"Album Name","Artist Name","Rock","2024","Vinyl","true"
"Another Album","Another Artist","Jazz","2023","CD","false"
```

#### **Extended CSV Format with Tracks:**
```csv
name,artist,genre,year,medium,digital,tracks
"Album Name","Artist Name","Rock","2024","Vinyl","true","01 - Song Title|02 - Another Song|03 - Final Track"
"Another Album","Another Artist","Jazz","2023","CD","false","01 - Jazz Intro|02 - Main Theme"
```

**CSV Column Headers:**
- `name` - Album title (required)
- `artist` - Artist name (required) 
- `genre` - Music genre (optional)
- `year` - Release year (optional)
- `medium` - Physical format: "Vinyl", "CD", "Digital", etc. (optional)
- `digital` - Digital availability: "true" or "false" (optional)
- `tracks` - Track listing separated by pipe (`|`) character (optional)
  - Format: `"01 - Track Title|02 - Next Track|03 - Final Track"`
  - Each track: `TrackNumber - TrackTitle`

### 🗂️ **XML Format**
Structured format for data exchange:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<albums>
  <album>
    <id>unique_album_id</id>
    <name>Album Name</name>
    <artist>Artist Name</artist>
    <genre>Rock</genre>
    <year>2024</year>
    <medium>Vinyl</medium>
    <digital>true</digital>
    <tracks>
      <track>
        <trackNumber>01</trackNumber>
        <title>Song Title</title>
      </track>
    </tracks>
  </album>
</albums>
```

### 📁 **Folder Import Requirements**
For automatic folder-based import:

```
📁 Album Folder Name/
  🎵 01 - Track Title.mp3
  🎵 02 - Another Track.mp3  
  🎵 03 - Third Track.mp3
```

**Requirements:**
- **Folder Name** = Album name
- **File Format:** `##` - `Track Title.mp3`
- **Track Numbers:** Two digits (01, 02, 03...)
- **Separator:** Space-dash-space (` - `)
- **File Extension:** .mp3 files only

### 💡 **Import Tips**
- **JSON** provides complete data preservation with best track information support
- **CSV** supports both basic album info and track listings (using pipe `|` separator)
- **XML** works well for integration with other music management tools  
- **Folder Import** automatically extracts track listings from organized music files
- All formats support automatic duplicate detection during import
- **Track Format**: Always use `TrackNumber - TrackTitle` pattern (e.g., `01 - Song Name`)
- **CSV Tracks**: Use pipe character `|` to separate multiple tracks in one cell

## Testing

**MusicUp** features comprehensive test coverage across multiple layers to ensure reliability and maintainability.

### Test Coverage

Our test suite includes:
- **Service Layer Tests:** Critical business logic including wantlist sync, Discogs integration, and data persistence
- **Widget Tests:** UI component testing for forms, album lists, and user interactions
- **Integration Tests:** Complete user flows from adding albums to editing and deleting
- **Error Handling Tests:** Comprehensive testing of edge cases and error scenarios

### Running Tests

Execute all tests using Flutter's built-in testing framework:

```bash
flutter test
```

To run specific test categories:

```bash
# Run service layer tests
flutter test test/*_service_test.dart

# Run widget tests
flutter test test/*_widget_test.dart

# Run integration tests
flutter test test/integration_test.dart
```

### Test Structure

- **Critical Services:** WantlistSyncService (online/offline sync logic, merge conflicts, API error handling)
- **API Integration:** DiscogsService (OAuth authentication, API response parsing, rate limiting)
- **Data Layer:** JsonService, ConfigManager, ImportExportService
- **UI Components:** AlbumFormWidget, AlbumListWidget, SearchBarWidget
- **Complete Flows:** Add → Edit → Delete album workflows with form validation

The test coverage ensures robust functionality across all core features of the application.

## Motivation

The idea for **MusicUp** came from my personal need to organize a large collection of CDs and vinyl records. Initially,
I used a paid app that allowed scanning albums, but it often failed to find certain CDs, requiring manual entries. As a
result, I decided to build **MusicUp**, focusing on ease of use and customization. Scanning is a feature I may consider
adding in the future, but for now, manual input is still a reliable option.

**MusicUp** is currently available and tested on:
- **Linux Desktop** (specifically tested on Linux Mint)
- **Android** (mobile version available)

## Contributing

**MusicUp** is currently developed as a personal project. While the source code is publicly visible for educational purposes, the project is not accepting external contributions at this time. 

If you have suggestions or feedback, please feel free to contact the author directly.

## Project Background

I also have a repository with a Swift version of this software, which I originally developed on Swift/IOS. My initial
thought was, "Great! Just one codebase, and I can publish on all platforms." However, I quickly ran into dependency
issues that became difficult to resolve.

As a result, I developed the mobile version of the software for my iPhone in Swift.

### Future Plans

1. **iOS Version** - Flutter version for iPhone and iPad
2. **Windows & macOS Desktop** - Native Flutter desktop applications
3. **Enhanced Features**:
   - Advanced statistics and analytics (listening habits, collection insights)
   - Cloud synchronization options for multi-device access
   - Barcode scanning for quick album identification
   - Enhanced offline capabilities

## License

**All Rights Reserved**

This project is proprietary software owned exclusively by the author.

### Copyright Notice

© 2024 - All rights reserved. This software and its source code are the exclusive property of the author.

### Usage Terms

- **Code Ownership**: This code is publicly visible on GitHub as part of the author's portfolio
- **No Usage Rights**: Viewing this code does not grant any rights to use, copy, modify, or distribute it
- **Educational Purpose**: The code is available for viewing and learning purposes only
- **No Forks/Downloads**: Please do not fork, download, or use this code in any way
- **Portfolio Display**: This repository serves as a showcase of the author's development skills

### Contact for Licensing

If you are interested in licensing this software or any part of it, please contact the author directly.

**Note**: This is a personal portfolio project. The code is public for demonstration purposes only - all rights remain with the original author.

## Contact

For any inquiries or feedback, feel free to contact me
at [Nobo](mailto:nobo_code@posteo.de?subject=[GitHub]%Source%20MusicUP).
