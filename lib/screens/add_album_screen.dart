// lib/screens/add_album_screen.dart

import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/folder_import_service.dart';
import 'package:music_up/services/logger_service.dart';
import 'package:music_up/services/validation_service.dart';
import 'package:music_up/services/auto_save_service.dart';
import 'package:music_up/services/toast_service.dart';
import 'package:music_up/services/accessibility_service.dart';
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
  final AutoSaveService _autoSaveService = AutoSaveService();

  String? _selectedYear;
  String? _selectedMedium;
  bool? _isDigital;
  List<Track> _tracks = [];
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeWithEmptyTrack();
    _setupAutoSave();
    _loadDraftIfExists();
  }

  @override
  void dispose() {
    _autoSaveService.dispose();
    _nameController.dispose();
    _artistController.dispose();
    _genreController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeWithEmptyTrack() {
    _tracks = [Track(trackNumber: '01', title: '')];
  }

  void _setupAutoSave() {
    // Auto-save bei Text-Änderungen
    _nameController.addListener(_triggerAutoSave);
    _artistController.addListener(_triggerAutoSave);
    _genreController.addListener(_triggerAutoSave);
  }

  void _triggerAutoSave() {
    setState(() {
      _hasUnsavedChanges = true;
    });

    final formData = {
      'name': _nameController.text,
      'artist': _artistController.text,
      'genre': _genreController.text,
      'year': _selectedYear,
      'medium': _selectedMedium,
      'digital': _isDigital,
      'tracks': _tracks.map((t) => {'trackNumber': t.trackNumber, 'title': t.title}).toList(),
    };

    _autoSaveService.saveFormData('add_album', formData);
  }

  Future<void> _loadDraftIfExists() async {
    final hasDraft = await _autoSaveService.hasDraftData('add_album');
    if (hasDraft && mounted) {
      final shouldLoad = await _showLoadDraftDialog();
      if (shouldLoad == true) {
        await _loadDraft();
      }
    }
  }

  Future<bool?> _showLoadDraftDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Entwurf gefunden'),
        content: const Text('Es wurde ein gespeicherter Entwurf gefunden. Möchten Sie ihn laden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Nein'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ja, laden'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadDraft() async {
    final formData = await _autoSaveService.loadFormData('add_album');
    if (formData != null && mounted) {
      setState(() {
        _nameController.text = formData['name'] ?? '';
        _artistController.text = formData['artist'] ?? '';
        _genreController.text = formData['genre'] ?? '';
        _selectedYear = formData['year'];
        _selectedMedium = formData['medium'];
        _isDigital = formData['digital'];
        
        final tracksData = formData['tracks'] as List<dynamic>? ?? [];
        _tracks = tracksData.map((t) => Track(
          trackNumber: t['trackNumber'] ?? '',
          title: t['title'] ?? '',
        )).toList();
        
        if (_tracks.isEmpty) {
          _initializeWithEmptyTrack();
        }
        
        _hasUnsavedChanges = true;
      });
      
      ToastService.showInfo(context, 'Entwurf geladen');
    }
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
    // Album-Name und Künstler sind PFLICHT, Rest optional
    final validationErrors = <String>[];
    
    final nameError = ValidationService.validateAlbumName(_nameController.text);
    if (nameError != null) validationErrors.add(nameError);
    
    final artistError = ValidationService.validateArtistName(_artistController.text);
    if (artistError != null) validationErrors.add(artistError);
    
    final genreError = ValidationService.validateGenre(_genreController.text);
    if (genreError != null) validationErrors.add(genreError);
    
    final yearError = ValidationService.validateYear(_selectedYear);
    if (yearError != null) validationErrors.add(yearError);
    
    final mediumError = ValidationService.validateMedium(_selectedMedium);
    if (mediumError != null) validationErrors.add(mediumError);
    
    if (validationErrors.isNotEmpty) {
      ToastService.showError(context, validationErrors.first);
      AccessibilityAnnouncer.validationError(context, validationErrors.first);
      return;
    }

    var uuid = const Uuid();
    Album newAlbum = prefilledAlbum ??
        Album(
          id: uuid.v4(),
          name: _nameController.text.trim(), // Pflicht-Felder wie eingegeben
          artist: _artistController.text.trim(), // Pflicht-Felder wie eingegeben
          genre: ValidationService.getGenreOrDefault(_genreController.text),
          year: ValidationService.getYearOrDefault(_selectedYear),
          medium: ValidationService.getMediumOrDefault(_selectedMedium),
          digital: ValidationService.getDigitalOrDefault(_isDigital),
          tracks: _tracks,
        );
    
    // Draft löschen nach erfolgreichem Speichern
    _autoSaveService.clearFormData('add_album');
    setState(() {
      _hasUnsavedChanges = false;
    });
    
    LoggerService.info('Album created', '${newAlbum.name} by ${newAlbum.artist}');
    ToastService.showSuccess(context, 'Album "${newAlbum.name}" erfolgreich hinzugefügt');
    AccessibilityAnnouncer.albumAdded(context, newAlbum.name, newAlbum.artist);
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