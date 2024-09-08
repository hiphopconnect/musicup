import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
    jsonPathController.text = widget.jsonService.configManager.getJsonPath() ?? '';
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],  // Hier kannst du die erlaubten Dateitypen festlegen
    );

    if (result != null && result.files.single.path != null) {
      String? selectedPath = result.files.single.path;
      if (selectedPath != null) {
        setState(() {
          jsonPathController.text = selectedPath;
        });
        await widget.jsonService.configManager.setJsonPath(selectedPath);
        await widget.jsonService.configManager.saveConfig();

        // Check if the widget is still mounted before accessing the context
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('JSON path saved!')),
        );

        Navigator.pop(context, true);  // Zurück zum MainScreen, um die Alben neu zu laden
      }
    }
  }

  Future<void> _exportFile(String fileType) async {
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

      // Check if the widget is still mounted before accessing the context
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$fileType file exported: $filePath')),
      );
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
          await widget.jsonService.importAlbums(selectedPath);

          // Check if the widget is still mounted before accessing the context
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$fileType file imported: $selectedPath')),
          );
        } catch (e) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to import: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: jsonPathController,
                    decoration: const InputDecoration(labelText: 'JSON File Path'),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _pickFile,
                  child: const Text('Select File'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          ],
        ),
      ),
    );
  }
}
