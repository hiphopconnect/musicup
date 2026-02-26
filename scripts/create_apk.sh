#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project information
APP_NAME="MusicUp"
PACKAGE_NAME="com.musicup.app"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    MusicUp Android APK Builder v2.0   ${NC}"
echo -e "${BLUE}========================================${NC}"

# Function to get version from pubspec.yaml
get_version() {
    VERSION_LINE=$(grep '^version:' pubspec.yaml)
    if [ -z "$VERSION_LINE" ]; then
        echo -e "${RED}Error: 'version:' line not found in pubspec.yaml.${NC}"
        exit 1
    fi
    VERSION=$(echo $VERSION_LINE | awk '{print $2}' | cut -d '+' -f1)
    BUILD_NUMBER=$(echo $VERSION_LINE | awk '{print $2}' | cut -d '+' -f2)
    echo "VERSION: $VERSION, BUILD: $BUILD_NUMBER"
}

# Display current version
echo -e "${GREEN}Checking current version...${NC}"
get_version

# Check if Android is enabled
echo -e "${GREEN}Ensuring Android support is enabled...${NC}"
flutter config --enable-android

# Clean previous builds
echo -e "${GREEN}Cleaning previous builds...${NC}"
flutter clean

# Get dependencies
echo -e "${GREEN}Getting dependencies...${NC}"
flutter pub get

# Check Android setup
echo -e "${GREEN}Checking Android setup...${NC}"
flutter doctor --android-licenses 2>/dev/null || echo -e "${RED}Note: Android licenses might need to be accepted${NC}"

# Build options menu
echo -e "${BLUE}Select build type:${NC}"
echo "1) Debug APK (faster build, larger size)"
echo "2) Release APK (optimized, smaller size) - RECOMMENDED"
echo "3) App Bundle (for Play Store)"
read -p "Enter your choice (1-3): " BUILD_CHOICE

case $BUILD_CHOICE in
    1)
        echo -e "${GREEN}Building Debug APK...${NC}"
        flutter build apk --debug
        APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"
        APK_TYPE="debug"
        ;;
    2)
        echo -e "${GREEN}Building Release APK (optimized)...${NC}"
        flutter build apk --release
        APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
        APK_TYPE="release"
        ;;
    3)
        echo -e "${GREEN}Building App Bundle for Play Store...${NC}"
        flutter build appbundle --release
        APK_PATH="build/app/outputs/bundle/release/app-release.aab"
        APK_TYPE="appbundle"
        ;;
    *)
        echo -e "${RED}Invalid choice. Building Release APK by default...${NC}"
        flutter build apk --release
        APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
        APK_TYPE="release"
        ;;
esac

# Check if build was successful
if [ $? -ne 0 ]; then
    echo -e "${RED}Android build failed. Exiting...${NC}"
    exit 1
fi

# Verify APK/AAB exists
if [ ! -f "$APK_PATH" ]; then
    echo -e "${RED}Build file not found at: $APK_PATH${NC}"
    exit 1
fi

# Get file info
FILE_SIZE=$(du -h "$APK_PATH" | cut -f1)
echo -e "${GREEN}Build successful!${NC}"
echo -e "${BLUE}File: $APK_PATH${NC}"
echo -e "${BLUE}Size: $FILE_SIZE${NC}"
echo -e "${BLUE}Type: $APK_TYPE${NC}"

# Create organized output directory
OUTPUT_DIR="releases/android"
mkdir -p "$OUTPUT_DIR"

# Copy APK/AAB to releases directory with version name
if [ "$APK_TYPE" = "appbundle" ]; then
    OUTPUT_FILE="$OUTPUT_DIR/MusicUp-v$VERSION-build$BUILD_NUMBER.aab"
    cp "$APK_PATH" "$OUTPUT_FILE"
    echo -e "${GREEN}App Bundle copied to: $OUTPUT_FILE${NC}"
else
    OUTPUT_FILE="$OUTPUT_DIR/MusicUp-v$VERSION-build$BUILD_NUMBER-$APK_TYPE.apk"
    cp "$APK_PATH" "$OUTPUT_FILE"
    echo -e "${GREEN}APK copied to: $OUTPUT_FILE${NC}"
fi

# Show file info
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Android build completed successfully!${NC}"
echo -e "${BLUE}Version: v$VERSION (Build $BUILD_NUMBER)${NC}"
echo -e "${BLUE}Output: $OUTPUT_FILE${NC}"
echo -e "${BLUE}Size: $FILE_SIZE${NC}"
echo -e "${BLUE}========================================${NC}"

# Installation options (only for APK)
if [ "$APK_TYPE" != "appbundle" ]; then
    echo ""
    echo -e "${BLUE}Installation Options:${NC}"
    echo "1) Install via ADB (device connected)"
    echo "2) Copy to device manually"
    echo "3) Send via email/cloud"
    echo "0) Skip installation"
    read -p "Enter your choice (0-3): " INSTALL_CHOICE

    case $INSTALL_CHOICE in
        1)
            echo -e "${GREEN}Installing via ADB...${NC}"
            adb devices
            if adb get-state 1>/dev/null 2>&1; then
                adb install "$OUTPUT_FILE"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ APK installed successfully!${NC}"
                else
                    echo -e "${RED}❌ Installation failed. Try installing manually.${NC}"
                fi
            else
                echo -e "${RED}No ADB devices found. Connect your device and enable USB debugging.${NC}"
            fi
            ;;
        2)
            echo -e "${BLUE}Manual installation:${NC}"
            echo "1. Copy this file to your Android device: $OUTPUT_FILE"
            echo "2. Enable 'Install from unknown sources' in Android settings"
            echo "3. Open the APK file on your device to install"
            ;;
        3)
            echo -e "${BLUE}Cloud/Email sharing:${NC}"
            echo "You can find your APK here: $OUTPUT_FILE"
            echo "Share this file via Google Drive, Dropbox, email, etc."
            ;;
        *)
            echo -e "${BLUE}Build completed. APK ready for distribution.${NC}"
            ;;
    esac
fi

echo -e "${GREEN}🎉 MusicUp Android build process completed!${NC}"