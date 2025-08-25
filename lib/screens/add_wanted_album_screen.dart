// lib/screens/add_wanted_album_screen.dart

import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/services/wantlist_service.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/app_layout.dart';
import 'package:music_up/widgets/status_banner.dart';
import 'package:music_up/widgets/wantlist_album_form_widget.dart';

class AddWantedAlbumScreen extends StatefulWidget {
  final JsonService jsonService;
  final ConfigManager configManager;

  const AddWantedAlbumScreen({
    super.key,
    required this.jsonService,
    required this.configManager,
  });

  @override
  AddWantedAlbumScreenState createState() => AddWantedAlbumScreenState();
}

class AddWantedAlbumScreenState extends State<AddWantedAlbumScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _albumNameController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  late WantlistService _wantlistService;
  String _selectedMedium = 'Vinyl';
  bool _digital = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _wantlistService = WantlistService(widget.jsonService);
  }

  @override
  void dispose() {
    _albumNameController.dispose();
    _artistController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _saveWantedAlbum() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final album = await _wantlistService.createWantedAlbum(
        name: _albumNameController.text,
        artist: _artistController.text,
        genre: _genreController.text,
        year: _yearController.text,
        medium: _selectedMedium,
        digital: _digital,
      );

      await _wantlistService.addToWantlist(album);

      if (!mounted) return;

      _showSuccessMessage(album);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showErrorMessage(e.toString());
    }
  }

  void _showSuccessMessage(Album album) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${album.name}" zur Wantlist hinzugefügt'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fehler: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: DS.md),
          Text('Speichere zur Wantlist...'),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DS.md),
      child: Column(
        children: [
          // Info Banner
          StatusBanner(
            message: 'Alben, die Sie in Zukunft erwerben möchten',
            backgroundColor: Colors.green[50]!,
            textColor: Colors.green[800]!,
            icon: Icons.favorite,
          ),

          const SizedBox(height: DS.lg),

          // Wantlist Form
          WantlistAlbumFormWidget(
            formKey: _formKey,
            albumNameController: _albumNameController,
            artistController: _artistController,
            genreController: _genreController,
            yearController: _yearController,
            selectedMedium: _selectedMedium,
            digital: _digital,
            onMediumChanged: (medium) => setState(() => _selectedMedium = medium),
            onDigitalChanged: (digital) => setState(() => _digital = digital),
          ),

          const SizedBox(height: DS.xl),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveWantedAlbum,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.favorite),
              label: Text(_isSaving ? 'Speichere...' : 'Zur Wantlist hinzufügen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(DS.md),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Zur Wantlist hinzufügen',
      appBarColor: Colors.green,
      actions: [
        if (!_isSaving)
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveWantedAlbum,
          ),
      ],
      body: _isSaving ? _buildLoadingState() : _buildFormContent(),
    );
  }
}