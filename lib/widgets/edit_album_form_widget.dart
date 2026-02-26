// lib/widgets/edit_album_form_widget.dart

import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/section_card.dart';

class EditAlbumFormWidget extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController artistController;
  final TextEditingController genreController;
  final String? selectedYear;
  final String? selectedMedium;
  final bool? isDigital;
  final ValueChanged<String?>? onYearChanged;
  final ValueChanged<String?>? onMediumChanged;
  final ValueChanged<bool?>? onDigitalChanged;

  const EditAlbumFormWidget({
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
  State<EditAlbumFormWidget> createState() => _EditAlbumFormWidgetState();
}

class _EditAlbumFormWidgetState extends State<EditAlbumFormWidget> {
  final int currentYear = DateTime.now().year;
  late List<String> years;

  static const List<String> _knownMediums = [
    'Vinyl',
    'CD',
    'Cassette',
    'Digital',
    'Unknown',
  ];

  @override
  void initState() {
    super.initState();
    years = List.generate(currentYear - 1900 + 1, (index) => (currentYear - index).toString());
  }

  /// Stellt sicher, dass der Year-Wert im Dropdown vorhanden ist
  String? _getSafeYear() {
    if (widget.selectedYear == null) return null;
    if (years.contains(widget.selectedYear)) return widget.selectedYear;
    // Wert nicht in Liste - als null behandeln (zeigt Placeholder)
    return null;
  }

  /// Stellt sicher, dass der Medium-Wert im Dropdown vorhanden ist
  List<String> _getMediumItems() {
    final mediums = List<String>.from(_knownMediums);
    if (widget.selectedMedium != null && !mediums.contains(widget.selectedMedium)) {
      mediums.add(widget.selectedMedium!);
    }
    return mediums;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        // Album-Informationen Sektion
        SectionCard(
          title: l10n.albumInformation,
          child: Column(
            children: [
              TextFormField(
                controller: widget.nameController,
                maxLength: 200,
                decoration: InputDecoration(
                  labelText: l10n.albumName,
                  prefixIcon: const Icon(Icons.album),
                  border: const OutlineInputBorder(),
                  counterText: '',
                ),
              ),
              const SizedBox(height: DS.md),
              TextFormField(
                controller: widget.artistController,
                maxLength: 200,
                decoration: InputDecoration(
                  labelText: l10n.artist,
                  prefixIcon: const Icon(Icons.person),
                  border: const OutlineInputBorder(),
                  counterText: '',
                ),
              ),
              const SizedBox(height: DS.md),
              TextFormField(
                controller: widget.genreController,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: l10n.genre,
                  prefixIcon: const Icon(Icons.music_note),
                  border: const OutlineInputBorder(),
                  counterText: '',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: DS.lg),

        // Format-Einstellungen Sektion
        SectionCard(
          title: l10n.formatSettings,
          child: Column(
            children: [
              // Year Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: l10n.year,
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                ),
                value: _getSafeYear(),
                onChanged: widget.onYearChanged,
                items: years.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: DS.md),

              // Medium Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: l10n.medium,
                  prefixIcon: const Icon(Icons.storage),
                  border: const OutlineInputBorder(),
                ),
                value: widget.selectedMedium,
                onChanged: widget.onMediumChanged,
                items: _getMediumItems().map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: DS.md),

              // Digital Status Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: l10n.digitalAvailable,
                  prefixIcon: const Icon(Icons.cloud),
                  border: const OutlineInputBorder(),
                ),
                value: widget.isDigital != null
                    ? (widget.isDigital! ? 'true' : 'false')
                    : null,
                onChanged: (String? newValue) {
                  final digitalValue = newValue == 'true';
                  widget.onDigitalChanged?.call(digitalValue);
                },
                items: [
                  DropdownMenuItem<String>(
                    value: 'true',
                    child: Text(l10n.yes),
                  ),
                  DropdownMenuItem<String>(
                    value: 'false',
                    child: Text(l10n.no),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
