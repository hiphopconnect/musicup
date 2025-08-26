#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    MusicUp iOS App Builder v2.0       ${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ Error: iOS builds can only be created on macOS systems!${NC}"
    echo -e "${YELLOW}You are currently on: $OSTYPE${NC}"
    echo -e "${YELLOW}To build for iOS, you need:${NC}"
    echo "   - macOS computer (Mac, MacBook, iMac, Mac Studio)"
    echo "   - Xcode installed from Mac App Store"
    echo "   - Apple Developer Account (\$99/year)"
    echo "   - iOS device or Simulator for testing"
    echo ""
    echo -e "${BLUE}Alternative options:${NC}"
    echo "   - Use GitHub Actions with macOS runners"
    echo "   - Use cloud-based macOS services (MacInCloud, etc.)"
    echo "   - Access a Mac remotely"
    exit 1
fi

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

# Check if iOS is enabled
echo -e "${GREEN}Enabling iOS support...${NC}"
flutter config --enable-ios

# Clean previous builds
echo -e "${GREEN}Cleaning previous builds...${NC}"
flutter clean

# Get dependencies
echo -e "${GREEN}Getting dependencies...${NC}"
flutter pub get

# Check Xcode and iOS toolchain
echo -e "${GREEN}Checking iOS build requirements...${NC}"
xcode-select --print-path > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Xcode command line tools not found!${NC}"
    echo -e "${YELLOW}Please install Xcode from the Mac App Store or run:${NC}"
    echo "   xcode-select --install"
    exit 1
fi

# Check for CocoaPods
which pod > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️  CocoaPods not found. Installing...${NC}"
    sudo gem install cocoapods
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to install CocoaPods. Please install manually:${NC}"
        echo "   sudo gem install cocoapods"
        exit 1
    fi
fi

# Install iOS dependencies
echo -e "${GREEN}Installing iOS dependencies (CocoaPods)...${NC}"
cd ios
pod install
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}CocoaPods install had issues. Trying to resolve...${NC}"
    pod repo update
    pod install
fi
cd ..

# Flutter doctor check
flutter doctor --verbose | grep -A 10 "iOS toolchain"

# Build options menu
echo -e "${BLUE}Select iOS build type:${NC}"
echo "1) Debug (for testing on device/simulator)"
echo "2) Release (optimized for App Store/TestFlight)"
echo "3) Release with code signing (requires Apple Developer Account)"
read -p "Enter your choice (1-3): " BUILD_CHOICE

case $BUILD_CHOICE in
    1)
        echo -e "${GREEN}Building iOS Debug...${NC}"
        flutter build ios --debug
        BUILD_TYPE="debug"
        ;;
    2)
        echo -e "${GREEN}Building iOS Release (no code signing)...${NC}"
        flutter build ios --release --no-codesign
        BUILD_TYPE="release-no-codesign"
        ;;
    3)
        echo -e "${GREEN}Building iOS Release with code signing...${NC}"
        echo -e "${YELLOW}⚠️  This requires a valid Apple Developer Account and certificates!${NC}"
        flutter build ios --release
        BUILD_TYPE="release-signed"
        ;;
    *)
        echo -e "${YELLOW}Invalid choice. Building Debug by default...${NC}"
        flutter build ios --debug
        BUILD_TYPE="debug"
        ;;
esac

# Check if build was successful
if [ $? -ne 0 ]; then
    echo -e "${RED}iOS build failed. Please check the error messages above.${NC}"
    echo -e "${YELLOW}Common issues:${NC}"
    echo -e "${YELLOW}- Xcode not properly installed${NC}"
    echo -e "${YELLOW}- iOS SDK missing${NC}"
    echo -e "${YELLOW}- Code signing certificate issues${NC}"
    echo -e "${YELLOW}- Apple Developer Account not configured${NC}"
    echo -e "${YELLOW}- Provisioning profile problems${NC}"
    exit 1
fi

# Find built app
if [ "$BUILD_TYPE" = "debug" ]; then
    APP_PATH="build/ios/Debug-iphonesimulator/Runner.app"
    ARCHIVE_PATH=""
else
    APP_PATH="build/ios/Release-iphoneos/Runner.app"
    ARCHIVE_PATH="build/ios/archive/Runner.xcarchive"
fi

# Create organized output directory
OUTPUT_DIR="releases/ios"
mkdir -p "$OUTPUT_DIR"

if [ -d "$APP_PATH" ]; then
    APP_SIZE=$(du -sh "$APP_PATH" | cut -f1)
    OUTPUT_APP="$OUTPUT_DIR/MusicUp-v$VERSION-build$BUILD_NUMBER-$BUILD_TYPE.app"
    cp -r "$APP_PATH" "$OUTPUT_APP"
    echo -e "${GREEN}App copied to: $OUTPUT_APP${NC}"
fi

# Handle archive for App Store distribution
if [ -d "$ARCHIVE_PATH" ] && [ "$BUILD_TYPE" = "release-signed" ]; then
    OUTPUT_ARCHIVE="$OUTPUT_DIR/MusicUp-v$VERSION-build$BUILD_NUMBER.xcarchive"
    cp -r "$ARCHIVE_PATH" "$OUTPUT_ARCHIVE"
    echo -e "${GREEN}Archive copied to: $OUTPUT_ARCHIVE${NC}"
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ iOS build completed successfully!${NC}"
echo -e "${BLUE}Version: v$VERSION (Build $BUILD_NUMBER)${NC}"
echo -e "${BLUE}Build Type: $BUILD_TYPE${NC}"
if [ -d "$OUTPUT_APP" ]; then
    echo -e "${BLUE}App Bundle: $OUTPUT_APP${NC}"
    echo -e "${BLUE}App Size: $APP_SIZE${NC}"
fi
echo -e "${BLUE}========================================${NC}"

echo -e "${YELLOW}📱 Next Steps for Distribution:${NC}"
echo ""

case $BUILD_TYPE in
    "debug")
        echo -e "${BLUE}Debug Build:${NC}"
        echo "• Install on iOS Simulator: Use Xcode"
        echo "• Install on device: Use Xcode or iOS App Installer"
        ;;
    "release-no-codesign")
        echo -e "${BLUE}Release Build (No Code Signing):${NC}"
        echo "• Cannot install on physical devices"
        echo "• Use for Simulator testing only"
        echo "• Need Apple Developer Account for device installation"
        ;;
    "release-signed")
        echo -e "${BLUE}Release Build (Code Signed):${NC}"
        echo "• Ready for App Store submission"
        echo "• Can install on registered devices"
        echo "• Use Xcode or Application Loader for App Store upload"
        echo "• Archive location: $OUTPUT_ARCHIVE"
        ;;
esac

echo ""
echo -e "${YELLOW}🍎 App Store Submission Process:${NC}"
echo "1. Open Xcode → Window → Organizer"
echo "2. Select your archive → Distribute App"
echo "3. Choose distribution method (App Store Connect, TestFlight, etc.)"
echo "4. Follow Xcode's guided process"

echo ""
echo -e "${YELLOW}💡 Requirements for App Store:${NC}"
echo "• Apple Developer Account (\$99/year)"
echo "• Valid code signing certificates"
echo "• App Store guidelines compliance"
echo "• App icons in all required sizes"
echo "• Privacy policy and app metadata"

echo -e "${GREEN}🎉 MusicUp iOS build process completed!${NC}"