// lib/screens/add_wanted_album_screen.dart

import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/app_layout.dart';
import 'package:music_up/widgets/section_card.dart';
import 'package:music_up/widgets/status_banner.dart';

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

        // SPEICHERE das Album in der Wantlist
        List<Album> currentWantlist = await widget.jsonService.loadWantlist();
        currentWantlist.add(wantedAlbum);
        await widget.jsonService.saveWantlist(currentWantlist);

        if (!mounted) return;

        // ZEIGE Erfolgs-Message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${wantedAlbum.name}" added to wantlist'),
            backgroundColor: Colors.green,
          ),
        );

        // KEHRE zur Wantlist zurück mit "true" (= refresh needed)
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;

        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding to wantlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
      body: _isSaving
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: DS.md),
                  Text('Speichere zur Wantlist...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(DS.md),
              child: Form(
                key: _formKey,
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

                    // Album-Informationen Sektion
                    SectionCard(
                      title: "Album-Informationen",
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _albumNameController,
                            decoration: const InputDecoration(
                              labelText: 'Album-Name *',
                              prefixIcon: Icon(Icons.album),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Bitte Album-Name eingeben';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: DS.md),
                          TextFormField(
                            controller: _artistController,
                            decoration: const InputDecoration(
                              labelText: 'Künstler *',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Bitte Künstler-Name eingeben';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: DS.md),
                          TextFormField(
                            controller: _genreController,
                            decoration: const InputDecoration(
                              labelText: 'Genre (optional)',
                              prefixIcon: Icon(Icons.music_note),
                            ),
                          ),
                          const SizedBox(height: DS.md),
                          TextFormField(
                            controller: _yearController,
                            decoration: const InputDecoration(
                              labelText: 'Jahr (optional)',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.trim().isNotEmpty) {
                                int? year = int.tryParse(value.trim());
                                if (year == null ||
                                    year < 1900 ||
                                    year > DateTime.now().year + 10) {
                                  return 'Bitte gültiges Jahr eingeben (1900-${DateTime.now().year + 10})';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    // Format-Einstellungen Sektion
                    SectionCard(
                      title: "Format-Einstellungen",
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedMedium,
                            decoration: const InputDecoration(
                              labelText: 'Medium',
                              prefixIcon: Icon(Icons.storage),
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
                          const SizedBox(height: DS.md),
                          Card(
                            child: SwitchListTile(
                              title: const Text('Digital verfügbar'),
                              subtitle: const Text(
                                  'Ist dieses Album digital verfügbar?'),
                              value: _digital,
                              onChanged: (bool value) {
                                setState(() {
                                  _digital = value;
                                });
                              },
                              secondary: const Icon(Icons.cloud),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: DS.xl),

                    // Speichern Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveWantedAlbum,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.favorite),
                        label: Text(_isSaving
                            ? 'Speichere...'
                            : 'Zur Wantlist hinzufügen'),
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
              ),
            ),
    );
  }
}
