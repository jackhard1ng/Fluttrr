import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/api_response.dart';
import '../repositories/auth_repository.dart';

/// Authentication controller
class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  // Text controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // Business text controllers
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessPhoneController = TextEditingController();
  final RxString selectedBusinessType = ''.obs;

  // State
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxString errorMessage = ''.obs;

  // Temporary email storage for OTP verification
  String _tempEmail = '';
  String get tempEmail => _tempEmail;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    userNameController.dispose();
    otpController.dispose();
    businessNameController.dispose();
    businessPhoneController.dispose();
    super.onClose();
  }

  /// Clear all fields
  void clearFields() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    userNameController.clear();
    otpController.clear();
    businessNameController.clear();
    businessPhoneController.clear();
    selectedBusinessType.value = '';
    errorMessage.value = '';
  }

  /// Clear business fields only
  void clearBusinessFields() {
    businessNameController.clear();
    businessPhoneController.clear();
    selectedBusinessType.value = '';
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    errorMessage.value = '';
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  /// Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validate confirm password
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validate username
  String? validateUserName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  /// Login with email and password
  Future<bool> login() async {
    errorMessage.value = '';

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      errorMessage.value = 'Please fill in all fields';
      return false;
    }

    isLoading.value = true;

    try {
      final response = await _authRepository.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      isLoading.value = false;

      if (response.success) {
        clearFields();
        return true;
      } else {
        errorMessage.value = response.displayMessage;
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Login failed. Please try again.';
      return false;
    }
  }

  /// Send OTP for registration
  Future<bool> sendOtp() async {
    errorMessage.value = '';

    if (userNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      errorMessage.value = 'Please fill in all fields';
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      errorMessage.value = 'Passwords do not match';
      return false;
    }

    isLoading.value = true;
    _tempEmail = emailController.text.trim();

    try {
      final response = await _authRepository.sendOtp(
        userName: userNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      isLoading.value = false;

      if (response.success) {
        return true;
      } else {
        errorMessage.value = response.displayMessage;
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to send OTP. Please try again.';
      return false;
    }
  }

  /// Verify OTP for registration
  Future<bool> verifyOtp() async {
    errorMessage.value = '';

    if (otpController.text.isEmpty || otpController.text.length < 4) {
      errorMessage.value = 'Please enter a valid OTP';
      return false;
    }

    isLoading.value = true;

    try {
      final response = await _authRepository.verifyOtp(
        email: _tempEmail,
        otp: otpController.text.trim(),
      );

      isLoading.value = false;

      if (response.success) {
        clearFields();
        return true;
      } else {
        errorMessage.value = response.displayMessage;
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'OTP verification failed. Please try again.';
      return false;
    }
  }

  /// Request password reset OTP
  Future<bool> requestPasswordResetOtp() async {
    errorMessage.value = '';

    if (emailController.text.isEmpty) {
      errorMessage.value = 'Please enter your email';
      return false;
    }

    isLoading.value = true;
    _tempEmail = emailController.text.trim();

    try {
      final response = await _authRepository.requestPasswordResetOtp(
        email: emailController.text.trim(),
      );

      isLoading.value = false;

      if (response.success) {
        return true;
      } else {
        errorMessage.value = response.displayMessage;
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to send OTP. Please try again.';
      return false;
    }
  }

  /// Verify password reset OTP
  Future<bool> verifyPasswordResetOtp() async {
    errorMessage.value = '';

    if (otpController.text.isEmpty || otpController.text.length < 4) {
      errorMessage.value = 'Please enter a valid OTP';
      return false;
    }

    isLoading.value = true;

    try {
      final response = await _authRepository.verifyPasswordResetOtp(
        email: _tempEmail,
        otp: otpController.text.trim(),
      );

      isLoading.value = false;

      if (response.success) {
        otpController.clear();
        return true;
      } else {
        errorMessage.value = response.displayMessage;
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'OTP verification failed. Please try again.';
      return false;
    }
  }

  /// Reset password
  Future<bool> resetPassword() async {
    errorMessage.value = '';

    if (passwordController.text.isEmpty) {
      errorMessage.value = 'Please enter a new password';
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      errorMessage.value = 'Passwords do not match';
      return false;
    }

    isLoading.value = true;

    try {
      final response = await _authRepository.resetPassword(
        newPassword: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      isLoading.value = false;

      if (response.success) {
        clearFields();
        return true;
      } else {
        errorMessage.value = response.displayMessage;
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Password reset failed. Please try again.';
      return false;
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    errorMessage.value = '';
    isLoading.value = true;

    try {
      final response = await _authRepository.signInWithGoogle();

      isLoading.value = false;

      if (response.success) {
        return true;
      } else {
        errorMessage.value = response.displayMessage;
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Google Sign-In failed. Please try again.';
      return false;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _authRepository.isLoggedIn();
  }

  /// Logout
  Future<void> logout() async {
    await _authRepository.logout();
    clearFields();
  }

  // ==================== Business Authentication ====================

  /// Validate business name
  String? validateBusinessName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Business name is required';
    }
    if (value.length < 2) {
      return 'Business name must be at least 2 characters';
    }
    return null;
  }

  /// Validate phone number
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Basic phone validation - can be customized
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validate business type selection
  String? validateBusinessType(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a business type';
    }
    return null;
  }

  /// Login as business account
  Future<bool> loginBusiness() async {
    errorMessage.value = '';

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      errorMessage.value = 'Please fill in all fields';
      return false;
    }

    isLoading.value = true;

    try {
      final response = await _authRepository.loginBusiness(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      isLoading.value = false;

      if (response.success) {
        clearFields();
        return true;
      } else {
        errorMessage.value = response.displayMessage;
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Business login failed. Please try again.';
      return false;
    }
  }

  /// Register business account
  Future<bool> registerBusiness() async {
    errorMessage.value = '';

    // Validate all required fields
    if (businessNameController.text.isEmpty ||
        selectedBusinessType.value.isEmpty ||
        emailController.text.isEmpty ||
        businessPhoneController.text.isEmpty ||
        passwordController.text.isEmpty) {
      errorMessage.value = 'Please fill in all fields';
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      errorMessage.value = 'Passwords do not match';
      return false;
    }

    isLoading.value = true;

    try {
      final response = await _authRepository.registerBusiness(
        businessName: businessNameController.text.trim(),
        businessType: selectedBusinessType.value,
        email: emailController.text.trim(),
        phone: businessPhoneController.text.trim(),
        password: passwordController.text,
      );

      isLoading.value = false;

      if (response.success) {
        clearBusinessFields();
        return true;
      } else {
        errorMessage.value = response.displayMessage;
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Business registration failed. Please try again.';
      return false;
    }
  }
}
