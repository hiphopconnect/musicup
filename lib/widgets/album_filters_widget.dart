// lib/widgets/album_filters_widget.dart

import 'package:flutter/material.dart';
import 'package:music_up/theme/design_system.dart';

class AlbumFiltersWidget extends StatelessWidget {
  final Map<String, bool> mediumFilters;
  final String digitalFilter;
  final bool isAscending;
  final Function(String, bool) onMediumFilterChanged;
  final Function(String) onDigitalFilterChanged;
  final VoidCallback onToggleSortOrder;
  final VoidCallback onResetFilters;

  const AlbumFiltersWidget({
    super.key,
    required this.mediumFilters,
    required this.digitalFilter,
    required this.isAscending,
    required this.onMediumFilterChanged,
    required this.onDigitalFilterChanged,
    required this.onToggleSortOrder,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('Filter & Sort'),
      leading: const Icon(Icons.filter_list),
      children: [
        Padding(
          padding: const EdgeInsets.all(DS.md),
          child: Column(
            children: [
              // Medium filters
              const Text(
                'Medium Filter:',
                style: TextStyle(fontWeight: FontWeight.bold),
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
                    label: const Text('Reset Filters'),
                    onPressed: onResetFilters,
                  ),
                ],
              ),
              
              const SizedBox(height: DS.md),
              
              // Sort order control
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sort:'),
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
                  const Text('Digital:'),
                  const SizedBox(width: DS.sm),
                  DropdownButton<String>(
                    value: digitalFilter,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                      DropdownMenuItem(value: 'No', child: Text('No')),
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
    return Padding(
      padding: const EdgeInsets.all(DS.sm),
      child: Row(
        children: [
          // Dropdown for search category
          DropdownButton<String>(
            value: searchCategory,
            items: const [
              DropdownMenuItem(value: 'Album', child: Text('Album')),
              DropdownMenuItem(value: 'Artist', child: Text('Artist')),
              DropdownMenuItem(value: 'Song', child: Text('Song')),
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
                    hintText: "Search...",
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