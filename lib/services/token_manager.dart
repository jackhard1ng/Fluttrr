import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized token management - single source of truth for auth tokens
///
/// SECURITY: Tokens are stored using flutter_secure_storage which provides:
/// - iOS: Keychain with kSecAttrAccessibleWhenUnlockedThisDeviceOnly
/// - Android: EncryptedSharedPreferences with AES encryption
///
/// This class provides a unified interface for token storage and retrieval,
/// eliminating the dual storage issue (SharedPreferences vs Hive).
class TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  static TokenManager? _instance;

  // Secure storage for sensitive tokens (encrypted)
  static FlutterSecureStorage? _secureStorage;

  // Regular prefs for non-sensitive data (expiry timestamps)
  static SharedPreferences? _prefs;

  // Cached token for faster access (avoids async calls for every request)
  static String? _cachedToken;

  TokenManager._();

  /// Get secure storage options (platform-specific configuration)
  static AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
        sharedPreferencesName: 'fluttrr_secure_prefs',
        preferencesKeyPrefix: 'fluttrr_',
      );

  static IOSOptions _getIOSOptions() => const IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
        accountName: 'fluttrr_auth',
      );

  /// Initialize the token manager - call this in main.dart before runApp
  static Future<void> init() async {
    _secureStorage = FlutterSecureStorage(
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
    _prefs = await SharedPreferences.getInstance();

    // Load cached token from secure storage
    try {
      _cachedToken = await _secureStorage?.read(key: _tokenKey);
    } catch (e) {
      debugPrint('TokenManager: Error reading token from secure storage: $e');
      _cachedToken = null;
    }
  }

  /// Get the singleton instance
  static TokenManager get instance {
    _instance ??= TokenManager._();
    return _instance!;
  }

  /// Get the current auth token (synchronous - uses cache)
  static String? get token => _cachedToken;

  /// Get the current auth token (async - reads from storage)
  static Future<String?> getToken() async {
    if (_secureStorage == null) await init();
    try {
      _cachedToken = await _secureStorage?.read(key: _tokenKey);
    } catch (e) {
      debugPrint('TokenManager: Error reading token: $e');
      _cachedToken = null;
    }
    return _cachedToken;
  }

  /// Save the auth token (encrypted)
  static Future<void> saveToken(String token) async {
    if (_secureStorage == null) await init();
    try {
      await _secureStorage?.write(key: _tokenKey, value: token);
      _cachedToken = token;
      debugPrint('TokenManager: Token saved securely');
    } catch (e) {
      debugPrint('TokenManager: Error saving token: $e');
      rethrow;
    }
  }

  /// Clear the auth token
  static Future<void> clearToken() async {
    if (_secureStorage == null) await init();
    try {
      await _secureStorage?.delete(key: _tokenKey);
      await _secureStorage?.delete(key: _refreshTokenKey);
      await _prefs?.remove(_tokenExpiryKey);
      _cachedToken = null;
      debugPrint('TokenManager: Token cleared');
    } catch (e) {
      debugPrint('TokenManager: Error clearing token: $e');
    }
  }

  /// Check if user has a valid token
  static bool get hasToken => _cachedToken != null && _cachedToken!.isNotEmpty;

  /// Check if user is authenticated (async version)
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== Refresh Token Support ====================

  /// Get the refresh token (encrypted)
  static Future<String?> getRefreshToken() async {
    if (_secureStorage == null) await init();
    try {
      return await _secureStorage?.read(key: _refreshTokenKey);
    } catch (e) {
      debugPrint('TokenManager: Error reading refresh token: $e');
      return null;
    }
  }

  /// Save the refresh token (encrypted)
  static Future<void> saveRefreshToken(String refreshToken) async {
    if (_secureStorage == null) await init();
    try {
      await _secureStorage?.write(key: _refreshTokenKey, value: refreshToken);
    } catch (e) {
      debugPrint('TokenManager: Error saving refresh token: $e');
    }
  }

  /// Save token expiry time (not encrypted - not sensitive)
  static Future<void> saveTokenExpiry(DateTime expiry) async {
    if (_prefs == null) await init();
    await _prefs?.setInt(_tokenExpiryKey, expiry.millisecondsSinceEpoch);
  }

  /// Check if token is expired
  static Future<bool> isTokenExpired() async {
    if (_prefs == null) await init();
    final expiryMs = _prefs?.getInt(_tokenExpiryKey);
    if (expiryMs == null) return false; // No expiry set, assume valid
    return DateTime.now().millisecondsSinceEpoch > expiryMs;
  }

  /// Save both tokens at once (for login/refresh responses)
  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    DateTime? expiry,
  }) async {
    await saveToken(accessToken);
    if (refreshToken != null) {
      await saveRefreshToken(refreshToken);
    }
    if (expiry != null) {
      await saveTokenExpiry(expiry);
    }
  }

  /// Clear all secure storage (for logout or app reset)
  static Future<void> clearAll() async {
    if (_secureStorage == null) await init();
    try {
      await _secureStorage?.deleteAll();
      await _prefs?.remove(_tokenExpiryKey);
      _cachedToken = null;
      debugPrint('TokenManager: All tokens cleared');
    } catch (e) {
      debugPrint('TokenManager: Error clearing all tokens: $e');
    }
  }
}
