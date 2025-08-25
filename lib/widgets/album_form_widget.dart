// lib/widgets/album_form_widget.dart

import 'package:flutter/material.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/section_card.dart';

class AlbumFormData {
  final String name;
  final String artist;
  final String genre;
  final String? selectedYear;
  final String? selectedMedium;
  final bool? isDigital;

  AlbumFormData({
    required this.name,
    required this.artist,
    required this.genre,
    this.selectedYear,
    this.selectedMedium,
    this.isDigital,
  });
}

class AlbumFormWidget extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController artistController;
  final TextEditingController genreController;
  final String? selectedYear;
  final String? selectedMedium;
  final bool? isDigital;
  final ValueChanged<String?>? onYearChanged;
  final ValueChanged<String?>? onMediumChanged;
  final ValueChanged<bool?>? onDigitalChanged;

  const AlbumFormWidget({
    super.key,
    required this.nameController,
    required this.artistController,
    required this.genreController,
    this.selectedYear,
    this.selectedMedium,
    this.isDigital,
    this.onYearChanged,
    this.onMediumChanged,
    this.onDigitalChanged,
  });

  @override
  State<AlbumFormWidget> createState() => _AlbumFormWidgetState();
}

class _AlbumFormWidgetState extends State<AlbumFormWidget> {
  final int currentYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Album Information Section
        SectionCard(
          title: 'Album-Informationen',
          child: Column(
            children: [
              TextField(
                controller: widget.nameController,
                decoration: const InputDecoration(
                  labelText: 'Album-Name *',
                  prefixIcon: Icon(Icons.album),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: DS.md),
              TextField(
                controller: widget.artistController,
                decoration: const InputDecoration(
                  labelText: 'Künstler *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: DS.md),
              TextField(
                controller: widget.genreController,
                decoration: const InputDecoration(
                  labelText: 'Genre',
                  prefixIcon: Icon(Icons.music_note),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: DS.lg),

        // Album Details Section
        SectionCard(
          title: 'Album-Details',
          child: Column(
            children: [
              // Year Dropdown
              DropdownButtonFormField<String>(
                value: widget.selectedYear,
                decoration: const InputDecoration(
                  labelText: 'Jahr',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Jahr auswählen'),
                  ),
                  ...List.generate(currentYear - 1950 + 1, (index) {
                    final year = (currentYear - index).toString();
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(year),
                    );
                  }),
                ],
                onChanged: widget.onYearChanged,
              ),
              const SizedBox(height: DS.md),

              // Medium Dropdown
              DropdownButtonFormField<String>(
                value: widget.selectedMedium,
                decoration: const InputDecoration(
                  labelText: 'Medium',
                  prefixIcon: Icon(Icons.storage),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('Medium auswählen'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Vinyl',
                    child: Text('Vinyl'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'CD',
                    child: Text('CD'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Cassette',
                    child: Text('Cassette'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Digital',
                    child: Text('Digital'),
                  ),
                ],
                onChanged: widget.onMediumChanged,
              ),
              const SizedBox(height: DS.md),

              // Digital Switch
              Card(
                child: SwitchListTile(
                  title: const Text('Digital verfügbar'),
                  subtitle: const Text('Ist dieses Album digital verfügbar?'),
                  value: widget.isDigital ?? false,
                  onChanged: widget.onDigitalChanged,
                  secondary: const Icon(Icons.cloud),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AlbumFormValidator {
  static String? validateAlbumName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte geben Sie einen Album-Namen ein';
    }
    return null;
  }

  static String? validateArtist(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte geben Sie einen Künstler ein';
    }
    return null;
  }

  static bool isFormValid({
    required String albumName,
    required String artist,
  }) {
    return albumName.trim().isNotEmpty && artist.trim().isNotEmpty;
  }
}