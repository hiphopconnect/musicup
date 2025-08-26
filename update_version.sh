#!/bin/bash

# Color definitions for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}    MusicUp Version Update Script${NC}"
echo -e "${BLUE}===========================================${NC}"

# Get current version from pubspec.yaml
CURRENT_VERSION=$(grep "version:" pubspec.yaml | sed 's/version: //' | sed 's/+.*//')
CURRENT_BUILD=$(grep "version:" pubspec.yaml | sed 's/.*+//')

echo -e "${YELLOW}Current version: ${CURRENT_VERSION}+${CURRENT_BUILD}${NC}"
echo

# Ask for new version
read -p "Enter new version (format x.y.z): " NEW_VERSION

# Validate version format
if [[ ! $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "${RED}Error: Invalid version format. Use x.y.z (e.g., 2.1.2)${NC}"
    exit 1
fi

# Ask for build number (optional)
read -p "Enter build number [default: keep current ${CURRENT_BUILD}]: " NEW_BUILD
NEW_BUILD=${NEW_BUILD:-$CURRENT_BUILD}

# Validate build number
if [[ ! $NEW_BUILD =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Error: Build number must be numeric${NC}"
    exit 1
fi

echo
echo -e "${YELLOW}Will update to version: ${NEW_VERSION}+${NEW_BUILD}${NC}"
echo

# Ask for confirmation
read -p "Continue? (y/N): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Aborted.${NC}"
    exit 0
fi

echo
echo -e "${GREEN}Updating version in all files...${NC}"

# 1. Update pubspec.yaml
echo -e "  ${BLUE}→${NC} Updating pubspec.yaml"
sed -i "s/version: .*/version: ${NEW_VERSION}+${NEW_BUILD}/" pubspec.yaml

# 2. Update README.md
echo -e "  ${BLUE}→${NC} Updating README.md"
sed -i "s/Version-v[0-9]\+\.[0-9]\+\.[0-9]\+/Version-v${NEW_VERSION}/" README.md

# 3. Update Android version
echo -e "  ${BLUE}→${NC} Updating Android build.gradle"
# Increment versionCode by 1
CURRENT_VERSION_CODE=$(grep "versionCode = " android/app/build.gradle | sed 's/.*versionCode = //' | sed 's/[^0-9]*//g')
NEW_VERSION_CODE=$((CURRENT_VERSION_CODE + 1))

sed -i "s/versionCode = .*/versionCode = ${NEW_VERSION_CODE}/" android/app/build.gradle
sed -i "s/versionName = .*/versionName = \"${NEW_VERSION}\"/" android/app/build.gradle

# 4. iOS and macOS already use $(FLUTTER_BUILD_NAME) and $(FLUTTER_BUILD_NUMBER) so they're automatically updated

echo
echo -e "${GREEN}✅ Version update completed!${NC}"
echo
echo -e "${YELLOW}Summary of changes:${NC}"
echo -e "  • pubspec.yaml: ${NEW_VERSION}+${NEW_BUILD}"
echo -e "  • README.md: v${NEW_VERSION}"
echo -e "  • Android: versionCode ${NEW_VERSION_CODE}, versionName ${NEW_VERSION}"
echo -e "  • iOS/macOS: Automatically use Flutter version variables"
echo
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Test the application: ${YELLOW}flutter run${NC}"
echo -e "  2. Commit changes: ${YELLOW}git add . && git commit -m \"Bump version to ${NEW_VERSION}\"${NC}"
echo -e "  3. Create builds with: ${YELLOW}./create_apk.sh${NC} or ${YELLOW}./create_deb.sh${NC}"
echo
echo -e "${GREEN}Version update completed successfully!${NC}"