// lib/widgets/wantlist_dialogs.dart

import 'package:flutter/material.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/theme/design_system.dart';

class WantlistDialogs {
  static Future<bool?> showAddToCollectionDialog(
    BuildContext context,
    Album wantlistAlbum,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Zur Sammlung hinzufügen'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Album: ${wantlistAlbum.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: DS.xs),
                Text('Künstler: ${wantlistAlbum.artist}'),
                Text('Jahr: ${wantlistAlbum.year}'),
                Text('Medium: ${wantlistAlbum.medium}'),
                if (wantlistAlbum.genre.isNotEmpty)
                  Text('Genre: ${wantlistAlbum.genre}'),
                
                const SizedBox(height: DS.md),
                
                Container(
                  padding: const EdgeInsets.all(DS.sm),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E4F2E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DS.xs),
                    border: Border.all(color: const Color(0xFF2E4F2E).withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: const Color(0xFF2E4F2E)),
                          SizedBox(width: DS.xs),
                          Text(
                            'Was passiert:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E4F2E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DS.xs),
                      const Text(
                        '• Album wird zu Ihrer Sammlung hinzugefügt\n'
                        '• Album wird aus der Wantlist entfernt\n'
                        '• Track-Informationen werden geladen',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
              child: const Text('Zur Sammlung hinzufügen'),
            ),
          ],
        );
      },
    );
  }

  static Future<bool?> showDeleteConfirmationDialog(
    BuildContext context,
    Album album,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aus Wantlist entfernen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Möchten Sie "${album.name}" wirklich aus der Wantlist entfernen?'),
              const SizedBox(height: DS.md),
              Container(
                padding: const EdgeInsets.all(DS.sm),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(DS.xs),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_outlined, color: Colors.orange),
                        SizedBox(width: DS.xs),
                        Text(
                          'Hinweis:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: DS.xs),
                    Text(
                      'Das Album wird sowohl aus der lokalen Wantlist als auch aus Ihrer Discogs-Wantlist entfernt (falls konfiguriert).',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Entfernen'),
            ),
          ],
        );
      },
    );
  }

  static void showSuccessMessage(
    BuildContext context,
    String message, {
    Color backgroundColor = Colors.green,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  static void showErrorMessage(
    BuildContext context,
    String error,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fehler: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  static void showLoadingSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: DS.sm),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}