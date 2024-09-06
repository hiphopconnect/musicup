#!/bin/bash

# Farben für die Ausgabe
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Aktivieren des Linux-Supports für Flutter...${NC}"
flutter config --enable-linux-desktop

echo -e "${GREEN}Erstellen des Linux Builds...${NC}"
flutter build linux

# Verzeichnisstruktur für das .deb-Paket erstellen
echo -e "${GREEN}Erstellen der Verzeichnisstruktur für das Debian-Paket...${NC}"
PACKAGE_NAME="music-up"
VERSION="1.0"
ARCH="amd64"
MAINTAINER="Dein Name <deinemail@example.com>"
DESCRIPTION="MusicUp - Ein Musik-Management-Tool für Linux"

# Paketverzeichnisse erstellen
mkdir -p package/DEBIAN
mkdir -p package/usr/local/bin/$PACKAGE_NAME

# Erstellen der control-Datei
echo -e "${GREEN}Erstellen der control-Datei...${NC}"
cat <<EOF > package/DEBIAN/control
Package: $PACKAGE_NAME
Version: $VERSION
Section: base
Priority: optional
Architecture: $ARCH
Maintainer: $MAINTAINER
Description: $DESCRIPTION
EOF

# Kopieren des Flutter Builds in das Paketverzeichnis
echo -e "${GREEN}Kopieren des Builds in das Paketverzeichnis...${NC}"
cp -r build/linux/x64/release/bundle/* package/usr/local/bin/$PACKAGE_NAME/

# .deb-Paket erstellen
echo -e "${GREEN}Erstellen des .deb-Pakets: ${PACKAGE_NAME}_${VERSION}_${ARCH}.deb${NC}"
dpkg-deb --build package "${PACKAGE_NAME}_${VERSION}_${ARCH}.deb"

# Prüfen, ob das Paket erfolgreich erstellt wurde
if [ -f "${PACKAGE_NAME}_${VERSION}_${ARCH}.deb" ]; then
    echo -e "${GREEN}.deb-Paket erfolgreich erstellt: ${PACKAGE_NAME}_${VERSION}_${ARCH}.deb${NC}"
else
    echo -e "${RED}Fehler beim Erstellen des .deb-Pakets${NC}"
    exit 1
fi

# Installation des Pakets
read -p "Möchten Sie das .deb-Paket jetzt installieren? (y/n): " install_choice

if [ "$install_choice" == "y" ]; then
    echo -e "${GREEN}Installieren des .deb-Pakets...${NC}"
    sudo dpkg -i "${PACKAGE_NAME}_${VERSION}_${ARCH}.deb"

    echo -e "${GREEN}Beheben von Abhängigkeitsproblemen (falls erforderlich)...${NC}"
    sudo apt --fix-broken install
fi

# Erstellen des .desktop-Eintrags für das Startmenü
echo -e "${GREEN}Erstellen des Startmenüeintrags...${NC}"
DESKTOP_FILE_PATH="$HOME/.local/share/applications/${PACKAGE_NAME}.desktop"

cp assets/icons/music_up_icon.png ~/.local/share/icons/music_up_icon.png

cat <<EOF > $DESKTOP_FILE_PATH
[Desktop Entry]
Version=1.0
Name=MusicUp
Comment=Music Management Application
Exec=/usr/local/bin/$PACKAGE_NAME/music_up
Icon=/home/hiphopconnect/.local/share/icons/music_up_icon.png
Terminal=false
Type=Application
Categories=Audio;Music;
EOF


# Sicherstellen, dass die .desktop-Datei ausführbar ist
chmod +x $DESKTOP_FILE_PATH

echo -e "${GREEN}Startmenüeintrag erstellt: $DESKTOP_FILE_PATH${NC}"
echo -e "${GREEN}Sie können MusicUp jetzt über das Startmenü starten.${NC}"

