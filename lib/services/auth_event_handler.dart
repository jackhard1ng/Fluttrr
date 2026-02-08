import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../config/routes.dart';
import '../constants/api_endpoints.dart';
import 'token_manager.dart';
import 'storage_service.dart';

/// Types of authentication events
enum AuthEventType {
  /// Token expired or 401 received
  unauthorized,

  /// User explicitly logged out
  loggedOut,

  /// Session expired
  sessionExpired,

  /// Token refreshed successfully
  tokenRefreshed,
}

/// Authentication event data
class AuthEvent {
  final AuthEventType type;
  final String? message;
  final DateTime timestamp;

  AuthEvent({
    required this.type,
    this.message,
  }) : timestamp = DateTime.now();
}

/// Global handler for authentication events
///
/// This service provides a centralized way to handle auth failures (401),
/// session expiration, and logout across the entire app.
class AuthEventHandler {
  static final AuthEventHandler _instance = AuthEventHandler._internal();
  factory AuthEventHandler() => _instance;
  AuthEventHandler._internal();

  final StreamController<AuthEvent> _eventController =
      StreamController<AuthEvent>.broadcast();

  /// Stream of auth events for listeners
  Stream<AuthEvent> get events => _eventController.stream;

  /// Track if we're already handling a 401 to prevent multiple redirects
  bool _isHandlingUnauthorized = false;

  /// Timestamp of when unauthorized handling started (for timeout detection)
  DateTime? _unauthorizedHandlingStartTime;

  /// Maximum time to wait for unauthorized handling before allowing retry
  static const Duration _maxHandlingDuration = Duration(seconds: 10);

  /// Handle a 401 Unauthorized response
  ///
  /// This is called from BaseRepository when a 401 is received.
  /// First attempts to refresh the token, then logs out if refresh fails.
  Future<void> handleUnauthorized({String? message}) async {
    // Prevent multiple simultaneous handling with timeout fallback
    if (_isHandlingUnauthorized) {
      // Check if previous handling has timed out
      final startTime = _unauthorizedHandlingStartTime;
      if (startTime != null) {
        final elapsed = DateTime.now().difference(startTime);
        if (elapsed < _maxHandlingDuration) {
          debugPrint('AuthEventHandler: Already handling unauthorized, skipping');
          return;
        }
        debugPrint('AuthEventHandler: Previous handling timed out, proceeding');
      }
    }

    _isHandlingUnauthorized = true;
    _unauthorizedHandlingStartTime = DateTime.now();

    try {
      debugPrint('AuthEventHandler: Handling 401 Unauthorized');

      // First, attempt to refresh the token
      final refreshed = await _attemptTokenRefresh();

      if (refreshed) {
        debugPrint('AuthEventHandler: Token refresh successful, resuming session');
        _eventController.add(AuthEvent(
          type: AuthEventType.tokenRefreshed,
          message: 'Session refreshed successfully.',
        ));
        return; // Token refreshed, no need to logout
      }

      debugPrint('AuthEventHandler: Token refresh failed, proceeding with logout');

      // Emit event for any listeners
      _eventController.add(AuthEvent(
        type: AuthEventType.unauthorized,
        message: message ?? 'Your session has expired. Please log in again.',
      ));

      // Clear the token
      await TokenManager.clearToken();

      // Clear user data from storage
      await StorageService.clearUser();

      // Navigate to login screen
      // Use offAllNamed to clear the navigation stack
      if (Get.context != null) {
        Get.offAllNamed(AppRoutes.login);

        // Show a snackbar message with try-catch for context safety (#80)
        try {
          Get.snackbar(
            'Session Expired',
            message ?? 'Please log in again to continue.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        } catch (e) {
          // Context may have become invalid after navigation
          debugPrint('AuthEventHandler: Could not show snackbar: $e');
        }
      }
    } catch (e) {
      debugPrint('AuthEventHandler: Error handling unauthorized: $e');
    } finally {
      // Reset the flag immediately - no race condition with Future.delayed
      _isHandlingUnauthorized = false;
      _unauthorizedHandlingStartTime = null;
    }
  }

  /// Attempt to refresh the access token
  ///
  /// Returns true if refresh was successful, false otherwise.
  Future<bool> _attemptTokenRefresh() async {
    try {
      final refreshToken = await TokenManager.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('AuthEventHandler: No refresh token available');
        return false;
      }

      debugPrint('AuthEventHandler: Attempting token refresh');

      final response = await http.post(
        Uri.parse(ApiEndpoints.refreshToken),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newToken = data['token'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newToken != null) {
          await TokenManager.saveToken(newToken);

          if (newRefreshToken != null) {
            await TokenManager.saveRefreshToken(newRefreshToken);
          }

          debugPrint('AuthEventHandler: Token refresh successful');
          return true;
        }
      }

      debugPrint('AuthEventHandler: Token refresh failed with status ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('AuthEventHandler: Token refresh error: $e');
      return false;
    }
  }

  /// Handle explicit logout
  Future<void> handleLogout() async {
    debugPrint('AuthEventHandler: Handling logout');

    _eventController.add(AuthEvent(
      type: AuthEventType.loggedOut,
      message: 'You have been logged out.',
    ));

    await TokenManager.clearToken();
    await StorageService.clearUser();

    if (Get.context != null) {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  /// Handle session expiration (similar to unauthorized but with different message)
  Future<void> handleSessionExpired() async {
    await handleUnauthorized(
      message: 'Your session has expired. Please log in again.',
    );

    _eventController.add(AuthEvent(
      type: AuthEventType.sessionExpired,
    ));
  }

  /// Check if currently handling an unauthorized event
  bool get isHandlingUnauthorized => _isHandlingUnauthorized;

  /// Dispose the handler
  void dispose() {
    _eventController.close();
  }
}
