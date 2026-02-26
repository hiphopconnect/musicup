// lib/widgets/wantlist_album_form_widget.dart

import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          // Album-Informationen Sektion
          SectionCard(
            title: l10n.albumInformation,
            child: Column(
              children: [
                TextFormField(
                  controller: widget.albumNameController,
                  decoration: InputDecoration(
                    labelText: l10n.albumNameRequired,
                    prefixIcon: const Icon(Icons.album),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterAlbumNameShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: DS.md),
                TextFormField(
                  controller: widget.artistController,
                  decoration: InputDecoration(
                    labelText: l10n.artistRequired,
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterArtistShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: DS.md),
                TextFormField(
                  controller: widget.genreController,
                  decoration: InputDecoration(
                    labelText: l10n.genreOptional,
                    prefixIcon: const Icon(Icons.music_note),
                  ),
                ),
                const SizedBox(height: DS.md),
                TextFormField(
                  controller: widget.yearController,
                  decoration: InputDecoration(
                    labelText: l10n.yearOptional,
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      int? year = int.tryParse(value.trim());
                      if (year == null ||
                          year < 1900 ||
                          year > DateTime.now().year + 10) {
                        return l10n.pleaseEnterValidYear(DateTime.now().year + 10);
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
            title: l10n.formatSettings,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: widget.selectedMedium,
                  decoration: InputDecoration(
                    labelText: l10n.medium,
                    prefixIcon: const Icon(Icons.storage),
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
                    title: Text(l10n.digitalAvailable),
                    subtitle: Text(l10n.digitalAvailableQuestion),
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
