// lib/widgets/import_export_widget.dart

import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/services/import_export_service.dart';
import 'package:music_up/services/service_locator.dart';
import 'package:music_up/theme/design_system.dart';

class ImportExportWidget extends StatefulWidget {
  const ImportExportWidget({super.key});

  @override
  State<ImportExportWidget> createState() => _ImportExportWidgetState();
}

class _ImportExportWidgetState extends State<ImportExportWidget> {
  late ImportExportService _importExportService;

  @override
  void initState() {
    super.initState();
    _importExportService = ImportExportService();
  }

  Future<void> _showImportExportDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.importExport),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.file_upload),
                title: Text(l10n.importCollection),
                subtitle: Text(l10n.importCollectionSubtitle),
                onTap: () {
                  Navigator.pop(context);
                  _showImportDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_download),
                title: Text(l10n.exportCollection),
                subtitle: Text(l10n.exportCollectionSubtitle),
                onTap: () {
                  Navigator.pop(context);
                  _showExportDialog();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showImportDialog() async {
    ImportFormat? selectedFormat = await showDialog<ImportFormat>(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.importFormatTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('JSON'),
                subtitle: Text(l10n.standardFormat),
                onTap: () => Navigator.pop(context, ImportFormat.json),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('CSV'),
                subtitle: Text(l10n.tableData),
                onTap: () => Navigator.pop(context, ImportFormat.csv),
              ),
              ListTile(
                leading: const Icon(Icons.data_object),
                title: const Text('XML'),
                subtitle: Text(l10n.structuredData),
                onTap: () => Navigator.pop(context, ImportFormat.xml),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );

    if (selectedFormat != null) {
      await _performImport(selectedFormat);
    }
  }

  Future<void> _showExportDialog() async {
    ExportFormat? selectedFormat = await showDialog<ExportFormat>(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.exportFormatTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('JSON'),
                subtitle: Text(l10n.standardFormat),
                onTap: () => Navigator.pop(context, ExportFormat.json),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('CSV'),
                subtitle: Text(l10n.forSpreadsheet),
                onTap: () => Navigator.pop(context, ExportFormat.csv),
              ),
              ListTile(
                leading: const Icon(Icons.data_object),
                title: const Text('XML'),
                subtitle: Text(l10n.structuredData),
                onTap: () => Navigator.pop(context, ExportFormat.xml),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );

    if (selectedFormat != null) {
      await _performExport(selectedFormat);
    }
  }

  Future<void> _performImport(ImportFormat format) async {
    try {
      final albums =
          await _importExportService.importCollection(format: format);

      if (albums.isNotEmpty) {
        final existing = await sl.jsonService.loadAlbums();
        final existingIds = existing.map((a) => a.id).toSet();
        final newAlbums = albums.where((a) => !existingIds.contains(a.id)).toList();
        final merged = [...existing, ...newAlbums];
        await sl.jsonService.saveAlbums(merged);

        if (mounted) {
          final l10n = AppLocalizations.of(context);
          final skipped = albums.length - newAlbums.length;
          final message = skipped > 0
              ? l10n.albumsImportedWithSkipped(newAlbums.length, skipped)
              : l10n.albumsImported(newAlbums.length);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.importFailed('$e')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _performExport(ExportFormat format) async {
    try {
      final albums = await sl.jsonService.loadAlbums();

      if (albums.isEmpty) {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noAlbumsToExport),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final filePath = await _importExportService.exportCollection(
        albums: albums,
        format: format,
      );

      if (filePath != null && mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(l10n.albumsExported(albums.length, filePath)),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.exportFailed('$e')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _showImportExportDialog,
          icon: const Icon(Icons.import_export),
          label: Text(l10n.importExport),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: DS.xs),
        Text(
          l10n.supportedFormats,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
