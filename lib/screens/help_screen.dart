import 'package:flutter/material.dart';
import 'package:music_up/help/help_content.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/theme/app_theme.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:music_up/widgets/app_layout.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = info.version;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppLayout(
      title: l10n.help,
      appBarColor: AppTheme.charcoal,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DS.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DS.md,
                vertical: DS.sm,
              ),
              child: Text(
                '${HelpContent.appName} $_version',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DS.md),
              child: Text(
                HelpContent.shortDescription(l10n),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: DS.lg),
            ...HelpContent.sections(l10n).map(_buildSection),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(HelpSection section) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: DS.md, vertical: DS.xxs),
      child: ExpansionTile(
        title: Text(
          section.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(DS.md, 0, DS.md, DS.md),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            section.body,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
