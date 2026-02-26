// lib/widgets/oauth_setup_widget.dart

import 'package:flutter/material.dart';
import 'package:music_up/l10n/app_localizations.dart';
import 'package:music_up/services/discogs_oauth_service.dart';
import 'package:music_up/services/service_locator.dart';
import 'package:music_up/theme/design_system.dart';
import 'package:url_launcher/url_launcher.dart';

class OAuthSetupWidget extends StatefulWidget {
  final VoidCallback? onOAuthChanged;

  const OAuthSetupWidget({
    super.key,
    this.onOAuthChanged,
  });

  @override
  State<OAuthSetupWidget> createState() => _OAuthSetupWidgetState();
}

class _OAuthSetupWidgetState extends State<OAuthSetupWidget> {
  late TextEditingController _consumerKeyController;
  late TextEditingController _consumerSecretController;
  late TextEditingController _verifierController;
  DiscogsOAuthService? _pendingOAuthService;
  bool _isProcessing = false;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _consumerKeyController = TextEditingController();
    _consumerSecretController = TextEditingController();
    _verifierController = TextEditingController();
    _loadCredentials();
  }

  @override
  void dispose() {
    _consumerKeyController.dispose();
    _consumerSecretController.dispose();
    _verifierController.dispose();
    super.dispose();
  }

  void _loadCredentials() {
    final creds = sl.configManager.getDiscogsConsumerCredentials();
    _consumerKeyController.text = creds['consumer_key'] ?? '';
    _consumerSecretController.text = creds['consumer_secret'] ?? '';
  }

  Future<void> _saveConsumerCreds() async {
    final l10n = AppLocalizations.of(context);
    final key = _consumerKeyController.text.trim();
    final secret = _consumerSecretController.text.trim();
    if (key.isEmpty || secret.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterConsumerKeySecret)),
      );
      return;
    }
    await sl.configManager.setDiscogsConsumerCredentials(
      consumerKey: key,
      consumerSecret: secret,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.consumerCredentialsSaved)),
    );
  }

  Future<void> _startOAuthFlow() async {
    final l10n = AppLocalizations.of(context);
    final creds = sl.configManager.getDiscogsConsumerCredentials();
    final key = creds['consumer_key'] ?? '';
    final secret = creds['consumer_secret'] ?? '';
    if (key.isEmpty || secret.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseFirstSaveConsumerKey)),
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
          SnackBar(
            content: Text(l10n.browserOpenedVerifier),
          ),
        );
        _pendingOAuthService = service;
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.couldNotOpenUrl(authUrl))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final message = _networkErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _submitVerifier() async {
    final l10n = AppLocalizations.of(context);
    final verifier = _verifierController.text.trim();
    if (verifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseEnterVerifierCode)),
      );
      return;
    }
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      await _completeOAuthFlow(verifier);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _completeOAuthFlow(String verifier) async {
    final l10n = AppLocalizations.of(context);
    if (_pendingOAuthService == null) {
      final creds = sl.configManager.getDiscogsConsumerCredentials();
      final key = creds['consumer_key'] ?? '';
      final secret = creds['consumer_secret'] ?? '';
      if (key.isEmpty || secret.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.pleaseFirstSaveConsumerKey)),
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
          SnackBar(
            content: Text(l10n.invalidAccessTokenResponse),
          ),
        );
        return;
      }

      await sl.configManager.setDiscogsOAuthTokens(
        oauthToken,
        oauthSecret,
      );

      _pendingOAuthService = null;

      if (!mounted) return;
      _verifierController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.oauthCompleted)),
      );
      setState(() {});
      widget.onOAuthChanged?.call();
    } catch (e) {
      if (!mounted) return;
      final message = _networkErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  String _networkErrorMessage(Object error) {
    final l10n = AppLocalizations.of(context);
    final msg = error.toString();
    if (msg.contains('Failed host lookup') ||
        msg.contains('No address associated with hostname')) {
      return l10n.noInternetConnection;
    }
    if (msg.contains('SocketException') ||
        msg.contains('Connection refused') ||
        msg.contains('Connection timed out')) {
      return l10n.connectionToDiscogsFailed;
    }
    return l10n.oauthFailed(msg);
  }

  Future<void> _testConnection() async {
    if (_isTesting || _isProcessing) return;
    setState(() => _isTesting = true);
    try {
      final result = await sl.discogsService.testAuthentication();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result
                ? l10n.discogsConnectionSuccessful
                : l10n.discogsConnectionFailed,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.discogsConnectionFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _isTesting = false);
      }
    }
  }

  Future<void> _clearOAuthTokens() async {
    await sl.configManager.clearDiscogsOAuthTokens();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.oauthTokensRemoved)),
    );
    setState(() {});
    widget.onOAuthChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasOAuth = sl.configManager.hasDiscogsOAuthTokens();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.discogsOAuthWriteAccess,
          style: const TextStyle(fontWeight: FontWeight.bold),
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
                label: Text(l10n.save),
              ),
            ),
            const SizedBox(width: DS.sm),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _startOAuthFlow,
                icon: const Icon(Icons.shield),
                label: Text(l10n.oauth),
              ),
            ),
          ],
        ),
        const SizedBox(height: DS.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _verifierController,
                decoration: InputDecoration(
                  labelText: l10n.verifierCodeLabel,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.check),
                ),
                onSubmitted: (_) => _submitVerifier(),
              ),
            ),
            const SizedBox(width: DS.xs),
            ElevatedButton(
              onPressed: _isProcessing ? null : _submitVerifier,
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.confirm),
            ),
          ],
        ),
        const SizedBox(height: DS.sm),
        if (hasOAuth)
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              Text(l10n.oauthConfigured),
              OutlinedButton.icon(
                onPressed: _clearOAuthTokens,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.removeOAuth),
              ),
              OutlinedButton.icon(
                onPressed: (_isTesting || _isProcessing)
                    ? null
                    : _testConnection,
                icon: _isTesting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi),
                label: Text(l10n.testConnection),
              ),
            ],
          ),
      ],
    );
  }
}
