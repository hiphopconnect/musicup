# MusicUp - ToDo

## Vorlagen Ordner mit Tools erstellen Versions Update, Manual, help

## Bilder nachladen irgendwo her? bzw. hinzufügen? Auf jeden Fall als Funktion die man hin und zufügt.

## Online Service / Premium Funktion, um Wantlist und Albums zu syncronisieren.

## Liste schreiben von dingen die eine Software sein sollte.

# DRY, KISS, Best practice, ist es sicher? kann man falsche sachen eingeben?

## CI/CD Pipeline

### ci.yml (bei jedem Push/PR)

- Flutter setup (stable channel)
- flutter pub get
- dart run build_runner build --delete-conflicting-outputs
- flutter analyze
- flutter test

### release.yml (bei Tag v*)

- Build Linux: flutter build linux --release + dpkg-deb fuer .deb
- Build Android: flutter build apk --release (erstmal debug signing)
- GitHub Release erstellen mit .deb + .apk als Assets
- Android Keystore-Signing spaeter als GitHub Secret ergaenzen     