// lib/widgets/wantlist_album_form_widget.dart

import 'package:flutter/material.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/section_card.dart';

class WantlistAlbumFormWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController albumNameController;
  final TextEditingController artistController;
  final TextEditingController genreController;
  final TextEditingController yearController;
  final String selectedMedium;
  final bool digital;
  final ValueChanged<String> onMediumChanged;
  final ValueChanged<bool> onDigitalChanged;

  const WantlistAlbumFormWidget({
    super.key,
    required this.formKey,
    required this.albumNameController,
    required this.artistController,
    required this.genreController,
    required this.yearController,
    required this.selectedMedium,
    required this.digital,
    required this.onMediumChanged,
    required this.onDigitalChanged,
  });

  @override
  State<WantlistAlbumFormWidget> createState() => _WantlistAlbumFormWidgetState();
}

class _WantlistAlbumFormWidgetState extends State<WantlistAlbumFormWidget> {
  final List<String> _mediumOptions = ['Vinyl', 'CD', 'Cassette', 'Digital'];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          // Album-Informationen Sektion
          SectionCard(
            title: "Album-Informationen",
            child: Column(
              children: [
                TextFormField(
                  controller: widget.albumNameController,
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
                  controller: widget.artistController,
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
                  controller: widget.genreController,
                  decoration: const InputDecoration(
                    labelText: 'Genre (optional)',
                    prefixIcon: Icon(Icons.music_note),
                  ),
                ),
                const SizedBox(height: DS.md),
                TextFormField(
                  controller: widget.yearController,
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

          const SizedBox(height: DS.lg),

          // Format-Einstellungen Sektion
          SectionCard(
            title: "Format-Einstellungen",
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: widget.selectedMedium,
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
                    if (newValue != null) {
                      widget.onMediumChanged(newValue);
                    }
                  },
                ),
                const SizedBox(height: DS.md),
                Card(
                  child: SwitchListTile(
                    title: const Text('Digital verfügbar'),
                    subtitle: const Text('Ist dieses Album digital verfügbar?'),
                    value: widget.digital,
                    onChanged: widget.onDigitalChanged,
                    secondary: const Icon(Icons.cloud),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WantlistAlbumValidator {
  static bool isValid({
    required String albumName,
    required String artist,
  }) {
    return albumName.trim().isNotEmpty && artist.trim().isNotEmpty;
  }
}