import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
import 'base_repository.dart';

/// Authentication repository
class AuthRepository extends BaseRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

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

    // Save token if login successful
    final token = response.data?.token;
    if (response.success && token != null) {
      await saveToken(token);
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

    // Save token if verification successful
    final token = response.data?.token;
    if (response.success && token != null) {
      await saveToken(token);
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
    required String newPassword,
    required String confirmPassword,
  }) async {
    return post(
      ApiEndpoints.resetPassword,
      body: {
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

      // Save token if successful
      final token = response.data?.token;
      if (response.success && token != null) {
        await saveToken(token);
      }

      return response;
    } catch (e) {
      return ApiResponse.failure(error: 'Google Sign-In failed: $e');
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

    // Save token if login successful
    final token = response.data?.token;
    if (response.success && token != null) {
      await saveToken(token);
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

    // Save token if registration successful
    final token = response.data?.token;
    if (response.success && token != null) {
      await saveToken(token);
    }

    return response;
  }
}
