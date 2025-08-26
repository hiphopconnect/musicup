// lib/widgets/oauth_setup_widget.dart

import 'package:flutter/material.dart';
import 'package:music_up/services/config_manager.dart';
import 'package:music_up/services/discogs_oauth_service.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:url_launcher/url_launcher.dart';

class OAuthSetupWidget extends StatefulWidget {
  final ConfigManager configManager;
  final VoidCallback? onOAuthChanged;

  const OAuthSetupWidget({
    super.key,
    required this.configManager,
    this.onOAuthChanged,
  });

  @override
  State<OAuthSetupWidget> createState() => _OAuthSetupWidgetState();
}

class _OAuthSetupWidgetState extends State<OAuthSetupWidget> {
  late TextEditingController _consumerKeyController;
  late TextEditingController _consumerSecretController;
  DiscogsOAuthService? _pendingOAuthService;

  @override
  void initState() {
    super.initState();
    _consumerKeyController = TextEditingController();
    _consumerSecretController = TextEditingController();
    _loadCredentials();
  }

  @override
  void dispose() {
    _consumerKeyController.dispose();
    _consumerSecretController.dispose();
    super.dispose();
  }

  void _loadCredentials() {
    final creds = widget.configManager.getDiscogsConsumerCredentials();
    _consumerKeyController.text = creds['consumer_key'] ?? '';
    _consumerSecretController.text = creds['consumer_secret'] ?? '';
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
    await widget.configManager.setDiscogsConsumerCredentials(
      consumerKey: key,
      consumerSecret: secret,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Consumer-Zugangsdaten gespeichert')),
    );
  }

  Future<void> _startOAuthFlow() async {
    final creds = widget.configManager.getDiscogsConsumerCredentials();
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
        _pendingOAuthService = service;
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konnte URL nicht öffnen: \$authUrl')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OAuth-Start fehlgeschlagen: \$e')),
      );
    }
  }

  Future<void> _completeOAuthFlow(String verifier) async {
    if (_pendingOAuthService == null) {
      final creds = widget.configManager.getDiscogsConsumerCredentials();
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

      await widget.configManager.setDiscogsOAuthTokens(
        oauthToken,
        oauthSecret,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OAuth erfolgreich abgeschlossen')),
      );
      setState(() {});
      widget.onOAuthChanged?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OAuth-Abschluss fehlgeschlagen: \$e')),
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
    await widget.configManager.clearDiscogsOAuthTokens();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OAuth-Tokens entfernt')),
    );
    setState(() {});
    widget.onOAuthChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final hasOAuth = widget.configManager.hasDiscogsOAuthTokens();

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
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saveConsumerCreds,
                icon: const Icon(Icons.save),
                label: const Text('Speichern'),
              ),
            ),
            const SizedBox(width: DS.sm),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _startOAuthFlow,
                icon: const Icon(Icons.shield),
                label: const Text('OAuth'),
              ),
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
}