// lib/services/discogs_oauth_service.dart

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:music_up/services/logger_service.dart';

class DiscogsOAuthService {
  // RUNTIME-KONFIGURIERBAR (statt statisch)
  final String consumerKey;
  final String consumerSecret;

  static const String _baseUrl = 'https://api.discogs.com';
  static const String _userAgent =
      'MusicUp/2.1.0 +https://github.com/hiphopconnect/musicup';

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


    final response = await http.post(
      Uri.parse('$_baseUrl/oauth/request_token'),
      headers: {
        'Authorization': authHeader,
        'User-Agent': _userAgent,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );


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

      LoggerService.oauth('Request token obtained');
      return authUrl;
    } else {
      LoggerService.api('oauth/request_token', response.statusCode, response.body);
      throw Exception(
          'Request Token Fehler: ${response.statusCode} - ${response.body}');
    }
  }

  // OAuth-signierte Anfrage erstellen
  Map<String, String> createOAuthHeaders(String method, String url,
      {Map<String, String>? additionalParams}) {
    if (_accessToken == null || _accessTokenSecret == null) {
      LoggerService.error('OAuth Headers', 'Access token missing');
      throw Exception(
          'Access Token fehlt. Führen Sie zuerst die OAuth-Authentifizierung durch.');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final nonce = _generateNonce();

    // Parse URL to separate base URL and query parameters
    final uri = Uri.parse(url);
    final baseUrl = uri.replace(query: '').toString().replaceAll('?', '');


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
    }
    if (additionalParams != null) {
      allParams.addAll(additionalParams);
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


    // HMAC-SHA1 Signature berechnen
    final hmac = Hmac(sha1, utf8.encode(signingKey));
    final digest = hmac.convert(utf8.encode(signatureBaseString));

    final signature = base64.encode(digest.bytes);
    

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


    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': authHeader,
        'User-Agent': _userAgent,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );


    if (response.statusCode != 200) {
      LoggerService.api('oauth/access_token', response.statusCode, response.body);
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

    LoggerService.oauth('Access token obtained');
    return {
      'oauth_token': accessTok,
      'oauth_token_secret': accessSec,
    };
  }
}
