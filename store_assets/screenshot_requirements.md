# Store Screenshot Requirements

## Required Screenshots (Take from running app)

### 📱 **Mobile (Android/iOS)**
**Sizes needed:**
- Phone: 1080x1920, 1080x2340, 1284x2778
- Tablet: 1536x2048, 2048x2732

**Screenshots to take:**
1. **Main Collection View** - Show album grid with your collection
2. **Album Detail View** - Open an album to show detailed information  
3. **Discogs Search** - Show search results from Discogs
4. **Add Album Form** - Show the add new album interface
5. **Wantlist View** - Show wantlist management
6. **Settings/Export** - Show export/settings options

### 💻 **Desktop (Windows/macOS/Linux)**
**Sizes needed:**
- 1280x800, 1920x1080, 2560x1440

**Screenshots to take:**
1. **Main Window** - Full desktop app with album collection
2. **Album Details** - Detailed view of an album
3. **Discogs Integration** - Search and import process
4. **Export Dialog** - Show export functionality
5. **Settings Panel** - App preferences and configuration

## 🎨 **Screenshot Guidelines**

### Content Requirements:
- ✅ Show populated data (use your 777 albums!)
- ✅ Use attractive album covers (pick the best ones)
- ✅ Show different genres/years for variety
- ✅ Demonstrate key features in action
- ❌ No empty states or placeholder data
- ❌ No personal information visible

### Visual Quality:
- 📱 High resolution (2x or 3x device pixel ratio)
- 🎨 Consistent theme (light or dark throughout)
- 🖼️ Clean, uncluttered interface
- ✨ Show the app at its best

### Store-Specific Notes:

#### **Apple App Store:**
- Need exactly 3-10 screenshots per device type
- No text overlays allowed on screenshots
- Must show actual app content

#### **Google Play:**
- 2-8 screenshots recommended
- Can add text overlays/captions
- Feature graphic (1024x500) also needed

#### **Microsoft Store:**
- 1-10 screenshots
- Recommended: 1920x1080 for best display
- Can include captions

## 📋 **Screenshot Checklist**

Before submitting:
- [ ] All screenshots are high resolution
- [ ] No debugging/development UI visible
- [ ] Consistent theme across all screenshots
- [ ] Show diverse album collection
- [ ] No empty or error states
- [ ] All text is readable
- [ ] App looks professional and polished

## 🛠️ **How to Take Screenshots**

### Mobile:
```bash
# Android (via adb)
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png

# iOS (via Simulator)
Device > Screenshot (Cmd+S)
```

### Desktop:
```bash
# Linux
gnome-screenshot --window --file=screenshot.png

# macOS  
Cmd+Shift+4 then spacebar, click window

# Windows
Snipping Tool or Print Screen
```

### Flutter DevTools:
1. Run app with `flutter run`
2. Open DevTools in browser
3. Use Inspector to take widget screenshots
4. Perfect for consistent, clean shots