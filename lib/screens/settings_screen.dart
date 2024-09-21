import 'dart:io';
import 'package:flutter/material.dart';
import '../services/json_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class SettingsScreen extends StatefulWidget {
  final JsonService jsonService;

  const SettingsScreen({super.key, required this.jsonService});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController jsonFileNameController = TextEditingController();
  TextEditingController jsonPathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    jsonFileNameController.text = widget.jsonService.configManager.getJsonFileName();
    jsonPathController.text = widget.jsonService.configManager.getJsonFilePath() ?? '';
  }

  Future<void> _pickJsonFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.isNotEmpty) {
      String? selectedFile = result.files.single.path;
      if (selectedFile != null) {
        setState(() {
          jsonPathController.text = selectedFile;
        });
        await widget.jsonService.configManager.setJsonFilePath(selectedFile);
        await widget.jsonService.configManager.saveConfig();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('JSON-Datei gespeichert!')),
        );

        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _saveSettings() async {
    String fileName = jsonFileNameController.text;
    await widget.jsonService.configManager.setJsonFileName(fileName);
    await widget.jsonService.configManager.saveConfig();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Einstellungen gespeichert!')),
    );

    Navigator.pop(context, true);
  }

  Future<void> _exportFile(String fileType) async {
    if (Platform.isIOS || Platform.isAndroid) {
      // Auf mobilen Plattformen teilen wir die Datei
      String tempDir = (await getTemporaryDirectory()).path;
      String exportPath = '$tempDir/albums_export.$fileType';

      if (fileType == 'json') {
        await widget.jsonService.exportJson(exportPath);
      } else if (fileType == 'xml') {
        await widget.jsonService.exportXml(exportPath);
      } else if (fileType == 'csv') {
        await widget.jsonService.exportCsv(exportPath);
      }

      await Share.shareXFiles([XFile(exportPath)], text: 'Hier ist meine Albumliste');
    } else {
      // Auf Desktop-Plattformen verwenden wir den Dateipicker
      String? filePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Export $fileType File',
        fileName: 'albums_export.$fileType',
      );

      if (filePath != null) {
        if (fileType == 'json') {
          await widget.jsonService.exportJson(filePath);
        } else if (fileType == 'xml') {
          await widget.jsonService.exportXml(filePath);
        } else if (fileType == 'csv') {
          await widget.jsonService.exportCsv(filePath);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$fileType-Datei exportiert: $filePath')),
        );
      }
    }
  }

  Future<void> _importFile(String fileType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.isNotEmpty) {
      String? selectedPath = result.files.single.path;
      if (selectedPath != null) {
        try {
          await widget.jsonService.importAlbums(selectedPath);

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$fileType-Datei importiert: $selectedPath')),
          );
        } catch (e) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Import fehlgeschlagen: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String platformInfo = Platform.isIOS || Platform.isAndroid
        ? 'Auf mobilen Geräten wird die Datei im Anwendungsverzeichnis gespeichert.'
        : 'Auf Desktop-Geräten können Sie den Pfad auswählen.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(platformInfo),
            const SizedBox(height: 16),
            TextField(
              controller: jsonFileNameController,
              decoration: const InputDecoration(labelText: 'JSON-Dateiname'),
            ),
            if (!Platform.isIOS && !Platform.isAndroid) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: jsonPathController,
                      decoration: const InputDecoration(labelText: 'JSON-Dateipfad'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _pickJsonFile,
                    child: const Text('JSON-Datei wählen'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Speichern'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _exportFile('json'),
                  child: const Text('Export als JSON'),
                ),
                ElevatedButton(
                  onPressed: () => _exportFile('xml'),
                  child: const Text('Export als XML'),
                ),
                ElevatedButton(
                  onPressed: () => _exportFile('csv'),
                  child: const Text('Export als CSV'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _importFile('json'),
              child: const Text('Import JSON'),
            ),
          ],
        ),
      ),
    );
  }
}
