// lib/screens/edit_album_screen.dart

import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/album_edit_service.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/app_layout.dart';
import 'package:music_up/widgets/edit_album_form_widget.dart';
import 'package:music_up/widgets/track_management_widget.dart';

class EditAlbumScreen extends StatefulWidget {
  final Album album;
  final JsonService? jsonService;

  const EditAlbumScreen({super.key, required this.album, this.jsonService});

  @override
  EditAlbumScreenState createState() => EditAlbumScreenState();
}

class EditAlbumScreenState extends State<EditAlbumScreen> {
  late TextEditingController _nameController;
  late TextEditingController _artistController;
  late TextEditingController _genreController;
  final ScrollController _scrollController = ScrollController();

  late AlbumEditService _editService;
  late Album _originalAlbum;

  String? _selectedMedium;
  bool? _isDigital;
  String? _selectedYear;
  List<Track> _tracks = [];
  bool _isLoadingTracks = false;

  @override
  void initState() {
    super.initState();
    
    _editService = AlbumEditService();
    _originalAlbum = widget.album;
    
    _initializeFormData();
    _loadTracksIfNeeded();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _artistController.dispose();
    _genreController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeFormData() {
    _nameController = TextEditingController(text: _originalAlbum.name);
    _artistController = TextEditingController(text: _originalAlbum.artist);
    _genreController = TextEditingController(text: _originalAlbum.genre);
    _selectedMedium = _originalAlbum.medium;
    _isDigital = _originalAlbum.digital;
    _selectedYear = _originalAlbum.year;
    _tracks = _editService.createEditableCopy(_originalAlbum).tracks;
  }

  Future<void> _loadTracksIfNeeded() async {
    if (_originalAlbum.tracks.isNotEmpty || widget.jsonService == null) {
      return;
    }

    setState(() => _isLoadingTracks = true);
    
    try {
      final albumWithTracks = await widget.jsonService!.loadAlbumWithTracks(_originalAlbum.id);
      if (mounted && albumWithTracks != null) {
        setState(() {
          _tracks = _editService.createEditableCopy(albumWithTracks).tracks;
          _isLoadingTracks = false;
        });
      } else if (mounted) {
        setState(() => _isLoadingTracks = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTracks = false);
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges()) {
      return true; // No changes, can pop
    }

    final shouldDiscard = await _showUnsavedChangesDialog();
    return shouldDiscard ?? false;
  }

  bool _hasUnsavedChanges() {
    return _editService.hasChanges(
      original: _originalAlbum,
      name: _nameController.text,
      artist: _artistController.text,
      genre: _genreController.text,
      selectedYear: _selectedYear,
      selectedMedium: _selectedMedium,
      isDigital: _isDigital,
      tracks: _tracks,
    );
  }

  Future<bool?> _showUnsavedChangesDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ungespeicherte Änderungen'),
          content: const Text(
            'Sie haben ungespeicherte Änderungen. Möchten Sie diese verwerfen?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Bearbeitung fortsetzen'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Änderungen verwerfen'),
            ),
          ],
        );
      },
    );
  }

  void _saveAlbum() {
    final validationErrors = _editService.validateAlbumEdit(
      name: _nameController.text,
      artist: _artistController.text,
      selectedMedium: _selectedMedium,
      isDigital: _isDigital,
      tracks: _tracks,
    );

    if (validationErrors.isNotEmpty) {
      _showValidationErrors(validationErrors);
      return;
    }

    final updatedAlbum = _editService.updateAlbumFromForm(
      originalAlbum: _originalAlbum,
      name: _nameController.text,
      artist: _artistController.text,
      genre: _genreController.text,
      selectedYear: _selectedYear,
      selectedMedium: _selectedMedium,
      isDigital: _isDigital,
      tracks: _tracks,
    );

    Navigator.pop(context, updatedAlbum);
  }

  void _showValidationErrors(List<String> errors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Validierungsfehler'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: errors.map((error) => Text('• $error')).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: AppLayout(
        title: 'Album bearbeiten',
        appBarColor: const Color(0xFF556B2F), // Olive green
        actions: [
          if (_hasUnsavedChanges())
            IconButton(
              onPressed: _saveAlbum,
              icon: const Icon(Icons.save),
              tooltip: 'Änderungen speichern',
            ),
        ],
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(DS.md),
          child: Column(
            children: [
              // Album Form
              EditAlbumFormWidget(
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
              _isLoadingTracks
                  ? const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('Tracks werden geladen...'),
                        ],
                      ),
                    )
                  : TrackManagementWidget(
                      tracks: _tracks,
                      scrollController: _scrollController,
                      onTracksChanged: (tracks) => setState(() => _tracks = tracks),
                    ),

              const SizedBox(height: DS.xl),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveAlbum,
                  icon: const Icon(Icons.save),
                  label: const Text('Änderungen speichern'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(DS.md),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              // Discard Changes Button
              const SizedBox(height: DS.sm),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final shouldDiscard = await _showUnsavedChangesDialog();
                    if (shouldDiscard == true && mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Änderungen verwerfen'),
                  style: OutlinedButton.styleFrom(
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