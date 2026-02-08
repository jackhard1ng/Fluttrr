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
        return 'https://staging-api.fluttrr.app';
      case Environment.production:
        return 'https://api.fluttrr.app';
    }
  }

  /// Get the socket URL for the current environment
  static String get socketUrl {
    switch (currentEnvironment) {
      case Environment.development:
        return 'http://localhost:3000';
      case Environment.staging:
        return 'https://staging-api.fluttrr.app';
      case Environment.production:
        return 'https://api.fluttrr.app';
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
        return 15;
    }
  }
}
