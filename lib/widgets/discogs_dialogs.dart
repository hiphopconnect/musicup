// lib/widgets/discogs_dialogs.dart

import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/theme/design_system.dart';

class DiscogsDialogs {
  static void showSearchResultDetails(
    BuildContext context,
    DiscogsSearchResult result,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(result.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (result.imageUrl.isNotEmpty)
                  Center(
                    child: ClipRRect(
                      borderRadius: DS.rMd,
                      child: Image.network(
                        result.imageUrl,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: DS.rMd,
                            ),
                            child: const Icon(Icons.album, size: 50),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: DS.md),
                _buildDetailRow('Künstler', result.artist),
                _buildDetailRow('Jahr', result.year),
                _buildDetailRow('Format', result.format),
                if (result.genre.isNotEmpty)
                  _buildDetailRow('Genre', result.genre),
                _buildDetailRow('Discogs ID', result.id),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Schließen'),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? 'Unbekannt' : value),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showAddToCollectionDialog(
    BuildContext context,
    DiscogsSearchResult result,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Zur Sammlung hinzufügen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Album: ${result.title}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Künstler: ${result.artist}'),
              Text('Jahr: ${result.year}'),
              Text('Format: ${result.format}'),
              const SizedBox(height: DS.md),
              const Text(
                'Dieses Album wird zu Ihrer Sammlung hinzugefügt. '
                'Track-Informationen werden von Discogs geladen.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E4F2E),
                foregroundColor: Colors.white,
              ),
              child: const Text('Hinzufügen'),
            ),
          ],
        );
      },
    );
  }

  static void showOAuthNeededDialog(
    BuildContext context,
    DiscogsSearchResult result,
    VoidCallback onGoToSettings,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('OAuth erforderlich'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 48,
                color: Colors.orange,
              ),
              const SizedBox(height: DS.md),
              Text(
                'Um "${result.title}" zur Wantlist hinzuzufügen, '
                'benötigen Sie OAuth-Authentifizierung.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DS.sm),
              const Text(
                'Möchten Sie OAuth in den Einstellungen einrichten?',
                style: TextStyle(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Später'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onGoToSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Zu Einstellungen'),
            ),
          ],
        );
      },
    );
  }

  static void showNoTokenMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bitte OAuth in den Einstellungen einrichten.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  static void showEmptyQueryMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bitte Suchbegriffe eingeben')),
    );
  }

  static void showSearchErrorMessage(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Suche fehlgeschlagen: $error')),
    );
  }
}