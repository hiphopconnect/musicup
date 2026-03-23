// lib/widgets/album_filters_widget.dart

import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/theme/design_system.dart';

class AlbumFiltersWidget extends StatelessWidget {
  final Map<String, bool> mediumFilters;
  final String digitalFilter;
  final bool isAscending;
  final String sortField;
  final Function(String, bool) onMediumFilterChanged;
  final Function(String) onDigitalFilterChanged;
  final VoidCallback onToggleSortOrder;
  final Function(String) onSortFieldChanged;
  final VoidCallback onResetFilters;

  const AlbumFiltersWidget({
    super.key,
    required this.mediumFilters,
    required this.digitalFilter,
    required this.isAscending,
    required this.sortField,
    required this.onMediumFilterChanged,
    required this.onDigitalFilterChanged,
    required this.onToggleSortOrder,
    required this.onSortFieldChanged,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ExpansionTile(
      title: Text(l10n.filterAndSort),
      leading: const Icon(Icons.filter_list),
      children: [
        Padding(
          padding: const EdgeInsets.all(DS.md),
          child: Column(
            children: [
              // Medium filters
              Text(
                l10n.mediumFilter,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: DS.xs),
              Wrap(
                spacing: DS.xs,
                children: mediumFilters.entries.map((entry) {
                  return FilterChip(
                    label: Text(entry.key),
                    selected: entry.value,
                    onSelected: (bool selected) {
                      onMediumFilterChanged(entry.key, selected);
                    },
                  );
                }).toList(),
              ),

              // Reset filters button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.resetFilters),
                    onPressed: onResetFilters,
                  ),
                ],
              ),

              const SizedBox(height: DS.md),

              // Sort order control
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.sorting),
                  const SizedBox(width: DS.sm),
                  DropdownButton<String>(
                    value: sortField,
                    items: [
                      const DropdownMenuItem(value: 'Album', child: Text('Album')),
                      DropdownMenuItem(value: 'Artist', child: Text(l10n.artist)),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        onSortFieldChanged(newValue);
                      }
                    },
                  ),
                  const SizedBox(width: DS.sm),
                  ElevatedButton.icon(
                    icon: Icon(
                      isAscending
                        ? Icons.sort_by_alpha
                        : Icons.sort_by_alpha_outlined
                    ),
                    label: Text(isAscending ? 'A-Z' : 'Z-A'),
                    onPressed: onToggleSortOrder,
                  ),
                ],
              ),

              const SizedBox(height: DS.md),

              // Digital status filter
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.digitalLabel),
                  const SizedBox(width: DS.sm),
                  DropdownButton<String>(
                    value: digitalFilter,
                    items: [
                      DropdownMenuItem(value: 'All', child: Text(l10n.all)),
                      DropdownMenuItem(value: 'Yes', child: Text(l10n.yes)),
                      DropdownMenuItem(value: 'No', child: Text(l10n.no)),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        onDigitalFilterChanged(newValue);
                      }
                    },
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

class AlbumSearchWidget extends StatelessWidget {
  final TextEditingController searchController;
  final String searchCategory;
  final Function(String) onSearchCategoryChanged;

  const AlbumSearchWidget({
    super.key,
    required this.searchController,
    required this.searchCategory,
    required this.onSearchCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(DS.sm),
      child: Row(
        children: [
          // Dropdown for search category
          DropdownButton<String>(
            value: searchCategory,
            items: [
              const DropdownMenuItem(value: 'Album', child: Text('Album')),
              DropdownMenuItem(value: 'Artist', child: Text(l10n.artist)),
              DropdownMenuItem(value: 'Song', child: Text(l10n.titleCategory)),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                onSearchCategoryChanged(newValue);
              }
            },
          ),
          const SizedBox(width: DS.sm),

          // Search field
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: searchController,
              builder: (context, value, child) {
                return TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: value.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => searchController.clear(),
                        )
                      : null,
                    border: const OutlineInputBorder(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
