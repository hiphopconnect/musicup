import 'package:flutter/material.dart';
import 'package:music_up/theme/design_system.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onSearch;
  final bool enabled;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.hintText = 'Search...',
    this.onSearch,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DS.md),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: onSearch != null ? (_) => onSearch!() : null,
            ),
          ),
          if (onSearch != null) ...[
            const SizedBox(width: DS.xs),
            ElevatedButton(
              onPressed: enabled ? onSearch : null,
              child: const Text('Search'),
            ),
          ],
        ],
      ),
    );
  }
}
