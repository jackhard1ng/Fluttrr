/// Environment configuration for different deployment stages
enum Environment { development, staging, production }

/// Application configuration based on environment
class AppConfig {
  AppConfig._();

  /// Current environment - change this for different builds
  /// In production, this should be set via build configuration
  static const Environment currentEnvironment = Environment.production;

  /// Get the API base URL for the current environment
  static String get baseUrl {
    switch (currentEnvironment) {
      case Environment.development:
        return 'http://localhost:3000';
      case Environment.staging:
        return 'https://staging-api.fluttrr.com';
      case Environment.production:
        return 'https://api.fluttrr.com';
    }
  }

  /// Get the socket URL for the current environment
  static String get socketUrl {
    switch (currentEnvironment) {
      case Environment.development:
        return 'http://localhost:3000';
      case Environment.staging:
        return 'https://staging-api.fluttrr.com';
      case Environment.production:
        return 'https://api.fluttrr.com';
    }
  }

  /// Whether to enable debug logging
  static bool get enableDebugLogging {
    return currentEnvironment != Environment.production;
  }

  /// Whether to show debug UI elements
  static bool get showDebugUI {
    return currentEnvironment == Environment.development;
  }

  /// API request timeout in seconds
  static int get requestTimeout {
    switch (currentEnvironment) {
      case Environment.development:
        return 60;
      case Environment.staging:
        return 30;
      case Environment.production:
        return 30; // Increased from 15 - some operations need more time
    }
  }

  /// Whether to enable certificate pinning
  /// SECURITY: Enable this in production to prevent MITM attacks
  static bool get enableCertificatePinning {
    switch (currentEnvironment) {
      case Environment.development:
        return false; // Disable for local development
      case Environment.staging:
        return true;  // Enable for testing
      case Environment.production:
        return true;  // Always enable in production
    }
  }

  /// Whether to use secure storage for tokens
  static bool get useSecureStorage {
    return true; // Always use secure storage for tokens
  }

  // ==================== Discovery & Search Defaults ====================

  /// Default search radius in miles for finding events and people
  static const double defaultSearchRadius = 25.0;

  /// Default maximum attendees for new events
  static const int defaultMaxAttendees = 20;

  /// Maximum search query length
  static const int maxSearchQueryLength = 100;

  /// Default page size for paginated lists
  static const int defaultPageSize = 20;

  // ==================== Matching & Filtering Defaults ====================

  /// Default minimum age for filtering
  static const int defaultMinAge = 18;

  /// Default maximum age for filtering
  static const int defaultMaxAge = 60;

  /// Default maximum distance in miles for matching
  static const double defaultMaxDistance = 50.0;
}
