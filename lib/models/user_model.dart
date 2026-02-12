import 'phone_verification_model.dart';

/// Account types
enum AccountType {
  regular,
  business,
}

/// User profile model
class UserModel {
  final int? userId;
  final String? userName;
  final String? email;
  final String? onlineStatus;
  final Profile? profile;
  final ActivityStats? activities;
  final int? completionPercentage;
  final AccountType accountType;
  final String? businessName;
  final bool isLowProfile;
  final PhoneVerificationModel? phoneVerification;
  final double? averageRating;
  final int? totalRatings;
  final List<int> followedBusinessIds;

  const UserModel({
    this.userId,
    this.userName,
    this.email,
    this.onlineStatus,
    this.profile,
    this.activities,
    this.completionPercentage,
    this.accountType = AccountType.regular,
    this.businessName,
    this.isLowProfile = false,
    this.phoneVerification,
    this.averageRating,
    this.totalRatings,
    this.followedBusinessIds = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as int?,
      userName: json['userName'] as String?,
      email: json['email'] as String?,
      onlineStatus: json['onlineStatus'] as String?,
      profile: json['profile'] != null
          ? Profile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      activities: json['activities'] != null
          ? ActivityStats.fromJson(json['activities'] as Map<String, dynamic>)
          : null,
      completionPercentage: json['completionPercentage'] as int?,
      accountType: json['accountType'] == 'business'
          ? AccountType.business
          : AccountType.regular,
      businessName: json['businessName'] as String?,
      isLowProfile: json['isLowProfile'] as bool? ?? false,
      phoneVerification: json['phoneVerification'] != null
          ? PhoneVerificationModel.fromJson(json['phoneVerification'] as Map<String, dynamic>)
          : null,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      totalRatings: json['totalRatings'] as int?,
      followedBusinessIds: _parseIntList(json['followedBusinessIds']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'email': email,
      'onlineStatus': onlineStatus,
      'profile': profile?.toJson(),
      'activities': activities?.toJson(),
      'completionPercentage': completionPercentage,
      'accountType': accountType == AccountType.business ? 'business' : 'regular',
      'businessName': businessName,
      'isLowProfile': isLowProfile,
      'phoneVerification': phoneVerification?.toJson(),
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'followedBusinessIds': followedBusinessIds,
    };
  }

  UserModel copyWith({
    int? userId,
    String? userName,
    String? email,
    String? onlineStatus,
    Profile? profile,
    ActivityStats? activities,
    int? completionPercentage,
    AccountType? accountType,
    String? businessName,
    bool? isLowProfile,
    PhoneVerificationModel? phoneVerification,
    double? averageRating,
    int? totalRatings,
    List<int>? followedBusinessIds,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      onlineStatus: onlineStatus ?? this.onlineStatus,
      profile: profile ?? this.profile,
      activities: activities ?? this.activities,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      accountType: accountType ?? this.accountType,
      businessName: businessName ?? this.businessName,
      isLowProfile: isLowProfile ?? this.isLowProfile,
      phoneVerification: phoneVerification ?? this.phoneVerification,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      followedBusinessIds: followedBusinessIds ?? this.followedBusinessIds,
    );
  }

  bool get isOnline => onlineStatus?.toLowerCase() == 'online';

  bool get isBusinessAccount => accountType == AccountType.business;

  bool get canCreateEvents => isBusinessAccount;

  String get displayName {
    if (isBusinessAccount && businessName != null && businessName!.isNotEmpty) {
      return businessName!;
    }
    return userName ?? 'User';
  }

  String? get profileImage {
    final images = profile?.images;
    return (images != null && images.isNotEmpty) ? images.first : null;
  }

  bool get isPhoneVerified => phoneVerification?.isVerified ?? false;

  bool isFollowingBusiness(int businessId) => followedBusinessIds.contains(businessId);
}

/// User profile details
class Profile {
  final int? age;
  final String? status;
  final String? gender;
  final String? bio;
  final List<String>? interests;
  final List<String>? images;
  final String? location;
  final List<String>? coverImages;
  final List<String>? languages;
  final double? latitude;
  final double? longitude;

  const Profile({
    this.age,
    this.status,
    this.gender,
    this.bio,
    this.interests,
    this.images,
    this.location,
    this.coverImages,
    this.languages,
    this.latitude,
    this.longitude,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      age: json['age'] as int?,
      status: json['status'] as String?,
      gender: json['gender'] as String?,
      bio: json['bio'] as String?,
      interests: _parseStringList(json['interests']),
      images: _parseStringList(json['images']),
      location: json['location'] as String?,
      coverImages: _parseStringList(json['coverImage']),
      languages: _parseStringList(json['Language']),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'status': status,
      'gender': gender,
      'bio': bio,
      'interests': interests,
      'images': images,
      'location': location,
      'coverImage': coverImages,
      'Language': languages,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  Profile copyWith({
    int? age,
    String? status,
    String? gender,
    String? bio,
    List<String>? interests,
    List<String>? images,
    String? location,
    List<String>? coverImages,
    List<String>? languages,
    double? latitude,
    double? longitude,
  }) {
    return Profile(
      age: age ?? this.age,
      status: status ?? this.status,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      images: images ?? this.images,
      location: location ?? this.location,
      coverImages: coverImages ?? this.coverImages,
      languages: languages ?? this.languages,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

/// User activity statistics
class ActivityStats {
  final int? created;
  final int? joined;

  const ActivityStats({
    this.created,
    this.joined,
  });

  factory ActivityStats.fromJson(Map<String, dynamic> json) {
    return ActivityStats(
      created: json['created'] as int?,
      joined: json['joined'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created': created,
      'joined': joined,
    };
  }

  int get total => (created ?? 0) + (joined ?? 0);
}

/// Helper function to parse string lists from JSON
List<String>? _parseStringList(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    return value.whereType<String>().toList();
  }
  return null;
}

/// Helper function to parse int lists from JSON
List<int> _parseIntList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.whereType<int>().toList();
  }
  return [];
}
