// lib/widgets/album_form_widget.dart

import 'package:flutter/material.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/section_card.dart';
import 'package:music_up/services/validation_service.dart';
import 'package:music_up/services/accessibility_service.dart';

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
  final bool enableValidation;

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
    this.enableValidation = true,
  });

  @override
  State<AlbumFormWidget> createState() => _AlbumFormWidgetState();
}

class _AlbumFormWidgetState extends State<AlbumFormWidget> {
  final int currentYear = DateTime.now().year;
  
  // Validation state
  String? _nameError;
  String? _artistError;
  String? _genreError;
  
  @override
  void initState() {
    super.initState();
    if (widget.enableValidation) {
      // Add listeners für real-time validation
      widget.nameController.addListener(_validateName);
      widget.artistController.addListener(_validateArtist);
      widget.genreController.addListener(_validateGenre);
    }
  }
  
  @override
  void dispose() {
    if (widget.enableValidation) {
      widget.nameController.removeListener(_validateName);
      widget.artistController.removeListener(_validateArtist);
      widget.genreController.removeListener(_validateGenre);
    }
    super.dispose();
  }
  
  void _validateName() {
    if (!widget.enableValidation) return;
    setState(() {
      _nameError = ValidationService.validateAlbumName(widget.nameController.text);
    });
  }
  
  void _validateArtist() {
    if (!widget.enableValidation) return;
    setState(() {
      _artistError = ValidationService.validateArtistName(widget.artistController.text);
    });
  }
  
  void _validateGenre() {
    if (!widget.enableValidation) return;
    setState(() {
      _genreError = ValidationService.validateGenre(widget.genreController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Album Information Section
        SectionCard(
          title: 'Album-Informationen',
          child: Column(
            children: [
              Semantics(
                label: AccessibilityService.createFormFieldLabel(
                  'Album-Name', 
                  true, 
                  widget.nameController.text
                ),
                textField: true,
                child: TextField(
                  controller: widget.nameController,
                  decoration: InputDecoration(
                    labelText: 'Album-Name *',
                    prefixIcon: const Icon(Icons.album),
                    border: const OutlineInputBorder(),
                    errorText: widget.enableValidation ? _nameError : null,
                  ),
                ),
              ),
              const SizedBox(height: DS.md),
              Semantics(
                label: AccessibilityService.createFormFieldLabel(
                  'Künstler', 
                  true, 
                  widget.artistController.text
                ),
                textField: true,
                child: TextField(
                  controller: widget.artistController,
                  decoration: InputDecoration(
                    labelText: 'Künstler *',
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder(),
                    errorText: widget.enableValidation ? _artistError : null,
                  ),
                ),
              ),
              const SizedBox(height: DS.md),
              Semantics(
                label: AccessibilityService.createFormFieldLabel(
                  'Genre', 
                  false, 
                  widget.genreController.text
                ),
                textField: true,
                child: TextField(
                  controller: widget.genreController,
                  decoration: InputDecoration(
                    labelText: 'Genre (optional)',
                    prefixIcon: const Icon(Icons.music_note),
                    border: const OutlineInputBorder(),
                    errorText: widget.enableValidation ? _genreError : null,
                  ),
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