import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized token management - single source of truth for auth tokens
///
/// This class provides a unified interface for token storage and retrieval,
/// eliminating the dual storage issue (SharedPreferences vs Hive).
class TokenManager {
  static const String _tokenKey = 'token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  static TokenManager? _instance;
  static SharedPreferences? _prefs;

  // Cached token for faster access (avoids async calls for every request)
  static String? _cachedToken;

  TokenManager._();

  /// Initialize the token manager - call this in main.dart before runApp
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _cachedToken = _prefs?.getString(_tokenKey);
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
    if (_prefs == null) await init();
    _cachedToken = _prefs?.getString(_tokenKey);
    return _cachedToken;
  }

  /// Save the auth token
  static Future<void> saveToken(String token) async {
    if (_prefs == null) await init();
    await _prefs?.setString(_tokenKey, token);
    _cachedToken = token;
    debugPrint('TokenManager: Token saved');
  }

  /// Clear the auth token
  static Future<void> clearToken() async {
    if (_prefs == null) await init();
    await _prefs?.remove(_tokenKey);
    await _prefs?.remove(_refreshTokenKey);
    await _prefs?.remove(_tokenExpiryKey);
    _cachedToken = null;
    debugPrint('TokenManager: Token cleared');
  }

  /// Check if user has a valid token
  static bool get hasToken => _cachedToken != null && _cachedToken!.isNotEmpty;

  /// Check if user is authenticated (async version)
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== Refresh Token Support ====================

  /// Get the refresh token
  static Future<String?> getRefreshToken() async {
    if (_prefs == null) await init();
    return _prefs?.getString(_refreshTokenKey);
  }

  /// Save the refresh token
  static Future<void> saveRefreshToken(String refreshToken) async {
    if (_prefs == null) await init();
    await _prefs?.setString(_refreshTokenKey, refreshToken);
  }

  /// Save token expiry time
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
}
