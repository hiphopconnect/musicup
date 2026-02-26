import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/services/logger_service.dart';
import 'package:music_up/theme/app_theme.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/app_layout.dart';
import 'package:music_up/widgets/section_card.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:music_up/screens/help_screen.dart';
import 'package:music_up/services/service_locator.dart';
import 'package:music_up/widgets/import_export_widget.dart';
import 'package:music_up/widgets/oauth_setup_widget.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;
  final Function(Locale)? onLocaleChanged;

  const SettingsScreen({
    super.key,
    this.onThemeChanged,
    this.onLocaleChanged,
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
  late Locale _currentLocale;
  String _appVersion = '';
  String _logInfo = '';
  late String _currentLogLevel;

  @override
  void initState() {
    super.initState();
    _collectionPathController = TextEditingController();
    _wantlistPathController = TextEditingController();
    _currentThemeMode = sl.configManager.getThemeMode();
    _currentLocale = sl.configManager.getLocale();
    _currentLogLevel = sl.configManager.getLogLevel();
    _loadSettings();
    _loadPackageInfo();
    _loadLogInfo();
  }

  @override
  void dispose() {
    _collectionPathController.dispose();
    _wantlistPathController.dispose();
    super.dispose();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = '${info.version}+${info.buildNumber}';
      });
    }
  }

  Future<void> _loadLogInfo() async {
    try {
      final size = await LoggerService.getCurrentLogSize();
      final files = LoggerService.getLogFiles();
      if (mounted) {
        String sizeStr;
        if (size > 1024 * 1024) {
          sizeStr = '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
        } else if (size > 1024) {
          sizeStr = '${(size / 1024).toStringAsFixed(1)} KB';
        } else {
          sizeStr = '$size Bytes';
        }
        setState(() {
          _logInfo = AppLocalizations.of(context).logFilesInfo(files.length, sizeStr);
        });
      }
    } catch (_) {
      // Ignore errors loading log info
    }
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final cm = sl.configManager;
      final collectionPath = cm.getCollectionFilePath();
      final wantlistPath = await cm.getWantlistFilePathOrDefault();
      setState(() {
        _collectionPathController.text = collectionPath;
        _wantlistPathController.text = wantlistPath;
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.error('Settings load', e, 'SettingsScreen');
      setState(() => _isLoading = false);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorLoadingSettings('$e'))),
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

        await sl.configManager.setCollectionFilePath(path);
        await sl.configManager.loadConfig();

        if (mounted) {
          setState(() {
            _collectionPathController.text = path;
            _dataChanged = true;
          });

          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.collectionPathUpdated)),
          );
        }
      }
    } catch (e) {
      LoggerService.error('Collection file select', e, 'SettingsScreen');
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorFileSelection('$e'))),
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
          _dataChanged = true;
        });
        await sl.configManager.setWantlistFilePath(path);

        if (!mounted) return;
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.wantlistPathUpdated)),
        );
      }
    } catch (e) {
      LoggerService.error('Wantlist file select', e, 'SettingsScreen');
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorFileSelection('$e'))),
      );
    }
  }

  Future<void> _resetSettings() async {
    final l10n = AppLocalizations.of(context);
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetSettings),
        content: Text(l10n.resetSettingsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.resetSettings),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await sl.configManager.resetConfig();
        await _loadSettings();

        _dataChanged = true;

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsReset)),
        );
      } catch (e) {
        LoggerService.error('Settings reset', e, 'SettingsScreen');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorResetting('$e'))),
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
    final l10n = AppLocalizations.of(context);
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
                  hintText: l10n.noFileSelected,
                  prefixIcon: Icon(icon),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            const SizedBox(width: DS.xs),
            ElevatedButton.icon(
              onPressed: onSelectFile,
              icon: const Icon(Icons.folder_open),
              label: Text(l10n.browse),
            ),
          ],
        ),
      ],
    );
  }

  String _logLevelLabel(String level) {
    final l10n = AppLocalizations.of(context);
    switch (level) {
      case 'debug':
        return l10n.logLevelDebug;
      case 'info':
        return l10n.logLevelInfo;
      case 'warning':
        return l10n.logLevelWarning;
      case 'error':
        return l10n.logLevelError;
      default:
        return level;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _onThemeModeChanged(ThemeMode? value) {
    if (value != null && value != _currentThemeMode) {
      setState(() => _currentThemeMode = value);
      sl.configManager.setThemeMode(value);
      widget.onThemeChanged?.call(value);
    }
  }

  void _onLocaleChanged(Locale? value) {
    if (value != null && value != _currentLocale) {
      setState(() => _currentLocale = value);
      sl.configManager.setLocale(value);
      widget.onLocaleChanged?.call(value);
    }
  }

  Widget _buildLanguageSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          RadioListTile<Locale>(
            title: const Text('Deutsch'),
            value: const Locale('de'),
            groupValue: _currentLocale,
            onChanged: _onLocaleChanged,
            secondary: const Icon(Icons.language),
          ),
          RadioListTile<Locale>(
            title: const Text('English'),
            value: const Locale('en'),
            groupValue: _currentLocale,
            onChanged: _onLocaleChanged,
            secondary: const Icon(Icons.language),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableThemeSection() {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeLight),
            subtitle: Text(l10n.themeLightDesc),
            value: ThemeMode.light,
            groupValue: _currentThemeMode,
            onChanged: _onThemeModeChanged,
            secondary: const Icon(Icons.light_mode),
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeDark),
            subtitle: Text(l10n.themeDarkDesc),
            value: ThemeMode.dark,
            groupValue: _currentThemeMode,
            onChanged: _onThemeModeChanged,
            secondary: const Icon(Icons.dark_mode),
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.themeSystem),
            subtitle: Text(l10n.themeSystemDesc),
            value: ThemeMode.system,
            groupValue: _currentThemeMode,
            onChanged: _onThemeModeChanged,
            secondary: const Icon(Icons.settings_suggest),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return AppLayout(
        title: l10n.settings,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pop(context, _dataChanged);
        }
      },
      child: AppLayout(
        title: l10n.settings,
        appBarColor: AppTheme.charcoal,
        actions: [
          IconButton(
            onPressed: _resetSettings,
            icon: const Icon(Icons.restore),
            tooltip: l10n.resetSettings,
          ),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(DS.md),
          child: Column(
            children: [
              SectionCard(
                title: l10n.filePaths,
                child: Column(
                  children: [
                    _buildFilePathField(
                      label: l10n.collectionJsonFile,
                      controller: _collectionPathController,
                      onSelectFile: _selectCollectionFile,
                      icon: Icons.library_music,
                    ),
                    const SizedBox(height: DS.md),
                    _buildFilePathField(
                      label: l10n.wantlistJsonFile,
                      controller: _wantlistPathController,
                      onSelectFile: _selectWantlistFile,
                      icon: Icons.favorite,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: DS.lg),

              SectionCard(
                title: l10n.discogsIntegration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OAuthSetupWidget(),
                  ],
                ),
              ),

              const SizedBox(height: DS.lg),

              SectionCard(
                title: l10n.importExport,
                child: const ImportExportWidget(),
              ),

              const SizedBox(height: DS.lg),

              _buildSectionTitle(l10n.appearance),
              _buildExpandableThemeSection(),

              const SizedBox(height: 16),

              _buildSectionTitle(l10n.language),
              _buildLanguageSection(),

              const SizedBox(height: 16),

              _buildSectionTitle(l10n.advanced),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.tune),
                  title: Text(l10n.logLevel),
                  subtitle: Text(_logLevelLabel(_currentLogLevel)),
                  trailing: DropdownButton<String>(
                    value: _currentLogLevel,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'debug', child: Text('Debug')),
                      DropdownMenuItem(value: 'info', child: Text('Info')),
                      DropdownMenuItem(value: 'warning', child: Text('Warning')),
                      DropdownMenuItem(value: 'error', child: Text('Error')),
                    ],
                    onChanged: (value) async {
                      if (value != null) {
                        setState(() => _currentLogLevel = value);
                        await sl.configManager.setLogLevel(value);
                        LoggerService.setMinLevel(LoggerService.parseLogLevel(value));
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _buildSectionTitle(l10n.aboutMusicUp),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: Text(l10n.help),
                      subtitle: Text(l10n.helpSubtitle),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpScreen(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.tour),
                      title: Text(l10n.startTour),
                      subtitle: Text(l10n.startTourSubtitle),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        await sl.configManager.resetTourCompleted();
                        if (context.mounted) {
                          Navigator.pop(context, 'startTour');
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: Text(l10n.version),
                      subtitle: Text(_appVersion.isEmpty ? '...' : _appVersion),
                    ),
                    ListTile(
                      leading: const Icon(Icons.gavel),
                      title: Text(l10n.license),
                      subtitle: Text(l10n.proprietarySoftware),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(l10n.developer),
                      subtitle: const Text('Michael Milke (Nobo)'),
                      onTap: () async {
                        final Uri url =
                            Uri.parse('https://github.com/hiphopconnect');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: Text(l10n.contact),
                      subtitle: const Text('nobo_code@posteo.de'),
                      onTap: () async {
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: 'nobo_code@posteo.de',
                        );
                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(emailUri);
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.bug_report),
                      title: Text(l10n.reportProblem),
                      subtitle: Text(l10n.reportProblemSubtitle),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: 'nobo_code@posteo.de',
                          query:
                              'subject=MusicUp Support&body=Problem beschreibung:\n\n',
                        );
                        if (await canLaunchUrl(emailUri)) {
                          await launchUrl(emailUri);
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: Text(l10n.sendLogs),
                      subtitle: Text(_logInfo.isEmpty ? l10n.sendLogsDefault : _logInfo),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        await LoggerService.shareLogs(context);
                        _loadLogInfo();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.code),
                      title: Text(l10n.repository),
                      subtitle: const Text('github.com/hiphopconnect/musicup'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        final Uri url = Uri.parse(
                            'https://github.com/hiphopconnect/musicup');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                    ),
                  ],
                ),
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
