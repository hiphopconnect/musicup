// lib/widgets/discogs_dialogs.dart

import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/models/album_model.dart';
import 'package:music_up/theme/app_theme.dart';
import 'package:music_up/theme/design_system.dart';

class DiscogsDialogs {
  static void showSearchResultDetails(
    BuildContext context,
    DiscogsSearchResult result,
  ) {
    final l10n = AppLocalizations.of(context);
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
                _buildDetailRow(l10n.artist, result.artist, l10n),
                _buildDetailRow(l10n.year, result.year, l10n),
                _buildDetailRow(l10n.format, result.format, l10n),
                if (result.genre.isNotEmpty)
                  _buildDetailRow(l10n.genre, result.genre, l10n),
                _buildDetailRow('Discogs ID', result.id, l10n),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildDetailRow(String label, String value, AppLocalizations l10n) {
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
            child: Text(value.isEmpty ? l10n.unknown : value),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showAddToCollectionDialog(
    BuildContext context,
    DiscogsSearchResult result,
  ) async {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.addToCollection),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Album: ${result.title}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(l10n.artistPrefix(result.artist)),
              Text(l10n.yearPrefix(result.year)),
              Text(l10n.formatPrefix(result.format)),
              const SizedBox(height: DS.md),
              Text(
                l10n.addToCollectionDiscogsBody,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
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
              child: Text(l10n.add),
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
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.oauthRequired),
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
                l10n.oauthRequiredBody(result.title),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: DS.sm),
              Text(
                l10n.oauthSetupQuestion,
                style: const TextStyle(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.later),
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
              child: Text(l10n.goToSettings),
            ),
          ],
        );
      },
    );
  }

  static void showNoTokenMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.pleaseConfigureOAuth),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showEmptyQueryMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.pleaseEnterSearchTerms)),
    );
  }

  static void showSearchErrorMessage(BuildContext context, String error) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.searchFailed(error))),
    );
  }
}
