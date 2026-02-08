import '../constants/api_endpoints.dart';
import '../models/api_response.dart';
import '../models/phone_verification_model.dart';
import 'base_repository.dart';

/// Repository for phone verification operations
class PhoneVerificationRepository extends BaseRepository {
  /// Send OTP to phone number for verification
  Future<ApiResponse<dynamic>> sendPhoneOtp({
    required String phoneNumber,
    required String countryCode,
  }) async {
    return post(
      ApiEndpoints.sendPhoneOtp,
      body: {
        'phone_number': phoneNumber,
        'country_code': countryCode,
      },
    );
  }

  /// Verify phone OTP
  Future<ApiResponse<PhoneVerificationModel>> verifyPhoneOtp({
    required String phoneNumber,
    required String countryCode,
    required String otp,
  }) async {
    return post<PhoneVerificationModel>(
      ApiEndpoints.verifyPhoneOtp,
      body: {
        'phone_number': phoneNumber,
        'country_code': countryCode,
        'otp': otp,
      },
      fromJson: PhoneVerificationModel.fromJson,
    );
  }

  /// Get phone verification status
  Future<ApiResponse<PhoneVerificationModel>> getPhoneVerificationStatus() async {
    return get<PhoneVerificationModel>(
      ApiEndpoints.phoneVerificationStatus,
      fromJson: PhoneVerificationModel.fromJson,
    );
  }

  /// Resend phone OTP
  Future<ApiResponse<dynamic>> resendPhoneOtp({
    required String phoneNumber,
    required String countryCode,
  }) async {
    return post(
      ApiEndpoints.sendPhoneOtp,
      body: {
        'phone_number': phoneNumber,
        'country_code': countryCode,
        'resend': true,
      },
    );
  }
}
