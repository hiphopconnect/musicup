// lib/widgets/import_export_widget.dart

import 'package:flutter/material.dart';
import 'package:music_up/services/import_export_service.dart';
import 'package:music_up/services/json_service.dart';
import 'package:music_up/theme/design_system.dart';

class ImportExportWidget extends StatefulWidget {
  final JsonService jsonService;

  const ImportExportWidget({
    super.key,
    required this.jsonService,
  });

  @override
  State<ImportExportWidget> createState() => _ImportExportWidgetState();
}

class _ImportExportWidgetState extends State<ImportExportWidget> {
  late ImportExportService _importExportService;

  @override
  void initState() {
    super.initState();
    _importExportService = ImportExportService(widget.jsonService);
  }

  Future<void> _showImportExportDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Import / Export'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.file_upload),
                title: const Text('Import Collection'),
                subtitle: const Text('JSON, CSV oder XML importieren'),
                onTap: () {
                  Navigator.pop(context);
                  _showImportDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_download),
                title: const Text('Export Collection'),
                subtitle: const Text('Als JSON, CSV oder XML exportieren'),
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
              child: const Text('Abbrechen'),
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
        return AlertDialog(
          title: const Text('Import Format wählen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('JSON'),
                subtitle: const Text('Standard MusicUp Format'),
                onTap: () => Navigator.pop(context, ImportFormat.json),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('CSV'),
                subtitle: const Text('Tabellendaten'),
                onTap: () => Navigator.pop(context, ImportFormat.csv),
              ),
              ListTile(
                leading: const Icon(Icons.data_object),
                title: const Text('XML'),
                subtitle: const Text('Strukturierte Daten'),
                onTap: () => Navigator.pop(context, ImportFormat.xml),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
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
        return AlertDialog(
          title: const Text('Export Format wählen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('JSON'),
                subtitle: const Text('Standard MusicUp Format'),
                onTap: () => Navigator.pop(context, ExportFormat.json),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('CSV'),
                subtitle: const Text('Für Excel/Calc'),
                onTap: () => Navigator.pop(context, ExportFormat.csv),
              ),
              ListTile(
                leading: const Icon(Icons.data_object),
                title: const Text('XML'),
                subtitle: const Text('Strukturierte Daten'),
                onTap: () => Navigator.pop(context, ExportFormat.xml),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen'),
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
        final existing = await widget.jsonService.loadAlbums();
        final merged = [...existing, ...albums];
        await widget.jsonService.saveAlbums(merged);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${albums.length} Alben importiert'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import fehlgeschlagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _performExport(ExportFormat format) async {
    try {
      final albums = await widget.jsonService.loadAlbums();

      if (albums.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Keine Alben zum Exportieren vorhanden'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${albums.length} Alben exportiert nach\n$filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export fehlgeschlagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _showImportExportDialog,
          icon: const Icon(Icons.import_export),
          label: const Text('Import / Export'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: DS.xs),
        Text(
          'Unterstützte Formate: JSON, CSV, XML',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}