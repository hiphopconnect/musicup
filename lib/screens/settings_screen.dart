import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:music_up/services/import_export_service.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/app_layout.dart';
import 'package:music_up/widgets/section_card.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/discogs_oauth_service.dart';
import '../services/json_service.dart';

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

  // Consumer Key/Secret
  late TextEditingController _consumerKeyController;
  late TextEditingController _consumerSecretController;
  late ImportExportService _importExportService;
  bool _isLoading = true;
  bool _dataChanged = false;
  ThemeMode _currentThemeMode = ThemeMode.system;
  PackageInfo? _packageInfo;

  // Pending OAuth Service im State
  DiscogsOAuthService? _pendingOAuthService;

  @override
  void initState() {
    super.initState();
    _collectionPathController = TextEditingController();
    _wantlistPathController = TextEditingController();
    _consumerKeyController = TextEditingController();
    _consumerSecretController = TextEditingController();
    _importExportService = ImportExportService(widget.jsonService);
    _currentThemeMode = widget.jsonService.configManager.getThemeMode();
    _loadSettings();
    _loadPackageInfo();
  }

  @override
  void dispose() {
    _collectionPathController.dispose();
    _wantlistPathController.dispose();
    _consumerKeyController.dispose();
    _consumerSecretController.dispose();
    super.dispose();
  }

  Future<void> _loadPackageInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
    if (mounted) setState(() {});
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final cm = widget.jsonService.configManager;
      final collectionPath = cm.getCollectionFilePath();
      final wantlistPath = await cm.getWantlistFilePathOrDefault();
      final creds = cm.getDiscogsConsumerCredentials();

      setState(() {
        _collectionPathController.text = collectionPath;
        _wantlistPathController.text = wantlistPath;
        _consumerKeyController.text = creds['consumer_key'] ?? '';
        _consumerSecretController.text = creds['consumer_secret'] ?? '';
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

        // ✅ WICHTIG: Erst ConfigManager aktualisieren
        await widget.jsonService.configManager.setCollectionFilePath(path);

        // ✅ DANN die Konfiguration neu laden
        await widget.jsonService.configManager.loadConfig();

        // ✅ ERST DANACH setState
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
          _dataChanged = true; // ✅ auch hier setzen, falls gewünscht
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

        _dataChanged = true;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${albums.length} Alben importiert'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Import fehlgeschlagen: $e'),
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
              content: Text('⚠️ Keine Alben zum Exportieren vorhanden'),
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
                Text('✅ ${albums.length} Alben exportiert nach\n$filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Export fehlgeschlagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onWillPop(bool didPop) {
    if (!didPop) {
      // ✅ Wichtige Änderung: nur wenn Pop noch nicht stattgefunden hat
      Navigator.pop(context, _dataChanged);
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
                    // ✅ Schutz vor doppelten Updates
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
                    // ✅ Schutz vor doppelten Updates
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
                    // ✅ Schutz vor doppelten Updates
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

  Widget _buildAppInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info, color: Theme.of(context).primaryColor),
            const SizedBox(width: DS.xs),
            const Text(
              'App-Informationen',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: DS.sm),
        if (_packageInfo != null) ...[
          _buildInfoRow('Version',
              '${_packageInfo!.version}+${_packageInfo!.buildNumber}'),
          _buildInfoRow('App Name', _packageInfo!.appName),
          _buildInfoRow('Package', _packageInfo!.packageName),
        ],
        const SizedBox(height: DS.sm),
        _buildInfoRow('Maintainer', 'Michael Milke (Nobo)'),
        _buildInfoRow('Email', 'nobo_code@posteo.de'),
        _buildInfoRow('Repository', 'github.com/hiphopconnect/musicup'),
        _buildInfoRow('Lizenz', 'Open Source'),
        const SizedBox(height: DS.sm),
        const Text(
          'MusicUp ist ein Open-Source Musik-Verwaltungstool für Linux, entwickelt mit Flutter.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
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
        appBarColor: Colors.blue,
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

              // Theme-Sektion
              SectionCard(
                title: 'Design',
                child: _buildThemeSection(),
              ),

              const SizedBox(height: DS.lg),

              // Discogs Integration Sektion
              SectionCard(
                title: 'Discogs Integration',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOAuthSection(), // NEU
                  ],
                ),
              ),

              const SizedBox(height: DS.lg),

              // Import/Export Sektion
              SectionCard(
                title: 'Import/Export',
                child: Column(
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
                ),
              ),

              const SizedBox(height: DS.lg),

              // App-Informationen Sektion
              SectionCard(
                title: 'Über MusicUp',
                child: _buildAppInfoSection(),
              ),

              const SizedBox(height: DS.lg),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // NEU: UI für OAuth-Setup inkl. Consumer Key/Secret (jetzt innerhalb der Klasse)
  Widget _buildOAuthSection() {
    final hasOAuth = widget.jsonService.configManager.hasDiscogsOAuthTokens();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Discogs OAuth (für Schreibzugriff)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: DS.xs),
        TextField(
          controller: _consumerKeyController,
          decoration: const InputDecoration(
            labelText: 'Consumer Key',
            prefixIcon: Icon(Icons.vpn_key),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: DS.sm),
        TextField(
          controller: _consumerSecretController,
          decoration: const InputDecoration(
            labelText: 'Consumer Secret',
            prefixIcon: Icon(Icons.lock),
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        const SizedBox(height: DS.sm),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _saveConsumerCreds,
              icon: const Icon(Icons.save),
              label: const Text('Zugangsdaten speichern'),
            ),
            const SizedBox(width: DS.sm),
            ElevatedButton.icon(
              onPressed: _startOAuthFlow,
              icon: const Icon(Icons.shield),
              label: const Text('OAuth starten'),
            ),
          ],
        ),
        const SizedBox(height: DS.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Verifier-Code (nach Autorisierung)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.check),
                ),
                onSubmitted: (v) => _completeOAuthFlow(v.trim()),
              ),
            ),
            const SizedBox(width: DS.xs),
            ElevatedButton(
              onPressed: () async {
                final verifier = await _askVerifierDialog();
                if (verifier != null && verifier.isNotEmpty) {
                  await _completeOAuthFlow(verifier.trim());
                }
              },
              child: const Text('Verifier eingeben'),
            ),
          ],
        ),
        const SizedBox(height: DS.sm),
        if (hasOAuth)
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              const Text('OAuth konfiguriert'),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _clearOAuthTokens,
                icon: const Icon(Icons.delete_outline),
                label: const Text('OAuth entfernen'),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _saveConsumerCreds() async {
    final key = _consumerKeyController.text.trim();
    final secret = _consumerSecretController.text.trim();
    if (key.isEmpty || secret.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Consumer Key und Secret eingeben')),
      );
      return;
    }
    await widget.jsonService.configManager.setDiscogsConsumerCredentials(
      consumerKey: key,
      consumerSecret: secret,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Consumer-Zugangsdaten gespeichert')),
    );
  }

  Future<void> _startOAuthFlow() async {
    final creds =
        widget.jsonService.configManager.getDiscogsConsumerCredentials();
    final key = creds['consumer_key'] ?? '';
    final secret = creds['consumer_secret'] ?? '';
    if (key.isEmpty || secret.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bitte zuerst Consumer Key/Secret speichern')),
      );
      return;
    }
    try {
      final service =
          DiscogsOAuthService(consumerKey: key, consumerSecret: secret);
      final authUrl = await service.getRequestToken();
      final uri = Uri.parse(authUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Browser geöffnet. Nach Autorisierung Verifier eingeben.'),
          ),
        );
        _pendingOAuthService = service; // im State merken
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konnte URL nicht öffnen: $authUrl')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OAuth-Start fehlgeschlagen: $e')),
      );
    }
  }

  Future<void> _completeOAuthFlow(String verifier) async {
    if (_pendingOAuthService == null) {
      final creds =
          widget.jsonService.configManager.getDiscogsConsumerCredentials();
      final key = creds['consumer_key'] ?? '';
      final secret = creds['consumer_secret'] ?? '';
      if (key.isEmpty || secret.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Bitte zuerst Consumer Key/Secret speichern')),
        );
        return;
      }
      _pendingOAuthService =
          DiscogsOAuthService(consumerKey: key, consumerSecret: secret);
      try {
        await _pendingOAuthService!.getRequestToken();
      } catch (_) {
        // ignorieren
      }
    }

    try {
      // Korrekte Methode mit Verifier
      final tokenMap = await _pendingOAuthService!.getAccessToken(verifier);

      final oauthToken = tokenMap['oauth_token'] ?? '';
      final oauthSecret = tokenMap['oauth_token_secret'] ?? '';
      if (oauthToken.isEmpty || oauthSecret.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ungültige Access-Token-Antwort erhalten'),
          ),
        );
        return;
      }

      await widget.jsonService.configManager.setDiscogsOAuthTokens(
        oauthToken,
        oauthSecret,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ OAuth erfolgreich abgeschlossen')),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OAuth-Abschluss fehlgeschlagen: $e')),
      );
    }
  }

  Future<String?> _askVerifierDialog() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verifier-Code eingeben'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'Verifier',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Abbrechen')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('OK')),
        ],
      ),
    );
    ctrl.dispose();
    return result;
  }

  Future<void> _clearOAuthTokens() async {
    await widget.jsonService.configManager.clearDiscogsOAuthTokens();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OAuth-Tokens entfernt')),
    );
    setState(() {});
  }
}
