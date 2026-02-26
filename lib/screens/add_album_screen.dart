// lib/screens/add_album_screen.dart

import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/l10n/validation_translations.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/folder_import_service.dart';
import 'package:music_up/services/logger_service.dart';
import 'package:music_up/services/validation_service.dart';
import 'package:music_up/services/auto_save_service.dart';
import 'package:music_up/services/toast_service.dart';
import 'package:music_up/services/accessibility_service.dart';
import 'package:music_up/theme/app_theme.dart';
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
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.draftFound),
        content: Text(l10n.draftFoundMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.loadDraft),
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

        });

      final l10n = AppLocalizations.of(context);
      ToastService.showInfo(context, l10n.draftLoaded);
    }
  }

  Future<bool> _onWillPop() async {
    final l10n = AppLocalizations.of(context);
    bool? shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.saveChangesQuestion),
        content: Text(l10n.saveChangesBeforeLeaving),
        actions: [
          TextButton(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text(l10n.dontSave),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          TextButton(
            child: Text(l10n.saveAndLeave),
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

        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.tracksImported(newAlbum.tracks.length, newAlbum.name)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      LoggerService.error('Folder import', e);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorImporting('$e')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveAlbum([Album? prefilledAlbum]) {
    final l10n = AppLocalizations.of(context);
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

    // Leere Track-Titel pruefen
    final nonEmptyTracks = _tracks.where((t) => t.title.trim().isNotEmpty).toList();
    if (nonEmptyTracks.isEmpty) {
      validationErrors.add(l10n.trackWithTitleRequired);
    }

    if (validationErrors.isNotEmpty) {
      ToastService.showError(context, translateValidation(l10n, validationErrors.first));
      AccessibilityAnnouncer.validationError(context, validationErrors.first);
      return;
    }

    // Leere Tracks rausfiltern
    final cleanTracks = nonEmptyTracks;

    var uuid = const Uuid();
    Album newAlbum = prefilledAlbum ??
        Album(
          id: uuid.v4(),
          name: _nameController.text.trim(),
          artist: _artistController.text.trim(),
          genre: ValidationService.getGenreOrDefault(_genreController.text),
          year: ValidationService.getYearOrDefault(_selectedYear),
          medium: ValidationService.getMediumOrDefault(_selectedMedium),
          digital: ValidationService.getDigitalOrDefault(_isDigital),
          tracks: cleanTracks,
        );

    // Draft löschen nach erfolgreichem Speichern
    _autoSaveService.clearFormData('add_album');

    LoggerService.info('Album created', '${newAlbum.name} by ${newAlbum.artist}');
    ToastService.showSuccess(context, l10n.albumAddedSuccess(newAlbum.name));
    AccessibilityAnnouncer.albumAdded(context, newAlbum.name, newAlbum.artist);
    Navigator.pop(context, newAlbum);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
        title: l10n.addNewAlbum,
        appBarColor: AppTheme.darkGreen, // Dark green
        actions: [
          IconButton(
            onPressed: _addAlbumFromFolder,
            icon: const Icon(Icons.folder_open),
            tooltip: l10n.importFromFolder,
          ),
          IconButton(
            onPressed: () => _saveAlbum(),
            icon: const Icon(Icons.save),
            tooltip: l10n.saveAlbum,
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
                  label: Text(l10n.saveAlbum),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.darkGreen, // Dark green
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
