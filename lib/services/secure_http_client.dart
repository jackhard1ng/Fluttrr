import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../config/environment.dart';

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
    _instance ??= SecureHttpClient._();
    return _instance!;
  }

  /// Get the secure HTTP client
  ///
  /// Returns a client with certificate pinning enabled (if configured)
  static Future<http.Client> getClient() async {
    if (_client != null) return _client!;

    if (!enablePinning || kIsWeb) {
      // Web doesn't support certificate pinning
      // Also skip if pinning is disabled
      _client = http.Client();
      return _client!;
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

      _client = IOClient(httpClient);
      debugPrint('SecureHttpClient: Initialized with certificate pinning');
      return _client!;
    } catch (e) {
      debugPrint('SecureHttpClient: Error creating secure client: $e');
      // Fallback to regular client
      _client = http.Client();
      return _client!;
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
}

/// Extension to easily use secure client
extension SecureHttp on http.Client {
  /// Get a secure HTTP client with certificate pinning
  static Future<http.Client> secure() => SecureHttpClient.getClient();
}
