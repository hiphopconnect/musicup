// lib/widgets/wantlist_dialogs.dart

import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/theme/app_theme.dart';
import 'package:music_up/theme/design_system.dart';

class WantlistDialogs {
  static Future<bool?> showAddToCollectionDialog(
    BuildContext context,
    Album wantlistAlbum,
  ) async {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.addToCollection),
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
                Text(l10n.artistPrefix(wantlistAlbum.artist)),
                Text(l10n.yearPrefix(wantlistAlbum.year)),
                Text(l10n.mediumPrefix(wantlistAlbum.medium)),
                if (wantlistAlbum.genre.isNotEmpty)
                  Text(l10n.genrePrefix(wantlistAlbum.genre)),

                const SizedBox(height: DS.md),

                Container(
                  padding: const EdgeInsets.all(DS.sm),
                  decoration: BoxDecoration(
                    color: AppTheme.darkGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DS.xs),
                    border: Border.all(color: AppTheme.darkGreen.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppTheme.darkGreen),
                          const SizedBox(width: DS.xs),
                          Text(
                            l10n.whatHappens,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DS.xs),
                      Text(
                        l10n.whatHappensBody,
                        style: const TextStyle(fontSize: 14),
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
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkGreen,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.addToCollection),
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
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.removeFromWantlistTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.removeFromWantlistConfirm(album.name)),
              const SizedBox(height: DS.md),
              Container(
                padding: const EdgeInsets.all(DS.sm),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(DS.xs),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_outlined, color: Colors.orange),
                        const SizedBox(width: DS.xs),
                        Text(
                          l10n.note,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DS.xs),
                    Text(
                      l10n.removeFromWantlistNote,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(l10n.remove),
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
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.errorGeneric(error)),
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
