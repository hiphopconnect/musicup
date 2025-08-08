// lib/screens/add_wanted_album_screen.dart

import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/json_service.dart';

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
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _albumNameController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  String _selectedMedium = 'Vinyl';
  bool _digital = false;
  bool _isSaving = false;

  final List<String> _mediumOptions = ['Vinyl', 'CD', 'Cassette', 'Digital'];

  @override
  void dispose() {
    _albumNameController.dispose();
    _artistController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _saveWantedAlbum() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        // Create new Album object for wantlist
        Album wantedAlbum = Album(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _albumNameController.text.trim(),
          artist: _artistController.text.trim(),
          genre: _genreController.text.trim(),
          year: _yearController.text.trim(),
          medium: _selectedMedium,
          digital: _digital,
          tracks: [], // Wantlist albums don't need tracks initially
        );

        // ✅ SPEICHERE das Album in der Wantlist
        List<Album> currentWantlist = await widget.jsonService.loadWantlist();
        currentWantlist.add(wantedAlbum);
        await widget.jsonService.saveWantlist(currentWantlist);

        if (!mounted) return;

        // ✅ ZEIGE Erfolgs-Message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ "${wantedAlbum.name}" added to wantlist'),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ KEHRE zur Wantlist zurück mit "true" (= refresh needed)
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;

        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error adding to wantlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add to Wantlist'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          if (!_isSaving)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveWantedAlbum,
            ),
        ],
      ),
      body: _isSaving
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Saving to wantlist...'),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info Card
                    Card(
                      color: Colors.green[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.green[600],
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Add Album to Wantlist',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Albums you want to acquire in the future',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Album Name Field
                    TextFormField(
                      controller: _albumNameController,
                      decoration: const InputDecoration(
                        labelText: 'Album Name *',
                        prefixIcon: Icon(Icons.album),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter album name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Artist Field
                    TextFormField(
                      controller: _artistController,
                      decoration: const InputDecoration(
                        labelText: 'Artist *',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter artist name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Genre Field
                    TextFormField(
                      controller: _genreController,
                      decoration: const InputDecoration(
                        labelText: 'Genre (optional)',
                        prefixIcon: Icon(Icons.music_note),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Year Field
                    TextFormField(
                      controller: _yearController,
                      decoration: const InputDecoration(
                        labelText: 'Year (optional)',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          int? year = int.tryParse(value.trim());
                          if (year == null ||
                              year < 1900 ||
                              year > DateTime.now().year + 10) {
                            return 'Please enter valid year (1900-${DateTime.now().year + 10})';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Medium Selection
                    DropdownButtonFormField<String>(
                      value: _selectedMedium,
                      decoration: const InputDecoration(
                        labelText: 'Medium',
                        prefixIcon: Icon(Icons.storage),
                        border: OutlineInputBorder(),
                      ),
                      items: _mediumOptions.map((String medium) {
                        return DropdownMenuItem<String>(
                          value: medium,
                          child: Text(medium),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedMedium = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Digital Switch
                    Card(
                      child: SwitchListTile(
                        title: const Text('Digital Available'),
                        subtitle:
                            const Text('Is this album available digitally?'),
                        value: _digital,
                        onChanged: (bool value) {
                          setState(() {
                            _digital = value;
                          });
                        },
                        secondary: const Icon(Icons.cloud),
                      ),
                    ),
                    const Spacer(),

                    // Save Button
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveWantedAlbum,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.favorite),
                      label: Text(_isSaving ? 'Saving...' : 'Add to Wantlist'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
