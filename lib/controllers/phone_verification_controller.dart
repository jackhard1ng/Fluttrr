import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/phone_verification_model.dart';
import '../repositories/phone_verification_repository.dart';

/// Controller for phone verification
class PhoneVerificationController extends GetxController {
  final PhoneVerificationRepository _repository = PhoneVerificationRepository();

  // State
  final Rx<PhoneVerificationModel?> verificationStatus = Rx<PhoneVerificationModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSendingOtp = false.obs;
  final RxBool isVerifying = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Form controllers
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final RxString selectedCountryCode = '+1'.obs;

  // OTP cooldown
  final RxInt otpCooldownSeconds = 0.obs;
  final RxBool canResendOtp = true.obs;

  // Country codes
  static const List<Map<String, String>> countryCodes = [
    {'code': '+1', 'country': 'US/CA'},
    {'code': '+44', 'country': 'UK'},
    {'code': '+91', 'country': 'IN'},
    {'code': '+61', 'country': 'AU'},
    {'code': '+49', 'country': 'DE'},
    {'code': '+33', 'country': 'FR'},
    {'code': '+81', 'country': 'JP'},
    {'code': '+86', 'country': 'CN'},
    {'code': '+55', 'country': 'BR'},
    {'code': '+52', 'country': 'MX'},
  ];

  @override
  void onInit() {
    super.onInit();
    loadVerificationStatus();
  }

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  /// Load current verification status
  Future<void> loadVerificationStatus() async {
    isLoading.value = true;
    try {
      final response = await _repository.getPhoneVerificationStatus();
      if (response.success && response.data != null) {
        verificationStatus.value = response.data;
      }
    } catch (e) {
      debugPrint('Error loading verification status: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Send OTP to phone number
  Future<bool> sendOtp() async {
    if (!_validatePhoneNumber()) return false;
    if (!canResendOtp.value) {
      errorMessage.value = 'Please wait before requesting a new code';
      return false;
    }

    isSendingOtp.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await _repository.sendPhoneOtp(
        phoneNumber: phoneController.text.trim(),
        countryCode: selectedCountryCode.value,
      );

      if (response.success) {
        successMessage.value = 'Verification code sent to your phone';
        _startOtpCooldown();
        return true;
      } else {
        errorMessage.value = response.error ?? 'Failed to send verification code';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Failed to send verification code. Please try again.';
      return false;
    } finally {
      isSendingOtp.value = false;
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp() async {
    if (!_validateOtp()) return false;

    isVerifying.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await _repository.verifyPhoneOtp(
        phoneNumber: phoneController.text.trim(),
        countryCode: selectedCountryCode.value,
        otp: otpController.text.trim(),
      );

      if (response.success && response.data != null) {
        verificationStatus.value = response.data;
        successMessage.value = 'Phone number verified successfully!';
        _clearForm();
        return true;
      } else {
        errorMessage.value = response.error ?? 'Invalid verification code';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Verification failed. Please try again.';
      return false;
    } finally {
      isVerifying.value = false;
    }
  }

  /// Resend OTP
  Future<bool> resendOtp() async {
    if (!canResendOtp.value) {
      errorMessage.value = 'Please wait ${otpCooldownSeconds.value} seconds before resending';
      return false;
    }

    return sendOtp();
  }

  /// Start OTP cooldown timer
  void _startOtpCooldown() {
    canResendOtp.value = false;
    otpCooldownSeconds.value = 60;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      otpCooldownSeconds.value--;
      if (otpCooldownSeconds.value <= 0) {
        canResendOtp.value = true;
        return false;
      }
      return true;
    });
  }

  /// Validate phone number
  bool _validatePhoneNumber() {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      errorMessage.value = 'Please enter your phone number';
      return false;
    }
    if (phone.length < 10) {
      errorMessage.value = 'Please enter a valid phone number';
      return false;
    }
    // Remove non-digits for validation
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      errorMessage.value = 'Please enter a valid phone number';
      return false;
    }
    return true;
  }

  /// Validate OTP
  bool _validateOtp() {
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      errorMessage.value = 'Please enter the verification code';
      return false;
    }
    if (otp.length < 4 || otp.length > 8) {
      errorMessage.value = 'Please enter a valid verification code';
      return false;
    }
    return true;
  }

  /// Clear form
  void _clearForm() {
    phoneController.clear();
    otpController.clear();
  }

  /// Set country code
  void setCountryCode(String code) {
    selectedCountryCode.value = code;
  }

  /// Check if phone is verified
  bool get isPhoneVerified => verificationStatus.value?.isVerified ?? false;

  /// Get masked phone number
  String get maskedPhoneNumber => verificationStatus.value?.maskedPhoneNumber ?? '';

  /// Get full phone number (for display)
  String get fullPhoneNumber => verificationStatus.value?.fullPhoneNumber ?? '';
}
