#!/bin/bash

# MusicUp - Cross-Platform Build Script
# Builds for Android, iOS, Windows, macOS, and Linux

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Version information
VERSION=$(grep '^version:' pubspec.yaml | cut -d ' ' -f 2)
echo -e "${BLUE}🚀 Building MusicUp v$VERSION for all platforms${NC}"

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean
flutter pub get

# Generate code (Riverpod, etc.)
echo -e "${YELLOW}⚙️  Generating code...${NC}"
dart run build_runner build --delete-conflicting-outputs

# Create release directory
RELEASE_DIR="releases/v$VERSION"
mkdir -p "$RELEASE_DIR"

# Platform-specific build functions
build_android() {
    echo -e "${BLUE}📱 Building for Android...${NC}"
    
    # Build APK
    flutter build apk --release --split-per-abi
    cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk "$RELEASE_DIR/musicup-v$VERSION-android-arm64.apk"
    cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk "$RELEASE_DIR/musicup-v$VERSION-android-arm.apk"
    cp build/app/outputs/flutter-apk/app-x86_64-release.apk "$RELEASE_DIR/musicup-v$VERSION-android-x64.apk"
    
    # Build App Bundle for Play Store
    flutter build appbundle --release
    cp build/app/outputs/bundle/release/app-release.aab "$RELEASE_DIR/musicup-v$VERSION-playstore.aab"
    
    echo -e "${GREEN}✅ Android build complete${NC}"
}

build_ios() {
    echo -e "${BLUE}📱 Building for iOS...${NC}"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Build iOS (requires macOS)
        flutter build ios --release --no-codesign
        
        # Create IPA (requires further setup)
        echo -e "${YELLOW}📝 iOS build complete. Manual code signing and IPA creation required.${NC}"
        echo -e "${YELLOW}   Follow iOS deployment guide for App Store submission.${NC}"
    else
        echo -e "${RED}❌ iOS build requires macOS. Skipping...${NC}"
    fi
}

build_windows() {
    echo -e "${BLUE}💻 Building for Windows...${NC}"
    
    if command -v flutter &> /dev/null && flutter config | grep -q "enable-windows-desktop: true"; then
        flutter build windows --release
        
        # Create Windows installer
        if command -v iscc &> /dev/null; then
            # Inno Setup compiler available
            cp -r build/windows/runner/Release/* "$RELEASE_DIR/windows/"
            echo -e "${GREEN}✅ Windows build complete${NC}"
        else
            # Just copy the built files
            mkdir -p "$RELEASE_DIR/windows"
            cp -r build/windows/runner/Release/* "$RELEASE_DIR/windows/"
            echo -e "${YELLOW}⚠️  Windows build complete. Install Inno Setup for installer creation.${NC}"
        fi
    else
        echo -e "${RED}❌ Windows desktop support not enabled. Run: flutter config --enable-windows-desktop${NC}"
    fi
}

build_macos() {
    echo -e "${BLUE}🍎 Building for macOS...${NC}"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if flutter config | grep -q "enable-macos-desktop: true"; then
            flutter build macos --release
            
            # Create DMG (requires additional tools)
            mkdir -p "$RELEASE_DIR/macos"
            cp -r build/macos/Build/Products/Release/MusicUp.app "$RELEASE_DIR/macos/"
            
            echo -e "${GREEN}✅ macOS build complete${NC}"
            echo -e "${YELLOW}📝 For distribution, create DMG with: create-dmg or npm install -g appdmg${NC}"
        else
            echo -e "${RED}❌ macOS desktop support not enabled. Run: flutter config --enable-macos-desktop${NC}"
        fi
    else
        echo -e "${RED}❌ macOS build requires macOS. Skipping...${NC}"
    fi
}

build_linux() {
    echo -e "${BLUE}🐧 Building for Linux...${NC}"
    
    if flutter config | grep -q "enable-linux-desktop: true"; then
        flutter build linux --release
        
        # Create AppImage (if tools available)
        mkdir -p "$RELEASE_DIR/linux"
        cp -r build/linux/x64/release/bundle/* "$RELEASE_DIR/linux/"
        
        # Create tar.gz package
        cd "$RELEASE_DIR"
        tar -czf "musicup-v$VERSION-linux.tar.gz" linux/
        cd ../..
        
        # Create .deb package (reuse existing script)
        if [ -f "create_deb.sh" ]; then
            ./create_deb.sh
            cp music-up_*.deb "$RELEASE_DIR/"
        fi
        
        echo -e "${GREEN}✅ Linux build complete${NC}"
    else
        echo -e "${RED}❌ Linux desktop support not enabled. Run: flutter config --enable-linux-desktop${NC}"
    fi
}

# Main build process
echo -e "${BLUE}🏗️  Starting multi-platform build process...${NC}"

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

# Check Flutter doctor
echo -e "${YELLOW}🩺 Checking Flutter installation...${NC}"
flutter doctor

# Build for each platform (with error handling)
FAILED_BUILDS=()

# Android
if flutter doctor | grep -q "Android toolchain"; then
    if ! build_android; then
        FAILED_BUILDS+=("Android")
    fi
else
    echo -e "${YELLOW}⚠️  Android toolchain not available. Skipping Android build.${NC}"
fi

# iOS  
if flutter doctor | grep -q "iOS toolchain"; then
    if ! build_ios; then
        FAILED_BUILDS+=("iOS")
    fi
else
    echo -e "${YELLOW}⚠️  iOS toolchain not available. Skipping iOS build.${NC}"
fi

# Windows
if ! build_windows; then
    FAILED_BUILDS+=("Windows")
fi

# macOS
if ! build_macos; then
    FAILED_BUILDS+=("macOS")
fi

# Linux
if ! build_linux; then
    FAILED_BUILDS+=("Linux")
fi

# Generate checksums
echo -e "${BLUE}🔒 Generating checksums...${NC}"
cd "$RELEASE_DIR"
find . -type f \( -name "*.apk" -o -name "*.aab" -o -name "*.exe" -o -name "*.deb" -o -name "*.tar.gz" \) -exec sha256sum {} \; > SHA256SUMS
cd ../..

# Summary
echo -e "${BLUE}📊 Build Summary${NC}"
echo "=========================="
echo -e "Version: ${GREEN}v$VERSION${NC}"
echo -e "Release Directory: ${GREEN}$RELEASE_DIR${NC}"

if [ ${#FAILED_BUILDS[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ All available platforms built successfully!${NC}"
else
    echo -e "${RED}❌ Failed builds: ${FAILED_BUILDS[*]}${NC}"
fi

echo ""
echo "Available builds:"
ls -la "$RELEASE_DIR"

echo ""
echo -e "${BLUE}🚀 Build process complete!${NC}"
echo -e "${YELLOW}📝 Next steps:${NC}"
echo "   1. Test each platform build"
echo "   2. Update release notes"
echo "   3. Upload to respective app stores/repositories"
echo "   4. Create GitHub release with binaries"