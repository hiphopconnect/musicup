#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    MusicUp Windows EXE Builder v2.0   ${NC}"
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

# Check if we're on Windows (required for Windows builds)
if [[ "$OSTYPE" != "msys" && "$OSTYPE" != "cygwin" && "$OSTYPE" != "win32" ]]; then
    echo -e "${RED}❌ Error: Windows builds can only be created on Windows systems!${NC}"
    echo -e "${YELLOW}You are currently on: $OSTYPE (Linux)${NC}"
    echo ""
    echo -e "${BLUE}🛠️  Alternative Solutions:${NC}"
    echo ""
    echo -e "${GREEN}1. 🖥️  Use a Windows Computer/VM:${NC}"
    echo "   • Install Flutter on Windows"
    echo "   • Copy your project to Windows"
    echo "   • Run: flutter build windows --release"
    echo ""
    echo -e "${GREEN}2. ☁️  Use GitHub Actions (Recommended):${NC}"
    echo "   • Create .github/workflows/build-windows.yml"
    echo "   • Automated builds on Windows runners"
    echo "   • Free for public repositories"
    echo ""
    echo -e "${GREEN}3. 🌐 Use Cloud Services:${NC}"
    echo "   • GitHub Codespaces with Windows"
    echo "   • Azure DevOps Windows agents"
    echo "   • AWS/Google Cloud Windows VMs"
    echo ""
    echo -e "${GREEN}4. 🐳 Docker with Windows Containers:${NC}"
    echo "   • Windows-based Docker containers"
    echo "   • More complex setup"
    echo ""
    echo -e "${YELLOW}💡 Quick GitHub Actions Setup:${NC}"
    echo "Would you like me to create a GitHub Actions workflow for you?"
    echo "This would automatically build Windows EXE on every commit."
    echo ""
    read -p "Create GitHub Actions workflow? (y/n): " CREATE_WORKFLOW
    
    if [[ $CREATE_WORKFLOW == "y" || $CREATE_WORKFLOW == "Y" ]]; then
        echo -e "${GREEN}Creating GitHub Actions workflow...${NC}"
        mkdir -p .github/workflows
        
        cat > .github/workflows/build-windows.yml << 'EOF'
name: Build Windows EXE

on:
  push:
    branches: [ main, feat/* ]
  pull_request:
    branches: [ main ]

jobs:
  build-windows:
    runs-on: windows-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
      
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.32.7'
        channel: 'stable'
        
    - name: Enable Windows desktop
      run: flutter config --enable-windows-desktop
      
    - name: Install dependencies
      run: flutter pub get
      
    - name: Build Windows EXE
      run: flutter build windows --release
      
    - name: Create release archive
      run: |
        $version = (Select-String -Path pubspec.yaml -Pattern "version: (.+)" | ForEach-Object { $_.Matches.Groups[1].Value })
        Compress-Archive -Path "build\windows\x64\runner\Release\*" -DestinationPath "MusicUp-$version-windows.zip"
        
    - name: Upload Windows build
      uses: actions/upload-artifact@v3
      with:
        name: windows-build
        path: MusicUp-*.zip
EOF
        
        echo -e "${GREEN}✅ GitHub Actions workflow created at .github/workflows/build-windows.yml${NC}"
        echo -e "${BLUE}Next steps:${NC}"
        echo "1. Commit and push this workflow to GitHub"
        echo "2. GitHub will automatically build Windows EXE"
        echo "3. Download from Actions tab in your repository"
        echo ""
        echo -e "${YELLOW}Commands to commit:${NC}"
        echo "git add .github/workflows/build-windows.yml"
        echo "git commit -m 'Add Windows build workflow'"
        echo "git push"
    fi
    
    echo ""
    echo -e "${BLUE}For now, you can build:${NC}"
    echo "✅ Linux (your current system): flutter build linux --release"
    echo "✅ Android: ./create_apk.sh"
    echo "⏳ Windows: Use GitHub Actions or Windows computer"
    echo "⏳ macOS: Use Mac computer"
    echo "⏳ iOS: Use Mac computer + Apple Developer Account"
    
    exit 1
fi

# Check if Windows is enabled (only runs if on Windows)
echo -e "${GREEN}Enabling Windows desktop support...${NC}"
flutter config --enable-windows-desktop

# Clean previous builds
echo -e "${GREEN}Cleaning previous builds...${NC}"
flutter clean

# Get dependencies
echo -e "${GREEN}Getting dependencies...${NC}"
flutter pub get

# Check Flutter doctor for Windows
echo -e "${GREEN}Checking Windows build requirements...${NC}"
flutter doctor --verbose | grep -i windows || echo -e "${YELLOW}Windows toolchain check completed${NC}"

# Build Windows release
echo -e "${GREEN}Building Windows Release EXE...${NC}"
echo -e "${BLUE}This may take several minutes...${NC}"

flutter build windows --release

# Check if build was successful
if [ $? -ne 0 ]; then
    echo -e "${RED}Windows build failed. Please check the error messages above.${NC}"
    echo -e "${YELLOW}Common issues:${NC}"
    echo -e "${YELLOW}- Visual Studio Build Tools not installed${NC}"
    echo -e "${YELLOW}- Windows SDK missing${NC}"
    echo -e "${YELLOW}- CMake not found${NC}"
    exit 1
fi

# Check if EXE exists
EXE_PATH="build/windows/x64/runner/Release/music_up.exe"
if [ ! -f "$EXE_PATH" ]; then
    echo -e "${RED}EXE file not found at: $EXE_PATH${NC}"
    echo -e "${YELLOW}Checking alternative locations...${NC}"
    find build/windows -name "*.exe" -type f 2>/dev/null || echo -e "${RED}No EXE files found in build directory${NC}"
    exit 1
fi

# Get file info
FILE_SIZE=$(du -h "$EXE_PATH" | cut -f1)
echo -e "${GREEN}Build successful!${NC}"
echo -e "${BLUE}EXE Path: $EXE_PATH${NC}"
echo -e "${BLUE}File Size: $FILE_SIZE${NC}"

# Create organized output directory
OUTPUT_DIR="releases/windows"
mkdir -p "$OUTPUT_DIR"

# Copy EXE and dependencies to releases directory
OUTPUT_FILE="$OUTPUT_DIR/MusicUp-v$VERSION-build$BUILD_NUMBER-windows.exe"
cp "$EXE_PATH" "$OUTPUT_FILE"

# Copy required DLLs and data
echo -e "${GREEN}Copying Windows dependencies...${NC}"
BUNDLE_DIR="$OUTPUT_DIR/MusicUp-v$VERSION-build$BUILD_NUMBER-windows-bundle"
mkdir -p "$BUNDLE_DIR"

# Copy the entire Release folder for complete bundle
cp -r "build/windows/x64/runner/Release/"* "$BUNDLE_DIR/"

# Create a standalone launcher script
cat > "$BUNDLE_DIR/run_musicup.bat" << 'EOF'
@echo off
cd /d "%~dp0"
start music_up.exe
EOF

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Windows EXE build completed successfully!${NC}"
echo -e "${BLUE}Version: v$VERSION (Build $BUILD_NUMBER)${NC}"
echo -e "${BLUE}Standalone EXE: $OUTPUT_FILE${NC}"
echo -e "${BLUE}Complete Bundle: $BUNDLE_DIR/${NC}"
echo -e "${BLUE}File Size: $FILE_SIZE${NC}"
echo -e "${BLUE}========================================${NC}"

echo -e "${YELLOW}📋 Distribution Options:${NC}"
echo "1. Standalone EXE: Copy just the EXE file (may need Visual C++ Redistributable)"
echo "2. Complete Bundle: Copy the entire bundle folder (includes all dependencies)"
echo "3. Windows Installer: Use tools like NSIS or Inno Setup to create an installer"

echo -e "${GREEN}🎉 MusicUp Windows build process completed!${NC}"