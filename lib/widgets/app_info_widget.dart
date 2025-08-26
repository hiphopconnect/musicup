// lib/widgets/app_info_widget.dart

import 'package:flutter/material.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppInfoWidget extends StatefulWidget {
  const AppInfoWidget({super.key});

  @override
  State<AppInfoWidget> createState() => _AppInfoWidgetState();
}

class _AppInfoWidgetState extends State<AppInfoWidget> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
    if (mounted) setState(() {});
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
        _buildInfoRow('Lizenz', 'Proprietary Software'),
        const SizedBox(height: DS.sm),
        const Text(
          'MusicUp ist ein proprietäres Musik-Verwaltungstool für Linux und Android, entwickelt mit Flutter.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}