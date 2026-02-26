// lib/screens/setup_wizard_screen.dart

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/services/service_locator.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/oauth_setup_widget.dart';

class SetupWizardScreen extends StatefulWidget {
  final VoidCallback onSetupComplete;

  const SetupWizardScreen({super.key, required this.onSetupComplete});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 4;

  String _collectionPath = '';
  bool _discogsConfigured = false;

  @override
  void initState() {
    super.initState();
    _collectionPath = sl.configManager.getCollectionFilePath();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeSetup() async {
    await sl.configManager.setSetupCompleted();
    widget.onSetupComplete();
  }

  Future<void> _selectCollectionFile() async {
    final l10n = AppLocalizations.of(context);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: l10n.selectCollectionFile,
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        await sl.configManager.setCollectionFilePath(path);
        await sl.configManager.loadConfig();
        setState(() {
          _collectionPath = path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric('$e'))),
        );
      }
    }
  }

  Widget _buildWelcomePage() {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(DS.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_music,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: DS.xl),
          Text(
            l10n.welcomeTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DS.md),
          Text(
            l10n.welcomeBody,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DS.xl),
          FilledButton.icon(
            onPressed: _nextPage,
            icon: const Icon(Icons.arrow_forward),
            label: Text(l10n.letsGo),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: DS.xl,
                vertical: DS.md,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionPathPage() {
    final l10n = AppLocalizations.of(context);
    final isMobile = Platform.isAndroid || Platform.isIOS;

    return Padding(
      padding: const EdgeInsets.all(DS.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: DS.lg),
          Text(
            l10n.collectionFile,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DS.md),
          Text(
            isMobile
                ? l10n.collectionAutoSaved
                : l10n.collectionChooseLocation,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DS.lg),
          if (_collectionPath.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(DS.md),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: DS.sm),
                    Expanded(
                      child: Text(
                        _collectionPath,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!isMobile) ...[
            const SizedBox(height: DS.md),
            OutlinedButton.icon(
              onPressed: _selectCollectionFile,
              icon: const Icon(Icons.folder_open),
              label: Text(
                _collectionPath.isEmpty ? l10n.selectFile : l10n.selectOtherFile,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiscogsPage() {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(DS.xl),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.album,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: DS.lg),
            Text(
              l10n.discogsIntegration,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DS.md),
            Text(
              l10n.discogsOptionalBody,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DS.lg),
            if (_discogsConfigured)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(DS.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: DS.sm),
                      Text(l10n.discogsConnected),
                    ],
                  ),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(DS.md),
                  child: OAuthSetupWidget(
                    onOAuthChanged: () {
                      setState(() {
                        _discogsConfigured = sl.configManager.hasDiscogsOAuthTokens();
                      });
                    },
                  ),
                ),
              ),
            const SizedBox(height: DS.md),
            TextButton(
              onPressed: _nextPage,
              child: Text(l10n.setupLater),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletePage() {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(DS.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 100,
            color: Colors.green[600],
          ),
          const SizedBox(height: DS.xl),
          Text(
            l10n.allReady,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DS.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(DS.md),
              child: Column(
                children: [
                  _buildSummaryRow(
                    Icons.folder,
                    l10n.collection,
                    _collectionPath.isNotEmpty ? l10n.configured : l10n.standard,
                  ),
                  const Divider(),
                  _buildSummaryRow(
                    Icons.album,
                    l10n.discogs,
                    _discogsConfigured ? l10n.connected : l10n.notConfigured,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: DS.xl),
          FilledButton.icon(
            onPressed: _completeSetup,
            icon: const Icon(Icons.rocket_launch),
            label: Text(l10n.startApp),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: DS.xl,
                vertical: DS.md,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DS.xs),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: DS.sm),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalPages, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Navigation oben
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DS.md, vertical: DS.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_back),
                    )
                  else
                    const SizedBox(width: 48),
                  _buildStepIndicator(),
                  if (_currentPage < _totalPages - 1 && _currentPage > 0)
                    IconButton(
                      onPressed: _nextPage,
                      icon: const Icon(Icons.arrow_forward),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _buildWelcomePage(),
                  _buildCollectionPathPage(),
                  _buildDiscogsPage(),
                  _buildCompletePage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
