// lib/widgets/edit_album_form_widget.dart

import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    years = List.generate(100, (index) => (currentYear - index).toString());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Album-Informationen Sektion
        SectionCard(
          title: "Album-Informationen",
          child: Column(
            children: [
              TextFormField(
                controller: widget.nameController,
                decoration: const InputDecoration(
                  labelText: "Album-Name",
                  prefixIcon: Icon(Icons.album),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: DS.md),
              TextFormField(
                controller: widget.artistController,
                decoration: const InputDecoration(
                  labelText: "Künstler",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: DS.md),
              TextFormField(
                controller: widget.genreController,
                decoration: const InputDecoration(
                  labelText: "Genre",
                  prefixIcon: Icon(Icons.music_note),
                  border: OutlineInputBorder(),
                ),
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
              // Year Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Jahr",
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                value: widget.selectedYear,
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
                decoration: const InputDecoration(
                  labelText: "Medium",
                  prefixIcon: Icon(Icons.storage),
                  border: OutlineInputBorder(),
                ),
                value: widget.selectedMedium,
                onChanged: widget.onMediumChanged,
                items: <String>{
                  'Vinyl',
                  'CD',
                  'Cassette',
                  'Digital',
                  'Unknown'
                }.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: DS.md),

              // Digital Status Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Digital verfügbar",
                  prefixIcon: Icon(Icons.cloud),
                  border: OutlineInputBorder(),
                ),
                value: widget.isDigital != null
                    ? (widget.isDigital! ? "Ja" : "Nein")
                    : null,
                onChanged: (String? newValue) {
                  final digitalValue = newValue == "Ja" ? true : false;
                  widget.onDigitalChanged?.call(digitalValue);
                },
                items: <String>['Ja', 'Nein']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}