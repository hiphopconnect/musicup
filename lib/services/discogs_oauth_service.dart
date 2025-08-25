// lib/services/discogs_oauth_service.dart

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DiscogsOAuthService {
  // RUNTIME-KONFIGURIERBAR (statt statisch)
  final String consumerKey;
  final String consumerSecret;

  static const String _baseUrl = 'https://api.discogs.com';
  static const String _userAgent =
      'MusicUp/1.3.1 +https://github.com/hiphopconnect/musicup';

  String? _requestToken;
  String? _requestTokenSecret;
  String? _accessToken;
  String? _accessTokenSecret;

  DiscogsOAuthService({
    required this.consumerKey,
    required this.consumerSecret,
  });

  // OAuth 1.0a Schritt 1: Request Token anfordern
  Future<String> getRequestToken() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final nonce = _generateNonce();

    final parameters = {
      'oauth_consumer_key': consumerKey,
      'oauth_nonce': nonce,
      'oauth_signature_method': 'HMAC-SHA1',
      'oauth_timestamp': timestamp.toString(),
      'oauth_version': '1.0',
    };

    final signature = _generateSignature(
      'POST',
      '$_baseUrl/oauth/request_token',
      parameters,
      consumerSecret,
      '',
    );
    parameters['oauth_signature'] = signature;

    final authHeader = _buildAuthorizationHeader(parameters);

    if (kDebugMode) debugPrint('🔐 Requesting OAuth token...');

    final response = await http.post(
      Uri.parse('$_baseUrl/oauth/request_token'),
      headers: {
        'Authorization': authHeader,
        'User-Agent': _userAgent,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (kDebugMode)
      debugPrint('🔐 Request token response: ${response.statusCode}');
    if (kDebugMode) debugPrint('🔐 Request token body: ${response.body}');

    if (response.statusCode == 200) {
      final params = Uri.splitQueryString(response.body);
      _requestToken = params['oauth_token'];
      _requestTokenSecret = params['oauth_token_secret'];

      if (_requestToken == null || _requestTokenSecret == null) {
        throw Exception('Ungültige Response: Request Token oder Secret fehlt');
      }

      // Autorisierungs-URL erstellen
      final authUrl =
          'https://www.discogs.com/de/oauth/authorize?oauth_token=$_requestToken';

      if (kDebugMode) debugPrint('🔐 Authorization URL: $authUrl');
      return authUrl;
    } else {
      throw Exception(
          'Request Token Fehler: ${response.statusCode} - ${response.body}');
    }
  }

  // OAuth-signierte Anfrage erstellen
  Map<String, String> createOAuthHeaders(String method, String url,
      {Map<String, String>? additionalParams}) {
    if (_accessToken == null || _accessTokenSecret == null) {
      if (kDebugMode) {
        debugPrint('🔐 ERROR: Access Token fehlt!');
        debugPrint('🔐 Access Token: ${_accessToken != null ? "***SET***" : "NULL"}');
        debugPrint('🔐 Access Secret: ${_accessTokenSecret != null ? "***SET***" : "NULL"}');
      }
      throw Exception(
          'Access Token fehlt. Führen Sie zuerst die OAuth-Authentifizierung durch.');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final nonce = _generateNonce();

    // Parse URL to separate base URL and query parameters
    final uri = Uri.parse(url);
    final baseUrl = uri.replace(query: '').toString().replaceAll('?', '');

    if (kDebugMode) {
      debugPrint('🔐 Creating OAuth headers for: $method $url');
      debugPrint('🔐 Base URL (for signature): $baseUrl');
      debugPrint('🔐 Query Parameters: ${uri.queryParameters}');
      debugPrint('🔐 Consumer Key: ${consumerKey.isNotEmpty ? "***SET***" : "EMPTY"}');
      debugPrint('🔐 Access Token: ${_accessToken!.isNotEmpty ? "***SET***" : "EMPTY"}');
    }

    final parameters = {
      'oauth_consumer_key': consumerKey,
      'oauth_nonce': nonce,
      'oauth_signature_method': 'HMAC-SHA1',
      'oauth_timestamp': timestamp.toString(),
      'oauth_token': _accessToken!,
      'oauth_version': '1.0',
    };

    // Add query parameters from URL to signature (but not to auth header)
    final allParams = Map<String, String>.from(parameters);
    if (uri.queryParameters.isNotEmpty) {
      allParams.addAll(uri.queryParameters);
      if (kDebugMode) debugPrint('🔐 Added ${uri.queryParameters.length} query params to signature');
    }
    if (additionalParams != null) {
      allParams.addAll(additionalParams);
      if (kDebugMode) debugPrint('🔐 Added ${additionalParams.length} additional params to signature');
    }

    final signature = _generateSignature(
      method,
      baseUrl, // Base URL ohne Query-Parameter
      allParams, // Alle Parameter in der Signatur berücksichtigen
      consumerSecret,
      _accessTokenSecret!,
    );
    parameters['oauth_signature'] = signature;

    final authHeader = _buildAuthorizationHeader(parameters);

    if (kDebugMode) {
      debugPrint('🔐 Generated signature successfully');
      debugPrint('🔐 OAuth Authorization header created');
    }

    return {
      'Authorization': authHeader,
      'User-Agent': _userAgent,
    };
  }

  // Access Token aus gespeicherten Werten setzen
  void setAccessToken(String token, String secret) {
    _accessToken = token;
    _accessTokenSecret = secret;
  }

  // Helper: Nonce generieren
  String _generateNonce() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  // Helper: OAuth Signature generieren
  String _generateSignature(String method, String url,
      Map<String, String> params, String consumerSecret, String tokenSecret) {
    // Parameter sortieren und kodieren
    final sortedParams = Map.fromEntries(
        params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));

    final paramString = sortedParams.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    // Signature Base String erstellen
    final signatureBaseString = [
      method.toUpperCase(),
      Uri.encodeComponent(url),
      Uri.encodeComponent(paramString),
    ].join('&');

    // Signing Key erstellen
    final signingKey =
        '${Uri.encodeComponent(consumerSecret)}&${Uri.encodeComponent(tokenSecret)}';

    if (kDebugMode) {
      debugPrint('🔐 Signature Debug:');
      debugPrint('🔐   Method: ${method.toUpperCase()}');
      debugPrint('🔐   URL: $url');
      debugPrint('🔐   Param String: $paramString');
      debugPrint('🔐   Signature Base: $signatureBaseString');
      debugPrint('🔐   Signing Key Length: ${signingKey.length}');
    }

    // HMAC-SHA1 Signature berechnen
    final hmac = Hmac(sha1, utf8.encode(signingKey));
    final digest = hmac.convert(utf8.encode(signatureBaseString));

    final signature = base64.encode(digest.bytes);
    
    if (kDebugMode) {
      debugPrint('🔐   Generated Signature: $signature');
    }

    return signature;
  }

  // Helper: Authorization Header erstellen
  String _buildAuthorizationHeader(Map<String, String> params) {
    // Nur OAuth-Parameter (oauth_*) in den Authorization-Header aufnehmen.
    final oauthParamsEntries =
        params.entries.where((e) => e.key.startsWith('oauth_')).toList();

    final oauthParams = oauthParamsEntries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}="${Uri.encodeComponent(e.value)}"')
        .join(', ');

    return 'OAuth $oauthParams';
  }

  // Getter für aktuelle Tokens
  String? get accessToken => _accessToken;

  String? get accessTokenSecret => _accessTokenSecret;

  // Entferne den kollidierenden Kompatibilitäts-Getter:
  // String? getAccessToken() => _accessToken;

  String? getAccessTokenSecret() => _accessTokenSecret;

  bool get isAuthenticated =>
      _accessToken != null && _accessTokenSecret != null;

  // OAuth 1.0a Schritt 2: Access Token (nach Verifier) abholen und intern setzen
  Future<Map<String, String>> getAccessToken(String verifier) async {
    if (_requestToken == null || _requestTokenSecret == null) {
      throw Exception('Request Token fehlt. Bitte OAuth-Flow neu starten.');
    }

    const method = 'POST';
    final url = '$_baseUrl/oauth/access_token';

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final nonce = _generateNonce();

    final parameters = <String, String>{
      'oauth_consumer_key': consumerKey,
      'oauth_nonce': nonce,
      'oauth_signature_method': 'HMAC-SHA1',
      'oauth_timestamp': timestamp.toString(),
      'oauth_token': _requestToken!,
      'oauth_verifier': verifier,
      'oauth_version': '1.0',
    };

    final signature = _generateSignature(
      method,
      url,
      parameters,
      consumerSecret,
      _requestTokenSecret!,
    );
    parameters['oauth_signature'] = signature;

    final authHeader = _buildAuthorizationHeader(parameters);

    if (kDebugMode) debugPrint('🔐 Requesting access token...');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': authHeader,
        'User-Agent': _userAgent,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (kDebugMode) {
      debugPrint('🔐 Access token response: ${response.statusCode}');
      debugPrint('🔐 Access token body: ${response.body}');
    }

    if (response.statusCode != 200) {
      throw Exception(
          'Access Token Fehler: ${response.statusCode} - ${response.body}');
    }

    final params = Uri.splitQueryString(response.body);
    final accessTok = params['oauth_token'];
    final accessSec = params['oauth_token_secret'];

    if (accessTok == null || accessSec == null) {
      throw Exception('Ungültige Access-Token-Antwort');
    }

    _accessToken = accessTok;
    _accessTokenSecret = accessSec;

    return {
      'oauth_token': accessTok,
      'oauth_token_secret': accessSec,
    };
  }
}
