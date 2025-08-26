#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    MusicUp macOS App Builder v2.0     ${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ Error: macOS builds can only be created on macOS systems!${NC}"
    echo -e "${YELLOW}You are currently on: $OSTYPE${NC}"
    echo -e "${YELLOW}To build for macOS, you need:${NC}"
    echo "   - macOS computer (Mac, MacBook, iMac, Mac Studio)"
    echo "   - Xcode installed from Mac App Store"
    echo "   - Flutter with macOS support enabled"
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

# Check if macOS is enabled
echo -e "${GREEN}Enabling macOS desktop support...${NC}"
flutter config --enable-macos-desktop

# Clean previous builds
echo -e "${GREEN}Cleaning previous builds...${NC}"
flutter clean

# Get dependencies
echo -e "${GREEN}Getting dependencies...${NC}"
flutter pub get

# Check Xcode and macOS toolchain
echo -e "${GREEN}Checking macOS build requirements...${NC}"
xcode-select --print-path > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Xcode command line tools not found!${NC}"
    echo -e "${YELLOW}Please install Xcode from the Mac App Store or run:${NC}"
    echo "   xcode-select --install"
    exit 1
fi

flutter doctor --verbose | grep -A 5 "Xcode"

# Build macOS release
echo -e "${GREEN}Building macOS Release App...${NC}"
echo -e "${BLUE}This may take several minutes...${NC}"

flutter build macos --release

# Check if build was successful
if [ $? -ne 0 ]; then
    echo -e "${RED}macOS build failed. Please check the error messages above.${NC}"
    echo -e "${YELLOW}Common issues:${NC}"
    echo -e "${YELLOW}- Xcode not properly installed${NC}"
    echo -e "${YELLOW}- macOS SDK missing${NC}"
    echo -e "${YELLOW}- Code signing issues${NC}"
    exit 1
fi

# Check if App exists
APP_PATH="build/macos/Build/Products/Release/MusicUp.app"
if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}App bundle not found at: $APP_PATH${NC}"
    echo -e "${YELLOW}Checking alternative locations...${NC}"
    find build/macos -name "*.app" -type d 2>/dev/null || echo -e "${RED}No .app bundles found in build directory${NC}"
    exit 1
fi

# Get app info
APP_SIZE=$(du -sh "$APP_PATH" | cut -f1)
echo -e "${GREEN}Build successful!${NC}"
echo -e "${BLUE}App Path: $APP_PATH${NC}"
echo -e "${BLUE}App Size: $APP_SIZE${NC}"

# Create organized output directory
OUTPUT_DIR="releases/macos"
mkdir -p "$OUTPUT_DIR"

# Copy App to releases directory
OUTPUT_APP="$OUTPUT_DIR/MusicUp-v$VERSION-build$BUILD_NUMBER.app"
cp -r "$APP_PATH" "$OUTPUT_APP"

# Create DMG (Disk Image) for easy distribution
echo -e "${GREEN}Creating DMG installer...${NC}"
DMG_NAME="MusicUp-v$VERSION-build$BUILD_NUMBER-macOS.dmg"
DMG_PATH="$OUTPUT_DIR/$DMG_NAME"

# Create temporary DMG directory
TMP_DMG_DIR="/tmp/musicup_dmg"
rm -rf "$TMP_DMG_DIR"
mkdir -p "$TMP_DMG_DIR"

# Copy app to temp directory
cp -r "$OUTPUT_APP" "$TMP_DMG_DIR/"

# Create Applications symlink for easy installation
ln -s "/Applications" "$TMP_DMG_DIR/Applications"

# Create DMG
hdiutil create -srcfolder "$TMP_DMG_DIR" -volname "MusicUp v$VERSION" -format UDZO -o "$DMG_PATH"

# Clean up temp directory
rm -rf "$TMP_DMG_DIR"

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ macOS App build completed successfully!${NC}"
echo -e "${BLUE}Version: v$VERSION (Build $BUILD_NUMBER)${NC}"
echo -e "${BLUE}App Bundle: $OUTPUT_APP${NC}"
echo -e "${BLUE}DMG Installer: $DMG_PATH${NC}"
echo -e "${BLUE}App Size: $APP_SIZE${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "${YELLOW}📋 Distribution Options:${NC}"
echo "1. App Bundle: Drag & drop installation (.app file)"
echo "2. DMG Installer: Professional installer with Applications shortcut"
echo "3. Mac App Store: Requires Apple Developer Program membership"
echo "4. Notarization: For distribution outside Mac App Store (requires Apple Developer account)"

echo -e "${YELLOW}💡 Installation Instructions:${NC}"
echo "- DMG: Double-click → Drag MusicUp to Applications folder"
echo "- App: Copy .app file directly to /Applications/"

echo -e "${GREEN}🎉 MusicUp macOS build process completed!${NC}"