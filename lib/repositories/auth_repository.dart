import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
import '../services/auth_event_handler.dart';
import '../services/token_manager.dart';
import 'base_repository.dart';

/// Authentication repository
class AuthRepository extends BaseRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Save both access and refresh tokens from an auth response
  Future<void> _saveAuthTokens(AuthResponse authResponse) async {
    final token = authResponse.token;
    if (token != null) {
      await TokenManager.saveTokens(
        accessToken: token,
        refreshToken: authResponse.refreshToken,
      );
    }
  }

  /// Login with email and password
  Future<ApiResponse<AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    final response = await post<AuthResponse>(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
      fromJson: AuthResponse.fromJson,
      requiresAuth: false,
    );

    // Save tokens if login successful
    if (response.success && response.data != null) {
      await _saveAuthTokens(response.data!);
    }

    return response;
  }

  /// Send OTP for registration
  Future<ApiResponse<dynamic>> sendOtp({
    required String userName,
    required String email,
    required String password,
  }) async {
    return post(
      ApiEndpoints.sendOtp,
      body: {
        'userName': userName,
        'email': email,
        'password': password,
      },
      requiresAuth: false,
    );
  }

  /// Verify OTP for registration
  Future<ApiResponse<AuthResponse>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await post<AuthResponse>(
      ApiEndpoints.verifyOtp,
      body: {'email': email, 'otp': otp},
      fromJson: AuthResponse.fromJson,
      requiresAuth: false,
    );

    // Save tokens if verification successful
    if (response.success && response.data != null) {
      await _saveAuthTokens(response.data!);
    }

    return response;
  }

  /// Request OTP for password reset
  Future<ApiResponse<dynamic>> requestPasswordResetOtp({
    required String email,
  }) async {
    return post(
      ApiEndpoints.requestOtp,
      body: {'email': email},
      requiresAuth: false,
    );
  }

  /// Verify OTP for password reset
  Future<ApiResponse<dynamic>> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    return post(
      ApiEndpoints.verifyResetOtp,
      body: {'email': email, 'otp': otp},
      requiresAuth: false,
    );
  }

  /// Reset password
  Future<ApiResponse<dynamic>> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return post(
      ApiEndpoints.resetPassword,
      body: {
        'email': email,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
      requiresAuth: false,
    );
  }

  /// Change password (when logged in)
  Future<ApiResponse<dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return post(
      ApiEndpoints.changePassword,
      body: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }

  /// Sign in with Google
  Future<ApiResponse<AuthResponse>> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return ApiResponse.failure(error: 'Google Sign-In cancelled');
      }

      // Get authentication details
      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        return ApiResponse.failure(error: 'Failed to get ID token');
      }

      // Send to backend
      final response = await post<AuthResponse>(
        ApiEndpoints.googleLogin,
        body: {'idToken': googleAuth.idToken},
        fromJson: AuthResponse.fromJson,
        requiresAuth: false,
      );

      // Save tokens if successful
      if (response.success && response.data != null) {
        await _saveAuthTokens(response.data!);
      }

      return response;
    } catch (e) {
      final errorStr = e.toString();
      String userMessage;
      if (errorStr.contains('ApiException: 10') || errorStr.contains('DEVELOPER_ERROR')) {
        userMessage = 'Google Sign-In is not configured for this build. '
            'Please check SHA-1 fingerprint in Google Cloud Console.';
        debugPrint('Google Sign-In DEVELOPER_ERROR: SHA-1 fingerprint mismatch. '
            'Run: cd android && ./gradlew signingReport');
      } else if (errorStr.contains('network_error') || errorStr.contains('ApiException: 7')) {
        userMessage = 'Network error during Google Sign-In. Please check your connection.';
      } else if (errorStr.contains('sign_in_canceled') || errorStr.contains('ApiException: 12')) {
        userMessage = 'Google Sign-In was cancelled.';
      } else {
        userMessage = 'Google Sign-In failed. Please try again.';
      }
      debugPrint('Google Sign-In error: $e');
      return ApiResponse.failure(error: userMessage);
    }
  }

  /// Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Error signing out from Google: $e');
    }
  }

  /// Logout - clear all tokens
  Future<void> logout() async {
    await clearToken();
    await signOutGoogle();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== Token Refresh ====================

  /// Attempt to refresh the access token using the refresh token.
  /// Delegates to AuthEventHandler which is the single source of truth.
  Future<bool> refreshAccessToken() async {
    return AuthEventHandler().attemptTokenRefresh();
  }

  /// Static method for use in BaseRepository without creating circular dependency
  static Future<bool> tryRefreshToken() async {
    return AuthEventHandler().attemptTokenRefresh();
  }

  // ==================== Business Authentication ====================

  /// Login as business account
  Future<ApiResponse<AuthResponse>> loginBusiness({
    required String email,
    required String password,
  }) async {
    final response = await post<AuthResponse>(
      ApiEndpoints.businessLogin,
      body: {'email': email, 'password': password},
      fromJson: AuthResponse.fromJson,
      requiresAuth: false,
    );

    // Save tokens if login successful
    if (response.success && response.data != null) {
      await _saveAuthTokens(response.data!);
    }

    return response;
  }

  /// Register business account
  Future<ApiResponse<AuthResponse>> registerBusiness({
    required String businessName,
    required String businessType,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await post<AuthResponse>(
      ApiEndpoints.businessRegister,
      body: {
        'businessName': businessName,
        'businessType': businessType,
        'email': email,
        'phone': phone,
        'password': password,
      },
      fromJson: AuthResponse.fromJson,
      requiresAuth: false,
    );

    // Save tokens if registration successful
    if (response.success && response.data != null) {
      await _saveAuthTokens(response.data!);
    }

    return response;
  }
}
