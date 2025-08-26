import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/app_layout.dart';
import 'package:music_up/widgets/section_card.dart';

import '../services/json_service.dart';
import '../widgets/app_info_widget.dart';
import '../widgets/import_export_widget.dart';
import '../widgets/oauth_setup_widget.dart';

class SettingsScreen extends StatefulWidget {
  final JsonService jsonService;
  final Function(ThemeMode)? onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.jsonService,
    this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _collectionPathController;
  late TextEditingController _wantlistPathController;

  bool _isLoading = true;
  bool _dataChanged = false;
  ThemeMode _currentThemeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _collectionPathController = TextEditingController();
    _wantlistPathController = TextEditingController();
    _currentThemeMode = widget.jsonService.configManager.getThemeMode();
    _loadSettings();
  }

  @override
  void dispose() {
    _collectionPathController.dispose();
    _wantlistPathController.dispose();
    super.dispose();
  }


  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final cm = widget.jsonService.configManager;
      final collectionPath = cm.getCollectionFilePath();
      final wantlistPath = await cm.getWantlistFilePathOrDefault();
      setState(() {
        _collectionPathController.text = collectionPath;
        _wantlistPathController.text = wantlistPath;
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

        // WICHTIG: Erst ConfigManager aktualisieren
        await widget.jsonService.configManager.setCollectionFilePath(path);

        // DANN die Konfiguration neu laden
        await widget.jsonService.configManager.loadConfig();

        // ERST DANACH setState
        if (mounted) {
          setState(() {
            _collectionPathController.text = path;
            _dataChanged = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Collection path updated!')),
          );
        }
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
          _dataChanged = true; // auch hier setzen, falls gewünscht
        });
        await widget.jsonService.configManager.setWantlistFilePath(path);

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

        _dataChanged = true;

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
        const SizedBox(height: DS.xs),
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
            const SizedBox(width: DS.xs),
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


  Widget _buildExpandableThemeSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: DS.sm),
      child: ExpansionTile(
        title: const Text(
          'App-Design',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: const Icon(Icons.palette, color: Color(0xFF2E4F2E)),
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('Hell'),
            subtitle: const Text('Immer helles Design'),
            value: ThemeMode.light,
            groupValue: _currentThemeMode,
            onChanged: (ThemeMode? value) {
              if (value != null && value != _currentThemeMode) {
                setState(() {
                  _currentThemeMode = value;
                });
                widget.jsonService.configManager.setThemeMode(value);
                widget.onThemeChanged?.call(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dunkel'),
            subtitle: const Text('Immer dunkles Design'),
            value: ThemeMode.dark,
            groupValue: _currentThemeMode,
            onChanged: (ThemeMode? value) {
              if (value != null && value != _currentThemeMode) {
                setState(() {
                  _currentThemeMode = value;
                });
                widget.jsonService.configManager.setThemeMode(value);
                widget.onThemeChanged?.call(value);
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('System'),
            subtitle: const Text('Folgt den Systemeinstellungen'),
            value: ThemeMode.system,
            groupValue: _currentThemeMode,
            onChanged: (ThemeMode? value) {
              if (value != null && value != _currentThemeMode) {
                setState(() {
                  _currentThemeMode = value;
                });
                widget.jsonService.configManager.setThemeMode(value);
                widget.onThemeChanged?.call(value);
              }
            },
          ),
          const SizedBox(height: DS.sm),
        ],
      ),
    );
  }

  Widget _buildThemeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'App-Design',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: DS.xs),
        Card(
          child: Column(
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Hell'),
                subtitle: const Text('Immer helles Design'),
                value: ThemeMode.light,
                groupValue: _currentThemeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null && value != _currentThemeMode) {
                    // Schutz vor doppelten Updates
                    setState(() {
                      _currentThemeMode = value;
                    });
                    widget.jsonService.configManager.setThemeMode(value);
                    widget.onThemeChanged?.call(value);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dunkel'),
                subtitle: const Text('Immer dunkles Design'),
                value: ThemeMode.dark,
                groupValue: _currentThemeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null && value != _currentThemeMode) {
                    // Schutz vor doppelten Updates
                    setState(() {
                      _currentThemeMode = value;
                    });
                    widget.jsonService.configManager.setThemeMode(value);
                    widget.onThemeChanged?.call(value);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System'),
                subtitle: const Text('Folgt den Systemeinstellungen'),
                value: ThemeMode.system,
                groupValue: _currentThemeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null && value != _currentThemeMode) {
                    // Schutz vor doppelten Updates
                    setState(() {
                      _currentThemeMode = value;
                    });
                    widget.jsonService.configManager.setThemeMode(value);
                    widget.onThemeChanged?.call(value);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppLayout(
        title: 'Einstellungen',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pop(context, _dataChanged);
        }
      },
      child: AppLayout(
        title: 'Einstellungen',
        appBarColor: const Color(0xFF2C2C2C), // Charcoal
        actions: [
          IconButton(
            onPressed: _resetSettings,
            icon: const Icon(Icons.restore),
            tooltip: 'Einstellungen zurücksetzen',
          ),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(DS.md),
          child: Column(
            children: [
              // Dateipfade Sektion
              SectionCard(
                title: 'Dateipfade',
                child: Column(
                  children: [
                    _buildFilePathField(
                      label: 'Collection JSON-Datei',
                      controller: _collectionPathController,
                      onSelectFile: _selectCollectionFile,
                      icon: Icons.library_music,
                    ),
                    const SizedBox(height: DS.md),
                    _buildFilePathField(
                      label: 'Wantlist JSON-Datei',
                      controller: _wantlistPathController,
                      onSelectFile: _selectWantlistFile,
                      icon: Icons.favorite,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DS.lg),

              // Discogs Integration Sektion
              SectionCard(
                title: 'Discogs Integration',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OAuthSetupWidget(
                      configManager: widget.jsonService.configManager,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DS.lg),

              // Import/Export Sektion
              SectionCard(
                title: 'Import/Export',
                child: ImportExportWidget(
                  jsonService: widget.jsonService,
                ),
              ),

              const SizedBox(height: DS.lg),

              // Design-Sektion (Ausklappbar)
              _buildExpandableThemeSection(),

              const SizedBox(height: DS.lg),

              // App-Informationen Sektion
              SectionCard(
                title: 'Über MusicUp',
                child: const AppInfoWidget(),
              ),

              const SizedBox(height: DS.lg),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
