#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Enabling Linux support for Flutter...${NC}"
flutter config --enable-linux-desktop

echo -e "${GREEN}Building the Linux release...${NC}"
flutter build linux

# Create directory structure for the .deb package
echo -e "${GREEN}Creating directory structure for the Debian package...${NC}"
PACKAGE_NAME="music-up"
VERSION="1.0"
ARCH="amd64"
MAINTAINER="Your Name <youremail@example.com>"
DESCRIPTION="MusicUp - A Music Management Tool for Linux"

# Create package directories
mkdir -p package/DEBIAN
mkdir -p package/usr/local/bin/$PACKAGE_NAME

# Create the control file
echo -e "${GREEN}Creating the control file...${NC}"
cat <<EOF > package/DEBIAN/control
Package: $PACKAGE_NAME
Version: $VERSION
Section: base
Priority: optional
Architecture: $ARCH
Maintainer: $MAINTAINER
Description: $DESCRIPTION
EOF

# Copy the Flutter build into the package directory
echo -e "${GREEN}Copying the build into the package directory...${NC}"
cp -r build/linux/x64/release/bundle/* package/usr/local/bin/$PACKAGE_NAME/

# Create the .deb package
echo -e "${GREEN}Creating the .deb package: ${PACKAGE_NAME}_${VERSION}_${ARCH}.deb${NC}"
dpkg-deb --build package "${PACKAGE_NAME}_${VERSION}_${ARCH}.deb"

# Check if the package was created successfully
if [ -f "${PACKAGE_NAME}_${VERSION}_${ARCH}.deb" ]; then
    echo -e "${GREEN}.deb package successfully created: ${PACKAGE_NAME}_${VERSION}_${ARCH}.deb${NC}"
else
    echo -e "${RED}Error creating the .deb package${NC}"
    exit 1
fi

# Prompt to install the package
read -p "Do you want to install the .deb package now? (y/n): " install_choice

if [ "$install_choice" == "y" ]; then
    echo -e "${GREEN}Installing the .deb package...${NC}"
    sudo dpkg -i "${PACKAGE_NAME}_${VERSION}_${ARCH}.deb"

    echo -e "${GREEN}Fixing dependency issues (if any)...${NC}"
    sudo apt --fix-broken install
fi

# Create the .desktop entry for the application menu
echo -e "${GREEN}Creating the application menu entry...${NC}"
DESKTOP_FILE_PATH="$HOME/.local/share/applications/${PACKAGE_NAME}.desktop"

cp assets/icons/music_up_icon.png ~/.local/share/icons/music_up_icon.png

cat <<EOF > $DESKTOP_FILE_PATH
[Desktop Entry]
Version=1.0
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
