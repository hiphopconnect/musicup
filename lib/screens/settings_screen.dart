import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/json_service.dart';

class SettingsScreen extends StatefulWidget {
  final JsonService jsonService;

  SettingsScreen({required this.jsonService});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController jsonPathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    jsonPathController.text = widget.jsonService.configManager.getJsonPath() ?? '';
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
          await widget.jsonService.importAlbums(selectedPath);  // Import-Methode aufrufen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$fileType file imported: $selectedPath')),
          );
        } catch (e) {
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
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Path input and Save Path button in a row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: jsonPathController,
                    decoration: InputDecoration(labelText: 'JSON File Path'),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    widget.jsonService.configManager.setJsonPath(jsonPathController.text);
                    widget.jsonService.configManager.saveConfig();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('JSON path saved!')),
                    );
                  },
                  child: Text('Save Path'),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Export buttons in a horizontal row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _exportFile('json'),
                  child: Text('Export as JSON'),
                ),
                ElevatedButton(
                  onPressed: () => _exportFile('xml'),
                  child: Text('Export as XML'),
                ),
                ElevatedButton(
                  onPressed: () => _exportFile('csv'),
                  child: Text('Export as CSV'),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Import buttons in a horizontal row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _importFile('json'),
                  child: Text('Import JSON'),
                ),
                ElevatedButton(
                  onPressed: () => _importFile('xml'),
                  child: Text('Import XML'),
                ),
                ElevatedButton(
                  onPressed: () => _importFile('csv'),
                  child: Text('Import CSV'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
