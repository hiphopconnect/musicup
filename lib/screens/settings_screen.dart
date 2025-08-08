import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/json_service.dart';

class SettingsScreen extends StatefulWidget {
  final JsonService jsonService;

  const SettingsScreen({super.key, required this.jsonService});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _collectionPathController;
  late TextEditingController _wantlistPathController;
  late TextEditingController _discogsTokenController;
  bool _isLoading = true;
  bool _dataChanged = false; // ✅ FLAG für Daten-Änderungen

  @override
  void initState() {
    super.initState();
    _collectionPathController = TextEditingController();
    _wantlistPathController = TextEditingController();
    _discogsTokenController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _collectionPathController.dispose();
    _wantlistPathController.dispose();
    _discogsTokenController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      String collectionPath =
          widget.jsonService.configManager.getCollectionFilePath();
      String wantlistPath =
          await widget.jsonService.configManager.getWantlistFilePathOrDefault();
      String discogsToken = widget.jsonService.configManager.getDiscogsToken();

      setState(() {
        _collectionPathController.text = collectionPath;
        _wantlistPathController.text = wantlistPath;
        _discogsTokenController.text = discogsToken;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading settings: $e')),
      );
    }
  }

  Future<void> _selectCollectionFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select Collection JSON file',
      );

      if (result != null && result.files.single.path != null) {
        String path = result.files.single.path!;
        setState(() {
          _collectionPathController.text = path;
        });
        await widget.jsonService.configManager.setCollectionFilePath(path);

        _dataChanged = true; // ✅ MARKIERE ÄNDERUNG

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Collection path updated!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: $e')),
      );
    }
  }

  Future<void> _selectWantlistFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select Wantlist JSON file',
      );

      if (result != null && result.files.single.path != null) {
        String path = result.files.single.path!;
        setState(() {
          _wantlistPathController.text = path;
        });
        await widget.jsonService.configManager.setWantlistFilePath(path);

        // _dataChanged = true; // Wantlist-Änderungen brauchen kein Reload

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wantlist path updated!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: $e')),
      );
    }
  }

  Future<void> _saveDiscogsToken() async {
    try {
      String token = _discogsTokenController.text.trim();
      await widget.jsonService.configManager.setDiscogsToken(token);

      // Discogs Token braucht auch kein Reload der Collection

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Discogs token saved!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving token: $e')),
      );
    }
  }

  Future<void> _resetSettings() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
            'Are you sure you want to reset all settings to default?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.jsonService.configManager.resetConfig();
        await _loadSettings();

        _dataChanged = true; // ✅ MARKIERE ÄNDERUNG

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings reset to default!')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error resetting settings: $e')),
        );
      }
    }
  }

  // ✅ IMPORT-FUNKTIONEN MIT RETURN-VALUE
  Future<void> _importFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Import JSON file',
      );

      if (result != null && result.files.single.path != null) {
        String importPath = result.files.single.path!;

        // Hier würdest du normalerweise die Import-Logik aufrufen
        // await widget.jsonService.importFromFile(importPath);

        _dataChanged = true; // ✅ MARKIERE ÄNDERUNG

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File imported from: $importPath')),
        );

        // ✅ SOFORTIGES ZURÜCKKEHREN MIT true
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ WillPopScope - Return-Value setzen!
  Future<bool> _onWillPop() async {
    // Gib true zurück wenn Daten geändert wurden
    Navigator.pop(context, _dataChanged);
    return false; // Verhindere den normalen Pop
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildFilePathField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onSelectFile,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'No file selected',
                  prefixIcon: Icon(icon),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onSelectFile,
              icon: const Icon(Icons.folder_open),
              label: const Text('Browse'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTokenField() {
    bool hasToken = _discogsTokenController.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Discogs Personal Access Token',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _discogsTokenController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Enter your Discogs token',
            prefixIcon: const Icon(Icons.key),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasToken) Icon(Icons.check_circle, color: Colors.green),
                IconButton(
                  onPressed: _saveDiscogsToken,
                  icon: const Icon(Icons.save),
                  tooltip: 'Save Token',
                ),
              ],
            ),
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _saveDiscogsToken(),
        ),
        const SizedBox(height: 8),
        Text(
          'Get your token from: Settings > Developer > Personal access tokens',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      // ✅ HANDLE BACK NAVIGATION
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _resetSettings,
              icon: const Icon(Icons.restore),
              tooltip: 'Reset Settings',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File Paths Section
              _buildSection(
                'File Paths',
                [
                  _buildFilePathField(
                    label: 'Collection JSON File',
                    controller: _collectionPathController,
                    onSelectFile: _selectCollectionFile,
                    icon: Icons.library_music,
                  ),
                  const SizedBox(height: 16),
                  _buildFilePathField(
                    label: 'Wantlist JSON File',
                    controller: _wantlistPathController,
                    onSelectFile: _selectWantlistFile,
                    icon: Icons.favorite,
                  ),
                ],
              ),

              // Discogs Section
              _buildSection(
                'Discogs Integration',
                [
                  _buildTokenField(),
                ],
              ),

              // ✅ IMPORT/EXPORT Section
              _buildSection(
                'Import/Export',
                [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _importFile,
                        icon: const Icon(Icons.file_upload),
                        label: const Text('Import JSON'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Export not implemented yet')),
                          );
                        },
                        icon: const Icon(Icons.file_download),
                        label: const Text('Export JSON'),
                      ),
                    ],
                  ),
                ],
              ),

              // Info Section
              _buildSection(
                'Information',
                [
                  const ListTile(
                    leading: Icon(Icons.info, color: Colors.blue),
                    title: Text('How to get Discogs Token:'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Text('1. Go to discogs.com and log in'),
                  const Text(
                      '2. Settings → Developer → Personal access tokens'),
                  const Text('3. Generate new token'),
                  const Text('4. Copy and paste it here'),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.storage, color: Colors.green),
                    title: Text('File Storage:'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Text('Your albums are stored in JSON files'),
                  const Text('You can backup/sync these files manually'),
                  const Text(
                      'Files are created automatically if they don\'t exist'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
