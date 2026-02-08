/// Phone verification status
enum PhoneVerificationStatus {
  unverified,
  pending,
  verified,
}

/// Phone verification model
class PhoneVerificationModel {
  final String? phoneNumber;
  final String? countryCode;
  final PhoneVerificationStatus status;
  final DateTime? verifiedAt;
  final DateTime? otpSentAt;
  final int? otpAttempts;

  const PhoneVerificationModel({
    this.phoneNumber,
    this.countryCode,
    this.status = PhoneVerificationStatus.unverified,
    this.verifiedAt,
    this.otpSentAt,
    this.otpAttempts,
  });

  factory PhoneVerificationModel.fromJson(Map<String, dynamic> json) {
    return PhoneVerificationModel(
      phoneNumber: json['phone_number'] as String?,
      countryCode: json['country_code'] as String?,
      status: _parseStatus(json['status']),
      verifiedAt: _parseDateTime(json['verified_at']),
      otpSentAt: _parseDateTime(json['otp_sent_at']),
      otpAttempts: json['otp_attempts'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'country_code': countryCode,
      'status': status.name,
      'verified_at': verifiedAt?.toIso8601String(),
      'otp_sent_at': otpSentAt?.toIso8601String(),
      'otp_attempts': otpAttempts,
    };
  }

  bool get isVerified => status == PhoneVerificationStatus.verified;

  bool get isPending => status == PhoneVerificationStatus.pending;

  String get fullPhoneNumber => '${countryCode ?? ''}${phoneNumber ?? ''}';

  String get maskedPhoneNumber {
    if (phoneNumber == null || phoneNumber!.length < 4) return '****';
    return '****${phoneNumber!.substring(phoneNumber!.length - 4)}';
  }

  PhoneVerificationModel copyWith({
    String? phoneNumber,
    String? countryCode,
    PhoneVerificationStatus? status,
    DateTime? verifiedAt,
    DateTime? otpSentAt,
    int? otpAttempts,
  }) {
    return PhoneVerificationModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      status: status ?? this.status,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      otpSentAt: otpSentAt ?? this.otpSentAt,
      otpAttempts: otpAttempts ?? this.otpAttempts,
    );
  }
}

PhoneVerificationStatus _parseStatus(dynamic value) {
  if (value == null) return PhoneVerificationStatus.unverified;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'verified':
        return PhoneVerificationStatus.verified;
      case 'pending':
        return PhoneVerificationStatus.pending;
      default:
        return PhoneVerificationStatus.unverified;
    }
  }
  return PhoneVerificationStatus.unverified;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
