// lib/screens/settings_screen.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../services/json_service.dart';

class SettingsScreen extends StatefulWidget {
  final JsonService jsonService;

  const SettingsScreen({super.key, required this.jsonService});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController jsonPathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    jsonPathController.text =
        widget.jsonService.configManager.getJsonFilePath() ?? '';
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
          const SnackBar(content: Text('JSON-File saved!')),
        );

        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _exportFile(String fileType) async {
    if (Platform.isIOS || Platform.isAndroid) {
      // On mobile platforms, share the file
      String tempDir = (await getTemporaryDirectory()).path;
      String exportPath = '$tempDir/albums_export.$fileType';

      if (fileType == 'json') {
        await widget.jsonService.exportJson(exportPath);
      } else if (fileType == 'xml') {
        await widget.jsonService.exportXml(exportPath);
      } else if (fileType == 'csv') {
        await widget.jsonService.exportCsv(exportPath);
      }

      await Share.shareXFiles([XFile(exportPath)],
          text: 'Here is my album list');
    } else {
      // On desktop platforms, use file picker
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
          SnackBar(content: Text('$fileType-File exported: $filePath')),
        );
      }
    }
  }

  Future<void> _importFile(String fileType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [fileType],
    );

    if (result != null && result.files.isNotEmpty) {
      String? selectedPath = result.files.single.path;
      if (selectedPath != null) {
        try {
          if (fileType == 'json') {
            await widget.jsonService.importAlbums(selectedPath);
          } else if (fileType == 'csv') {
            await widget.jsonService.importCsv(selectedPath);
          } else if (fileType == 'xml') {
            await widget.jsonService.importXml(selectedPath);
          }

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$fileType-File imported: $selectedPath')),
          );

          // Pop back to MainScreen and signal that albums have been updated
          Navigator.pop(context, true);
        } catch (e) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Import failed: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String platformInfo = Platform.isIOS || Platform.isAndroid
        ? 'On mobile devices, the file is saved in the application directory.'
        : 'You can select the path on desktop devices.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(platformInfo),
            const SizedBox(height: 16),
            if (!Platform.isIOS && !Platform.isAndroid) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: jsonPathController,
                      decoration:
                          const InputDecoration(labelText: 'JSON-File path'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _pickJsonFile,
                    child: const Text('Select JSON-File'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            // Export Buttons in a row
            Wrap(
              spacing: 16.0, // space between buttons
              runSpacing: 8.0, // space between rows
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _exportFile('json'),
                  child: const Text('Export as JSON'),
                ),
                ElevatedButton(
                  onPressed: () => _exportFile('xml'),
                  child: const Text('Export as XML'),
                ),
                ElevatedButton(
                  onPressed: () => _exportFile('csv'),
                  child: const Text('Export as CSV'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Import Buttons in a row
            Wrap(
              spacing: 16.0, // space between buttons
              runSpacing: 8.0, // space between rows
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _importFile('json'),
                  child: const Text('Import JSON'),
                ),
                ElevatedButton(
                  onPressed: () => _importFile('xml'),
                  child: const Text('Import XML'),
                ),
                ElevatedButton(
                  onPressed: () => _importFile('csv'),
                  child: const Text('Import CSV'),
                ),
              ],
            ),
            const Spacer(),
            const Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Maintainer: Michael Milke (Nobo)'),
                  Text('Email: nobo_code@posteo.de'),
                  Text('GitHub: https://github.com/hiphopconnect/musicup/'),
                  Text('License: GPL-3.0'),
                  Text('Version: 1.0.0'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
