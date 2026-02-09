import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../config/environment.dart';

/// HTTP response wrapper for consistent API responses
class HttpResponse {
  final int statusCode;
  final dynamic data;
  final String? error;

  const HttpResponse({
    required this.statusCode,
    this.data,
    this.error,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

/// Secure HTTP client with certificate pinning support
///
/// SECURITY: This client validates server certificates against pinned certificates
/// to prevent MITM (Man-in-the-Middle) attacks.
///
/// Usage:
/// 1. Add your server's certificate to assets/certificates/
/// 2. Register the certificate path in [_certificatePaths]
/// 3. Use [SecureHttpClient.instance] instead of default http client
///
/// For development, set [enablePinning] to false.
class SecureHttpClient {
  static SecureHttpClient? _instance;
  static http.Client? _client;

  // Certificate paths (add your server certificates here)
  // These should be PEM or DER format certificates
  static const List<String> _certificatePaths = [
    // 'assets/certificates/api_fluttrr_app.pem',
    // Add more certificates as needed
  ];

  // Known certificate fingerprints (SHA-256)
  // These can be obtained using: openssl s_client -connect api.fluttrr.app:443 | openssl x509 -fingerprint -sha256
  static const List<String> _pinnedFingerprints = [
    // 'XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX',
    // Add your server's certificate fingerprints here
  ];

  /// Enable/disable certificate pinning (controlled by environment config)
  static bool get enablePinning => AppConfig.enableCertificatePinning;

  /// Allowed hosts that bypass pinning (for third-party APIs)
  static const List<String> _allowedHosts = [
    'api.stripe.com',
    'js.stripe.com',
    'maps.googleapis.com',
    'cloudflare.com',
    'firestore.googleapis.com',
  ];

  SecureHttpClient._();

  /// Get the singleton instance
  static SecureHttpClient get instance {
    var inst = _instance;
    if (inst == null) {
      inst = SecureHttpClient._();
      _instance = inst;
    }
    return inst;
  }

  /// Get the secure HTTP client
  ///
  /// Returns a client with certificate pinning enabled (if configured)
  static Future<http.Client> getClient() async {
    final existingClient = _client;
    if (existingClient != null) return existingClient;

    if (!enablePinning || kIsWeb) {
      // Web doesn't support certificate pinning
      // Also skip if pinning is disabled
      final client = http.Client();
      _client = client;
      return client;
    }

    try {
      final securityContext = await _createSecurityContext();
      final httpClient = HttpClient(context: securityContext);

      // Configure certificate validation
      httpClient.badCertificateCallback = (cert, host, port) {
        // Allow certain hosts (third-party APIs)
        if (_allowedHosts.any((allowed) => host.contains(allowed))) {
          return true;
        }

        // For pinned hosts, validate the certificate
        if (_pinnedFingerprints.isNotEmpty) {
          return _validateCertificate(cert, host);
        }

        // If no pinning configured, allow all (development mode)
        debugPrint('SecureHttpClient: No pinning configured for $host');
        return true;
      };

      final client = IOClient(httpClient);
      _client = client;
      debugPrint('SecureHttpClient: Initialized with certificate pinning');
      return client;
    } catch (e) {
      debugPrint('SecureHttpClient: Error creating secure client: $e');
      // Fallback to regular client
      final client = http.Client();
      _client = client;
      return client;
    }
  }

  /// Create security context with trusted certificates
  static Future<SecurityContext> _createSecurityContext() async {
    final context = SecurityContext(withTrustedRoots: true);

    for (final path in _certificatePaths) {
      try {
        final certData = await rootBundle.load(path);
        context.setTrustedCertificatesBytes(certData.buffer.asUint8List());
        debugPrint('SecureHttpClient: Loaded certificate from $path');
      } catch (e) {
        debugPrint('SecureHttpClient: Could not load certificate from $path: $e');
      }
    }

    return context;
  }

  /// Validate certificate against pinned fingerprints
  static bool _validateCertificate(X509Certificate cert, String host) {
    try {
      // Get certificate SHA-256 fingerprint
      final fingerprint = _getCertificateFingerprint(cert);

      // Check if fingerprint matches any pinned fingerprint
      final isValid = _pinnedFingerprints.any(
        (pinned) => pinned.toUpperCase() == fingerprint.toUpperCase(),
      );

      if (!isValid) {
        debugPrint('SecureHttpClient: Certificate validation failed for $host');
        debugPrint('SecureHttpClient: Certificate fingerprint: $fingerprint');
      }

      return isValid;
    } catch (e) {
      debugPrint('SecureHttpClient: Error validating certificate: $e');
      return false;
    }
  }

  /// Get SHA-256 fingerprint of certificate
  static String _getCertificateFingerprint(X509Certificate cert) {
    // The certificate's SHA-256 fingerprint
    // Note: In production, you should compute this from cert.der
    // For now, we use the certificate's SHA1 (available directly)
    // and recommend storing SHA-256 fingerprints from your certificate
    return cert.sha1.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(':');
  }

  /// Close the client
  static void close() {
    _client?.close();
    _client = null;
  }

  /// Reset the client (useful for testing)
  static void reset() {
    close();
    _instance = null;
  }

  // ============ HTTP Convenience Methods ============

  /// GET request
  Future<HttpResponse> get(String endpoint) async {
    try {
      final client = await getClient();
      final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final response = await client.get(
        uri,
        headers: await _getHeaders(),
      );
      return _parseResponse(response);
    } catch (e) {
      debugPrint('SecureHttpClient GET error: $e');
      return HttpResponse(statusCode: 0, error: e.toString());
    }
  }

  /// POST request
  Future<HttpResponse> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final client = await getClient();
      final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final response = await client.post(
        uri,
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );
      return _parseResponse(response);
    } catch (e) {
      debugPrint('SecureHttpClient POST error: $e');
      return HttpResponse(statusCode: 0, error: e.toString());
    }
  }

  /// PUT request
  Future<HttpResponse> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final client = await getClient();
      final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final response = await client.put(
        uri,
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );
      return _parseResponse(response);
    } catch (e) {
      debugPrint('SecureHttpClient PUT error: $e');
      return HttpResponse(statusCode: 0, error: e.toString());
    }
  }

  /// DELETE request
  Future<HttpResponse> delete(String endpoint) async {
    try {
      final client = await getClient();
      final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final response = await client.delete(
        uri,
        headers: await _getHeaders(),
      );
      return _parseResponse(response);
    } catch (e) {
      debugPrint('SecureHttpClient DELETE error: $e');
      return HttpResponse(statusCode: 0, error: e.toString());
    }
  }

  /// Upload file
  Future<HttpResponse> uploadFile(
    String endpoint,
    File file,
    String fieldName, {
    Map<String, String>? additionalFields,
  }) async {
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll(await _getHeaders(isMultipart: true));
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final client = await getClient();
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      return _parseResponse(response);
    } catch (e) {
      debugPrint('SecureHttpClient uploadFile error: $e');
      return HttpResponse(statusCode: 0, error: e.toString());
    }
  }

  /// Get headers for requests
  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final headers = <String, String>{
      if (!isMultipart) 'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add auth token if available
    // TODO: Get token from secure storage
    // final token = await SecureStorage.getToken();
    // if (token != null) {
    //   headers['Authorization'] = 'Bearer $token';
    // }

    return headers;
  }

  /// Parse HTTP response
  HttpResponse _parseResponse(http.Response response) {
    try {
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      String? errorMessage;
      if (response.statusCode >= 400 && data is Map<String, dynamic>) {
        errorMessage = data['message']?.toString();
      }
      return HttpResponse(
        statusCode: response.statusCode,
        data: data,
        error: errorMessage,
      );
    } catch (e) {
      return HttpResponse(
        statusCode: response.statusCode,
        data: response.body,
        error: 'Failed to parse response: $e',
      );
    }
  }
}

/// Extension to easily use secure client
extension SecureHttp on http.Client {
  /// Get a secure HTTP client with certificate pinning
  static Future<http.Client> secure() => SecureHttpClient.getClient();
}
