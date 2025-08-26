#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Project information
PACKAGE_NAME="music-up"

# Check if more than one argument is provided
if [ $# -gt 1 ]; then
    echo -e "${RED}Usage: $0 [major|minor|patch]${NC}"
    exit 1
fi

INCREMENT=$1

# Validate the argument, if provided
if [ $# -eq 1 ]; then
    if [[ "$INCREMENT" != "major" && "$INCREMENT" != "minor" && "$INCREMENT" != "patch" ]]; then
        echo -e "${RED}Invalid argument: $INCREMENT${NC}"
        echo -e "${RED}Usage: $0 [major|minor|patch]${NC}"
        exit 1
    fi
fi

# Function to extract and increment the version number from pubspec.yaml
increment_version() {
    PUBSPEC_PATH="pubspec.yaml"

    if [ ! -f "$PUBSPEC_PATH" ]; then
        echo -e "${RED}Error: pubspec.yaml not found.${NC}"
        exit 1
    fi

    # Extract the current version line
    VERSION_LINE=$(grep '^version:' $PUBSPEC_PATH)
    if [ -z "$VERSION_LINE" ]; then
        echo -e "${RED}Error: 'version:' line not found in pubspec.yaml.${NC}"
        exit 1
    fi

    # Extract version number and build number
    CURRENT_VERSION=$(echo $VERSION_LINE | awk '{print $2}' | cut -d '+' -f1)
    CURRENT_BUILD=$(echo $VERSION_LINE | awk '{print $2}' | cut -d '+' -f2)

    # Split the version number into parts
    IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"

    MAJOR=${VERSION_PARTS[0]}
    MINOR=${VERSION_PARTS[1]}
    PATCH=${VERSION_PARTS[2]}

    # Increment based on the argument
    if [ $# -eq 1 ]; then
        case $INCREMENT in
            major)
                MAJOR=$((MAJOR + 1))
                MINOR=0
                PATCH=0
                ;;
            minor)
                MINOR=$((MINOR + 1))
                PATCH=0
                ;;
            patch)
                PATCH=$((PATCH + 1))
                ;;
        esac

        # Increment build number
        BUILD=$((CURRENT_BUILD + 1))

        # Assemble the new version
        NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}+${BUILD}"

        # Update pubspec.yaml
        sed -i "s/^version: .*/version: $NEW_VERSION/" $PUBSPEC_PATH

        echo -e "${GREEN}Version updated to: $NEW_VERSION${NC}"
    else
        # Only increment the build number if no version part is specified
        BUILD=$((CURRENT_BUILD + 1))
        NEW_VERSION="${CURRENT_VERSION}+${BUILD}"
        sed -i "s/^version: .*/version: $NEW_VERSION/" $PUBSPEC_PATH
        echo -e "${GREEN}Build number increased to: $NEW_VERSION${NC}"
    fi
}

# Increment version if an argument is provided
increment_version "$INCREMENT"

# Function to format the Debian package version
get_deb_version() {
    VERSION_LINE=$(grep '^version:' pubspec.yaml)
    if [ -z "$VERSION_LINE" ]; then
        echo -e "${RED}Error: 'version:' line not found in pubspec.yaml.${NC}"
        exit 1
    fi
    VERSION=$(echo $VERSION_LINE | awk '{print $2}' | cut -d '+' -f1)
    BUILD_NUMBER=$(echo $VERSION_LINE | awk '{print $2}' | cut -d '+' -f2)
    VERSION_DEB="${VERSION}-${BUILD_NUMBER}"
    echo "$VERSION_DEB"
}

VERSION_DEB=$(get_deb_version)
ARCH="amd64"
MAINTAINER="Michael Milke (Nobo) <nobo_code@posteo.de>"
DESCRIPTION="MusicUp - A Music Management Tool for Linux"
LICENSE="Proprietary"
REPOSITORY="https://github.com/hiphopconnect/musicup/"

echo -e "${GREEN}Detected Flutter Version for Debian Package: $VERSION_DEB${NC}"

# Enable Linux desktop support for Flutter
echo -e "${GREEN}Enabling Linux support for Flutter...${NC}"
flutter config --enable-linux-desktop

# Clean previous builds
echo -e "${GREEN}Cleaning previous builds...${NC}"
flutter clean

# Get dependencies
echo -e "${GREEN}Updating dependencies...${NC}"
flutter pub get

# Build the Linux release
echo -e "${GREEN}Building the Linux release...${NC}"
flutter build linux

# Check if the build was successful
if [ $? -ne 0 ]; then
    echo -e "${RED}Flutter build failed. Exiting...${NC}"
    exit 1
fi

# Create directory structure for the .deb package
echo -e "${GREEN}Creating directory structure for the Debian package...${NC}"

# Remove previous package directory if it exists
rm -rf package

# Create necessary directories
mkdir -p package/DEBIAN
mkdir -p package/usr/local/bin/$PACKAGE_NAME
mkdir -p package/usr/share/doc/$PACKAGE_NAME

# Create the control file
echo -e "${GREEN}Creating the control file...${NC}"
cat <<EOF > package/DEBIAN/control
Package: $PACKAGE_NAME
Version: $VERSION_DEB
Section: base
Priority: optional
Architecture: $ARCH
Maintainer: $MAINTAINER
Description: $DESCRIPTION
License: $LICENSE
Homepage: $REPOSITORY
EOF

# Copy the Flutter build into the package directory
echo -e "${GREEN}Copying the build into the package directory...${NC}"
cp -r build/linux/x64/release/bundle/* package/usr/local/bin/$PACKAGE_NAME/

# Verify that the build files were copied successfully
if [ ! -d "package/usr/local/bin/$PACKAGE_NAME" ]; then
    echo -e "${RED}Failed to copy build files. Exiting...${NC}"
    exit 1
fi

# Copy README.md into the documentation directory
echo -e "${GREEN}Copying README.md into the documentation directory...${NC}"
cp README.md package/usr/share/doc/$PACKAGE_NAME/

# Optionally compress the README.md
echo -e "${GREEN}Compressing README.md...${NC}"
gzip -k -f package/usr/share/doc/$PACKAGE_NAME/README.md

# Create the .deb package
echo -e "${GREEN}Creating the .deb package: ${PACKAGE_NAME}_${VERSION_DEB}_${ARCH}.deb${NC}"
dpkg-deb --build package "${PACKAGE_NAME}_${VERSION_DEB}_${ARCH}.deb"

# Check if the package was created successfully
if [ -f "${PACKAGE_NAME}_${VERSION_DEB}_${ARCH}.deb" ]; then
    echo -e "${GREEN}.deb package successfully created: ${PACKAGE_NAME}_${VERSION_DEB}_${ARCH}.deb${NC}"
else
    echo -e "${RED}Error creating the .deb package${NC}"
    exit 1
fi

# Prompt to install the package
read -p "Do you want to install the .deb package now? (y/n): " install_choice

if [ "$install_choice" == "y" ]; then
    echo -e "${GREEN}Installing the .deb package...${NC}"
    sudo dpkg -i "${PACKAGE_NAME}_${VERSION_DEB}_${ARCH}.deb"

    echo -e "${GREEN}Fixing dependency issues (if any)...${NC}"
    sudo apt --fix-broken install
fi

# Create the .desktop entry for the application menu
echo -e "${GREEN}Creating the application menu entry...${NC}"
DESKTOP_FILE_PATH="$HOME/.local/share/applications/${PACKAGE_NAME}.desktop"

# Ensure the icons directory exists
mkdir -p ~/.local/share/icons/

# Copy the application icon
cp assets/icons/music_up_icon.png ~/.local/share/icons/music_up_icon.png

# Create the .desktop file
cat <<EOF > $DESKTOP_FILE_PATH
[Desktop Entry]
Version=$VERSION_DEB
Name=MusicUp
Comment=Music Management Application
Exec=/usr/local/bin/$PACKAGE_NAME/music_up
Icon=$HOME/.local/share/icons/music_up_icon.png
Terminal=false
Type=Application
Categories=Audio;Music;
EOF

# Ensure the .desktop file is executable
chmod +x $DESKTOP_FILE_PATH

echo -e "${GREEN}Application menu entry created: $DESKTOP_FILE_PATH${NC}"
echo -e "${GREEN}You can now launch MusicUp from the application menu.${NC}"
