// lib/screens/add_album_screen.dart

import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/folder_import_service.dart';
import 'package:music_up/services/logger_service.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/album_form_widget.dart';
import 'package:music_up/widgets/app_layout.dart';
import 'package:music_up/widgets/track_management_widget.dart';
import 'package:uuid/uuid.dart';

class AddAlbumScreen extends StatefulWidget {
  const AddAlbumScreen({super.key});

  @override
  AddAlbumScreenState createState() => AddAlbumScreenState();
}

class AddAlbumScreenState extends State<AddAlbumScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FolderImportService _folderImportService = FolderImportService();

  String? _selectedYear;
  String? _selectedMedium;
  bool? _isDigital;
  List<Track> _tracks = [];

  @override
  void initState() {
    super.initState();
    _initializeWithEmptyTrack();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _artistController.dispose();
    _genreController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeWithEmptyTrack() {
    _tracks = [Track(trackNumber: '01', title: '')];
  }

  Future<bool> _onWillPop() async {
    bool? shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Änderungen speichern?'),
        content: const Text(
            'Möchten Sie das neue Album vor dem Verlassen der Seite speichern?'),
        actions: [
          TextButton(
            child: const Text('Abbrechen'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Nicht speichern'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          TextButton(
            child: const Text('Speichern & Verlassen'),
            onPressed: () {
              Navigator.of(context).pop(false); // Don't pop automatically
              _saveAlbum(); // This will save and pop
            },
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  Future<void> _addAlbumFromFolder() async {
    try {
      String? folderPath = await _folderImportService.selectFolder();
      if (folderPath == null) return;

      Album? newAlbum = await _folderImportService.createAlbumFromFolder(folderPath);
      if (newAlbum != null) {
        if (!mounted) return;
        setState(() {
          _nameController.text = newAlbum.name;
          _tracks = newAlbum.tracks;
          _selectedYear = newAlbum.year;
          _selectedMedium = newAlbum.medium;
          _isDigital = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newAlbum.tracks.length} Tracks aus "${newAlbum.name}" importiert'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      LoggerService.error('Folder import', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Importieren: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveAlbum([Album? prefilledAlbum]) {
    if (!AlbumFormValidator.isFormValid(
      albumName: _nameController.text,
      artist: _artistController.text,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bitte Album-Name und Künstler eingeben")),
      );
      return;
    }

    if (_selectedMedium == null || _isDigital == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bitte Medium und Digital-Status auswählen")),
      );
      return;
    }

    var uuid = const Uuid();
    Album newAlbum = prefilledAlbum ??
        Album(
          id: uuid.v4(),
          name: _nameController.text.trim(),
          artist: _artistController.text.trim(),
          genre: _genreController.text.trim().isEmpty 
              ? 'Unbekannt' 
              : _genreController.text.trim(),
          year: _selectedYear ?? 'Unbekannt',
          medium: _selectedMedium!,
          digital: _isDigital!,
          tracks: _tracks,
        );
    
    LoggerService.info('Album created', '${newAlbum.name} by ${newAlbum.artist}');
    Navigator.pop(context, newAlbum);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: AppLayout(
        title: 'Neues Album hinzufügen',
        appBarColor: const Color(0xFF2E4F2E), // Dark green
        actions: [
          IconButton(
            onPressed: _addAlbumFromFolder,
            icon: const Icon(Icons.folder_open),
            tooltip: 'Aus Ordner importieren',
          ),
          IconButton(
            onPressed: () => _saveAlbum(),
            icon: const Icon(Icons.save),
            tooltip: 'Album speichern',
          ),
        ],
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(DS.md),
          child: Column(
            children: [
              // Album Form
              AlbumFormWidget(
                nameController: _nameController,
                artistController: _artistController,
                genreController: _genreController,
                selectedYear: _selectedYear,
                selectedMedium: _selectedMedium,
                isDigital: _isDigital,
                onYearChanged: (value) => setState(() => _selectedYear = value),
                onMediumChanged: (value) => setState(() => _selectedMedium = value),
                onDigitalChanged: (value) => setState(() => _isDigital = value),
              ),

              const SizedBox(height: DS.lg),

              // Track Management
              TrackManagementWidget(
                tracks: _tracks,
                scrollController: _scrollController,
                onTracksChanged: (tracks) => setState(() => _tracks = tracks),
              ),

              const SizedBox(height: DS.xl),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _saveAlbum(),
                  icon: const Icon(Icons.save),
                  label: const Text('Album speichern'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E4F2E), // Dark green
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(DS.md),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}