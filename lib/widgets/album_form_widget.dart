// lib/widgets/album_form_widget.dart

import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/l10n/validation_translations.dart';
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
      // Add listeners for real-time validation
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
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        // Album Information Section
        SectionCard(
          title: l10n.albumInformation,
          child: Column(
            children: [
              Semantics(
                label: AccessibilityService.createFormFieldLabel(
                  l10n.albumName,
                  true,
                  widget.nameController.text
                ),
                textField: true,
                child: TextField(
                  controller: widget.nameController,
                  maxLength: 200,
                  decoration: InputDecoration(
                    labelText: l10n.albumNameRequired,
                    prefixIcon: const Icon(Icons.album),
                    border: const OutlineInputBorder(),
                    counterText: '',
                    errorText: widget.enableValidation && _nameError != null
                        ? translateValidation(l10n, _nameError!)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: DS.md),
              Semantics(
                label: AccessibilityService.createFormFieldLabel(
                  l10n.artist,
                  true,
                  widget.artistController.text
                ),
                textField: true,
                child: TextField(
                  controller: widget.artistController,
                  maxLength: 200,
                  decoration: InputDecoration(
                    labelText: l10n.artistRequired,
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder(),
                    counterText: '',
                    errorText: widget.enableValidation && _artistError != null
                        ? translateValidation(l10n, _artistError!)
                        : null,
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
                  maxLength: 100,
                  decoration: InputDecoration(
                    labelText: l10n.genreOptional,
                    prefixIcon: const Icon(Icons.music_note),
                    border: const OutlineInputBorder(),
                    counterText: '',
                    errorText: widget.enableValidation && _genreError != null
                        ? translateValidation(l10n, _genreError!)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: DS.lg),

        // Album Details Section
        SectionCard(
          title: l10n.albumDetails,
          child: Column(
            children: [
              // Year Dropdown
              DropdownButtonFormField<String>(
                value: widget.selectedYear,
                decoration: InputDecoration(
                  labelText: l10n.year,
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(l10n.selectYear),
                  ),
                  ...List.generate(currentYear - 1900 + 1, (index) {
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
                decoration: InputDecoration(
                  labelText: l10n.medium,
                  prefixIcon: const Icon(Icons.storage),
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(l10n.selectMedium),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'Vinyl',
                    child: Text('Vinyl'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'CD',
                    child: Text('CD'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'Cassette',
                    child: Text('Cassette'),
                  ),
                  const DropdownMenuItem<String>(
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
                  title: Text(l10n.digitalAvailable),
                  subtitle: Text(l10n.digitalAvailableQuestion),
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
  static String? validateAlbumName(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l10n.pleaseEnterAlbumName;
    }
    return null;
  }

  static String? validateArtist(String? value, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l10n.pleaseEnterArtist;
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
